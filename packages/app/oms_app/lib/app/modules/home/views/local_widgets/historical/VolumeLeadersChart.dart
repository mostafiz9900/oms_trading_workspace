import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '/app/app_pkg.dart';

// =========================================================================
// 🚀 1. Traded Value Leaders Chart (Horizontal Bar + Gradient)
// =========================================================================
class VolumeLeadersChart extends StatelessWidget {
  const VolumeLeadersChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: "marketList",
      builder: (homeCont) {
        final List<Map<String, dynamic>> data = homeCont.chartDataVolumeLeaders;
        return _ProChartContainer(
          context: context,
          title: 'Top Traded Value Leaders',
          child: SfCartesianChart(
            margin: EdgeInsets.zero,
            plotAreaBorderWidth: 0, // প্রো লুকের জন্য বর্ডার হাইড
            tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x : point.y BDT'),
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
              labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            primaryYAxis: NumericAxis(isVisible: false), // Y-Axis লুকানো, ডেটা লেবেল ব্যবহার করা হবে
            series: <CartesianSeries>[
              BarSeries<Map<String, dynamic>, String>(
                dataSource: data,
                xValueMapper: (d, _) => d['sn'],
                yValueMapper: (d, _) => d['val'],
                // 🚀 প্রো ফিচার: সুন্দর গ্রেডিয়েন্ট এবং ডেটা লেবেল[cite: 12]
                gradient: LinearGradient(
                  colors: [context.buttonColor.withOpacity(0.5), context.buttonColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(4),
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.outer,
                  builder: (data, point, series, pointIndex, seriesIndex) {
                    return Text(
                      NumberFormat.compact().format(data['val']),
                      style: TextStyle(color: context.isDark ? Colors.white70 : Colors.black87, fontSize: 9),
                    );
                  },
                ),
                animationDuration: 1000,
              ),
            ],
          ),
        );
      },
    );
  }
}

// =========================================================================
// 🛠️ Shared Container for Consistent Pro Look
// =========================================================================
class _ProChartContainer extends StatelessWidget {
  final BuildContext context;
  final String title;
  final Widget child;

  const _ProChartContainer({required this.context, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 12, right: 12),
      decoration: BoxDecoration(
        color: context.isDark ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.isDark ? Colors.white10 : Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Get.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class ProWatchlistTicker extends StatelessWidget {
  final List<MarketModel> marketList;

  const ProWatchlistTicker({super.key, required this.marketList});

  @override
  Widget build(BuildContext context) {
    // ভলিউম অনুযায়ী সর্ট করে টপ ২০টি ডেটা নেওয়া হলো
    final top20 = List<MarketModel>.from(marketList)..sort((a, b) => (b.volume ?? 0).compareTo(a.volume ?? 0));
    final displayList = top20.take(20).toList();

    return SizedBox(
      height: 65, // 🚀 Google Finance এর মতো স্লিক হাইট
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10), // দুই পাশে একটু স্পেস
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final item = displayList[index];
          final isPositive = (item.chg ?? 0) >= 0;

          // 🚀 কালার এবং আইকন লজিক (Google Finance Style)
          final changeColor = isPositive ? Colors.green.shade700 : Colors.red.shade700;
          final trendIcon = isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

          return Container(
            width: 130, // প্রাইস এবং পার্সেন্টেজ পাশাপাশি রাখার জন্য উইডথ একটু বাড়ানো হয়েছে
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.isDark ? Colors.grey.shade900 : Colors.white, // 🚀 ক্লিন ব্যাকগ্রাউন্ড
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.isDark ? Colors.white10 : Colors.grey.shade200, // 🚀 একদম হালকা বর্ডার
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ১. স্টকের নাম (ডিফল্ট কালার)
                Text(
                  item.shortName ?? '',
                  style: Get.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // ২. প্রাইস এবং চেঞ্জ রেট পাশাপাশি
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // বর্তমান প্রাইস (ডিফল্ট কালার, একটু বোল্ড)
                    Text(
                      '${item.last?.toStringAsFixed(2)}',
                      style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(width: 6),

                    // আপ/ডাউন অ্যারো আইকন
                    Icon(trendIcon, color: changeColor, size: 12),

                    // পরিবর্তনের হার (সবুজ বা লাল)
                    Text(
                      '${item.chg?.toStringAsFixed(2)}%',
                      style: TextStyle(color: changeColor, fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
