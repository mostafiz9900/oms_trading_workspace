import 'dart:ui' show PlatformDispatcher;

import 'package:broker_config/broker_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app/app_pkg.dart';
import 'app/data/services/notification_service.dart';

final providerContainer = ProviderContainer();
bool isDarkMode = Get.isDarkMode;
int initScreen = 0;
const _definedEnvironment = String.fromEnvironment('OMS_ENV');

/// Receives every uncaught error (framework and async). Plug crash reporting
/// in here, e.g. `FirebaseCrashlytics.instance.recordError`.
typedef OmsErrorReporter = void Function(Object error, StackTrace? stack, {required bool fatal});

/// Starts the shared OMS trading app for one broker house.
///
/// [environment] comes from the app's flavor entry point; endpoints and
/// branding from `--dart-define-from-file`. [profile], [firebaseOptions],
/// [firebaseBackgroundHandler] and the root widget [app] are owned by the app.
Future<void> runOmsApp({
  required OmsEnvironment environment,
  required HouseProfile profile,
  required FirebaseOptions firebaseOptions,
  required BackgroundMessageHandler firebaseBackgroundHandler,
  required Widget Function() app,
  OmsErrorReporter? reportError,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorHandlers(reportError);
  if (_definedEnvironment != environment.name) {
    throw StateError(
      'Entry point is "${environment.name}" but the --dart-define-from-file '
      'profile has OMS_ENV="$_definedEnvironment". Use the matching profile.',
    );
  }
  AppConfig.initialize(environment: environment.name, profile: profile);
  // Independent of each other, so they start together.
  await Future.wait([
    GetStorage.init(),
    Firebase.initializeApp(options: firebaseOptions),
  ]);

  await NotificationService.initialize(backgroundHandler: firebaseBackgroundHandler);
  initScreen = await StorageService.read("initScreen") ?? 0;
  StorageService.save("initScreen", 1);
  outCreateErrorWidget();

  await DependencyInjection.init();
  isDarkMode = await StorageService.read(StorageConstants.isDarkMode) ?? Get.isDarkMode;
  printLog(isDarkMode);
  printLog('isDarkMode');
  printLog(Get.isDarkMode);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(UncontrolledProviderScope(container: providerContainer, child: app()));
  configLoading();
}

/// Errors never stop the app (Flutter keeps running either way); this makes
/// sure each one is logged and handed to [reportError].
void _installErrorHandlers(OmsErrorReporter? reportError) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details); // default behaviour: log it
    reportError?.call(details.exception, details.stack, fatal: false);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught async error: $error');
    reportError?.call(error, stack, fatal: true);
    return true; // handled: logged and reported
  };
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.threeBounce
    ..loadingStyle = EasyLoadingStyle.custom
    ..radius = 10.0
    ..backgroundColor = ColorConstants.lightGray
    ..indicatorColor = hexToColor('#64DEE0')
    ..textColor = hexToColor('#64DEE0')
    ..userInteractions = false
    ..dismissOnTap = false
    ..animationStyle = EasyLoadingAnimationStyle.scale;
}

void outCreateErrorWidget() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong.',
              style: TextStyle(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              details.exceptionAsString(),
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  };
}
