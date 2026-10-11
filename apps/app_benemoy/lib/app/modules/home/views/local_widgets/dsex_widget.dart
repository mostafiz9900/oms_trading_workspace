import 'package:market/market.dart' show TradingChartModel;

import 'dart:math';

import 'package:app_benemoy/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interactive_chart/interactive_chart.dart';

import '../../../../data/models/response/mokdata_tesla.dart';

extension TradingChartMapper on TradingChartModel {
  List<CandleData> toCandles() {
    final List<CandleData> candles = [];

    for (int i = 0; i < (t?.length ?? 0); i++) {
      candles.add(
        CandleData(
          timestamp: (t![i]) * 1000, // API gives seconds → ms
          open: double.tryParse(o?[i].toString() ?? '0') ?? 0,
          high: double.tryParse(h?[i].toString() ?? '0') ?? 0,
          low: double.tryParse(l?[i].toString() ?? '0') ?? 0,
          close: double.tryParse(c?[i].toString() ?? '0') ?? 0,
          volume: double.tryParse(v?[i].toString() ?? '0') ?? 0,
        ),
      );
    }
    return candles;
  }

  List<CandleData> toCandles2() {
    final List<CandleData> candles = [];

    for (int i = 0; i < (t?.length ?? 0); i++) {
      double open = min(double.tryParse(o?[i].toString() ?? '0') ?? 0, 350);
      double high = min(double.tryParse(h?[i].toString() ?? '0') ?? 0, 350);
      double low = min(double.tryParse(l?[i].toString() ?? '0') ?? 0, 350);
      double close = min(double.tryParse(c?[i].toString() ?? '0') ?? 0, 350);
      double volume = double.tryParse(v?[i].toString() ?? '0') ?? 0;

      candles.add(
        CandleData(
          timestamp: (t![i]) * 1000, // API gives seconds → ms
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        ),
      );
    }

    return candles;
  }
}

