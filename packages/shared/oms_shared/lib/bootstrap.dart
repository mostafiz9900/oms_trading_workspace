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
const _omsEnvironment = String.fromEnvironment('OMS_ENV', defaultValue: 'prod');

/// Starts the shared OMS trading app for one broker house.
///
/// Endpoints and branding come from `--dart-define-from-file`; [profile],
/// [firebaseOptions] and [firebaseBackgroundHandler] are owned by the app.
Future<void> runOmsApp({
  required HouseProfile profile,
  required FirebaseOptions firebaseOptions,
  required BackgroundMessageHandler firebaseBackgroundHandler,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_omsEnvironment != 'uat' && _omsEnvironment != 'prod') {
    throw StateError('OMS_ENV must be either "uat" or "prod".');
  }
  AppConfig.initialize(environment: _omsEnvironment, profile: profile);
  await GetStorage.init();
  await Firebase.initializeApp(options: firebaseOptions);

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
  runApp(UncontrolledProviderScope(container: providerContainer, child: const MyApp()));
  configLoading();
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
