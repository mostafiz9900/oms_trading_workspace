import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../global_widgets/empty_widget.dart';
import '../appbar_right_search_tap.dart';
import '../quote_tab_widget.dart';
import '../responsive_wrap_widget.dart';
import '/app/app_pkg.dart';

// ========================================================
//  1. Pro Sector Horizontal List (Home Page Widget)
// ========================================================
class ProSectorHorizontalList extends StatelessWidget {
  const ProSectorHorizontalList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'sectorSummary',
      builder: (homeCon) {
        final sectorList = homeCon.sectorSummaryList;

        if (sectorList.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),

            itemCount: sectorList.length,
            itemBuilder: (context, index) {
              final sector = sectorList[index];
              final bool isPositive = sector.avgTodayChange >= 0;

              final changeColor = isPositive ? Colors.green.shade700 : Colors.red.shade700;
              final trendIcon = isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

              return Padding(
                padding: .only(
                  right: 12,
                  bottom: 6,
                  top: 4,
                  left: index == 0 ? 6 : 0,
                ), //  প্রথম আইটেমের জন্য বাম মার্জিন
                child: InkWell(
                  onTap: () async {
                    var model = await Get.to(() => SectorDetailsView(sectorName: sector.sectorName));
                    if (model != null) {
                      homeCon.goBottomNabBarPage(1, model.orderBook!);
                      homeCon.tradingChart();
                      homeCon.loadComanyDividentEPS(model.shortName ?? "");
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 155,
                    padding: const .symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: context.isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.isDark ? Colors.white12 : Colors.grey.shade200, width: 1),
                      //  প্রফেশনাল শ্যাডো অ্যাড করা হয়েছে
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(context.isDark ? 0.3 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          sector.sectorName,
                          style: Get.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${(sector.totalValue / 1000000).toStringAsFixed(1)}M',
                              style: Get.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: context.isDark ? Colors.white70 : Colors.grey.shade600,
                              ),
                            ),
                            Container(
                              padding: const .symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: changeColor.withOpacity(0.1), //  ব্যাকগ্রাউন্ড টিন্ট
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(trendIcon, color: changeColor, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${sector.avgTodayChange.toStringAsFixed(2)}%',
                                    style: TextStyle(color: changeColor, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ========================================================
//  2. Sector Details View (The Full Page)
// ========================================================
class SectorDetailsView extends StatelessWidget {
  final String sectorName;

  const SectorDetailsView({super.key, required this.sectorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        // automaticallyImplyLeading: false,
        titleText: sectorName,
        titleFontSize: 16,
        isBackButtonIcon: true,
        backButtonOnClick: () => Get.back(),
        right: AppbarRightSearchTapWidget(shouldPop: true),
      ),
      body: GetBuilder<HomeController>(
        id: 'sectorSummary',
        builder: (homeCon) {
          final sectorList = homeCon.sectorSummaryList.where((s) => s.sectorName == sectorName).toList();
          if (sectorList.isEmpty) return const Center(child: Text("Sector data not found"));

          final sector = sectorList.first;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const .symmetric(horizontal: 10, vertical: 6),
                  padding: const .symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: context.isDark ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.isDark ? Colors.white10 : Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(context.isDark ? 0.3 : 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final updatePriceWithColor = NumberHelper.formatPriceChange(sector.totalChangeTk, context);
                            return RichText(
                              text: TextSpan(
                                text: sector.avgLastPrice.toStringAsFixed(1),
                                style: Get.textTheme.bodySmall?.copyWith(
                                  fontSize: AppDimens.space14,
                                  fontWeight: FontWeight.w600,
                                  color: context.textColor,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        ' ${updatePriceWithColor.text} (${sector.avgTodayChange.toStringAsFixed(2)}%)',
                                    style: Get.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: AppDimens.space14,
                                      color: updatePriceWithColor.color,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' Avg: ${sector.avgVwap.toStringAsFixed(2)}',
                                    style: Get.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: AppDimens.space14,
                                      color: context.textColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const .symmetric(horizontal: 10, vertical: 6),
                  padding: const .symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: context.isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                  ),
                  child: ResponsiveWrap(
                    minItemWidth: 50,
                    children: [
                      QuoteUIHelper.buildSingleItem(
                        context,
                        'Today',
                        '${NumberHelper.formatSigned(sector.avgTodayChange)}%',
                        NumberHelper.getColor(sector.avgTodayChange),
                      ),
                      QuoteUIHelper.buildSingleItem(
                        context,
                        '1 wk',
                        '${NumberHelper.formatSigned(sector.avg1WeekChange)}%',
                        NumberHelper.getColor(sector.avg1WeekChange),
                      ),
                      QuoteUIHelper.buildSingleItem(
                        context,
                        '1 mths',
                        '${NumberHelper.formatSigned(sector.avg1MonthChange)}%',
                        NumberHelper.getColor(sector.avg1MonthChange),
                      ),
                      QuoteUIHelper.buildSingleItem(
                        context,
                        '6 mths',
                        '${NumberHelper.formatSigned(sector.avg6MonthChange)}%',
                        NumberHelper.getColor(sector.avg6MonthChange),
                      ),
                      QuoteUIHelper.buildSingleItem(
                        context,
                        '1 yr',
                        '${NumberHelper.formatSigned(sector.avg1YearChange)}%',
                        NumberHelper.getColor(sector.avg1YearChange),
                      ),
                    ],
                  ),
                ),

                //  ২. Detailed Stats Wrap
                Container(
                  margin: const .symmetric(horizontal: 10, vertical: 6),
                  padding: const .symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: context.isDark ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: BetterResponsiveWrap(
                    minItemWidth: 60,
                    children: [
                      QuoteUIHelper.buildPerformanceItem(
                        context,
                        'Open:',
                        NumberFormatter.bdFormat(sector.totalOpen, decimalPlaces: 1),
                      ),
                      QuoteUIHelper.buildPerformanceItem(context, 'High:', NumberFormatter.bdFormat(sector.totalHigh)),
                      QuoteUIHelper.buildPerformanceItem(context, 'Low:', NumberFormatter.bdFormat(sector.totalLow)),
                      QuoteUIHelper.buildPerformanceItem(context, 'YCP:', NumberFormatter.bdFormat(sector.totalYcp)),
                      QuoteUIHelper.buildPerformanceItem(
                        context,
                        'Vol:',
                        NumberFormatter.bdFormat(sector.totalVolume.toDouble(), decimalPlaces: 0),
                      ),
                      QuoteUIHelper.buildPerformanceItem(
                        context,
                        'Trades:',
                        NumberFormatter.bdFormat("${sector.totalTrades}"),
                      ),
                      QuoteUIHelper.buildPerformanceItem(
                        context,
                        'Value:',
                        NumberFormatter.croreFormat("${sector.totalValue}"),
                      ),
                      QuoteUIHelper.buildPerformanceItem(context, 'Bid Qty:', '${sector.totalBidQty}'),
                      QuoteUIHelper.buildPerformanceItem(context, 'Ask Qty:', '${sector.totalAskQty}'),
                      QuoteUIHelper.buildPerformanceItem(
                        context,
                        'Change Tk:',
                        sector.totalChangeTk.toStringAsFixed(2),
                      ),
                      QuoteUIHelper.buildPerformanceItem(
                        context,
                        'Avg Chg%:',
                        sector.avgTodayChange.toStringAsFixed(2),
                      ),
                    ],
                  ),
                ),

                Divider(color: context.isDark ? Colors.white10 : Colors.grey.shade200, thickness: 6),

                //  ৩. Live Stock List (হেডার এখন এই উইজেটের ভেতরেই আছে)
                ReusableLiveStockList(stocks: sector.stocks, homeCon: Get.find<HomeController>()),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ========================================================
//  3. Reusable Live Stock List
// ========================================================
class ReusableLiveStockList extends StatefulWidget {
  final List<MarketModel> stocks;
  final HomeController homeCon;

  const ReusableLiveStockList({super.key, required this.stocks, required this.homeCon});

  @override
  State<ReusableLiveStockList> createState() => _ReusableLiveStockListState();
}

class _ReusableLiveStockListState extends State<ReusableLiveStockList> {
  String currentViewMode = 'Default';
  final List<String> viewModes = ['Default', 'Small', 'Classic'];

  @override
  Widget build(BuildContext context) {
    final dividerWidget = Divider(height: 1, color: context.dividerColor);
    final displayList = widget.stocks;

    return Column(
      children: [
        //  Controls Row (View Mode Dropdown)
        Padding(
          padding: const .fromLTRB(16, 0, 16, 8), //  হেডার এবং লিস্টের মাঝের স্পেস অপটিমাইজড
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "View:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.isDark ? Colors.white60 : Colors.grey[700],
                ),
              ),
              const SizedBox(width: 8),
              CommonMinimalDropdown(
                currentValue: currentViewMode,
                items: viewModes,
                onSelected: (val) {
                  setState(() {
                    currentViewMode = val;
                  });
                },
                widthDropdown: 110,
              ),
            ],
          ),
        ),

        dividerWidget,

        //  The Dynamic List View
        if (displayList.isEmpty)
          const Padding(
            padding: .all(30.0),
            child: Center(child: EmptyWidget(title: 'No items found.')),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            padding: const .symmetric(vertical: 8), //  লিস্টের বাইরের স্পেস কমানো হয়েছে
            separatorBuilder: (_, __) => dividerWidget,
            itemBuilder: (context, index) {
              final model = displayList[index];

              return SharedMarketListItem(
                model: model,
                index: index,
                viewMode: currentViewMode,
                searchQuery: '',
                onTap: () {
                  if (model.orderBook != null) {
                    Get.back(result: model);
                  }
                  // Get.find<HomeController>().goBottomNabBarPage(1, model.orderBook!);
                  // Get.find<HomeController>().loadComanyDividentEPS('${model.shortName}');
                  // Get.back();
                },
                // onLongPress: () {
                //   if (model.orderBook != null) {
                //     MarketDialogHelper.showBuySellDialog(
                //       context: context,
                //       orderBookId: model.orderBook!,
                //       shortName: model.shortName ?? "",
                //     );
                //   }
                // },
                onFavoriteTap: () {
                  MarketDialogHelper.showFavouriteBottomSheet(context, model);
                },
              );
            },
          ),
      ],
    );
  }
}
