import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/values/assets.dart';
import '../../controllers/global_search_controller.dart';
import '../../controllers/home_controller.dart';

class AppbarRightSearchTapWidgetOld extends StatelessWidget {
  const AppbarRightSearchTapWidgetOld({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // onPressed: () {
      //   // Get.toNamed(Routes.SEARCH_WATCH_LIST);
      //   Get.find<HomeController>().changeCurrentIndex(2);
      // },
      onPressed: () async {
        final result = await SearchHelper.open();
        if (result != null) {
          print("Selected Market: ${result.shortName}");
          print("Selected Market to map: ${result.toJson()}");
          if (result.orderBook != null && result.shortName != null) {
            Get.find<HomeController>().goBottomNabBarPage(1, result.orderBook!);
            Get.find<HomeController>().tradingChart();
          }
        }
      },
      icon: SvgPicture.asset(AssetsConstants.searchIconSvg, width: 20, height: 20),
    );
  }
}

class AppbarRightSearchTapWidget extends StatelessWidget {
  final bool shouldPop; // 🚀 নতুন প্যারামিটার যুক্ত করা হলো

  const AppbarRightSearchTapWidget({
    super.key,
    this.shouldPop = false, // ডিফল্ট false থাকবে
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        // 🚀 যদি ইনার পেজ হয়, তবে আগে back (pop) করবে
        if (shouldPop) {
          Get.back();
        }

        // এরপর সার্চ ওপেন হবে
        final result = await SearchHelper.open();

        if (result != null) {
          print("Selected Market: ${result.shortName}");
          print("Selected Market to map: ${result.toJson()}");

          if (result.orderBook != null && result.shortName != null) {
            Get.find<HomeController>().goBottomNabBarPage(1, result.orderBook!);
            Get.find<HomeController>().tradingChart();
          }
        }
      },
      icon: SvgPicture.asset(AssetsConstants.searchIconSvg, width: 20, height: 20),
    );
  }
}
