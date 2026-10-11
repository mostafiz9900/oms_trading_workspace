import 'package:oms_shared/app/modules/auth/controllers/token_controller.dart';
import 'package:get/get.dart';
import 'package:trading_core/trading_core.dart';

import '../../../app_pkg.dart';

class SplashController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    final isToken = await StorageService.read(StorageConstants.token);
    printLog(isToken);
    printLog('token::: isValidToken : $isToken');
    final hasValidToken =
        isToken is String && isToken.isNotEmpty && !JwtToken.isExpired(isToken);
    printLog('hasValidToken :: $hasValidToken');
    Future.delayed(const Duration(seconds: 2), () {
      if (!hasValidToken) {
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

