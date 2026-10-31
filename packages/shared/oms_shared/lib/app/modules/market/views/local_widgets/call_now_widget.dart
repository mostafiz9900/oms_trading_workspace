

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/utils/extensions/string_extensions.dart';
import '../../../../core/values/colors.dart';
import '../../../../core/values/dimens.dart';
import '../../../home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/clock_controller.dart';


class CallNowWidget extends ConsumerWidget {
  const CallNowWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeCon = Get.find<HomeController>();
    final timeAsync = ref.watch(clockProvider);
    return Container(
      width: Get.width,
      height: 25,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Get.isDarkMode ? ColorConstants.primaryColorDark : ColorConstants.primaryColor),
      child: Padding(
        padding: const .symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            timeAsync.when(
              data: (time) {
                final formattedTime = DateFormat('EEE, dd MMM, yy,  hh:mm:ss a').format(time);
                return Text(
                  formattedTime,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: ColorConstants.white,
                    fontSize: AppDimens.space12,
                    fontWeight: FontWeight.w400,
                  ),
                );
              },
              loading: () => SizedBox(),
              error: (e, _) => Text('Error: $e'),
            ),
            Obx(() {
              return Text(
                homeCon.shownMarket.session.value == ''
                    ? ""
                    : homeCon.shownMarket.session.value.split('_').join(' ').toCapitalize(),
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: homeCon.shownMarket.session.value == ''
                      ? ColorConstants.white
                      : homeCon.shownMarket.session.value.split('_').join(' ').toCapitalize() ==
                            "Continuous" //Continuous
                      ? ColorConstants.success
                      : ColorConstants.redColor, //Auction
                  fontSize: AppDimens.space12,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),

          ],
        ),
      ),
    );
  }
}
