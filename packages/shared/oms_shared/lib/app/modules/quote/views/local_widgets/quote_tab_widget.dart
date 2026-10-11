

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/values/colors.dart';
import '../../../../data/models/response/news_model.dart';
import '../../../../global_widgets/visible_get_builder.dart';
import '../../../home/controllers/home_controller.dart';
import 'candle_series_charts.dart';
import 'related_item_watchlist.dart';
import 'market_depth_single_widget.dart';
import 'quote_top_details_section.dart';
import 'news_item_widget.dart';

class QuoteTabWidget extends StatelessWidget {
  const QuoteTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // ১. Top Header Section
            SliverToBoxAdapter(
              child: VisibleGetBuilder<HomeController>(
                id: 'marketList',
                builder: (homeCon) => QuoteTopDetailsSection(homeCon: homeCon),
              ),
            ),
            SliverToBoxAdapter(
              child: VisibleGetBuilder<HomeController>(
                id: 'marketList',
                builder: (homeCon) => RelatedItemWatchlist(
                  relatedMarketList: homeCon.getRelatedAssets(
                    homeCon.marketData,
                    homeCon.marketListAll,
                  ),
                  controller: homeCon,
                ),
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: context.textColor,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    color: ColorConstants.buttonColorLight,
                  ),
                  tabs: const [
                    Tab(text: "Market Depth"),
                    Tab(text: "News"),
                    Tab(text: "Chart"),
                    // Tab(text: "Financials"), // উদাহরণস্বরূপ
                  ],
                ),
                backgroundColor: context.tapBg, // ট্যাবের নিজস্ব ব্যাকগ্রাউন্ড
                gapColor: context
                    .bgColor, // 👈 গ্যাপের ব্যাকগ্রাউন্ড কালার (পেজের কালার)
                topGap: 6.0,
              ),
            ),
          ];
        },
        // ৩. Tab Views
        body: const TabBarView(
          children: [
            MarketDepthSingleWidget(),
            _NewsWidget(),
            CandleSeriesChartsWidget(),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. News Widget
// ==========================================
class _NewsWidget extends StatelessWidget {
  const _NewsWidget();

  @override
  Widget build(BuildContext context) {
    final dividerWidget = Divider(height: 1, color: context.dividerColor);

    return GetBuilder<HomeController>(
      id: "newsSingleItem",
      builder: (homeCon) {
        // 👈 FIX: যদি লিস্ট খালি থাকে, তাহলে লোডারের বদলে মেসেজ দেখাবে
        if (homeCon.newsSingleItem.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 40,
                    color: Colors.grey.withAlpha(128),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "No news available at the moment",
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // 👈 ডেটা থাকলে নরমালি লিস্ট দেখাবে
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: homeCon.newsSingleItem.length,
          separatorBuilder: (_, _) => dividerWidget,
          itemBuilder: (context, index) {
            final NewsModel model = homeCon.newsSingleItem[index];
            if (model.tl == null) {
              return const SizedBox.shrink();
            }
            return NewsItemWidget(model: model);
          },
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color backgroundColor;
  final Color gapColor;
  final double topGap;

  _SliverTabBarDelegate(
    this._tabBar, {
    required this.backgroundColor,
    required this.gapColor,
    this.topGap = 10.0, // ডিফল্ট গ্যাপ ১০ পিক্সেল
  });

  // 👈 ট্যাবের অরিজিনাল হাইট (40) এর সাথে গ্যাপের সাইজ যোগ করতে হবে
  @override
  double get minExtent => 40.0 + topGap;
  @override
  double get maxExtent => 40.0 + topGap;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: gapColor, // 👈 গ্যাপের জায়গাটি যেন পেজের কালার হয় (নাহলে স্ক্রল করার সময় পেছনের লেখা দেখা যাবে)
      child: Column(
        children: [
          SizedBox(height: topGap), // 👈 এখানেই সেই টপ গ্যাপটি তৈরি হবে
          Container(
            height: 40.0,
            width: double.infinity,
            color: backgroundColor, // 👈 এটি আপনার context.tapBg
            alignment: Alignment.centerLeft,
            child: _tabBar,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return oldDelegate.topGap != topGap ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.gapColor != gapColor;
  }
}
