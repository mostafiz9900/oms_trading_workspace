part of '../home_controller.dart';

/// Drawer account actions for custom_drawer: biometrics, token refresh, logout.
mixin AccountMixin on HomeState {
  Future<bool> enableDisableBiometric() async {
    try {
      // Safely check if user has biometric enabled on backend (defaults to false if null)
      bool isBioUser = userInfo.b ?? false;
      printLog('user info b::: $isBioUser');

      // Step 1: Authenticate before allowing them to change the setting
      final authenticated = await bioCon.authenticate();
      printLog('authenticated::::::: $authenticated');
      if (!authenticated) return false;

      // Step 2: Get device ID
      final deviceId = await Helpers.getSecureDeviceId();
      printLog('deviceId::::::: $deviceId');

      if (deviceId == null) {
        Helpers.snackbarForErorr2(
          bodyText: "Device ID not found. Cannot update biometric.",
        );
        return false;
      }

      // Step 3: Call backend to update status & update Local GetX State
      if (isBioUser == true) {
        printLog('Disabling Biometric locally and on backend...');

        // Call backend to disable
        await biometricActive(null, false);

        // Update GetX Controller & Local Storage
        await bioCon.disableBiometric();
      } else {
        printLog('Enabling Biometric locally and on backend...');

        // Call backend to enable
        await biometricActive(deviceId, true);

        // Update GetX Controller & Local Storage
        await bioCon.enableBiometric();
      }

      // Step 4: Handle Logout
      // NOTE: Consider removing this unless your app strictly requires
      // a fresh login immediately after toggling biometrics.
      await logout();

      return true;
    } catch (e) {
      printLog('Error in enableDisableBiometric: $e');
      return false;
    }
  }

  Future<bool?> refreshTokenIfNeeded() async {
    final res = await homeRepository.refreshTokenIfNeeded(
      watchlistTextEditField.text,
    );
    printLog(res?.success);
    printLog(res?.data);
    if (res?.success == true) {
      await StorageService.save(StorageConstants.token, res?.data['access']);
      await StorageService.save(
        StorageConstants.refreshToken,
        res?.data['refresh'],
      );
      return true;
    }
    return null;
  }

  Future<bool> biometricActive(String? bioToken, bool isActive) async {
    if (await NetworkUtil.checkInternetConnection()) {
      isCreateFavCat = true;
      update();
      final res = await homeRepository.biometricActive(bioToken, isActive);
      printLog(
        'res?.success biometricActive: ${res?.success}:  ${res?.errorMessage}',
      );
      if (res?.success == true) {
        isCreateFavCat = false;
        update();
        Get.back();
        return true;
      } else {
        isCreateFavCat = false;
        update();
        return false;
      }
    } else {
      NetworkUtil.networkErrorMessage();
      isCreateFavCat = false;
      update();
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await StorageService.read(
      StorageConstants.refreshToken,
    );
    if (refreshToken == null) {
      _clearLocal();
      return;
    }
    try {
      var response = await homeRepository.logout();
      if (response.success) {
        _clearLocal();
      } else {
        throw Exception('Logout failed');
      }
    } catch (e) {
      printLog('Logout error: $e');
      _clearLocal(); // still logout locally on error
    }
  }

  void _clearLocal() {
    // ১. লোকাল স্টোরেজ ক্লিয়ার করা
    StorageService.remove(StorageConstants.token);
    StorageService.remove(StorageConstants.refreshToken);
    StorageService.remove(StorageConstants.userInfo);
    StorageService.remove(StorageConstants.orderBookId);
    StorageService.remove('${StorageConstants.orderBookId}_cse');

    // ২. অন্যান্য কন্ট্রোলার ডিলিট করা
    Get.delete<TokenController>();

    Helpers.snackBarForSuccess2(bodyText: "Logged out successfully");

    // ৩. পুরো রাউট স্ট্যাক ক্লিয়ার করে লগইন পেজে পাঠানো
    Get.offAllNamed(Routes.LOGIN);

    //  ৪. Permanent HomeController-কে জোরপূর্বক ডিলিট করা
    Get.delete<HomeController>(force: true);
  }

}
