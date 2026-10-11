import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app_pkg.dart'; // context.isDark এর জন্য

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

class CartesianChartLoader extends StatelessWidget {
  final String title;
  const CartesianChartLoader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // 🚀 থিম অনুযায়ী শিমার কালার
    final baseColor = context.isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final highlightColor = context.isDark ? Colors.grey.shade700 : Colors.grey.shade50;

    // শিমারের ভেতরের শেপগুলোর কালার (যেকোনো সলিড কালার দিলেই হবে, শিমার এটা ওভাররাইট করবে)
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
            // 🚀 1. Header (Title & Legend Placeholder)
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

            // 🚀 3. X-Axis Labels Placeholder (DSEX, DS30 etc.)
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
      separatorBuilder: (_, __) => Divider(height: 1, color: context.dividerColor),
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

class PositionLoader extends StatelessWidget {
  const PositionLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = context.isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          children: [
            // --- 1. Top Summary Dashboard Skeleton ---
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 65,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 12),

            // --- 2. Header Filter Row Skeleton ---
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 90, height: 16, color: Colors.white),
                  Container(
                    width: 80,
                    height: 28,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- 3. Table Header Skeleton ---
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 40,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 8),

            // --- 4. Table Rows Skeleton (8 items) ---
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                children: List.generate(
                  8,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderListLoader extends StatelessWidget {
  const OrderListLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = context.isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return ListView.builder(
      itemCount: 8, // স্ক্রিনে দেখানোর জন্য ৮টি শিমার কার্ড
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: context.tapBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.borderSideColor.withOpacity(0.4)),
          ),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Col 1: Symbol & Time Skeleton
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 90,
                        height: 14,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 45,
                        height: 10,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Col 2: Qty & Price Skeleton
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 45,
                        height: 12,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 35,
                        height: 10,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 40,
                        height: 10,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Col 3: Status Skeleton
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 50,
                        height: 12,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 65,
                        height: 10,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
