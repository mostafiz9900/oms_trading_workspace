import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/utils/extensions/app_context.dart';

class WatchlistLoader extends StatelessWidget {
  const WatchlistLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = context.isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return ListView.separated(
      itemCount: 10, // স্ক্রিনে ১০টি শিমার রো দেখাবে
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, _) => Divider(height: 1, color: context.dividerColor),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // বাম পাশ: স্টক নেম ও ভলিউম/ভ্যালু প্লেসহোল্ডার
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 130,
                      height: 14,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 90,
                      height: 10,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                    ),
                  ],
                ),
                // ডান পাশ: প্রাইস ও পার্সেন্টেজ চেঞ্জ প্লেসহোল্ডার
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 65,
                      height: 14,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 50,
                      height: 12,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
