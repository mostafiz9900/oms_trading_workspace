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
        // Get.offAllNamed(Routes.LOGIN);
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.HOME);
        Get.find<TokenController>().startTokenCountdown(isToken);
      }
    });
  }
}

// class SplashController extends GetxController {
//   @override
//   void onInit() async {
//     super.onInit();
//     var isToken = await StorageService.read(StorageConstants.token);
//     printLog(isToken);
//     printLog('token::: isValidToken : $isToken');
//     var isValidToken = await JWTHelper.isValidToken(isToken);
//     var isValidTokenCustom = isToken == null ? false : isTokenExpired(isToken);
//     printLog('$isValidToken ::token:::[ $isValidTokenCustom ]]] isValidToken : $isToken');
//     Future.delayed(const Duration(seconds: 2), () {
//       if (isToken == null || JwtDecoder.isExpired(isToken)) {
//         StorageService.remove(StorageConstants.token);
//         StorageService.remove(StorageConstants.refreshToken);
//         StorageService.remove(StorageConstants.userInfo);
//         // Get.find<TokenController>().startTokenCountdown('$isToken');
//         Get.offAllNamed(Routes.HOME);
//       } else {
//         // Get.offAllNamed(Routes.LOGIN);
//         Get.offAllNamed(Routes.HOME);
//         Get.put(TokenController()).startTokenCountdown(isToken);
//       }
//     });
//   }

//   bool isTokenExpired(String token) {
//     try {
//       final parts = token.split('.');
//       if (parts.length != 3) return true;

//       final payload = parts[1];
//       final normalized = base64.normalize(payload);
//       final decoded = utf8.decode(base64Url.decode(normalized));
//       final payloadMap = json.decode(decoded);

//       if (payloadMap is! Map<String, dynamic>) return true;
//       final exp = payloadMap['exp'];
//       if (exp == null) return true;
//       final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
//       return DateTime.now().isAfter(expiryDate);
//     } catch (e) {
//       return true;
//     }
//   }
// }
