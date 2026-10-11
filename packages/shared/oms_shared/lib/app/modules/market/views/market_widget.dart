
import 'package:oms_shared/app/modules/market/controllers/live_index_controller.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '/app/modules/market/views/local_widgets/watchlist_distribution_page.dart';
import '../../../core/utils/extensions/app_context.dart';
import '../../../core/utils/helpers/log_helper.dart';
import '../../../core/values/app_config.dart';
import '../../../core/values/assets.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/space.dart';
import '../../../data/models/response/index_model.dart';
import '../../../global_widgets/custom_app_bar.dart';
import '../../../global_widgets/custom_drawer.dart';
import '../../global_search/controllers/global_search_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../../routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'local_widgets/home_pie_chart.dart';
import 'local_widgets/sector_horizontal_list.dart';
import 'local_widgets/top_sector_by_category_widget.dart';
import 'local_widgets/top_sector_by_gainer_widget.dart';

import 'local_widgets/market_index_list_widget.dart';
import 'local_widgets/market_treemap.dart';
import 'local_widgets/index_chart_widget.dart';
import 'local_widgets/notification_icon.dart';
import 'local_widgets/call_now_widget.dart';
import 'local_widgets/market_activity_chart.dart';
import 'local_widgets/market_sentiment_ratio_chart.dart';
import 'local_widgets/clickable_marquee_text_list.dart';
import '../../../global_widgets/loaders/index_value_loader.dart';

