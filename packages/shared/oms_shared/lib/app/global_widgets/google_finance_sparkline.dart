import '../core/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class GoogleFinanceSparkline extends StatelessWidget {
  final List<num> data;
  final double change;

  const GoogleFinanceSparkline({super.key, required this.data, required this.change});

  @override
  Widget build(BuildContext context) {
    // 🚀 Google Finance এর কালার প্যালেট
    final bool isPositive = change > 0;
    final bool isUnchanged = change == 0;

    final Color lineColor = isUnchanged
        ? Colors.grey.shade600
        : (isPositive ? const Color(0xFF137333) : const Color(0xFFA50E0E));

    final Color areaColor = lineColor.withOpacity(0.08);

    return SizedBox(
      height: 38,
      width: 85,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Row(
                children: List.generate(
                  16,
                  (index) => Expanded(
                    child: Container(
                      height: 1,
                      color: index % 2 == 0 ? Colors.grey.withOpacity(0.35) : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🚀 এরিয়া চার্ট
          SfSparkAreaChart(
            data: data.isEmpty ? [0, 0] : data,
            color: areaColor,
            borderColor: lineColor,
            borderWidth: 1.4,
            axisLineWidth: 0,
            marker: SparkChartMarker(
              displayMode: SparkChartMarkerDisplayMode.last,
              size: 4,
              color: lineColor,
              shape: SparkChartMarkerShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class BidAskPressureBar extends StatelessWidget {
  final int buyQty;
  final int sellQty;
  final double height;
  final double width;

  const BidAskPressureBar({
    super.key,
    required this.buyQty,
    required this.sellQty,
    this.height = 4.0,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final int total = buyQty + sellQty;
    // যদি কোনো অর্ডার না থাকে, তবে সমান সমান (১:১) এবং গ্রে কালার দেখাবে
    final int bFlex = total == 0 ? 1 : buyQty;
    final int sFlex = total == 0 ? 1 : sellQty;

    final Color bColor = total == 0 ? Colors.grey.withOpacity(0.3) : ColorConstants.upColor;
    final Color sColor = total == 0 ? Colors.grey.withOpacity(0.3) : ColorConstants.downColor;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Row(
          children: [
            Expanded(
              flex: bFlex,
              child: Container(color: bColor),
            ),
            Expanded(
              flex: sFlex,
              child: Container(color: sColor),
            ),
          ],
        ),
      ),
    );
  }
}

class DayRangeIndicator extends StatelessWidget {
  final double low;
  final double high;
  final double current;
  final bool isPositive;

  const DayRangeIndicator({
    super.key,
    required this.low,
    required this.high,
    required this.current,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    // পজিশন ক্যালকুলেশন
    double percentage = 0.0;
    if (high > low) {
      percentage = ((current - low) / (high - low)).clamp(0.0, 1.0);
    } else {
      percentage = 0.5; // হাই-লো সমান হলে মাঝখানে দেখাবে
    }

    final Color color = isPositive ? const Color(0xFF137333) : const Color(0xFFA50E0E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("L: ${low.toStringAsFixed(1)}", style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
            Text("H: ${high.toStringAsFixed(1)}", style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
          ],
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: 4,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              // ব্যাকগ্রাউন্ড লাইন
              Container(
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
              ),
              Positioned(
                left: percentage * 100 > 95 ? null : (percentage * 100), // ডানপাশে ওভারফ্লো বন্ধ করতে
                right: percentage * 100 > 95 ? 0 : null,
                child: Container(
                  height: 6,
                  width: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
