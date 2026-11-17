import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';
import 'package:oms_shared/app/core/values/session_timeout_config.dart';
import 'package:oms_shared/app/core/values/storage.dart';
import 'package:oms_shared/app/data/services/session_timeout_service.dart';
import 'package:oms_shared/app/data/services/storage_service.dart';
import 'package:oms_shared/app/routes/app_routes.dart';

import '../../helpers/fake_storage.dart';

void main() {
  setUpAll(initTestStorage);

  setUp(() async {
    await clearTestStorage();
    await StorageService.save(StorageConstants.token, 'active-token');
    await StorageService.save(StorageConstants.refreshToken, 'refresh-token');
  });

  tearDown(Get.reset);

  testWidgets('keeps the session for 4:59 and logs out at 5:00', (
    tester,
  ) async {
    Get.put<SessionTimeoutService>(SessionTimeoutService(), permanent: true);

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: Routes.HOME,
        getPages: [
          GetPage(name: Routes.HOME, page: () => const Scaffold()),
          GetPage(name: Routes.LOGIN, page: () => const Scaffold()),
        ],
      ),
    );
    await tester.pump();

    Get.find<SessionTimeoutService>().didChangeAppLifecycleState(
      AppLifecycleState.hidden,
    );
    await tester.pump(const Duration(minutes: 4, seconds: 59));
    expect(Get.currentRoute, Routes.HOME);
    expect(StorageService.readSync<String>(StorageConstants.token), isNotNull);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, Routes.LOGIN);
    expect(StorageService.readSync<String>(StorageConstants.token), isNull);
    expect(
      StorageService.readSync<String>(StorageConstants.refreshToken),
      isNull,
    );
    expect(
      StorageService.readSync<int>(
        SessionTimeoutConfig.backgroundedAtStorageKey,
      ),
      isNull,
    );
  });
}
