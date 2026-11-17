// ignore_for_file: deprecated_member_use

import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart' as legacy show Material, MaterialType;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:getxify/getxify.dart';

import 'package:oms_shared/app/core/theme/app_theme.dart';
import 'package:oms_shared/app/core/theme/theme_service.dart';
import 'package:oms_shared/app/core/values/app_config.dart';
import 'package:localization/localization.dart';

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
          child: MaterialUiCompatibilityBridge(
            child: legacy.Material(
              type: legacy.MaterialType.transparency,
              child: EasyLoading.init()(context, child),
            ),
          ),
        );
      },
    );
  }
}