class DsexWidget extends StatelessWidget {
  const DsexWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<CandleData> data0 = MockDataTesla.candles;

    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.alphaSafe(0.20),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      margin: const .symmetric(horizontal: 8.0),
      padding: const .symmetric(horizontal: 8.0, vertical: 10.0),
      height: 250,
      child: InteractiveChart(
        /** Only [candles] is required */
        candles: data0,
        /** Uncomment the following for examples on optional parameters */

        /** Example styling */
        style: ChartStyle(
          priceGainColor: Colors.teal[200]!,
          priceLossColor: Colors.blueGrey,
          volumeColor: Colors.teal.alphaSafe(0.8),
          trendLineStyles: [
            Paint()
              ..strokeWidth = 2.0
              ..strokeCap = StrokeCap.round
              ..color = Colors.deepOrange,
            Paint()
              ..strokeWidth = 4.0
              ..strokeCap = StrokeCap.round
              ..color = Colors.orange,
          ],
          priceGridLineColor: Colors.blue[200]!,
          priceLabelStyle: TextStyle(color: Colors.blue[200]),
          timeLabelStyle: TextStyle(color: Colors.blue[200]),
          selectionHighlightColor: Colors.red.alphaSafe(0.2),
          overlayBackgroundColor: Colors.red[900]!.alphaSafe(0.6),
          overlayTextStyle: TextStyle(color: Colors.red[100]),
          timeLabelHeight: 32,
          volumeHeightFactor: 0.2, // volume area is 20% of total height
        ),
        /** Customize axis labels */
        // timeLabel: (timestamp, visibleDataCount) => "📅",
        // priceLabel: (price) => "${price.round()} 💎",
        /** Customize overlay (tap and hold to see it)
             ** Or return an empty object to disable overlay info. */
        overlayInfo: (candle) => {
          "💎": "🤚    ",
          "Hi": "${candle.high?.toStringAsFixed(2)}",
          "Lo": "${candle.low?.toStringAsFixed(2)}",
        },
        /** Callbacks */
        onTap: (candle) => print("user tapped on $candle"),
        onCandleResize: (width) => print("each candle is $width wide"),
      ),
    );

    // return Container(
    //   margin: .all(AppDimens.space10),
    //   decoration: BoxDecoration(
    //     color: ColorConstants.white,
    //     borderRadius: BorderRadius.circular(AppDimens.space10),
    //     boxShadow: [
    //       BoxShadow(
    //         color: ColorConstants.gray,
    //         offset: const Offset(
    //           0.0,
    //           0.0,
    //         ),
    //         blurRadius: 0.0,
    //         spreadRadius: 0.0,
    //       ), //BoxShadow
    //     ],
    //   ),
    //   child: Column(
    //     children: [
    //       AppSpace.spaceH10,
    //       SfCartesianChart(
    //         borderColor: ColorConstants.blueColor,
    //         primaryXAxis:
    //             CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
    //         primaryYAxis: NumericAxis(majorGridLines: MajorGridLines(width: 0)),
    //         zoomPanBehavior: ZoomPanBehavior(
    //           enablePinching: true,
    //           enablePanning: true,
    //           enableDoubleTapZooming: true,
    //           enableMouseWheelZooming: true,
    //           enableSelectionZooming: true,
    //           selectionRectBorderColor: Colors.blue,
    //           selectionRectBorderWidth: 0.5,
    //           selectionRectColor: Colors.lightBlue.alphaSafe(0.3),
    //           zoomMode: ZoomMode.y, // Restrict zooming to the x-axis
    //         ),
    //         series: [
    //           SplineAreaSeries<_ChartData, dynamic>(
    //             color: ColorConstants.redColor
    //                 .alphaSafe(0.2), // Set spline color here
    //             dataSource: data,
    //             xValueMapper: (_ChartData sales, _) => sales.year,
    //             yValueMapper: (_ChartData sales, _) => sales.sales,
    //             gradient: LinearGradient(
    //               begin: Alignment.topCenter,
    //               end: Alignment.bottomCenter,
    //               colors: <Color>[
    //                 ColorConstants.blueColor,
    //                 ColorConstants.white.alphaSafe(0.5),
    //               ],
    //             ),
    //             borderColor: ColorConstants.greenColor,
    //             borderWidth: 1,
    //           ),
    //           BarSeries<_ChartData, dynamic>(
    //             dataSource: barData,
    //             xValueMapper: (_ChartData sales, _) => sales.year,
    //             yValueMapper: (_ChartData sales, _) => sales.sales,
    //             color: ColorConstants.greenColor,
    //           ),
    //         ],
    //       )
    //
    //       // InteractiveChart(
    //       //   /** Only [candles] is required */
    //       //   candles: _data,
    //       //   /** Uncomment the following for examples on optional parameters */
    //       //
    //       //   /** Example styling */
    //       //   style: ChartStyle(
    //       //     priceGainColor: Colors.teal[200]!,
    //       //     priceLossColor: Colors.blueGrey,
    //       //     volumeColor: Colors.teal.alphaSafe(0.8),
    //       //     trendLineStyles: [
    //       //       Paint()
    //       //         ..strokeWidth = 2.0
    //       //         ..strokeCap = StrokeCap.round
    //       //         ..color = Colors.deepOrange,
    //       //       Paint()
    //       //         ..strokeWidth = 4.0
    //       //         ..strokeCap = StrokeCap.round
    //       //         ..color = Colors.orange,
    //       //     ],
    //       //     priceGridLineColor: Colors.blue[200]!,
    //       //     priceLabelStyle: TextStyle(color: Colors.blue[200]),
    //       //     timeLabelStyle: TextStyle(color: Colors.blue[200]),
    //       //     selectionHighlightColor: Colors.red.alphaSafe(0.2),
    //       //     overlayBackgroundColor: Colors.red[900]!.alphaSafe(0.6),
    //       //     overlayTextStyle: TextStyle(color: Colors.red[100]),
    //       //     timeLabelHeight: 32,
    //       //     volumeHeightFactor: 0.2, // volume area is 20% of total height
    //       //   ),
    //       //   /** Customize axis labels */
    //       //   timeLabel: (timestamp, visibleDataCount) => "📅",
    //       //   priceLabel: (price) => "${price.round()} 💎",
    //       //   /** Customize overlay (tap and hold to see it)
    //       //    ** Or return an empty object to disable overlay info. */
    //       //   overlayInfo: (candle) => {
    //       //     "💎": "🤚    ",
    //       //     "Hi": "${candle.high?.toStringAsFixed(2)}",
    //       //     "Lo": "${candle.low?.toStringAsFixed(2)}",
    //       //   },
    //       //   /** Callbacks */
    //       //   onTap: (candle) => print("user tapped on $candle"),
    //       //   onCandleResize: (width) => print("each candle is $width wide"),
    //       // ),
    //     ],
    //   ),
    // );
  }
}

class DsexWidget2 extends StatelessWidget {
  const DsexWidget2({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: "interactive_charts",
      builder: (homeCon) {
        if (homeCon.tradingChartModel == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final candles = homeCon.tradingChartModel!.toCandles2();

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.alphaSafe(0.08),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              margin: const .symmetric(horizontal: 8.0),
              padding: const .symmetric(horizontal: 8.0, vertical: 10.0),
              height: 300,
              child: InteractiveChart(
                candles: candles,
                initialVisibleCandleCount: homeCon.visibleCount,
                style: ChartStyle(
                  priceGainColor: Colors.green.shade600,
                  priceLossColor: Colors.red.shade600,
                  volumeColor: Colors.grey.shade600,
                  priceLabelStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  timeLabelStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                  ),
                  overlayTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                  priceGridLineColor: Colors.grey.shade300,
                ),
                overlayInfo: (candle) => {
                  "O": "${candle.open?.toStringAsFixed(2)}",
                  "H": "${candle.high?.toStringAsFixed(2)}",
                  "L": "${candle.low?.toStringAsFixed(2)}",
                  "C": "${candle.close?.toStringAsFixed(2)}",
                  "V": "${candle.volume?.toStringAsFixed(0)}",
                },
                // timeLabel: (index, total) {
                //   final dt = DateTime.fromMillisecondsSinceEpoch(candles[index].timestamp);
                //   return "${dt.day}/${dt.month}";
                // },
                priceLabel: (price) => price.toStringAsFixed(2),
                onTap: (value) {
                  print('Candle tapped: $value');
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
