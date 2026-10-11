import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/utils/extensions/app_context.dart';

class TimeSalesListLoader extends StatelessWidget {
  const TimeSalesListLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = context.isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: index % 2 != 0 ? context.evenColor : context.oddColor,
              border: Border(bottom: BorderSide(color: context.dividerColor.withAlpha(25), width: 0.5)),
            ),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time Skeleton
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 14,
                      width: 60,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                  // Price Skeleton
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 14,
                      width: 40,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                  // Volume Skeleton
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        height: 14,
                        width: 40,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                  ),
                  // Side Skeleton
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 14,
                        width: 30,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: 12, // স্ক্রিনে দেখানোর জন্য ১২টি শিমার রো
      ),
    );
  }
}
