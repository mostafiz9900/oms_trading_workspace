import 'dart:math';
import 'package:oms_shared/app/app_pkg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'index_value_loader.dart';

class WatchlistDistributionPage extends StatelessWidget {
  WatchlistDistributionPage({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    // 🚀 এখন এটি শুধুমাত্র distributionChartUpdate ট্যাগের জন্য রিবিল্ড হবে
    return GetBuilder<HomeController>(
      id: 'distributionChartUpdate',
      builder: (_) {
        // 🚀 ডেটা সরাসরি কন্ট্রোলার থেকে নেওয়া হচ্ছে (No Loop, No Computation here)
        final counts = controller.distributionCounts;
        final total = controller.distributionTotal;
        final maxCount = controller.distributionMaxCount;

        if (total == 0 || counts.isEmpty) {
          return const DistributionChartLoader();
        }

        var buckets = controller.buckets;
        final int step = 30;
        final double chartMaxY = ((maxCount / step).ceil() * step).toDouble();

        return Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.alphaSafe(0.10),
                spreadRadius: 0,
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              double barWidthFixed = 28.0;
              const double minGap = 6.0;
              const double maxGap = 48.0;

              final totalBarsWidth = barWidthFixed * buckets.length;
              double computedGap = (availableWidth - totalBarsWidth) / (buckets.length + 1);

              if (computedGap < minGap) {
                final spareForBars = availableWidth - minGap * (buckets.length + 1);
                barWidthFixed = (spareForBars / buckets.length).clamp(8.0, 28.0);
                final recomputedTotalBarsWidth = barWidthFixed * buckets.length;
                computedGap = (availableWidth - recomputedTotalBarsWidth) / (buckets.length + 1);
              }

              final groupsSpace = computedGap.clamp(minGap, maxGap);
              final labelWidth = barWidthFixed + groupsSpace;
              final chartHeight = availableWidth < 360 ? 220.0 : 300.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppSpace.spaceW4,
                      Text(
                        'Advance Decline',
                        style: Get.textTheme.titleMedium?.copyWith(fontSize: 16, color: context.textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: chartHeight,
                    width: availableWidth,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.center,
                        maxY: chartMaxY.clamp(1.0, double.infinity),
                        minY: 0,
                        groupsSpace: groupsSpace,
                        barGroups: List.generate(buckets.length, (i) {
                          final value = counts[i].toDouble();
                          final bucket = buckets[i];
                          final color = bucket.isCenter
                              ? ColorConstants.unchangedColor
                              : (_represent(bucket) >= 0 ? ColorConstants.upColor : ColorConstants.downColor);

                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: value,
                                width: barWidthFixed,
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    color.alphaSafe(0.20),
                                    color.alphaSafe(0.35),
                                    color.alphaSafe(0.55),
                                    color.alphaSafe(0.75),
                                    color.alphaSafe(1.00),
                                  ],
                                  stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: maxCount.toDouble(),
                                  color: color.withAlpha(13),
                                ),
                              ),
                            ],
                          );
                        }),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final i = group.x.toInt();
                              final bucket = buckets[i];
                              final cnt = counts[i];
                              final pct = (total == 0) ? 0.0 : (cnt / total) * 100;
                              return BarTooltipItem(
                                "${bucket.label}\n$cnt items\n${pct.toStringAsFixed(1)}% of total",
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 0,
                                  child: SizedBox(
                                    width: 20,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "${value.toInt()}",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(fontSize: 10, color: context.textColor),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= buckets.length) return const SizedBox();
                                final fontSize = (labelWidth * 0.12).clamp(10.0, 12.0);
                                final label = buckets[i].label;

                                return SizedBox(
                                  width: labelWidth,
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: pi / 2,
                                      child: Text(
                                        '$label%',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: Get.textTheme.bodyMedium?.copyWith(
                                          fontSize: fontSize,
                                          color: context.textColor,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          drawVerticalLine: true,
                          verticalInterval: 1.0,
                          getDrawingVerticalLine: (value) => const FlLine(color: Colors.black12, strokeWidth: 0.5),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _legendDot(ColorConstants.upColor, "Positive"),
                      const SizedBox(width: 12),
                      _legendDot(ColorConstants.downColor, "Negative"),
                      const SizedBox(width: 12),
                      _legendDot(ColorConstants.unchangedColor, "Unchanged"),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // 🚀 কালার লজিকের জন্য এই হেল্পার ফাংশনগুলো UI তেই থাকবে
  double _represent(Bucket b) {
    if (b.isCenter) return 0;
    if (b.min == double.negativeInfinity) return b.max - 1;
    if (b.max == double.infinity) return b.min + 1;
    return (b.min + b.max) / 2;
  }

  Widget _legendDot(Color c, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
