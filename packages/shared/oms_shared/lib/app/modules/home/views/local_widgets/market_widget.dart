import 'dart:async';
import 'dart:math';

import 'package:oms_shared/app/modules/home/controllers/live_index_controller.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../controllers/index_chart_controller.dart';
import '/app/modules/home/views/local_widgets/watchlist_distribution_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../notification_view.dart';
import '/app/app_pkg.dart';
import '/app/data/models/marquee_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../controllers/clock_controller.dart';
import 'historical/HomePieChart.dart';
import 'historical/SectorHorizontalList.dart';
import 'historical/TopSectorByCategoryWidget.dart';
import 'historical/TopSectorByGainerWidget.dart';
import 'index_value_loader.dart';

import 'market_index_list_widget.dart';
import 'market_treemap.dart';
import 'stock_heatmap/index_chart_widget.dart';

class StockInstrument {
  final int id;
  final String session;
  final String shortName;
  final String fullName;
  final String filterName;
  final String firmId;
  final String tradingState;
  final String shareType;
  final String marketType;
  final int orderbook;
  final DateTime date;
  final double lq;
  final double bq;
  final double aq;
  final double dl;
  final double dh;
  final double bid;
  final double ask;
  final double open;
  final double reference;
  final double last;
  final double volume;
  final double high;
  final double low;
  final double close;
  final double d;
  final double chg;
  final double settle1;
  final double settle;
  final String status;
  final double val;
  final double vwap;
  final int sellPending;
  final int buyPending;
  final String board;
  final String group;
  final String instrumentType;
  final String ticker;
  final String sector;
  final String isinCode;
  final int trades;
  final String lastTradeTime;
  final double wkLow52;
  final double wkHigh52;
  final double wkAvgVol1;
  final List<dynamic> orders;
  final List<dynamic> executedOrders;
  final String? streamId;

  StockInstrument({
    required this.id,
    required this.session,
    required this.shortName,
    required this.fullName,
    required this.filterName,
    required this.firmId,
    required this.tradingState,
    required this.shareType,
    required this.marketType,
    required this.orderbook,
    required this.date,
    required this.lq,
    required this.bq,
    required this.aq,
    required this.dl,
    required this.dh,
    required this.bid,
    required this.ask,
    required this.open,
    required this.reference,
    required this.last,
    required this.volume,
    required this.high,
    required this.low,
    required this.close,
    required this.d,
    required this.chg,
    required this.settle1,
    required this.settle,
    required this.status,
    required this.val,
    required this.vwap,
    required this.sellPending,
    required this.buyPending,
    required this.board,
    required this.group,
    required this.instrumentType,
    required this.ticker,
    required this.sector,
    required this.isinCode,
    required this.trades,
    required this.lastTradeTime,
    required this.wkLow52,
    required this.wkHigh52,
    required this.wkAvgVol1,
    required this.orders,
    required this.executedOrders,
    this.streamId,
  });
}

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
                                homeNotifyCont.tradingChart();
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

class OnlineMarketDataModel {
  const OnlineMarketDataModel({required this.country, required this.sellerName, required this.visitorsInBillions});
  final String country;
  final String sellerName;
  final double visitorsInBillions;
}

