import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/utils/extensions/app_context.dart';

class IndexValueLoader extends StatelessWidget {
  const IndexValueLoader({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚀 ডার্ক এবং লাইট মোডের জন্য আলাদা কালার সেটআপ
    final baseColor = context.isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = context.isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 6, // 🚀 আসল গ্রিডের সাথে মিল রেখে
      crossAxisSpacing: 10, // 🚀 আসল গ্রিডের সাথে মিল রেখে
      shrinkWrap: true,
      childAspectRatio: 2.1, // 🚀 আসল গ্রিডের সাইজের সাথে হুবহু মিলানো হলো (UI Jump করবে না)
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      children: List.generate(6, (index) {
        // 🚀 কোড রিপিট না করে List.generate ব্যবহার করা হলো
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Shimmer এর জন্য সলিড কালার দিতে হয়
              borderRadius: BorderRadius.circular(6), // 🚀 কার্ডের মতো সুন্দর রাউন্ডেড কর্নার
            ),
          ),
        );
      }),
    );
  }
}