class MarketWidget extends StatelessWidget {
  const MarketWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return SafeArea(
      child: Column(
        children: [
          const CallNowWidget(),

          Expanded(
            child: Scaffold(
              key: scaffoldKey,
              drawer: CustomDrawer(),
              appBar: CustomAppBar(
                backButtonOnClick: () {
                  final state = scaffoldKey.currentState;
                  if (state == null) return; // safe-guard

                  if (state.isDrawerOpen) {
                    state.openEndDrawer();
                  } else {
                    state.openDrawer();
                  }
                },
                right: GetBuilder<HomeController>(
                  builder: (homeNotifyCont) {
                    return Row(
                      children: [
                        NotificationIcon(
                          notificationCount: 0, //homeNotifyCont.news.length,
                          onTap: () {
                            Get.toNamed(Routes.ORDER_ALERT);
                          },
                        ),
                        IconButton(
                          onPressed: () async {
                            final result = await SearchHelper.open();

                            if (result != null) {
                              print("Selected Market: ${result.shortName}");
                              print("Selected Market to map: ${result.toJson()}");
                              if (result.orderBook != null && result.shortName != null) {
                                homeNotifyCont.goBottomNabBarPage(1, result.orderBook!);
                              }
                            }
                          },
                          icon: SvgPicture.asset(
                            AssetsConstants.searchIconSvg,
                            width: 18,
                            height: 18,
                            colorFilter: ColorFilter.mode(context.textColor, BlendMode.srcIn),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              body: SizedBox(
                child: _BodyWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyWidget extends StatelessWidget {
  const _BodyWidget();

  @override
  Widget build(BuildContext context) {
    // ১. GetBuilder এর বদলে সরাসরি কন্ট্রোলার ফাইন্ড করে নিন
    final homeCon = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSpace.spaceH6,

        ClickableMarqueeTextList(homeCon: homeCon),

        // শুধুমাত্র তাকে আলাদাভাবে GetBuilder দিয়ে র‍্যাপ করুন।
        GetBuilder<HomeController>(
          id: 'indexList', // অথবা 'marketList', আপনার যেটা প্রয়োজন
          builder: (con) {
            return const _CustomTabWidget();
          },
        ),
      ],
    );
  }
}

class _CustomTabWidget extends HookWidget {
  const _CustomTabWidget();

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 3);

    return Expanded(
      child: Column(
        children: [
          Container(
            color: context.tapCustomBgColor,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            child: TabBar(
              controller: tabController, // 🚀 হুকস এর কন্ট্রোলার
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: context.textColor,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              indicator: BoxDecoration(borderRadius: BorderRadius.circular(0), color: ColorConstants.buttonColorLight),
              onTap: (index) {
                if (index == 1) {
                  // "Top Stocks" এ ক্লিক করলে নতুন পেজে যাবে
                  Get.toNamed(Routes.TOP_SHARE, arguments: 'Gainer');

                  // 🚀 ইউজার ব্যাক করে আসলে যেন আগের ট্যাবেই থাকে
                  tabController.index = tabController.previousIndex;
                }
              },
              tabs: const [
                Tab(text: "Market"),
                Tab(text: "Top Stocks"),
                Tab(text: "Indices"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController, // 🚀 হুকস এর কন্ট্রোলার
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MarketTabWidget(),
                const Icon(Icons.directions_transit, size: 10), // ডামি আইটেম
                _IndicesTabWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketTabWidget extends StatelessWidget {
  const _MarketTabWidget();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        printLog('refresh :::=== refreshSocket ${AppConfig.indexSocketId}');
        await Get.find<HomeController>().refreshIndex();
      },
      child: ListView(
        children: [
          TradeSummaryGridWidget(),
          MarketIndexListWidget(),
          IndexChartWidget(), //lastly added
          AppSpace.spaceH10,
          const TopSectorByGainerWidget(),
          const TopSectorByCategoryWidget(),
          AppSpace.spaceH10,
          ProSectorHorizontalList(),

          WatchlistDistributionPage(),

          MarketMapWidget(),
          AppSpace.spaceH20,

        ],
      ),
    );
  }
}

class _IndicesTabWidget extends StatelessWidget {
  const _IndicesTabWidget();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TradeSummaryGridWidget(),
        MarketIndexListWidget(),
        GetBuilder<LiveIndexController>(
          builder: (indexController) {
            if (indexController.indexList.isEmpty) {
              return const IndexValueLoader();
            } else {
              return Column(
                children: [
                  AppSpace.spaceH10,
                  _buildChart(context, indexController),
                  const HomePieChart(),
                  MarketActivityChart(),
                  MarketSentimentRatioChart(),
                  AppSpace.spaceH6,
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext ctx, LiveIndexController controller) {
    final selectedData = controller.selectedIndexData;
    if (selectedData == null) {
      return const SizedBox(height: 300, child: Center(child: Text('')));
    }

    final chartData = [selectedData];
    final double civ = selectedData.civ?.toDouble() ?? 0.0;
    final double ivd = selectedData.ivd?.toDouble() ?? 0.0;
    final double difference = civ - ivd; // Yesterday's Value

    // 🚀 কালার লজিক সহজ ও নিখুঁত করা হয়েছে
    final bool isUpToday = ivd >= 0;
    final Color todayColor = isUpToday ? hexToColor('#22C665') : hexToColor('#F54D64');
    final Color yesterdayColor = hexToColor('#177DFF');

    return InkWell(
      onTap: () {
        printLog('Chart tapped for ${controller.selectedIndexData?.toJson()}');
        // এখানে আপনি চাইলে আরও বিস্তারিত চার্ট বা ডেটা দেখানোর জন্য নতুন পেজে নেভিগেট করতে পারেন
      },
      child: Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: ctx.cardColor, // 🚀 ব্যাকগ্রাউন্ড কালার ডাইনামিক
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ctx.borderSideColor.withOpacity(0.5)),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0, // 🚀 চার্টের ভেতরের চারপাশের বর্ডার লাইন রিমুভ করা হয়েছে
          title: ChartTitle(
            text: '${controller.selectedSn} Analysis',
            textStyle: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: ctx.textColor,
            ),
          ),
          legend: Legend(
            isVisible: true,
            position: LegendPosition.top,
            overflowMode: LegendItemOverflowMode.wrap,
            textStyle: TextStyle(color: ctx.textColor, fontWeight: FontWeight.w500), // 🚀 লিজেন্ড টেক্সট কালার
          ),
          primaryXAxis: CategoryAxis(
            majorGridLines: const MajorGridLines(width: 0), // 🚀 X-অক্ষের গ্রিডলাইন হাইড
            axisLine: const AxisLine(width: 0), // 🚀 X-অক্ষের মূল লাইন হাইড
            labelStyle: TextStyle(fontWeight: FontWeight.w600, color: ctx.textColor),
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(
              text: 'Index Value',
              textStyle: TextStyle(fontSize: 12, color: ctx.textColor.withOpacity(0.6)),
            ),
            numberFormat: NumberFormat('#,##0.00'),
            minimum: null,
            maximum: null,
            axisLine: const AxisLine(width: 0),
            // 🚀 প্রফেশনাল ড্যাশড (Dashed) গ্রিডলাইন যুক্ত করা হয়েছে
            majorGridLines: MajorGridLines(
              width: 1,
              dashArray: const <double>[5, 5],
              color: ctx.dividerColor.withOpacity(0.4),
            ),
            labelStyle: TextStyle(fontWeight: FontWeight.w500, color: ctx.textColor.withOpacity(0.8)),
          ),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
              // 🚀 ডার্ক এবং লাইট মোড সাপোর্টেড কাস্টম টুলটিপ
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: ctx.isDark ? Colors.grey.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3)),
                  ],
                ),
                child: Text(
                  '${series.name}: ${point.y.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: ctx.isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
          series: <CartesianSeries<IndexModel, String>>[
            ColumnSeries<IndexModel, String>(
              name: 'Yesterday',
              dataSource: chartData,
              xValueMapper: (IndexModel data, _) => data.sn ?? '',
              yValueMapper: (IndexModel data, _) => difference,
              color: yesterdayColor,
              width: 0.5,
              spacing: 0.2, // 🚀 কলামগুলোর মাঝের দূরত্ব ঠিক করা হয়েছে
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), // 🚀 কলামের মাথা রাউন্ড করা হয়েছে
            ),
            ColumnSeries<IndexModel, String>(
              name: 'Today',
              dataSource: chartData,
              xValueMapper: (IndexModel data, _) => data.sn ?? '',
              yValueMapper: (IndexModel data, _) => civ,
              color: todayColor,
              width: 0.5,
              spacing: 0.2,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), // 🚀 কলামের মাথা রাউন্ড করা হয়েছে
            ),
          ],
        ),
      ),
    );
  }
}

// IndexChartPoint এবং LiveIndexController ইমপোর্ট করুন
