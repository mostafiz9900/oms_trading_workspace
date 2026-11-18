import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getxify/getxify.dart';

import '../core/values/assets.dart';
import '../modules/global_search/controllers/global_search_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../core/utils/helpers/log_helper.dart';

class AppbarRightSearchTapWidget extends StatelessWidget {
  final bool shouldPop; // 🚀 নতুন প্যারামিটার যুক্ত করা হলো
  final int targetIndex;

  const AppbarRightSearchTapWidget({
    super.key,
    this.shouldPop = false, // ডিফল্ট false থাকবে
    this.targetIndex = 1,
  });

  static Future<void> openAndSelect({
    bool shouldPop = false,
    int targetIndex = 1,
  }) async {
    if (shouldPop) Get.back();

    final result = await SearchHelper.open();
    if (result?.orderBook == null || result?.shortName == null) return;

    printLog('Selected Market: ${result!.shortName}');
    printLog('Selected Market to map: ${result.toJson()}');
    Get.find<HomeController>().goBottomNabBarPage(
      targetIndex,
      result.orderBook!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await openAndSelect(shouldPop: shouldPop, targetIndex: targetIndex);
      },
      icon: SvgPicture.asset(
        AssetsConstants.searchIconSvg,
        width: 20,
        height: 20,
      ),
    );
  }
}
