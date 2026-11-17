import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:getxify/getxify.dart';

import '../../../core/utils/extensions/app_context.dart';
import '../../../core/values/assets.dart';
import '../controllers/splash_controller.dart';
import '../../../core/utils/helpers/log_helper.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    printLog(controller.hashCode);
    return Scaffold(
      body: SizedBox(
        width: Get.context!.width,
        height: Get.context!.height,
        child: SvgPicture.asset(
          context.isDark
              ? AssetsConstants.splasDarthSvg
              : AssetsConstants.splashSvg,
          width: Get.context!.width,
          height: Get.context!.width,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
