import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/core/values/storage.dart';
import 'package:oms_shared/app/data/models/response/user_profile.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/data/services/storage_service.dart';
import 'package:oms_shared/app/modules/home/controllers/home_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/companies_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/market_index_controller.dart';
import 'package:oms_shared/app/modules/orders/controllers/order_summary_controller.dart';

import '../../../helpers/fake_socket.dart';
import '../../../helpers/fake_storage.dart';
import '../../../helpers/test_env.dart';

class _FakeHomeRepository implements HomeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// HomeController without onInit / onReady (they open every socket and
/// start timers); only its user is needed here.
class _QuietHomeController extends HomeController {
  _QuietHomeController(HomeRepository repo) : super(homeRepository: repo);

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  // ignore: must_call_super
  Future<void> onReady() async {}
}

void main() {
  late List<FakeChannel> sockets;

  setUpAll(() async {
    await initTestStorage();
    initTestAppConfig();
  });

  setUp(() async {
    await clearTestStorage();
    sockets = [];
  });

  tearDown(Get.reset);

  testWidgets('connects with the signed-in user\'s token and investor code', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    await StorageService.save(StorageConstants.token, 'user-token');
    final repo = _FakeHomeRepository();
    Get.put<HomeRepository>(repo);
    Get.put(MarketSocketService());
    Get.put(CompaniesController());
    Get.put(MarketIndexController(repo));
    Get.put(
      WebSocketService(
        connector: (uri) => (sockets..add(FakeChannel(uri))).last,
        onlineChanges: const Stream.empty(),
      ),
    );
    Get.put<HomeController>(
      _QuietHomeController(repo)
        ..userInfo = UserProfile(
          userDetail: UserDetail(investorCode: 'C-100'),
        ),
    );

    Get.put(OrderSummaryController());
    await tester.pump(const Duration(milliseconds: 100));

    final uri = sockets
        .singleWhere((s) => s.uri.path.contains('order_summary'))
        .uri;
    expect(uri.path, endsWith('order_summary/C-100/all/'));
    expect(uri.queryParameters['token'], 'user-token');

    await Get.delete<WebSocketService>(force: true);
    await tester.pump(const Duration(seconds: 2));
  });
}
