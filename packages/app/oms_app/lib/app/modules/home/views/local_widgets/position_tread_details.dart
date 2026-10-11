import 'package:oms_app/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/response/position_response.dart';

class PositionTradeDetails extends StatelessWidget {
  const PositionTradeDetails({super.key, required this.positionModel});
  final PositionModel positionModel;

  @override
  Widget build(BuildContext context) {
    Divider dividerWidget = Divider(height: 1, color: hexToColor('#E0E0E0'));
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          backButtonOnClick: () {
            Get.back();
          },
          isBackButtonIcon: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Padding(
              //   padding: .symmetric(horizontal: AppDimens.space10),
              //   child: Row(
              //     mainAxisAlignment: .start,
              //     children: [
              //       Expanded(
              //         child: Container(
              //           padding: const .symmetric(
              //               vertical: 5, horizontal: 10),
              //           // decoration:decoration,
              //           child: Column(
              //             crossAxisAlignment: .start,
              //             mainAxisAlignment: .start,
              //             children: [
              //               RichText(
              //                 text: TextSpan(
              //                   text: 'RUPALIBANK',
              //                   style: Get.textTheme.bodySmall?.copyWith(
              //                       fontSize: AppDimens.space17,
              //                       fontWeight: FontWeight.w700,
              //                       color: ColorConstants.success),
              //                   children: [
              //                     TextSpan(
              //                       text: ' DES',
              //                       style: Get.textTheme.bodySmall?.copyWith(
              //                           fontWeight: FontWeight.w400,
              //                           fontSize: AppDimens.space12,
              //                           color: ColorConstants.black),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //               Text('RUPALIBANK',
              //                   style: Get.textTheme.bodySmall?.copyWith(
              //                       color: ColorConstants.black,
              //                       fontSize: AppDimens.space11,
              //                       fontWeight: FontWeight.w400)),
              //             ],
              //           ),
              //         ),
              //       ),
              //       AppSpace.spaceW16,
              //       Expanded(
              //         child: Container(
              //           padding: const .symmetric(
              //               vertical: 5, horizontal: 10),
              //           // decoration:decoration,
              //           child: Column(
              //             crossAxisAlignment: .center,
              //             mainAxisAlignment: .spaceBetween,
              //             children: [
              //               Text('Balance',
              //                   style: Get.textTheme.bodySmall?.copyWith(
              //                       fontSize: AppDimens.space20,
              //                       fontWeight: FontWeight.w700,
              //                       color: ColorConstants.blueColor)),
              //               Text('15.12',
              //                   style: Get.textTheme.bodySmall?.copyWith(
              //                       fontSize: AppDimens.space12,
              //                       fontWeight: FontWeight.w400,
              //                       color: ColorConstants.gray))
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // Divider(
              //   height: 0.5,
              //   color: context.dividerColor,
              // ),
              // AppSpace.spaceH10,
              // Padding(
              //   padding: .symmetric(horizontal: AppDimens.space10),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: Column(
              //           mainAxisAlignment: .start,
              //           crossAxisAlignment: .start,
              //           children: [
              //             Container(
              //               width: Get.width,
              //               decoration: BoxDecoration(
              //                   color: HexColor("EBF2FC"),
              //                   borderRadius:
              //                       BorderRadius.circular(AppDimens.space10),
              //                   border: Border.all(
              //                       width: 1,
              //                       color:
              //                           ColorConstants.gray.alphaSafe(0.3))),
              //               child: Padding(
              //                 padding: .all(AppDimens.space10),
              //                 child: Column(
              //                   mainAxisAlignment: .start,
              //                   crossAxisAlignment: .start,
              //                   children: [
              //                     Container(
              //                         padding: .all(AppDimens.space5),
              //                         decoration: BoxDecoration(
              //                             color: ColorConstants.greenColor,
              //                             borderRadius: BorderRadius.circular(
              //                                 AppDimens.space10)),
              //                         child: Text(
              //                           "Todays Buy",
              //                           style: Get.textTheme.titleMedium
              //                               ?.copyWith(
              //                                   fontSize: AppDimens.space12,
              //                                   color: ColorConstants.white),
              //                         )),
              //                     AppSpace.spaceH20,
              //                     Column(
              //                       children: [
              //                         Text(
              //                           "\$ 854",
              //                           style: Get.textTheme.titleMedium
              //                               ?.copyWith(
              //                                   fontWeight: FontWeight.w700,
              //                                   fontSize: AppDimens.space24),
              //                         ),
              //                         Text(
              //                           "20 Qyt",
              //                           style: Get.textTheme.titleMedium
              //                               ?.copyWith(
              //                                   color:
              //                                       ColorConstants.greenColor,
              //                                   fontWeight: FontWeight.w700,
              //                                   fontSize: AppDimens.space16),
              //                         ),
              //                       ],
              //                     )
              //                   ],
              //                 ),
              //               ),
              //             ),
              //             AppSpace.spaceH10,
              //             Container(
              //               width: Get.width,
              //               decoration: BoxDecoration(
              //                   color: HexColor("EBF2FC"),
              //                   borderRadius:
              //                       BorderRadius.circular(AppDimens.space10),
              //                   border: Border.all(
              //                       width: 1,
              //                       color:
              //                           ColorConstants.gray.alphaSafe(0.3))),
              //               child: Padding(
              //                 padding: .all(AppDimens.space10),
              //                 child: Column(
              //                   mainAxisAlignment: .start,
              //                   crossAxisAlignment: .start,
              //                   children: [
              //                     Container(
              //                         padding: .all(AppDimens.space5),
              //                         decoration: BoxDecoration(
              //                             color: ColorConstants.redColor,
              //                             borderRadius: BorderRadius.circular(
              //                                 AppDimens.space10)),
              //                         child: Text(
              //                           "Todays Sell",
              //                           style: Get.textTheme.titleMedium
              //                               ?.copyWith(
              //                                   fontSize: AppDimens.space12,
              //                                   color: ColorConstants.white),
              //                         )),
              //                     AppSpace.spaceH20,
              //                     Column(
              //                       children: [
              //                         Text(
              //                           "\$ 854",
              //                           style: Get.textTheme.titleMedium
              //                               ?.copyWith(
              //                                   fontWeight: FontWeight.w700,
              //                                   fontSize: AppDimens.space24),
              //                         ),
              //                         Text(
              //                           "20 Qyt",
              //                           style: Get.textTheme.titleMedium
              //                               ?.copyWith(
              //                                   color: ColorConstants.redColor,
              //                                   fontWeight: FontWeight.w700,
              //                                   fontSize: AppDimens.space16),
              //                         ),
              //                       ],
              //                     )
              //                   ],
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       AppSpace.spaceW18,
              //       Expanded(
              //           child: SizedBox(
              //         width: Get.width,
              //         height: 200,
              //         child: Stack(
              //           alignment: Alignment.center,
              //           clipBehavior: Clip.none,
              //           children: [
              //             SfCircularChart(series: <CircularSeries>[
              //               // Render pie chart
              //               PieSeries<ChartData, String>(
              //                   dataSource: chartData,
              //                   pointColorMapper: (ChartData data, _) =>
              //                       data.color,
              //                   xValueMapper: (ChartData data, _) => data.x,
              //                   yValueMapper: (ChartData data, _) => data.y)
              //             ]),
              //             Positioned(
              //                 top: Get.width / 2.4,
              //                 child: Text(
              //                   "Portfolio%",
              //                   style: Get.textTheme.titleMedium?.copyWith(
              //                       color: ColorConstants.black,
              //                       fontSize: AppDimens.space17,
              //                       fontWeight: FontWeight.w400),
              //                 ))
              //           ],
              //         ),
              //       ))
              //     ],
              //   ),
              // ),
              // AppSpace.spaceH10,
              // Divider(
              //   height: 0.5,
              //   color: context.dividerColor,
              // ),
              AppSpace.spaceH10,
              Container(
                margin: const .symmetric(horizontal: 16, vertical: 6),
                padding: const .symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: hexToColor('#F7FAFF'),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: hexToColor('#D0D0D0')),
                ),
                child: Column(
                  children: [
                    _TitleAndValueRowWidget(title: 'Portfolio', value: positionModel.securityCode ?? ''),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Client Code', value: positionModel.clientCode ?? ''),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Currency', value: 'BDT'),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Average Cost', value: '${positionModel.avgPrice ?? 0.0}'),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Total Cost', value: '${positionModel.totalCost ?? 0.0}'),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: 'Initial Qty', value: '${positionModel.quantity ?? 0.0}'),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(
                      title: 'Last Price',
                      value: '${positionModel.lastPrice?.toStringAsFixed(2) ?? 0.0}',
                    ),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(
                      title: 'Market Value',
                      value: '${positionModel.marketValue?.toStringAsFixed(2) ?? 0.0}',
                    ),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(
                      title: 'Unrealized PnL',
                      value: '${positionModel.unrealizedValue?.toStringAsFixed(2) ?? 0.0}',
                      valueColor: (positionModel.unrealizedValue ?? 0) <= 0 ? Colors.red : Colors.black,
                    ),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(
                      title: 'Realized PnL',
                      value: '${positionModel.realizedValue?.toStringAsFixed(2) ?? 0.0}',
                    ),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(
                      title: 'Buy Quantity',
                      value: '${positionModel.intradayBuyQuantity?.toStringAsFixed(2) ?? 0.0}',
                    ),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(
                      title: 'Buy Price',
                      value: '${positionModel.intradayBuyPriceAvg?.toStringAsFixed(2) ?? 0.0}',
                    ),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(
                      title: 'Sell Quantity',
                      value: '${positionModel.intradayBuyPriceAvg?.toStringAsFixed(2) ?? 0.0}',
                    ),
                    AppSpace.spaceH10,
                    dividerWidget,
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(
                      title: 'Sell Price',
                      value: '${positionModel.intradaySellPriceAvg?.toStringAsFixed(2) ?? 0.0}',
                    ),
                  ],
                ),
              ),
              AppSpace.spaceH10,
              // Padding(
              //   padding: .symmetric(horizontal: AppDimens.space15),
              //   child: Row(
              //     mainAxisAlignment: .spaceBetween,
              //     children: [
              //       Expanded(
              //         child: CustomButton(
              //           onPressed: () {},
              //           title: "Buy",
              //           backgroundColor: ColorConstants.success,
              //           height: AppDimens.space54,
              //         ),
              //       ),
              //       AppSpace.spaceW10,
              //       Expanded(
              //         child: CustomButton(
              //           onPressed: () {},
              //           title: "Sell",
              //           backgroundColor: ColorConstants.redColor,
              //           height: AppDimens.space54,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // AppSpace.spaceH10,
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
            color: valueColor ?? hexToColor('#3F3F3F'),
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
