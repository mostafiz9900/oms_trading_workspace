
import 'package:oms_shared/app/modules/market/controllers/live_index_controller.dart';

import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class MarketActivityChart extends StatelessWidget {
  const MarketActivityChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveIndexController>(
      builder: (controller) {
        final chartData = controller.visibleIndexList;

        if (chartData.isEmpty) {
          return const SizedBox(height: 250, child: Center(child: Text("No activity data available")));
        }

        return Container(
          height: 320,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.isDark ? hexToColor('#161A33') : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderSideColor.withAlpha(128)),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚀 1. Premium Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Market Activity (Value vs Trades)',
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 🚀 2. Dual-Axis Chart
              Expanded(
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  margin: EdgeInsets.zero,
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    iconHeight: 12,
                    iconWidth: 12,
                    textStyle: TextStyle(color: context.textColor, fontWeight: FontWeight.w600, fontSize: 11),
                  ),

                  // 🚀 X-অক্ষ
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 0),
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, color: context.textColor, fontSize: 11),
                  ),

                  primaryYAxis: NumericAxis(
                    name: 'PrimaryYAxis',
                    title: AxisTitle(
                      text: 'Turnover (Cr)',
                      textStyle: TextStyle(
                        fontSize: 10,
                        color: context.textColor.withAlpha(128),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    majorGridLines: MajorGridLines(
                      width: 1,
                      dashArray: const <double>[4, 4], // স্লিক ড্যাশড লাইন
                      color: context.dividerColor.withAlpha(51),
                    ),
                    axisLine: const AxisLine(width: 0),
                    labelFormat: '{value}',
                    labelStyle: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold, fontSize: 10),
                  ),

                  // 🚀 Secondary Y-অক্ষ (ডান দিকে): Trades
                  axes: <ChartAxis>[
                    NumericAxis(
                      name: 'SecondaryYAxis',
                      opposedPosition: true,
                      title: AxisTitle(
                        text: 'Trades',
                        textStyle: TextStyle(
                          fontSize: 10,
                          color: context.textColor.withAlpha(128),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLine: const AxisLine(width: 0),
                      labelFormat: '{value}k',
                      labelStyle: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ],

                  // 🚀 Professional Shared Tooltip
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    shared: true,
                    color: context.isDark ? hexToColor('#1E2336') : Colors.grey.shade900,
                    textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                    elevation: 5,
                    shadowColor: Colors.black45,
                    format: 'point.series.name: point.y',
                  ),

                  series: <CartesianSeries>[
                    ColumnSeries<dynamic, String>(
                      name: 'Turnover (Cr)',
                      dataSource: chartData,
                      xValueMapper: (dynamic data, _) => data.sn ?? '',
                      yValueMapper: (dynamic data, _) {
                        final double vl = data.vl?.toDouble() ?? 0.0;
                        return vl / 10000000;
                      },
                      // 🚀 সলিড কালারের বদলে ফিনটেক স্টাইলের গ্রেডিয়েন্ট
                      gradient: LinearGradient(
                        colors: [
                          hexToColor('#177DFF'), // ডিপ ব্লু
                          hexToColor('#177DFF').withAlpha(128), // লাইট ব্লু
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      width: 0.45,
                      animationDuration: 0, // লাইভ ফিল্টারের জন্য ০
                    ),

                    SplineSeries<dynamic, String>(
                      name: 'Trades (K)',
                      dataSource: chartData,
                      yAxisName: 'SecondaryYAxis',
                      xValueMapper: (dynamic data, _) => data.sn ?? '',
                      yValueMapper: (dynamic data, _) {
                        final int tds = data.tds ?? 0;
                        return tds / 1000;
                      },
                      color: Colors.amber.shade600, // প্রিমিয়াম গোল্ডেন/অ্যাম্বার কালার
                      width: 2.5, // লাইন একটু স্লিক করা হয়েছে
                      animationDuration: 0,
                      // 🚀 মার্কারগুলোকে ছোট ও শার্প করা হয়েছে
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        color: context.cardColor,
                        borderWidth: 2,
                        borderColor: Colors.amber.shade600,
                        width: 6,
                        height: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
