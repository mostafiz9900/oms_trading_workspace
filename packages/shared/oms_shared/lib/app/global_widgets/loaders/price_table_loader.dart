import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app_pkg.dart'; // context.isDark এর জন্য

class PriceTableLoader extends StatelessWidget {
  const PriceTableLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = context.isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Days Selector Skeleton ---
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Row(
                children: [
                  Container(
                    width: 120,
                    height: 30,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. Stats Grid Skeleton (6 items) ---
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.0,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 50, height: 10, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(width: 40, height: 14, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- 3. Table Header & Rows Skeleton ---
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                children: [
                  // Table Header Row
                  Container(height: 40, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 8),
                  // Table Data Rows
                  ...List.generate(
                    8,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(height: 36, width: double.infinity, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
