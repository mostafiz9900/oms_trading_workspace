import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/core/values/storage.dart';
import 'package:oms_shared/app/data/api/api_response.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/services/storage_service.dart';
import 'package:oms_shared/app/modules/auth/controllers/token_controller.dart';
import 'package:oms_shared/app/routes/app_routes.dart';

import '../../helpers/fake_storage.dart';

String jwt(Map<String, dynamic> payload) {
  String part(Object o) => base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.${part(payload)}.sig';
}

String tokenExpiringIn(Duration d) =>
    jwt({'exp': DateTime.now().add(d).millisecondsSinceEpoch ~/ 1000});

/// Records refresh calls and answers with a scripted response.
class FakeHomeRepository implements HomeRepository {
  ApiResponse<dynamic>? Function(String refreshToken) answer = (_) => null;
  final List<String> refreshCalls = [];

  @override
  Future<ApiResponse<dynamic>?> refreshTokenIfNeeded(String accessToken) async {
    refreshCalls.add(accessToken);
    return answer(accessToken);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeHomeRepository repo;
  late TokenController controller;

  setUpAll(initTestStorage);

  setUp(() async {
    await clearTestStorage();
    repo = Get.put<HomeRepository>(FakeHomeRepository()) as FakeHomeRepository;
    controller = Get.put(TokenController());
  });

  tearDown(Get.reset);

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/home',
        getPages: [
          GetPage(name: '/home', page: () => const Text('home')),
          GetPage(name: Routes.LOGIN, page: () => const Text('login')),
        ],
      ),
    );
  }

  Future<void> storeSession({required String access, String? refresh}) async {
    await StorageService.save(StorageConstants.token, access);
    if (refresh != null) await StorageService.save(StorageConstants.refreshToken, refresh);
    await StorageService.save(StorageConstants.userInfo, {'id': 1});
  }

  Future<void> expectLoggedOut(WidgetTester tester) async {
    await tester.pumpAndSettle();
    expect(Get.currentRoute, Routes.LOGIN);
    expect(await StorageService.read(StorageConstants.token), isNull);
    expect(await StorageService.read(StorageConstants.refreshToken), isNull);
    expect(await StorageService.read(StorageConstants.userInfo), isNull);
    expect(Get.isRegistered<TokenController>(), isFalse);
  }

  group('a valid session', () {
    testWidgets('stays signed in and schedules a refresh 2 min before expiry', (tester) async {
      await pumpApp(tester);
      final access = tokenExpiringIn(const Duration(hours: 1));
      await storeSession(access: access, refresh: 'refresh-1');
      repo.answer = (_) => ApiResponse.success({
        'access': tokenExpiringIn(const Duration(hours: 1)),
        'refresh': 'refresh-2',
      });

      controller.startTokenCountdown(access);
      expect(controller.remainingSeconds.value, closeTo(3600, 5));

      await tester.pump(const Duration(minutes: 57));
      expect(repo.refreshCalls, isEmpty, reason: 'too early to refresh');

      await tester.pump(const Duration(minutes: 1, seconds: 5));
      await tester.pump();
      expect(repo.refreshCalls, ['refresh-1']);
      expect(await StorageService.read(StorageConstants.refreshToken), 'refresh-2');
      expect(Get.currentRoute, '/home');

      Get.delete<TokenController>(); // cancels the next scheduled refresh
    });

    testWidgets('a token close to expiry is refreshed at once', (tester) async {
      await pumpApp(tester);
      final access = tokenExpiringIn(const Duration(seconds: 60));
      final newAccess = tokenExpiringIn(const Duration(hours: 1));
      await storeSession(access: access, refresh: 'refresh-1');
      repo.answer = (_) => ApiResponse.success({'access': newAccess, 'refresh': 'refresh-2'});

      controller.startTokenCountdown(access);
      await tester.pump();

      expect(repo.refreshCalls, ['refresh-1']);
      expect(await StorageService.read(StorageConstants.token), newAccess);
      expect(Get.currentRoute, '/home');

      Get.delete<TokenController>();
    });
  });

  group('the user is sent to login and the session is cleared when', () {
    testWidgets('the token has already expired', (tester) async {
      await pumpApp(tester);
      final access = tokenExpiringIn(const Duration(minutes: -1));
      await storeSession(access: access, refresh: 'refresh-1');

      controller.startTokenCountdown(access);

      await expectLoggedOut(tester);
      expect(repo.refreshCalls, isEmpty);
    });

    testWidgets('the token cannot be decoded', (tester) async {
      await pumpApp(tester);
      await storeSession(access: 'garbage', refresh: 'refresh-1');

      controller.startTokenCountdown('garbage');

      await expectLoggedOut(tester);
    });

    testWidgets('the token has no numeric exp claim', (tester) async {
      await pumpApp(tester);
      final access = jwt({'exp': 'tomorrow'});
      await storeSession(access: access, refresh: 'refresh-1');

      controller.startTokenCountdown(access);

      await expectLoggedOut(tester);
    });

    testWidgets('there is no refresh token', (tester) async {
      await pumpApp(tester);
      final access = tokenExpiringIn(const Duration(seconds: 30));
      await storeSession(access: access);

      controller.startTokenCountdown(access);

      await expectLoggedOut(tester);
      expect(repo.refreshCalls, isEmpty);
    });

    testWidgets('the server rejects the refresh', (tester) async {
      await pumpApp(tester);
      final access = tokenExpiringIn(const Duration(seconds: 30));
      await storeSession(access: access, refresh: 'refresh-1');
      repo.answer = (_) => ApiResponse.error('expired');

      controller.startTokenCountdown(access);

      await expectLoggedOut(tester);
      expect(repo.refreshCalls, ['refresh-1']);
    });

    testWidgets('the refresh answer has no new refresh token', (tester) async {
      await pumpApp(tester);
      final access = tokenExpiringIn(const Duration(seconds: 30));
      await storeSession(access: access, refresh: 'refresh-1');
      repo.answer = (_) => ApiResponse.success({'access': tokenExpiringIn(const Duration(hours: 1))});

      controller.startTokenCountdown(access);

      await expectLoggedOut(tester);
    });

    testWidgets('the refresh call throws', (tester) async {
      await pumpApp(tester);
      final access = tokenExpiringIn(const Duration(seconds: 30));
      await storeSession(access: access, refresh: 'refresh-1');
      repo.answer = (_) => throw Exception('network down');

      controller.startTokenCountdown(access);

      await expectLoggedOut(tester);
    });
  });

  testWidgets('an empty token is ignored', (tester) async {
    await pumpApp(tester);
    controller.startTokenCountdown('');
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/home');
    expect(repo.refreshCalls, isEmpty);
  });
}
