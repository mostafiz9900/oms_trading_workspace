import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/utils/extensions/app_context.dart';

class CartesianChartLoader extends StatelessWidget {
  final String title;
  const CartesianChartLoader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // 🚀 থিম অনুযায়ী শিমার কালার
    final baseColor = context.isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final highlightColor = context.isDark ? Colors.grey.shade700 : Colors.grey.shade50;

    final shapeColor = Colors.white;

    return Container(
      height: 320, // চার্টের স্ট্যান্ডার্ড হাইট
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Get.theme.dividerColor.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 140,
                  height: 16,
                  decoration: BoxDecoration(color: shapeColor, borderRadius: BorderRadius.circular(4)),
                ),
                Container(
                  width: 50,
                  height: 12,
                  decoration: BoxDecoration(color: shapeColor, borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🚀 2. Chart Area with Gridlines & Bars
            Expanded(
              child: Stack(
                children: [
                  // --- Background Gridlines ---
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      return Container(height: 1, width: double.infinity, color: shapeColor.withOpacity(0.5));
                    }),
                  ),

                  // --- Foreground Bars ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar(120, shapeColor),
                        _buildBar(180, shapeColor),
                        _buildBar(90, shapeColor),
                        _buildBar(210, shapeColor),
                        _buildBar(150, shapeColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                return Container(
                  width: 30,
                  height: 8,
                  decoration: BoxDecoration(color: shapeColor, borderRadius: BorderRadius.circular(2)),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // 🚀 বার বানানোর ছোট হেল্পার মেথড
  Widget _buildBar(double height, Color color) {
    return Container(
      width: 24, // বারের সাইজ একটু স্লিক করা হয়েছে
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}
