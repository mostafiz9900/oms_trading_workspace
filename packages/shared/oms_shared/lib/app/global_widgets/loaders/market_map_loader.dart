import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../app_pkg.dart'; // context.isDark এর জন্য

class MarketMapLoader extends StatelessWidget {
  final double height;
  const MarketMapLoader({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = context.isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Container(
      constraints: BoxConstraints(minHeight: height, maxHeight: height, maxWidth: double.infinity),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(color: Get.theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(6)),
      child: Column(
        children: [
          // Fake Header
          SizedBox(
            height: 38,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: context.tapBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(width: 120, height: 14, color: Colors.white),
                  ),
                  Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(width: 70, height: 10, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          // Fake Treemap Grid Skeletons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: 12, // ১২টি মক বক্স গ্রিডের জন্য
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
