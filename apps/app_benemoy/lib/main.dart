import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/data/services/notification_service.dart';
import 'firebase_options.dart';
import 'app/app_pkg.dart';

final providerContainer = ProviderContainer();
bool isDarkMode = Get.isDarkMode;
int initScreen = 0;
const _omsEnvironment = String.fromEnvironment('OMS_ENV', defaultValue: 'prod');
void main() => runMain();

Future<void> runMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  // _initFirebaseConfig();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.initialize();
  if (_omsEnvironment != 'uat' && _omsEnvironment != 'prod') {
    throw StateError('OMS_ENV must be either "uat" or "prod".');
  }
  await dotenv.load(
    fileName: _omsEnvironment == 'uat' ? 'env/.env.dev' : 'env/.env.prod',
  );
  AppConfig.initialize(environment: _omsEnvironment);
  initScreen = await StorageService.read("initScreen") ?? 0;
  StorageService.save("initScreen", 1);
  outCreateErrorWidget();

  await DependencyInjection.init();
  isDarkMode = await StorageService.read(StorageConstants.isDarkMode) ?? Get.isDarkMode;
  printLog(isDarkMode);
  printLog('isDarkMode');
  printLog(Get.isDarkMode);

  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,
  //
  //   statusBarIconBrightness: Brightness.dark, // For Android: Dark icons
  //   statusBarBrightness: Brightness.dark, // For iOS: Light icons
  // ));
  // change the status bar color to material color [green-400]
  // await FlutterStatusbarcolor.setStatusBarColor(ColorConstants.primaryColor);
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  // if (useWhiteForeground(ColorConstants.primaryColor)) {
  //   FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
  // } else {
  //   FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  // }
  //
  // // change the navigation bar color to material color [orange-200]
  // await FlutterStatusbarcolor.setNavigationBarColor(
  //     ColorConstants.primaryColor);
  // if (useWhiteForeground(ColorConstants.primaryColor)) {
  //   FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
  // } else {
  //   FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
  // }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   statusBarColor: Colors.blue, // Set your desired color
  //   statusBarIconBrightness: Brightness.light, // For white icons
  // ));
  runApp(UncontrolledProviderScope(container: providerContainer, child: const MyApp()));
  configLoading();
}

Future<void> _initFirebaseConfig() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    debugPrint("✅ Firebase successfully initialized.");
  } catch (e, stackTrace) {
    debugPrint("❌ Firebase initialization failed: $e");
    debugPrint("StackTrace: $stackTrace");

    // Add fallback logic here if your app relies heavily on Firebase
    // e.g., enabling an explicit offline-first mode for Riverpod state
  }
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.threeBounce
    ..loadingStyle = EasyLoadingStyle.custom
    //..indicatorSize = 45.0
    ..radius = 10.0
    //..progressColor = Colors.yellow
    ..backgroundColor = ColorConstants.lightGray
    ..indicatorColor = hexToColor('#64DEE0')
    ..textColor = hexToColor('#64DEE0')
    //..maskColor = Colors.red
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
