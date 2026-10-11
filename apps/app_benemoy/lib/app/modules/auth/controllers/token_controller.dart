import 'dart:async';

import 'package:trading_core/trading_core.dart';

import '/app/app_pkg.dart';
import '/app/core/utils/helpers/jwt_helper.dart';

import 'package:get/get.dart';

class TokenController extends GetxController {
  static const Duration _refreshBuffer = Duration(minutes: 2);
  Timer? _refreshTimer;
  var remainingSeconds = 0.obs;

  void startTokenCountdown(String token) {
    printLog('startTokenCountdown');
    if (token.isEmpty) return;

    final decodedToken = JwtToken.decode(token);
    if (decodedToken == null) {
      printLog('Invalid token payload');
      _clearSession();
      return;
    }
    final exp = decodedToken['exp'];
    if (exp is! int) {
      printLog('Invalid token expiry');
      _clearSession();
      return;
    }

    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    final now = DateTime.now();
    remainingSeconds.value = expiry.difference(now).inSeconds.clamp(0, 1 << 31);
    printLog('expiry:: $expiry');
    if (!expiry.isAfter(now)) {
      print('Token already expired.');
      _clearSession();
      return;
    }

    final refreshTime = expiry.subtract(_refreshBuffer);
    final durationUntilRefresh = refreshTime.difference(now);
    _refreshTimer?.cancel();
    if (durationUntilRefresh.isNegative) {
      print('Token already expired or near expiry. Refresh now.');
      refreshToken();
      return;
    }

    _refreshTimer = Timer(durationUntilRefresh, () {
      print('Refreshing token before expiry...');
      refreshToken();
    });

    print('Scheduled refresh in: ${durationUntilRefresh.inSeconds} seconds');
  }

  Future<void> refreshToken() async {
    final refreshToken = await StorageService.read(
      StorageConstants.refreshToken,
    );
    final oldAccessToken = await StorageService.read(StorageConstants.token);
    bool isValid = await JWTHelper.isValidToken(oldAccessToken);
    printLog('isValid  ::: $isValid');
    final refreshTokenValue = refreshToken?.toString();
    if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
      _clearSession();
      return;
    }
    try {
      final response = await Get.find<HomeRepository>().refreshTokenIfNeeded(
        refreshTokenValue,
      );
      printLog('response:: ${response?.data}');
      printLog('response success:: ${response?.success}');
      if (response?.success == true && response?.data != null) {
        StorageService.remove(StorageConstants.token);
        StorageService.remove(StorageConstants.refreshToken);
        final newAccessToken = response?.data['access'];
        final newRefreshToken = response?.data['refresh'];
        if (newAccessToken == null || newRefreshToken == null) {
          _clearSession();
          return;
        }
        printLog(newAccessToken);
        printLog(newRefreshToken);
        await StorageService.save(StorageConstants.token, newAccessToken);
        await StorageService.save(
          StorageConstants.refreshToken,
          newRefreshToken,
        );
        var accessToken = await StorageService.read(StorageConstants.token);
        printLog('accessToken :: $accessToken');
        final isExpired = JWTHelper.isTokenExpired(accessToken);
        printLog('isExpired:::::::::::::: $isExpired');
        if (accessToken is String && accessToken.isNotEmpty) {
          startTokenCountdown(accessToken);
        } else {
          _clearSession();
        }
      } else {
        _clearSession();
      }
    } catch (e) {
      print('Refresh token failed: $e');
      _clearSession();
    }
  }

  void _clearSession() {
    _refreshTimer?.cancel();
    StorageService.remove(StorageConstants.token);
    StorageService.remove(StorageConstants.refreshToken);
    StorageService.remove(StorageConstants.userInfo);
    if (Get.isRegistered<TokenController>()) {
      Get.delete<TokenController>();
    }
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
}