class UpcomingEventWidget extends StatelessWidget {
  const UpcomingEventWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(8.0),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text('Upcoming Events', style: Get.textTheme.headlineSmall),
          AppSpace.spaceH20,
          Row(
            crossAxisAlignment: .start,
            mainAxisAlignment: .start,
            children: [
              Container(
                width: 46,
                height: 43,
                padding: const .all(10),
                decoration: BoxDecoration(
                  color: ColorConstants.buttonColorLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SvgPicture.asset(AssetsConstants.alertIconSvg, width: 20, height: 23),
              ),
              AppSpace.spaceW8,
              Flexible(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Contact -temporary download of banking Operation for llc bank',
                      style: Get.textTheme.bodyLarge?.copyWith(),
                    ),
                    AppSpace.spaceH6,
                    Text('2 days Ago', style: Get.textTheme.bodySmall?.copyWith()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({super.key, required this.index, this.extent, this.width, this.backgroundColor, this.bottomSpace});

  final int index;
  final double? extent;
  final double? width;
  final double? bottomSpace;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      color: backgroundColor ?? Colors.red,
      height: extent,
      width: width,
      child: Center(child: Text('$index', style: const TextStyle(fontSize: 20))),
    );

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(height: bottomSpace, color: Colors.green),
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

class _CustomCardWidget extends StatelessWidget {
  const _CustomCardWidget({
    super.key,
    required this.color,
    required this.title,
    required this.subtitle,
    this.active,
    this.onClick,
  });

  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onClick;
  final bool? active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        child: Column(
          crossAxisAlignment: .center,
          mainAxisAlignment: .center,
          children: [
            Text(title, style: Get.textTheme.labelLarge?.copyWith(color: ColorConstants.white)),
            Text(subtitle, style: Get.textTheme.labelLarge?.copyWith(color: ColorConstants.white)),
          ],
        ),
      ),
    );
  }
}

class CallNowWidget extends ConsumerWidget {
  const CallNowWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clockController = Get.put(ClockController());
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
  const _CustomTabWidget({super.key});

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
  const _IndicesTabWidget({super.key});

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

