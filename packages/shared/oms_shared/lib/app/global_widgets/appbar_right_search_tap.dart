import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../core/values/assets.dart';
import '../modules/global_search/controllers/global_search_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../core/utils/helpers/log_helper.dart';

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
          printLog("Selected Market: ${result.shortName}");
          printLog("Selected Market to map: ${result.toJson()}");

          if (result.orderBook != null && result.shortName != null) {
            Get.find<HomeController>().goBottomNabBarPage(1, result.orderBook!);
          }
        }
      },
      icon: SvgPicture.asset(AssetsConstants.searchIconSvg, width: 20, height: 20),
    );
  }
}
