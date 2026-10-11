// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:oms_app/app/app_pkg.dart';
import '/app/data/models/response/order_status_details_model.dart';

class OrderStatusDetailsView extends StatelessWidget {
  const OrderStatusDetailsView({super.key, required this.order});
  final OrderStatusDetailsModel order;

  @override
  Widget build(BuildContext context) {
    printLog('OrderDetailsView :: ${order.toJson()}');

    Divider dividerWidget = Divider(height: 1, color: context.borderSideColor);
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          backButtonOnClick: () {
            Get.back();
          },
          isBackButtonIcon: true,
          right: SizedBox(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              AppSpace.spaceH10,
              Container(
                margin: const .symmetric(horizontal: 16, vertical: 6),
                padding: const .symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: context.tapBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: context.borderSideColor),
                ),
                child: Column(
                  children: [
                    _TitleAndValueRowWidget(title: 'Name', value: order.name ?? ''),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Client A/C', value: order.clientCode ?? ''),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Side', value: order.side ?? ""),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Exec Qty', value: '${order.sentQty ?? 0.0}'),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Order Type', value: order.ordType ?? ""),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Cum Qty', value: '${order.cumQty ?? 0.0}'),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Last Price', value: '${order.lastPx ?? 0.0}'),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Limit', value: '${order.limit ?? 0.0}'),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Execution', value: '${order.execution ?? 0.0}'),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Order Status', value: order.orderStatus ?? ""),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Status', value: order.status ?? ""),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(
                      title: 'Transaction Time',
                      value: Helpers.formatCustomDateTime(rawDate: order.transactTime) ?? "",
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
            color: valueColor ?? context.textColor,
          ),
        ),
      ],
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}
