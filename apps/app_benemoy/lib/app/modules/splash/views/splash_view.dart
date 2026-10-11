import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';

import '../../../app_pkg.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    print(controller.hashCode);
    return Scaffold(
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: SvgPicture.asset(
          context.isDark ? AssetsConstants.splasDarthSvg : AssetsConstants.splashSvg,
          width: Get.width,
          height: Get.width,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
