import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app_pkg.dart'; // context.isDark এর জন্য

class IndexListLoader extends StatelessWidget {
  const IndexListLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = context.isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // 🚀 Fake Header
          Container(
            decoration: BoxDecoration(
              border: const Border(bottom: BorderSide(color: Colors.black26)),
              color: context.isDark ? hexToColor('#161A33') : ColorConstants.yaleBlue,
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 14,
                    width: 150, // "Last update on..." টেক্সটের আনুমানিক সাইজ
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
              ],
            ),
          ),
          // 🚀 Fake Rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4, // ইনডেক্সে সাধারণত ৪টি আইটেম থাকে (DSEX, DSES, DS30, DSMEX)
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: context.isDark ? hexToColor('#161A33') : null,
                  border: Border(bottom: BorderSide(color: context.borderSideColor, width: 1)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    // Index Name
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Shimmer.fromColors(
                          baseColor: baseColor,
                          highlightColor: highlightColor,
                          child: Container(height: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    // Value
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Shimmer.fromColors(
                          baseColor: baseColor,
                          highlightColor: highlightColor,
                          child: Container(height: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    // Change
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Shimmer.fromColors(
                          baseColor: baseColor,
                          highlightColor: highlightColor,
                          child: Container(height: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    // Change %
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Shimmer.fromColors(
                          baseColor: baseColor,
                          highlightColor: highlightColor,
                          child: Container(height: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    // Icon
                    SizedBox(
                      width: 30,
                      child: Center(
                        child: Shimmer.fromColors(
                          baseColor: baseColor,
                          highlightColor: highlightColor,
                          child: Container(height: 14, width: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
