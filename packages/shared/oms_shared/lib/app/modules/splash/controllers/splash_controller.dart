import 'package:oms_shared/app/modules/auth/controllers/token_controller.dart';
import 'package:getxify/getxify.dart';
import 'package:trading_core/trading_core.dart';

import '../../../core/utils/helpers/log_helper.dart';
import '../../../core/values/session_timeout_config.dart';
import '../../../core/values/storage.dart';
import '../../../data/repositories/home_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    final backgroundTimestamp = StorageService.readSync<dynamic>(
      SessionTimeoutConfig.backgroundedAtStorageKey,
    );
    final backgroundedAt = backgroundTimestamp is int
        ? DateTime.fromMillisecondsSinceEpoch(backgroundTimestamp)
        : null;
    final backgroundTimeoutExpired =
        backgroundedAt != null &&
        DateTime.now().difference(backgroundedAt) >=
            SessionTimeoutConfig.backgroundLogoutTimeout;

    final isToken = await StorageService.read(StorageConstants.token);
    printLog(isToken);
    printLog('token::: isValidToken : $isToken');
    final hasValidToken =
        isToken is String && isToken.isNotEmpty && !JwtToken.isExpired(isToken);
    printLog('hasValidToken :: $hasValidToken');
    if (backgroundTimeoutExpired) {
      // A suspended or killed process cannot run its Dart timer. Complete the
      // same logout on the next cold start, then clear the local session even
      // if the logout endpoint is unavailable.
      try {
        if (await StorageService.read(StorageConstants.refreshToken) != null) {
          await Get.find<HomeRepository>().logout();
        }
      } catch (error) {
        printLog('Background timeout logout request failed: $error');
      }
      StorageService.remove(StorageConstants.token);
      StorageService.remove(StorageConstants.refreshToken);
      StorageService.remove(StorageConstants.userInfo);
      StorageService.remove(StorageConstants.orderBookId);
      StorageService.remove('${StorageConstants.orderBookId}_cse');
      StorageService.remove(StorageConstants.selectedQuoteOrderBookDse);
      StorageService.remove(StorageConstants.selectedQuoteOrderBookCse);
    }
    StorageService.remove(SessionTimeoutConfig.backgroundedAtStorageKey);

    Future.delayed(const Duration(seconds: 2), () {
      if (backgroundTimeoutExpired) {
        Get.offAllNamed(Routes.LOGIN);
      } else if (!hasValidToken) {
        StorageService.remove(StorageConstants.token);
        StorageService.remove(StorageConstants.refreshToken);
        StorageService.remove(StorageConstants.userInfo);
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.HOME);
        Get.find<TokenController>().startTokenCountdown(isToken);
      }
    });
  }
}
