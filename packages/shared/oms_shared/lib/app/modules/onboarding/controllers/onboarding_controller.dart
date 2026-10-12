import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_config.dart';
import '../../../core/values/assets.dart';
import '../../../routes/app_routes.dart';
import 'package:localization/localization.dart';

class OnboardingController extends GetxController {
  var selectedIndex = 0;
  late PageController pageController;
  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: selectedIndex);
  }


  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changeNextPage() {
    if (demoData.length == selectedIndex + 1) {
      Get.offAllNamed(Routes.HOME);
    } else {
      pageController.jumpToPage(selectedIndex + 1);
    }
  }

  List<Map<String, dynamic>> demoData = [
    {
      "illustration": AssetsConstants.onboard_01Png,
      "title": AppTranslations.manageYourStocks.tr,
      "text": AppTranslations.growYourInvestmentsWithHouse.tr.replaceAll(
        'Benemoy',
        AppConfig.house.displayName,
      ),
    },
    {
      "illustration": AssetsConstants.onboard_02Png,
      "title": AppTranslations.getStarted.tr,
      "text": AppTranslations.growYourInvestmentsWithHouse.tr.replaceAll(
        'Benemoy',
        AppConfig.house.displayName,
      ),
    },
  ];
}
