import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'package:oms_shared/app/app_pkg.dart';

import 'routing/app_pages.dart';

/// Root widget: GetMaterialApp wired to this app's route table.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeServices themeController = Get.find();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.house.displayName,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: AppBinding(),
      smartManagement: SmartManagement.keepFactory,
      translations: LocalizationService(),
      locale: LocalizationService.parseLocale(AppConfig.house.defaultLocale),
      fallbackLocale: LocalizationService.fallbackLocale,
      theme: AppTheme().lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.getThemeMode(),
      routingCallback: (routing) {
        if (routing?.current == '/onboarding') {
          // Perform any logic before navigating to onboarding page
          // printLog('Navigating to onboarding...');
        }
      },
      onInit: () {},
      builder: (context, child) {
        // <-- Force fixed text scale factor
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(1.0), // <-- fixed text size
          ),
          child: EasyLoading.init()(context, child),
        );
      },
    );
  }
}
