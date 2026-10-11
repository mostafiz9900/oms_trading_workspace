import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/utils/helpers/formatter_helper.dart';
import '../../../../core/values/colors.dart';
import '../../../../core/values/space.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../../global_widgets/loaders/order_list_loader.dart';

class AccountSummaryTabWidget extends StatelessWidget {
  const AccountSummaryTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Divider dividerWidget = Divider(height: 1, color: context.dividerColor);
    return GetBuilder<HomeController>(
      id: 'user_balance_update',
      initState: (___) {
      },
      builder: (homeCont) {
        if (homeCont.userBalanceData == null) {
          return const OrderListLoader();
        }
        final user = homeCont.userBalanceData;
        return Column(
          children: [
            const _ClientCodeWidget(),
            AppSpace.spaceH20,
            Divider(height: 1, color: context.dividerColor),
            AppSpace.spaceH10,
            Container(
              margin: const .symmetric(horizontal: 16, vertical: 6),
              padding: const .symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: context.bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1, color: context.borderSideColor),
              ),
              child: Column(
                children: [
                  _TitleAndValueRowWidget(
                    title: 'Initial Amount',
                    value: NumberFormatter.bdFormat(user?.initialAmount ?? 0),
                    valueColor: context.textColor,
                  ),
                  AppSpace.spaceH10,
                  dividerWidget,
                  AppSpace.spaceH10,
                  _TitleAndValueRowWidget(
                    title: 'Intraday Amount',
                    value: NumberFormatter.bdFormat(user?.intradayAmount ?? 0),
                    valueColor: ColorConstants.success,
                  ),
                  AppSpace.spaceH10,
                  dividerWidget,
                  AppSpace.spaceH10,
                  _TitleAndValueRowWidget(
                    title: 'Cash Balance',
                    value: NumberFormatter.bdFormat(user?.amount ?? 0),
                    valueColor: ColorConstants.success,
                  ),
                  AppSpace.spaceH10,
                  dividerWidget,
                  AppSpace.spaceH10,
                  _TitleAndValueRowWidget(
                    title: 'Percentage',
                    value: '${user?.percentage ?? 0}%',
                    valueColor: context.textColor,
                  ),
                  AppSpace.spaceH10,
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TitleAndValueRowWidget extends StatelessWidget {
  const _TitleAndValueRowWidget({required this.title, required this.value, this.valueColor});

  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(
          title,
          textAlign: TextAlign.left,
          style: Get.textTheme.bodyMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: Get.textTheme.bodyMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: valueColor ?? hexToColor('#3F3F3F'),
          ),
        ),
      ],
    );
  }
}

class _ClientCodeWidget extends StatelessWidget {
  const _ClientCodeWidget();

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration = BoxDecoration(
      border: Border.all(width: 1, color: context.borderSideColor),
      borderRadius: BorderRadius.circular(4),
    );
    return Padding(
      padding: const .symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: .start,
        children: [
          Expanded(
            child: Container(
              padding: const .symmetric(vertical: 5, horizontal: 10),
              decoration: decoration,
              child: Column(
                crossAxisAlignment: .start,
                mainAxisAlignment: .start,
                children: [
                  Text('Currency', style: Get.textTheme.bodySmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w400)),
                  Text('BDT', style: Get.textTheme.titleLarge?.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