  Widget _buildTabButtons(BuildContext ctx, LiveIndexController controller) {
    if (controller.indexList.isEmpty) return const SizedBox.shrink();
    final isDark = ctx.isDark;
    return Container(
      height: 44, // পুরো বার-টির একটি স্ট্যান্ডার্ড হাইট
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(4), // ভেতরের বাটনগুলোকে একটু জায়গা দেওয়ার জন্য
      decoration: BoxDecoration(
        color: ctx.tapBg,
        borderRadius: BorderRadius.circular(16), // বাইরের ট্র্যাকের বর্ডার রেডিয়াস
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: controller.availableSns.map((sn) {
            final isSelected = sn == controller.selectedSn;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                controller.selectSn(sn);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic, // স্মুথ কালার ট্রানজিশনের জন্য
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? ColorConstants.buttonColorDark : ColorConstants.buttonColorLight)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]
                      : [], // আনসিলেক্টেড বাটনে কোনো শ্যাডো থাকবে না
                ),
                child: Center(
                  child: Text(
                    sn,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Colors.white : (ctx.isDark ? Colors.white70 : Colors.grey.shade700),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
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

class MarketBreadthMeter extends StatelessWidget {
  const MarketBreadthMeter({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveIndexController>(
      builder: (controller) {
        final selectedData = controller.selectedIndexData;
        if (selectedData == null) return const SizedBox.shrink();

        // ডেটা এক্সট্র্যাক্ট করা হচ্ছে
        final int up = selectedData.u ?? 0;
        final int down = selectedData.d ?? 0;
        final int unchanged = selectedData.uc ?? 0;
        final int total = up + down + unchanged;

        if (total == 0) return const SizedBox.shrink();

        // পার্সেন্টেজ ক্যালকুলেশন
        final double upPct = (up / total) * 100;
        final double downPct = (down / total) * 100;
        final double ucPct = (unchanged / total) * 100;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderSideColor.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Market Momentum (${selectedData.sn})', // DSEX বা DS30
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textColor),
              ),
              const SizedBox(height: 16),

              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    if (up > 0)
                      Expanded(
                        flex: up,
                        child: Container(height: 8, color: const Color(0xFF22C665)), // Green (Bull)
                      ),
                    if (unchanged > 0)
                      Expanded(
                        flex: unchanged,
                        child: Container(height: 8, color: const Color(0xFF177DFF)), // Blue (Neutral)
                      ),
                    if (down > 0)
                      Expanded(
                        flex: down,
                        child: Container(height: 8, color: const Color(0xFFF54D64)), // Red (Bear)
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 🚀 2. Labels & Values
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLegendInfo('Advances', up, upPct, const Color(0xFF22C665), context),
                  _buildLegendInfo('Unchanged', unchanged, ucPct, const Color(0xFF177DFF), context),
                  _buildLegendInfo('Declines', down, downPct, const Color(0xFFF54D64), context, isRight: true),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendInfo(String title, int value, double pct, Color color, BuildContext ctx, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (!isRight) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
            ],
            Text(title, style: TextStyle(fontSize: 11, color: ctx.textColor.withOpacity(0.6))),
            if (isRight) ...[
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            text: '$value ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ctx.textColor),
            children: [
              TextSpan(
                text: '(${pct.toStringAsFixed(1)}%)',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: color),
              ),
            ],
          ),
        ),
      ],
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

class MarketLiquidityChart extends StatelessWidget {
  const MarketLiquidityChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveIndexController>(
      builder: (controller) {
        // 🚀 সবগুলো ইনডেক্স লিস্ট থেকে নিচ্ছি
        final chartData = controller.visibleIndexList;

        if (chartData.isEmpty) {
          return const SizedBox(height: 250, child: Center(child: Text("No data available")));
        }

        return Container(
          height: 320,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderSideColor.withOpacity(0.5)),
          ),
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            title: ChartTitle(
              text: 'Liquidity & Activity Matrix',
              textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textColor),
              alignment: ChartAlignment.near,
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              iconHeight: 12,
              iconWidth: 12,
              textStyle: TextStyle(color: context.textColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),

            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
              labelStyle: TextStyle(fontWeight: FontWeight.bold, color: context.textColor),
            ),

            primaryYAxis: NumericAxis(
              title: AxisTitle(
                text: 'Value (Cr) / Volume (Mn)',
                textStyle: TextStyle(fontSize: 10, color: context.textColor.withOpacity(0.6)),
              ),
              majorGridLines: MajorGridLines(
                width: 1,
                dashArray: const <double>[5, 5],
                color: context.dividerColor.withOpacity(0.3),
              ),
              axisLine: const AxisLine(width: 0),
              labelStyle: TextStyle(color: context.textColor, fontWeight: FontWeight.w500),
            ),

            axes: <ChartAxis>[
              NumericAxis(
                name: 'TradesAxis',
                opposedPosition: true, // ডান দিকে বসানোর জন্য
                title: AxisTitle(
                  text: 'Trades (K)',
                  textStyle: TextStyle(fontSize: 10, color: context.textColor.withOpacity(0.6)),
                ),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],

            tooltipBehavior: TooltipBehavior(
              enable: true,
              shared: true, // 🚀 একটি ট্যাপেই ৩টি ডেটা (Value, Volume, Trades) একসাথে দেখাবে
              color: context.isDark ? Colors.grey.shade900 : Colors.white,
              textStyle: TextStyle(color: context.isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
            ),

            series: <CartesianSeries>[
              ColumnSeries<dynamic, String>(
                name: 'Value (Cr)',
                dataSource: chartData,
                xValueMapper: (dynamic data, _) => data.sn ?? '',
                yValueMapper: (dynamic data, _) {
                  final double vl = data.vl?.toDouble() ?? 0.0;

                  return vl / 10000000; // কোটিতে কনভার্ট
                },
                color: Colors.blue.shade600,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                width: 0.35,
                spacing: 0.1, // কলামের ভেতরের গ্যাপ
              ),

              ColumnSeries<dynamic, String>(
                name: 'Volume (Mn)',
                dataSource: chartData,
                xValueMapper: (dynamic data, _) => data.sn ?? '',
                yValueMapper: (dynamic data, _) {
                  final double v = data.v?.toDouble() ?? 0.0;

                  return v / 1000000; // মিলিয়নে কনভার্ট
                },
                color: Colors.teal.shade400,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                width: 0.35,
                spacing: 0.1,
              ),

              SplineSeries<dynamic, String>(
                name: 'Trades (K)',
                dataSource: chartData,
                yAxisName: 'TradesAxis', // 🚀 এটি ডানদিকের স্কেল ফলো করবে
                xValueMapper: (dynamic data, _) => data.sn ?? '',
                yValueMapper: (dynamic data, _) {
                  final int tds = data.tds ?? 0;

                  return tds / 1000; // হাজারে কনভার্ট
                },
                color: Colors.orange,
                width: 3,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  color: Colors.white,
                  borderWidth: 2,
                  borderColor: Colors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class InternationalMarketOverview extends StatelessWidget {
  const InternationalMarketOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveIndexController>(
      builder: (indexCon) {
        if (indexCon.indexList.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        // আপনার কোড অনুযায়ী newArr থেকে u, d, uc নিচ্ছি
        final newArr = indexCon.newArr;
        final int advanced = newArr?.u ?? 0;
        final int declined = newArr?.d ?? 0;
        final int unchanged = newArr?.uc ?? 0;
        final int total = advanced + declined + unchanged;

        final visibleIndices = indexCon.visibleIndexList;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.isDark ? hexToColor('#161A33') : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderSideColor.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Market Sentiment',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 12),
              if (total > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      if (advanced > 0)
                        Expanded(
                          flex: advanced,
                          child: Container(height: 8, color: ColorConstants.forestGreen),
                        ),
                      if (unchanged > 0)
                        Expanded(
                          flex: unchanged,
                          child: Container(height: 8, color: ColorConstants.brightBlue),
                        ),
                      if (declined > 0)
                        Expanded(
                          flex: declined,
                          child: Container(height: 8, color: ColorConstants.coralRed),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSentimentLabel('Advanced', advanced, ColorConstants.forestGreen, context),
                    _buildSentimentLabel('Unchanged', unchanged, ColorConstants.brightBlue, context),
                    _buildSentimentLabel('Declined', declined, ColorConstants.coralRed, context),
                  ],
                ),
              ],
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, thickness: 1)),

              Text(
                'Indices Performance (%)',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  margin: EdgeInsets.zero,
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 0),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, color: context.textColor, fontSize: 12),
                  ),
                  primaryYAxis: NumericAxis(
                    isVisible: false, // Y অক্ষ হাইড করা হয়েছে ক্লিন লুকের জন্য
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    header: '',
                    format: 'point.x: point.y%',
                    color: context.isDark ? Colors.grey.shade800 : Colors.black87,
                  ),
                  series: <CartesianSeries<IndexModel, String>>[
                    // BarSeries দিয়ে হরিজন্টাল চার্ট তৈরি করা হয়
                    BarSeries<IndexModel, String>(
                      dataSource: visibleIndices,
                      xValueMapper: (IndexModel data, _) => data.sn ?? "",
                      yValueMapper: (IndexModel data, _) => data.ip?.toDouble() ?? 0.0, // Percentage change
                      pointColorMapper: (IndexModel data, _) {
                        final bool isNegative = data.ip?.isNegative == true;
                        return isNegative ? Colors.redAccent : Colors.green;
                      },
                      borderRadius: BorderRadius.circular(4),
                      width: 0.5,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.outer,
                        textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: context.textColor),
                        // লেবেলের সাথে % চিহ্ন যোগ করা
                        builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                          final double val = data.ip?.toDouble() ?? 0.0;
                          final sign = val > 0 ? '+' : '';
                          return Text(
                            '$sign${val.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: val < 0 ? Colors.redAccent : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          );
                        },
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

  Widget _buildSentimentLabel(String title, int value, Color color, BuildContext ctx) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$title: $value',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ctx.textColor.withOpacity(0.8)),
        ),
      ],
    );
  }
}

class MarketBreadthMomentumChart extends StatelessWidget {
  const MarketBreadthMomentumChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveIndexController>(
      builder: (indexCon) {
        final visibleIndices = indexCon.visibleIndexList;

        if (visibleIndices.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        return Container(
          height: 320, // 🚀 চার্টটি সুন্দরভাবে দেখানোর জন্য হাইট
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.isDark ? hexToColor('#161A33') : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderSideColor.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            title: ChartTitle(
              text: 'Market Breadth vs Momentum',
              textStyle: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: context.textColor,
              ),
              alignment: ChartAlignment.near,
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              iconHeight: 12,
              iconWidth: 12,
              textStyle: TextStyle(color: context.textColor, fontWeight: FontWeight.w600, fontSize: 11),
            ),

            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
              labelStyle: TextStyle(fontWeight: FontWeight.bold, color: context.textColor),
            ),

            primaryYAxis: NumericAxis(
              title: AxisTitle(
                text: 'No. of Companies',
                textStyle: TextStyle(fontSize: 10, color: context.textColor.withOpacity(0.6)),
              ),
              majorGridLines: MajorGridLines(
                width: 1,
                dashArray: const <double>[5, 5],
                color: context.dividerColor.withOpacity(0.3),
              ),
              axisLine: const AxisLine(width: 0),
              labelStyle: TextStyle(color: context.textColor.withOpacity(0.8), fontWeight: FontWeight.bold),
            ),

            axes: <ChartAxis>[
              NumericAxis(
                name: 'PercentageAxis',
                opposedPosition: true, // ডান দিকে বসানোর জন্য
                title: AxisTitle(
                  text: 'Performance (%)',
                  textStyle: TextStyle(fontSize: 10, color: context.textColor.withOpacity(0.6)),
                ),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelFormat: '{value}%',
                labelStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],

            // 🚀 Shared Tooltip: একটা ইনডেক্সে ট্যাপ করলেই ৪টি ডেটা একসাথে দেখাবে
            tooltipBehavior: TooltipBehavior(
              enable: true,
              shared: true,
              color: context.isDark ? Colors.grey.shade900 : Colors.white,
              textStyle: TextStyle(color: context.isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
            ),

            series: <CartesianSeries>[
              ColumnSeries<IndexModel, String>(
                name: 'Advanced',
                dataSource: visibleIndices,
                xValueMapper: (IndexModel data, _) => data.sn ?? '',
                yValueMapper: (IndexModel data, _) => data.u ?? 0, // 'u' মানে Up/Advanced
                color: ColorConstants.forestGreen,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                width: 0.6,
                spacing: 0.1,
              ),

              ColumnSeries<IndexModel, String>(
                name: 'Unchanged',
                dataSource: visibleIndices,
                xValueMapper: (IndexModel data, _) => data.sn ?? '',
                yValueMapper: (IndexModel data, _) => data.uc ?? 0, // 'uc' মানে Unchanged
                color: ColorConstants.brightBlue,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                width: 0.6,
                spacing: 0.1,
              ),

              ColumnSeries<IndexModel, String>(
                name: 'Declined',
                dataSource: visibleIndices,
                xValueMapper: (IndexModel data, _) => data.sn ?? '',
                yValueMapper: (IndexModel data, _) => data.d ?? 0, // 'd' মানে Down/Declined
                color: ColorConstants.coralRed,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                width: 0.6,
                spacing: 0.1,
              ),

              SplineSeries<IndexModel, String>(
                name: 'Performance (%)',
                dataSource: visibleIndices,
                yAxisName: 'PercentageAxis', // 🚀 এটি ডানদিকের (%) স্কেল ফলো করবে
                xValueMapper: (IndexModel data, _) => data.sn ?? '',
                yValueMapper: (IndexModel data, _) => data.ip?.toDouble() ?? 0.0, // 'ip' মানে Index Percentage Change
                color: Colors.orange,
                width: 3,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  color: Colors.white,
                  borderWidth: 2,
                  borderColor: Colors.orange,
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

class _TradeGridViewWidget extends StatelessWidget {
  const _TradeGridViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚀 অপ্রয়োজনীয় homeCon2 ভেরিয়েবল রিমুভ করা হয়েছে

    return GetBuilder<HomeController>(
      id: 'indexList',
      builder: (homeController) {
        // ডেটা না থাকলে লোডার দেখাবে
        if (homeController.indexList.isEmpty) {
          return const IndexValueLoader();
        }

        final newArr = homeController.newArr;

        return GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 10,
          shrinkWrap: true,
          childAspectRatio: 2.1,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6), // 🚀 const যুক্ত করা হয়েছে
          children: [
            _CustomCardWidget(
              color: ColorConstants.yaleBlue,
              title: "TRADE", // 🚀 .toCapitalize() রিমুভ করা হয়েছে কারণ এটি অলরেডি ক্যাপিটাল
              subtitle: NumberFormatter.bdFormat(newArr?.tds ?? 0),
              onClick: () => Get.toNamed(Routes.TOP_SHARE, arguments: 'Trade'),
            ),
            _CustomCardWidget(
              color: ColorConstants.lightBlue,
              title: "VOLUME",
              subtitle: NumberFormatter.croreFormat(newArr?.v ?? 0.0),
              onClick: () => Get.toNamed(Routes.TOP_SHARE, arguments: 'Volume'),
            ),
            _CustomCardWidget(
              color: ColorConstants.goldenYellow,
              title: "VALUE",
              subtitle: NumberFormatter.croreFormat(newArr?.vl ?? 0.0),
              onClick: () => Get.toNamed(Routes.TOP_SHARE, arguments: 'Value'),
            ),
            _CustomCardWidget(
              color: ColorConstants.forestGreen,
              title: "ADVANCED",
              subtitle: "${newArr?.u ?? 0}",
              onClick: () => Get.toNamed(Routes.TOP_SHARE, arguments: 'Gainer'),
            ),
            _CustomCardWidget(
              color: ColorConstants.coralRed,
              title: "DECLINE",
              subtitle: "${newArr?.d ?? 0}",
              onClick: () => Get.toNamed(Routes.TOP_SHARE, arguments: 'Loser'),
            ),
            _CustomCardWidget(
              color: ColorConstants.brightBlue,
              title: "UNCHANGED",
              subtitle: "${newArr?.uc ?? 0}", // 🚀 0.0 এর বদলে 0 ব্যবহার করা হয়েছে (যেহেতু count পূর্ণসংখ্যা)
              onClick: () => Get.toNamed(Routes.TOP_SHARE, arguments: 'Unchanged'),
            ),
          ],
        );
      },
    );
  }
}

class IndexGroupedBarChart extends StatelessWidget {
  final List<IndexModel> indexData;

  const IndexGroupedBarChart({super.key, required this.indexData});

  @override
  Widget build(BuildContext context) {
    var defIndex = (indexData.first.civ ?? 0) - (indexData.first.ivd ?? 0);
    return SfCartesianChart(
      title: ChartTitle(text: 'Market Index Analysis'),
      legend: Legend(isVisible: true),
      primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Market Indices')),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Values'),
        numberFormat: NumberFormat('#,##0.00'),
      ),
      series: <CartesianSeries<IndexModel, String>>[
        ColumnSeries<IndexModel, String>(
          name: 'CIV',
          dataSource: indexData,
          xValueMapper: (IndexModel data, _) => data.sn ?? '',
          yValueMapper: (IndexModel data, _) => data.civ ?? 0,
          color: Colors.blue[600],
          width: 0.6,
        ),
        ColumnSeries<IndexModel, String>(
          name: 'IVD (CIV - IVD)',
          dataSource: indexData,
          xValueMapper: (IndexModel data, _) => data.sn ?? '',
          yValueMapper: (IndexModel data, _) => (data.civ ?? 0) - (data.ivd ?? 0),
          color: Colors.orange[600],
          width: 0.6,
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x : point.y points'),
    );
  }
}

class _ItemListWidget extends StatelessWidget {
  const _ItemListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat("MMM d, y 'at' h:mm a");

    return GetBuilder<HomeController>(
      id: 'indexList',
      builder: (homeCon) {
        final DateTime updateTime = homeCon.lastIndexUpdateTime ?? DateTime.now();

        // 🚀 কন্ট্রোলার থেকে ফিল্টার করা ফ্রেশ ডেটা নেওয়া হচ্ছে
        final visibleIndices = homeCon.visibleIndexList;

        return Container(
          margin: const EdgeInsets.all(6), // 🚀 const যুক্ত করা হলো পারফরম্যান্সের জন্য
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: const Border(bottom: BorderSide(color: Colors.black26)),
                  color: context.isDark ? hexToColor('#161A33') : ColorConstants.yaleBlue,
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Last update on ${formatter.format(updateTime)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // 🚀 Data Rows
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleIndices.length, // 🚀 ফিল্টার করা লিস্টের লেংথ
                itemBuilder: (context, index) {
                  IndexModel model = visibleIndices[index];
                  final bool isSelected = homeCon.newArr?.sn == model.sn;

                  var style = Get.textTheme.titleMedium?.copyWith(
                    fontSize: AppDimens.space14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  );

                  return Container(
                    key: ValueKey(model.sn),
                    decoration: BoxDecoration(
                      color: context.isDark ? hexToColor('#161A33') : null,
                      border: Border(bottom: BorderSide(color: context.borderSideColor, width: 1)),
                    ),
                    child: InkWell(
                      onTap: () {
                        homeCon.getSumOfAllIndex(model);
                        homeCon.marketIndexController.loadData('${model.sn}');
                        Get.find<IndexChartController>().fetchChartData('${model.sn}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: context.isDark ? null : ColorConstants.yaleBlue),
                                child: Text(
                                  model.sn ?? "",
                                  style: Get.textTheme.titleMedium?.copyWith(
                                    fontSize: AppDimens.space16,
                                    color: context.isDark ? ColorConstants.secondaryColorDark : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: context.isDark ? null : const Color(0xFFF8F9FA)),
                                child: Center(child: Text(NumberFormatter.bdFormat(model.civ ?? 0), style: style)),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  model.ivd?.toDouble().toStringAsFixed(2) ?? "",
                                  style: Get.textTheme.titleMedium?.copyWith(
                                    fontSize: AppDimens.space14,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    color: model.ivd?.isNegative == true ? Colors.redAccent : Colors.green,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: context.isDark ? null : ColorConstants.unselectedItemColorLight,
                                ),
                                child: Center(
                                  child: Text(
                                    '${model.ip?.toDouble().toStringAsFixed(2) ?? ""}%',
                                    style: Get.textTheme.titleMedium?.copyWith(
                                      fontSize: AppDimens.space14,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                      color: model.ip?.isNegative == true ? Colors.redAccent : Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                              child: Icon(
                                model.ip?.isNegative == true
                                    ? Icons.keyboard_double_arrow_down
                                    : Icons.keyboard_double_arrow_up,
                                color: model.ip?.isNegative == true ? Colors.redAccent : Colors.green,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryData {
  final String category;
  final int count;

  CategoryData(this.category, this.count);
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScroll());
  }

  void _autoScroll() async {
    _isScrolling = true;
    _scrollTimer?.cancel();
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
        : SizedBox(
            height: 40,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.homeCon.marqueeList.length,
              itemBuilder: (_, index) {
                final sortedList = List.from(widget.homeCon.marqueeList)
                  ..sort((a, b) => (a.shortName ?? '').toString().compareTo((b.shortName ?? '').toString()));
                // If you chose Option B or C above, use the same comparator here.

                final item = sortedList[index];
                return _buildItem(item);
              },
            ),
          );
  }
}
