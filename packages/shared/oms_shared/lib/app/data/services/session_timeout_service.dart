import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:getxify/getxify.dart';

import '../../core/utils/helpers/log_helper.dart';
import '../../core/values/session_timeout_config.dart';
import '../../core/values/storage.dart';
import '../repositories/home_repository.dart';
import 'storage_service.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../routes/app_routes.dart';

/// App-wide inactivity logout. It lives beyond individual page routes and
/// persists the background timestamp so it can recover after OS suspension.
class SessionTimeoutService extends GetxService with WidgetsBindingObserver {
  Timer? _timer;
  DateTime? _backgroundedAt;
  bool _logoutStarted = false;

  void resetForNewSession() {
    _logoutStarted = false;
    _timer?.cancel();
    _timer = null;
    _backgroundedAt = null;
    StorageService.remove(SessionTimeoutConfig.backgroundedAtStorageKey);
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    printLog('📱 Session lifecycle state: $state');
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _startCountdown();
        break;
      case AppLifecycleState.resumed:
        _checkOnResume();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _startCountdown() {
    if (_backgroundedAt != null) return;
    final storedTimestamp = StorageService.readSync<dynamic>(
      SessionTimeoutConfig.backgroundedAtStorageKey,
    );
    final storedTime = storedTimestamp is int
        ? DateTime.fromMillisecondsSinceEpoch(storedTimestamp)
        : null;
    _backgroundedAt = storedTime ?? DateTime.now();
    if (storedTime == null) {
      unawaited(
        StorageService.save(
          SessionTimeoutConfig.backgroundedAtStorageKey,
          _backgroundedAt!.millisecondsSinceEpoch,
        ),
      );
    }
    _timer?.cancel();
    final remaining =
        SessionTimeoutConfig.backgroundLogoutTimeout -
        DateTime.now().difference(_backgroundedAt!);
    _timer = Timer(
      remaining.isNegative ? Duration.zero : remaining,
      _logoutAfterTimeout,
    );
    printLog('🔒 Session background timeout started');
  }

  void _checkOnResume() {
    // SplashController owns cold-start recovery and will route once, after it
    // has checked the saved background timestamp.
    if (Get.currentRoute == Routes.SPLASH) return;

    final storedTimestamp = StorageService.readSync<dynamic>(
      SessionTimeoutConfig.backgroundedAtStorageKey,
    );
    final storedTime = storedTimestamp is int
        ? DateTime.fromMillisecondsSinceEpoch(storedTimestamp)
        : null;
    final pausedAt = _backgroundedAt ?? storedTime;

    if (pausedAt != null &&
        DateTime.now().difference(pausedAt) >=
            SessionTimeoutConfig.backgroundLogoutTimeout) {
      _logoutAfterTimeout();
      return;
    }

    _timer?.cancel();
    _timer = null;
    _backgroundedAt = null;
    StorageService.remove(SessionTimeoutConfig.backgroundedAtStorageKey);
    printLog('🔓 Session background timeout cancelled on resume');
  }

  Future<void> _logoutAfterTimeout() async {
    if (_logoutStarted) return;
    _logoutStarted = true;
    _timer?.cancel();
    _timer = null;
    _backgroundedAt = null;
    printLog('🔒 Background timeout reached; ending session');

    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().logout();
      return;
    }

    try {
      if (await StorageService.read(StorageConstants.refreshToken) != null &&
          Get.isRegistered<HomeRepository>()) {
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
    StorageService.remove(SessionTimeoutConfig.backgroundedAtStorageKey);
    FocusManager.instance.primaryFocus?.unfocus();
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.onClose();
  }
}
