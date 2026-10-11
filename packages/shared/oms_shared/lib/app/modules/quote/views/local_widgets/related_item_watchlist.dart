import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import '/app/app_pkg.dart';

// =========================================================================
// 🚀 1. Main Watchlist Container
// =========================================================================
class RelatedItemWatchlist extends StatelessWidget {
  final List<MarketModel> relatedMarketList;
  final dynamic controller; // এটি মূলত HomeController এর ইনস্ট্যান্স

  const RelatedItemWatchlist({super.key, required this.relatedMarketList, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (relatedMarketList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            "Related assets",
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: context.isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 145,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            itemCount: relatedMarketList.length,
            itemBuilder: (context, index) {
              final item = relatedMarketList[index];

              return _GoogleFinanceCard(
                item: item,
                onTap: () {
                  if (item.orderBook != null) {
                    // 🚀 FIX: .homeCon বাদ দেওয়া হয়েছে, সরাসরি controller থেকে কল করা হচ্ছে
                    controller.goBottomNabBarPage(1, item.orderBook!);
                    FocusManager.instance.primaryFocus?.unfocus();

                    // যদি searchController HomeController-এর অংশ হয়, তবে এটি কাজ করবে
                    controller.searchController.clear();

                    controller.loadComanyDividentEPS(item.shortName ?? "");
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// =========================================================================
class _GoogleFinanceCard extends StatelessWidget {
  final MarketModel item;
  final VoidCallback onTap; // 🚀 ট্যাপ রিসিভ করার জন্য

  const _GoogleFinanceCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double change = item.chg ?? 0.0;
    final bool isPositive = change >= 0;

    final Color textColor = isPositive ? const Color(0xFF137333) : const Color(0xFFA50E0E);
    final Color bgColor = context.isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA);
    final Color borderColor = context.isDark ? Colors.white12 : Colors.transparent;

    // 🚀 আপডেটেড জেনারেটর ব্যবহার করা হলো
    final List<num> sparklineData = _generateSparklineData(item, change);

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      // 🚀 4. InkWell বা Material দিয়ে র‍্যাপ করা হলো যেন ক্লিক করলে সুন্দর রিপল (Ripple) ইফেক্ট আসে
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap, // 🚀 এখানে ইউজারের দেওয়া ফাংশনটি ট্রিগার হবে
          child: Stack(
            children: [
              // 🟩 কার্ডের ওপরের টেক্সট ইনফরমেশন
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.shortName ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.isDark ? Colors.white54 : const Color(0xFF5F6368),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.fullName ?? item.shortName ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: context.isDark ? Colors.white : const Color(0xFF202124),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.last?.toStringAsFixed(2) ?? '0.00',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.isDark ? Colors.white70 : const Color(0xFF5F6368),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
                          child: Icon(
                            isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🟩 চার্ট এরিয়া
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: GoogleFinanceSparkline(data: sparklineData, change: change),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 🚀 5. Flat-line Proof Data Generator
  // =========================================================================
  List<num> _generateSparklineData(MarketModel item, double absoluteChange) {
    final double currentPrice = item.last ?? 0.0;
    final double ycp = (item.reference != null && item.reference! > 0) ? item.reference! : currentPrice;
    if (ycp == 0 || currentPrice == 0) return [10, 10, 10];

    final double open = (item.open != null && item.open! > 0) ? item.open! : ycp;
    double high = (item.high != null && item.high! > 0) ? item.high! : math.max(open, currentPrice);
    double low = (item.low != null && item.low! > 0) ? item.low! : math.min(open, currentPrice);

    if (low > high) {
      double temp = low;
      low = high;
      high = temp;
    }

    double minVisualSpread = ycp * 0.005;
    if ((high - low) < minVisualSpread) {
      double mid = (high + low) / 2;
      high = mid + (minVisualSpread / 2);
      low = mid - (minVisualSpread / 2);
    }

    final double chartHigh = math.max(high, ycp);
    final double chartLow = math.min(low, ycp);

    final int seed = item.orderBook ?? (item.shortName?.hashCode ?? 0);
    final random = math.Random(seed);

    bool isBullish = absoluteChange >= 0;
    List<double> keyAnchors = isBullish
        ? [
            ycp,
            ycp - (ycp - low) * 0.4,
            low,
            ycp + (high - ycp) * 0.6,
            high,
            high - (high - currentPrice) * 0.3,
            currentPrice,
          ]
        : [
            ycp,
            ycp + (high - ycp) * 0.4,
            high,
            ycp - (ycp - low) * 0.6,
            low,
            low + (currentPrice - low) * 0.3,
            currentPrice,
          ];

    List<num> finalPath = [];
    int totalSteps = 20;

    for (int i = 0; i <= totalSteps; i++) {
      double t = i / totalSteps;
      double segment = t * (keyAnchors.length - 1);
      int idx = segment.floor();
      int nextIdx = math.min(idx + 1, keyAnchors.length - 1);

      double localT = segment - idx;
      double smoothT = (1 - math.cos(localT * math.pi)) / 2;
      double point = keyAnchors[idx] + (keyAnchors[nextIdx] - keyAnchors[idx]) * smoothT;

      if (i > 0 && i < totalSteps) {
        point += ((random.nextDouble() * 2) - 1) * ((high - low) * 0.15);
      }
      finalPath.add(point.clamp(chartLow, chartHigh));
    }
    return finalPath;
  }
}

// =========================================================================
// =========================================================================
class GoogleFinanceSparkline extends StatelessWidget {
  final List<num> data;
  final double change;

  const GoogleFinanceSparkline({super.key, required this.data, required this.change});

  @override
  Widget build(BuildContext context) {
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
