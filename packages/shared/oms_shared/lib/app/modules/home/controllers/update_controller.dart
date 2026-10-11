import 'package:flutter/cupertino.dart';
import 'package:flutter_in_store_app_version_checker/flutter_in_store_app_version_checker.dart';
import 'package:new_version_plus/new_version_plus.dart';

import '/app/app_pkg.dart';
import 'package:get/get.dart';

class UpdateController extends GetxController {
  bool forceUpdate = false;
  String updateUrl = "";

  // Latest versions
  String androidLatestVersion = "1.0.8";
  String iosLatestVersion = "1.0.3";

  // Store URLs
  String get androidUrl => AppConfig.profile.store.playStoreUrl;
  String get iosUrl => AppConfig.profile.store.appStoreUrl;
  @override
  void onInit() {
    super.onInit();
    checkVersion();
    checkVersion2();
  }

  final _checker = InStoreAppVersionChecker.instance;
  final newVersion = NewVersionPlus(
    iOSId: AppConfig.profile.store.iosBundleId,
    androidId: AppConfig.profile.store.androidPackageId,
    androidPlayStoreCountry: "es_ES",
    androidHtmlReleaseNotes: true, //support country code
  );

  Future<void> checkVersion() async {
    try {
      final result = await _checker.checkUpdate(
        InStoreAppVersionCheckerParams(
          packageName: GetPlatform.isIOS
              ? AppConfig.profile.store.iosBundleId
              : AppConfig.profile.store.androidPackageId,
          locale: 'en',
        ),
      );
      var status = await newVersion.getVersionStatus();
      if (status != null) {
        debugPrint(status.releaseNotes);
        debugPrint(status.appStoreLink);
        debugPrint(status.localVersion);
        debugPrint(status.storeVersion);
        debugPrint(status.canUpdate.toString());
      }
      printLog('App url         : ${result.appURL}');
      printLog('Can update      : ${result.canUpdate}');
      printLog('Current version : ${result.currentVersion}');
      printLog('New version     : ${result.newVersion}');
      printLog('Error           : ${result.errorMessage}');

      // final current = result.currentVersion ?? "0.0.0";
      // final latest = result.newVersion ?? "0.0.0";

      // if (_isLower(current, latest)) {
      //   forceUpdate = true;
      //   updateUrl = result.appURL ?? (GetPlatform.isIOS ? iosUrl : androidUrl);
      //   update();
      // }
    } catch (e) {
      forceUpdate = false;
      update();
      printLog("Version check failed: $e");
    }
  }

  Future<void> checkVersion2() async {
    try {
      final status = await newVersion.getVersionStatus();

      if (status == null) {
        debugPrint("Version status is null");
        return;
      }

      debugPrint("Local Version: ${status.localVersion}");
      debugPrint("Store Version: ${status.storeVersion}");
      debugPrint("Can Update   : ${status.canUpdate}");
      debugPrint("App Store URL: ${status.appStoreLink}");
      final current = status.localVersion;
      final latest = status.storeVersion;
      if (status.canUpdate) {
        printLog('state can update');

        if (_isLower(current, latest)) {
          forceUpdate = true;
          updateUrl = status.appStoreLink;
          androidLatestVersion = latest;
          iosLatestVersion = latest;
          update();
        }
        // show built-in dialog
        // newVersion.showUpdateDialog(
        //   context: ,
        //   versionStatus: status,
        //   dialogTitle: "Update Available",
        //   dialogText:
        //   "A new version (${status.storeVersion}) is available. Please update.",
        //   updateButtonText: "Update Now",
        //   dismissButtonText: "Later",
        //   allowDismissal: true,
        // );
      }
    } catch (e) {
      debugPrint("Version check failed: $e");
    }
  }

  bool _isLower(String? current, String? latest) {
    if (current == null || latest == null) return false;

    final c = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final l = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // normalize length
    while (c.length < l.length) c.add(0);
    while (l.length < c.length) l.add(0);

    for (int i = 0; i < l.length; i++) {
      if (c[i] < l[i]) return true;
      if (c[i] > l[i]) return false;
    }
    return false;
  }
}
