import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/utils/extensions/app_context.dart';

class DistributionChartLoader extends StatelessWidget {
  const DistributionChartLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = context.isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(6)),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(width: 140, height: 16, color: Colors.white),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(8, (index) {
                  return Container(
                    width: 22,
                    height: 120.0 + (index * 15) % 100,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
