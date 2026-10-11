import 'package:oms_shared/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/response/position_response.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key, required this.userOrder});
  final UserOrder userOrder;

  // বেসিক স্ট্যাটাস কালার
  Color _getStatusColor(String? status, BuildContext context) {
    switch (status) {
      case 'FILLED':
        return HexColor("#22C665");
      case 'PARTIALLY_FILLED':
        return Colors.orange;
      case 'CANCELED':
        return Colors.grey;
      case 'REJECTED':
        return HexColor("#F70042");
      case 'NEW':
      case 'REPLACED':
        return Colors.blue;
      default:
        return context.textColor;
    }
  }

  // 🚀 টাইম ফরম্যাটিং লজিক
  String _formatTime(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return "";
    try {
      final parts = rawTime.split('-');
      if (parts.length == 2) {
        String datePart = parts[0]; // 20260906
        String timePart = parts[1].split('.')[0]; // 04:15:23

        // তারিখ সুন্দর করে সাজানো (DD-MM-YYYY)
        if (datePart.length == 8) {
          String year = datePart.substring(0, 4);
          String month = datePart.substring(4, 6);
          String day = datePart.substring(6, 8);
          return "$day-$month-$year   $timePart";
        }
        return "${parts[0]}  $timePart";
      }
    } catch (e) {
      // ফেইল করলে অন্তত র-টাইমটা দেখাবে
    }
    return rawTime;
  }

  @override
  Widget build(BuildContext context) {
    printLog('OrderDetailsView :: ${userOrder.toJson()}');

    Divider dividerWidget = Divider(height: 1, color: context.dividerColor.withOpacity(0.5));

    // Side Color
    String side = userOrder.side ?? "";
    Color sideColor = side.toUpperCase() == 'BUY' ? HexColor("#22C665") : HexColor("#F70042");

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          backButtonOnClick: () {
            Get.back();
          },
          isBackButtonIcon: true,
          titleText: "Order Details",
          right: const SizedBox(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              AppSpace.spaceH10,
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: context.borderSideColor.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    _TitleAndValueRowWidget(title: 'Instrument', value: userOrder.name ?? ''),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(title: 'Client A/C', value: userOrder.clientCode ?? ''),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(title: 'Side', value: side, valueColor: sideColor),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(title: 'Order Type', value: userOrder.ordType ?? ""),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(title: 'Total Qty', value: '${userOrder.sentQty ?? 0}'),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(title: 'Executed Qty', value: '${userOrder.cumQty ?? 0}'),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(title: 'Leaves Qty', value: '${userOrder.leavesQty ?? 0}'),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(title: 'Remaining Qty', value: '${userOrder.remainingQty ?? 0}'),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(title: 'Execution%', value: userOrder.execution ?? ""),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(title: 'Limit Price', value: '${userOrder.limit ?? 0.0}'),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(title: 'Avg Exec. Price', value: '${userOrder.avgPx ?? 0.0}'),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(title: 'Gross Amount', value: '${userOrder.grossTradeAmt ?? 0.0}'),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(
                      title: 'Order Status',
                      value: userOrder.orderStatus ?? "",
                      valueColor: _getStatusColor(userOrder.orderStatus, context),
                    ),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(title: 'Status', value: userOrder.status ?? ""),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    _TitleAndValueRowWidget(
                      title: 'Reason',
                      value: userOrder.rejectionReason ?? "N/A",
                      valueColor: userOrder.rejectionReason != null ? HexColor("#F70042") : null,
                    ),
                    AppSpace.spaceH10, dividerWidget, AppSpace.spaceH10,

                    // 🚀 টাইম ফরম্যাটিং অ্যাপ্লাই করা হলো
                    _TitleAndValueRowWidget(
                      title: 'Time',
                      value: Helpers.convertTimestampToLocalTime(userOrder.transactTime) ?? '',
                      valueFontSize: 13,
                    ),
                    AppSpace.spaceH10,
                  ],
                ),
              ),
              AppSpace.spaceH10,
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleAndValueRowWidget extends StatelessWidget {
  const _TitleAndValueRowWidget({
    super.key,
    required this.title,
    required this.value,
    this.valueColor,
    this.valueFontSize,
  });

  final String title;
  final String value;
  final Color? valueColor;
  final double? valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: TextAlign.left,
          style: Get.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: context.textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontSize: valueFontSize ?? 15,
              fontWeight: FontWeight.w600,
              color: valueColor ?? context.textColor,
            ),
          ),
        ),
      ],
    );
  }
}
