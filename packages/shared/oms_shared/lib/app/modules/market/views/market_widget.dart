import 'dart:async';

import 'package:oms_shared/app/modules/market/controllers/live_index_controller.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '/app/modules/market/views/local_widgets/watchlist_distribution_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/app/app_pkg.dart';
import '/app/data/models/marquee_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controllers/clock_controller.dart';
import 'local_widgets/home_pie_chart.dart';
import 'local_widgets/sector_horizontal_list.dart';
import 'local_widgets/top_sector_by_category_widget.dart';
import 'local_widgets/top_sector_by_gainer_widget.dart';
import '../../../global_widgets/index_value_loader.dart';

import 'local_widgets/market_index_list_widget.dart';
import 'local_widgets/market_treemap.dart';
import 'local_widgets/index_chart_widget.dart';

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

class NotificationIcon extends StatelessWidget {
  final int notificationCount;
  final VoidCallback onTap;

  const NotificationIcon({super.key, required this.notificationCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 🔔 Notification Icon Button
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, size: 30, color: context.textColor),
          onPressed: onTap,
        ),

        // 🔴 Notification Count Badge
        if (notificationCount > 0)
          Positioned(
            right: 6,
            top: 4,
            child: Container(
              padding: const .all(2),
              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$notificationCount',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
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

class ChartData {
  ChartData(this.dateTime, this.x, this.y1, this.y2, this.y3, this.y4, this.y5);

  final DateTime dateTime;
  final String x;
  final double y1;
  final double y2;
  final double y3;
  final double y4;
  final double y5;
}

class CallNowWidget extends ConsumerWidget {
  const CallNowWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeCon = Get.find<HomeController>();
    final timeAsync = ref.watch(clockProvider);
    return Container(
      width: Get.width,
      height: 25,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Get.isDarkMode ? ColorConstants.primaryColorDark : ColorConstants.primaryColor),
      child: Padding(
        padding: const .symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            timeAsync.when(
              data: (time) {
                final formattedTime = DateFormat('EEE, dd MMM, yy,  hh:mm:ss a').format(time);
                return Text(
                  formattedTime,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: ColorConstants.white,
                    fontSize: AppDimens.space12,
                    fontWeight: FontWeight.w400,
                  ),
                );
              },
              loading: () => SizedBox(),
              error: (e, _) => Text('Error: $e'),
            ),
            Obx(() {
              return Text(
                homeCon.currentSession.value == ''
                    ? ""
                    : homeCon.currentSession.value.split('_').join(' ').toCapitalize(),
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: homeCon.currentSession.value == ''
                      ? ColorConstants.white
                      : homeCon.currentSession.value.split('_').join(' ').toCapitalize() ==
                            "Continuous" //Continuous
                      ? ColorConstants.success
                      : ColorConstants.redColor, //Auction
                  fontSize: AppDimens.space12,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),

          ],
        ),
      ),
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

class MarketActivityChart extends StatelessWidget {
  const MarketActivityChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveIndexController>(
      builder: (controller) {
        final chartData = controller.visibleIndexList;

        if (chartData.isEmpty) {
          return const SizedBox(height: 250, child: Center(child: Text("No activity data available")));
        }

        return Container(
          height: 320,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.isDark ? hexToColor('#161A33') : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderSideColor.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚀 1. Premium Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Market Activity (Value vs Trades)',
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 🚀 2. Dual-Axis Chart
              Expanded(
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  margin: EdgeInsets.zero,
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    iconHeight: 12,
                    iconWidth: 12,
                    textStyle: TextStyle(color: context.textColor, fontWeight: FontWeight.w600, fontSize: 11),
                  ),

                  // 🚀 X-অক্ষ
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 0),
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, color: context.textColor, fontSize: 11),
                  ),

                  primaryYAxis: NumericAxis(
                    name: 'PrimaryYAxis',
                    title: AxisTitle(
                      text: 'Turnover (Cr)',
                      textStyle: TextStyle(
                        fontSize: 10,
                        color: context.textColor.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    majorGridLines: MajorGridLines(
                      width: 1,
                      dashArray: const <double>[4, 4], // স্লিক ড্যাশড লাইন
                      color: context.dividerColor.withOpacity(0.2),
                    ),
                    axisLine: const AxisLine(width: 0),
                    labelFormat: '{value}',
                    labelStyle: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold, fontSize: 10),
                  ),

                  // 🚀 Secondary Y-অক্ষ (ডান দিকে): Trades
                  axes: <ChartAxis>[
                    NumericAxis(
                      name: 'SecondaryYAxis',
                      opposedPosition: true,
                      title: AxisTitle(
                        text: 'Trades',
                        textStyle: TextStyle(
                          fontSize: 10,
                          color: context.textColor.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLine: const AxisLine(width: 0),
                      labelFormat: '{value}k',
                      labelStyle: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ],

                  // 🚀 Professional Shared Tooltip
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    shared: true,
                    color: context.isDark ? hexToColor('#1E2336') : Colors.grey.shade900,
                    textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                    elevation: 5,
                    shadowColor: Colors.black45,
                    format: 'point.series.name: point.y',
                  ),

                  series: <CartesianSeries>[
                    ColumnSeries<dynamic, String>(
                      name: 'Turnover (Cr)',
                      dataSource: chartData,
                      xValueMapper: (dynamic data, _) => data.sn ?? '',
                      yValueMapper: (dynamic data, _) {
                        final double vl = data.vl?.toDouble() ?? 0.0;
                        return vl / 10000000;
                      },
                      // 🚀 সলিড কালারের বদলে ফিনটেক স্টাইলের গ্রেডিয়েন্ট
                      gradient: LinearGradient(
                        colors: [
                          hexToColor('#177DFF'), // ডিপ ব্লু
                          hexToColor('#177DFF').withOpacity(0.5), // লাইট ব্লু
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      width: 0.45,
                      animationDuration: 0, // লাইভ ফিল্টারের জন্য ০
                    ),

                    SplineSeries<dynamic, String>(
                      name: 'Trades (K)',
                      dataSource: chartData,
                      yAxisName: 'SecondaryYAxis',
                      xValueMapper: (dynamic data, _) => data.sn ?? '',
                      yValueMapper: (dynamic data, _) {
                        final int tds = data.tds ?? 0;
                        return tds / 1000;
                      },
                      color: Colors.amber.shade600, // প্রিমিয়াম গোল্ডেন/অ্যাম্বার কালার
                      width: 2.5, // লাইন একটু স্লিক করা হয়েছে
                      animationDuration: 0,
                      // 🚀 মার্কারগুলোকে ছোট ও শার্প করা হয়েছে
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        color: context.cardColor,
                        borderWidth: 2,
                        borderColor: Colors.amber.shade600,
                        width: 6,
                        height: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MarketSentimentRatioChart extends StatelessWidget {
  const MarketSentimentRatioChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveIndexController>(
      builder: (indexCon) {
        final visibleIndices = indexCon.visibleIndexList;

        if (visibleIndices.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.isDark ? hexToColor('#161A33') : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderSideColor.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚀 1. Header with Blinking "LIVE" Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Market Sentiment',
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleIndices.length,
                separatorBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                itemBuilder: (context, index) {
                  final data = visibleIndices[index];
                  final int up = data.u ?? 0;
                  final int down = data.d ?? 0;
                  final int uc = data.uc ?? 0;
                  final int total = up + down + uc;

                  // যদি কোনো ডেটা না থাকে
                  if (total == 0) return const SizedBox.shrink();

                  // পার্সেন্টেজ হিসাব
                  final double upPct = (up / total) * 100;
                  final double ucPct = (uc / total) * 100;
                  final double downPct = (down / total) * 100;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.sn ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textColor),
                      ),
                      const SizedBox(height: 8),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 10, // বারের হাইট
                          child: Row(
                            children: [
                              if (up > 0)
                                Expanded(
                                  flex: up,
                                  child: Container(color: hexToColor('#22C665')),
                                ),
                              if (uc > 0)
                                Expanded(
                                  flex: uc,
                                  child: Container(color: hexToColor('#177DFF')),
                                ),
                              if (down > 0)
                                Expanded(
                                  flex: down,
                                  child: Container(color: hexToColor('#F54D64')),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLegendItem('Adv', upPct, hexToColor('#22C665'), context),
                          _buildLegendItem('Unch', ucPct, hexToColor('#177DFF'), context),
                          _buildLegendItem('Dec', downPct, hexToColor('#F54D64'), context),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 🚀 নিচে দেখানোর জন্য কাস্টম লেবেল উইজেট
  Widget _buildLegendItem(String title, double pct, Color color, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            text: '$title ',
            style: TextStyle(fontSize: 11, color: context.textColor.withOpacity(0.7)),
            children: [
              TextSpan(
                text: '${pct.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ClickableMarqueeTextList extends StatefulWidget {
  final HomeController homeCon;

  const ClickableMarqueeTextList({super.key, required this.homeCon});

  @override
  _ClickableMarqueeTextListState createState() => _ClickableMarqueeTextListState();
}

class _ClickableMarqueeTextListState extends State<ClickableMarqueeTextList> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  bool _isScrolling = true;
  bool _onScreen = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScroll());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pause the auto-scroll while the Market tab is hidden or another page
    // covers it (the timer used to run 33 times a second all session); it
    // resumes from the same spot when visible again.
    final onScreen = Visibility.of(context) && TickerMode.valuesOf(context).enabled;
    if (onScreen == _onScreen) return;
    _onScreen = onScreen;
    if (!onScreen) {
      _scrollTimer?.cancel();
    } else if (_isScrolling) {
      _autoScroll();
    }
  }

  void _autoScroll() async {
    _isScrolling = true;
    _scrollTimer?.cancel();
    if (!_onScreen) return;
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      // ✅ Ensure controller is attached
      if (!_scrollController.hasClients || !_isScrolling) return;

      final position = _scrollController.position;
      if (!position.hasPixels) return; // safety check

      try {
        if (_scrollController.offset >= position.maxScrollExtent) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(_scrollController.offset + 1);
        }
      } catch (e) {
        debugPrint("Auto-scroll error: $e");
      }
    });
  }

  void _onTextTap(MarqueeHolder marqueeHolder) {
    toggleScroll();
  }

  void stopScroll() {
    _isScrolling = false;
    _scrollTimer?.cancel();
  }

  void toggleScroll() {
    if (_isScrolling) {
      stopScroll();
    } else {
      _autoScroll();
    }
    setState(() {}); // Refresh button icon
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildItem(MarqueeHolder marqueeHolder) {
    return GestureDetector(
      onTap: () => _onTextTap(marqueeHolder),
      child: Container(
        color: context.bgColor,
        padding: const .symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            Icon(
              marqueeHolder.status == "Up"
                  ? Icons.arrow_upward_sharp
                  : marqueeHolder.status == "Down"
                  ? Icons.arrow_downward_sharp
                  : Icons.swap_vert,

              color: marqueeHolder.status == "Up"
                  ? Colors.green
                  : marqueeHolder.status == "Down"
                  ? Colors.redAccent
                  : context.textColor,
              size: 20,
            ),
            AppSpace.spaceW2,
            Column(
              mainAxisAlignment: .start,
              crossAxisAlignment: .start,
              children: [
                Text(
                  marqueeHolder.shortName ?? "",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textColor),
                ),

                Text(
                  marqueeHolder.chg?.toStringAsFixed(2) ?? "0",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getColorForValue('${marqueeHolder.chg ?? 0.0}'),
                  ),
                ),
              ],
            ),
            AppSpace.spaceW6,
            Column(
              mainAxisAlignment: .start,
              crossAxisAlignment: .start,
              children: [
                Text(
                  marqueeHolder.last?.toStringAsFixed(2) ?? "0",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getColorForValue('${marqueeHolder.chg ?? 0.0}'),
                    //     ? Colors.green
                    //     : marqueeHolder.status == "Down"
                    //     ? Colors.redAccent
                  ),
                ),
                Text(
                  '${marqueeHolder.d?.toStringAsFixed(2) ?? "0"}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getColorForValue('${marqueeHolder.d ?? 0.0}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForValue(String value) {

    // Handle "+" and "-" signs explicitly
    if (value.startsWith('+')) {
      return Colors.green;
    }
    if (value.startsWith('-')) {
      return Colors.red;
    }

    // Try to parse the value as a double
    double? numValue = double.tryParse(value);
    if (numValue != null) {
      // Handle the zero case separately if needed
      if (numValue > 0) {
        return Colors.green;
      } else if (numValue < 0) {
        return Colors.red;
      } else {
        // Handle exactly 0 (zero) as a neutral case
        return Colors.grey.shade400;
      }
    }

    // Fallback for invalid values (not numeric and not a + or -)
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return widget.homeCon.marqueeList == [] || widget.homeCon.marqueeList.isEmpty
        ? SizedBox.shrink()
        : RepaintBoundary(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.homeCon.marqueeList.length,
                // marqueeList is kept sorted by shortName in the controller.
                itemBuilder: (_, index) => _buildItem(widget.homeCon.marqueeList[index]),
              ),
            ),
          );
  }
}
