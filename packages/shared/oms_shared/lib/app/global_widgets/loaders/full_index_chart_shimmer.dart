import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/utils/extensions/app_context.dart';

class FullIndexChartShimmer extends StatelessWidget {
  const FullIndexChartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDark;
    final Color baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final Color highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🚀 Header Shimmer
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 50, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 10),
                        Container(width: 80, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(width: 110, height: 18, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  ],
                ),
                // Right Toggle Box
                Container(
                  width: 150, 
                  height: 32, 
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 🚀 Chart Area Shimmer
          Container(
            height: 280,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 12, right: 12, top: 20, bottom: 10),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      final List<double> heights = [70.0, 110.0, 60.0, 130.0, 80.0, 140.0, 100.0];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 14,
                            height: heights[index],
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 18,
                            height: heights[index] * 0.25, 
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                Container(height: 1.5, width: double.infinity, color: Colors.white),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    return Container(
                      height: 10,
                      width: 35,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
