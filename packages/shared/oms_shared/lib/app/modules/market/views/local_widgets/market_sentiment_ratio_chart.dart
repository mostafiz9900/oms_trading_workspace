
import 'package:oms_shared/app/modules/market/controllers/live_index_controller.dart';

import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class MarketSentimentRatioChart extends StatelessWidget {
  const MarketSentimentRatioChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveIndexController>(
      builder: (indexCon) {
        final visibleIndices = indexCon.visibleIndexList;

        if (visibleIndices.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.isDark ? hexToColor('#161A33') : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderSideColor.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚀 1. Header with Blinking "LIVE" Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Market Sentiment',
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleIndices.length,
                separatorBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                itemBuilder: (context, index) {
                  final data = visibleIndices[index];
                  final int up = data.u ?? 0;
                  final int down = data.d ?? 0;
                  final int uc = data.uc ?? 0;
                  final int total = up + down + uc;

                  // যদি কোনো ডেটা না থাকে
                  if (total == 0) return const SizedBox.shrink();

                  // পার্সেন্টেজ হিসাব
                  final double upPct = (up / total) * 100;
                  final double ucPct = (uc / total) * 100;
                  final double downPct = (down / total) * 100;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.sn ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textColor),
                      ),
                      const SizedBox(height: 8),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 10, // বারের হাইট
                          child: Row(
                            children: [
                              if (up > 0)
                                Expanded(
                                  flex: up,
                                  child: Container(color: hexToColor('#22C665')),
                                ),
                              if (uc > 0)
                                Expanded(
                                  flex: uc,
                                  child: Container(color: hexToColor('#177DFF')),
                                ),
                              if (down > 0)
                                Expanded(
                                  flex: down,
                                  child: Container(color: hexToColor('#F54D64')),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLegendItem('Adv', upPct, hexToColor('#22C665'), context),
                          _buildLegendItem('Unch', ucPct, hexToColor('#177DFF'), context),
                          _buildLegendItem('Dec', downPct, hexToColor('#F54D64'), context),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 🚀 নিচে দেখানোর জন্য কাস্টম লেবেল উইজেট
  Widget _buildLegendItem(String title, double pct, Color color, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            text: '$title ',
            style: TextStyle(fontSize: 11, color: context.textColor.withOpacity(0.7)),
            children: [
              TextSpan(
                text: '${pct.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
