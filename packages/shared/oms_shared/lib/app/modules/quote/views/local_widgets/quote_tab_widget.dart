import '../../../../data/models/request/add_fav_item_request.dart' show AddFavItemRequest;

import '../../../../global_widgets/info_tooltip_icon.dart';
import '/app/global_widgets/responsive_wrap_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../app_pkg.dart';
import 'candle_series_charts.dart';
import 'related_item_watchlist.dart';
import 'market_depth_single_widget.dart';

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
                builder: (homeCon) => _QuoteTopDetailsSection(homeCon: homeCon),
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
// ==========================================
class _QuoteTopDetailsSection extends StatelessWidget {
  final HomeController homeCon;
  const _QuoteTopDetailsSection({required this.homeCon});

  @override
  Widget build(BuildContext context) {
    Divider dividerWidget = Divider(
      height: 0,
      thickness: 0.9,
      color: context.dividerColor,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpace.spaceH10,
          _StockHeaderInfo(marketData: homeCon.marketData),
          AppSpace.spaceH8,
          _TimeAndSalesButton(homeCon: homeCon),
          AppSpace.spaceH8,
          _PriceAndFavSection(homeCon: homeCon),
          AppSpace.spaceH12,
          dividerWidget,
          AppSpace.spaceH2,

          _PerformanceMetricsWrap(marketData: homeCon.marketData),
          AppSpace.spaceH4,
          dividerWidget,
          AppSpace.spaceH8,

          _DetailedStatsWrap(homeCon: homeCon),
          AppSpace.spaceH10,
          dividerWidget,
          AppSpace.spaceH10,

          _DividendInfo(homeCon: homeCon),
          AppSpace.spaceH10,
          dividerWidget,
          AppSpace.spaceH10,

          _ShareholdingInfo(homeCon: homeCon),
          AppSpace.spaceH6,
        ],
      ),
    );
  }
}

// ==========================================
// ==========================================

/// কোম্পানির নাম এবং সেক্টর ইনফো
class _StockHeaderInfo extends StatelessWidget {
  final MarketModel marketData;
  const _StockHeaderInfo({required this.marketData});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: marketData.fullName ?? "",
        style: Get.textTheme.bodySmall?.copyWith(
          fontSize: AppDimens.space14,
          fontWeight: FontWeight.w600,
          color: context.textColor,
        ),
        children: [
          TextSpan(
            text: ' [${marketData.shareType ?? ""}]',
            style: Get.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: AppDimens.space12,
              color: context.textColor,
            ),
          ),
          TextSpan(
            text: ' [${marketData.sector ?? ""}]',
            style: Get.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: AppDimens.space12,
              color: context.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Time and sales বাটন সেকশন
class _TimeAndSalesButton extends StatelessWidget {
  final HomeController homeCon;
  const _TimeAndSalesButton({required this.homeCon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 33,
      width: Get.width,
      decoration: BoxDecoration(
        color: context.isDark ? ColorConstants.tapBgDark : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => homeCon.changeTabQuote(1),
        child: Row(
          children: [
            AppSpace.spaceW6,
            VisibleGetBuilder<HomeController>(
              id: 'timeAndSales',
              builder: (timeSalesCont) {
                if (timeSalesCont.timeAndSales.isNotEmpty) {
                  var firstItem = timeSalesCont.timeAndSales.first;
                  return Expanded(
                    child: Text(
                      'Traded ${firstItem.v ?? 0.0} shares @${firstItem.p ?? 0.0}Tk',
                      style: Get.textTheme.bodySmall?.copyWith(
                        fontSize: AppDimens.space14,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                  );
                } else {
                  return Expanded(
                    child: Text(
                      'No data available',
                      style: Get.textTheme.bodySmall?.copyWith(
                        fontSize: AppDimens.space14,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                  );
                }
              },
            ),
            Row(
              children: [
                Text(
                  'List ',
                  style: Get.textTheme.bodySmall?.copyWith(
                    fontSize: AppDimens.space14,
                    fontWeight: FontWeight.w600,
                    color: context.buttonColor,
                  ),
                ),
                SvgPicture.asset(
                  AssetsConstants.goFow,
                  colorFilter: ColorFilter.mode(
                    context.buttonColor,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            AppSpace.spaceW12,
          ],
        ),
      ),
    );
  }
}

/// প্রাইস, এভারেজ এবং ফেভারিট বাটন
class _PriceAndFavSection extends StatelessWidget {
  final HomeController homeCon;
  const _PriceAndFavSection({required this.homeCon});

  @override
  Widget build(BuildContext context) {
    var favList = homeCon.isFav(homeCon.marketData.orderBook ?? 0);
    final updatePriceWithColor = NumberHelper.formatPriceChange(
      (homeCon.marketData.activePrice) - (homeCon.marketData.reference ?? 0.0),
      context,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              text: homeCon.marketData.activePrice.toStringAsFixed(1),
              style: Get.textTheme.bodySmall?.copyWith(
                fontSize: AppDimens.space14,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
              children: [
                TextSpan(
                  text:
                      ' ${updatePriceWithColor.text} (${homeCon.marketData.d?.toStringAsFixed(2) ?? "0.00"}%)',
                  style: Get.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: AppDimens.space14,
                    color: updatePriceWithColor.color,
                  ),
                ),
                TextSpan(
                  text:
                      ' Avg: ${homeCon.marketData.vwap?.toStringAsFixed(2) ?? 0.0}',
                  style: Get.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: AppDimens.space14,
                    color: context.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFavButtons(context, favList),
      ],
    );
  }

  Widget _buildFavButtons(BuildContext context, bool favList) {
    return Row(
      children: [
        Container(
          height: 28,
          width: 45,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          decoration: BoxDecoration(
            color: context.bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColorConstants.redColor, width: 1),
          ),
          child: SvgPicture.asset(AssetsConstants.timeSvg, width: 30),
        ),
        AppSpace.spaceW4,
        InkWell(
          onTap: () {
            if (!favList) {
              favouriteBottomSheet(context, homeCon.marketData);
            }
          },
          child: Container(
            height: 28,
            width: 45,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: context.bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.borderSideColor, width: 1),
            ),
            child: favList
                ? const Icon(Icons.favorite, color: Colors.red, size: 22)
                : SvgPicture.asset(
                    AssetsConstants.loveSvg,
                    colorFilter: ColorFilter.mode(
                      ColorConstants.buttonColorDark,
                      BlendMode.srcIn,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// 1w, 1m, 1y ইত্যাদি পারফরম্যান্স
class _PerformanceMetricsWrap extends StatelessWidget {
  final MarketModel marketData;
  const _PerformanceMetricsWrap({required this.marketData});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrap(
      minItemWidth: 50,
      children: [
        QuoteUIHelper.buildSingleItem(
          context,
          'Today',
          '${NumberHelper.formatSigned(marketData.d)}%',
          NumberHelper.getColor(marketData.d),
        ),
        QuoteUIHelper.buildSingleItem(
          context,
          '1 wk',
          '${NumberHelper.formatSigned(marketData.chp1w)}%',
          NumberHelper.getColor(marketData.chp1w),
        ),
        QuoteUIHelper.buildSingleItem(
          context,
          '2 wk',
          '${NumberHelper.formatSigned(marketData.chp2w)}%',
          NumberHelper.getColor(marketData.chp2w),
        ),
        QuoteUIHelper.buildSingleItem(
          context,
          '1 mths',
          '${NumberHelper.formatSigned(marketData.chp1m)}%',
          NumberHelper.getColor(marketData.chp1m),
        ),
        QuoteUIHelper.buildSingleItem(
          context,
          '6 mths',
          '${NumberHelper.formatSigned(marketData.chp6m)}%',
          NumberHelper.getColor(marketData.chp6m),
        ),
        QuoteUIHelper.buildSingleItem(
          context,
          '1 yr',
          '${NumberHelper.formatSigned(marketData.chp1y)}%',
          NumberHelper.getColor(marketData.chp1y),
        ),
      ],
    );
  }
}

/// Open, High, Low ইত্যাদি ডিটেইলড স্ট্যাটস
class _DetailedStatsWrap extends StatelessWidget {
  final HomeController homeCon;
  const _DetailedStatsWrap({required this.homeCon});

  @override
  Widget build(BuildContext context) {
    final mData = homeCon.marketData;
    final cData = homeCon.company;
    final double epsQ1 = homeCon.epsData['Q1']?.epsContinuing ?? 0.0;
    final double epsQ2 = homeCon.epsData['Q2']?.epsContinuing ?? 0.0;
    final double epsQ3 = homeCon.epsData['Q3']?.epsContinuing ?? 0.0;
    final double epsQ4 = homeCon.epsData['Q4']?.epsContinuing ?? 0.0;

    // সবগুলো কোয়ার্টারের EPS যোগ করে TTM (Trailing Twelve Months) তৈরি
    final double epsTTM = epsQ1 + epsQ2 + epsQ3 + epsQ4;
    return BetterResponsiveWrap(
      minItemWidth: 60,
      children: [
        QuoteUIHelper.buildPerformanceItem(
          context,
          'Open:',
          NumberFormatter.bdFormat(mData.open ?? 0.0, decimalPlaces: 1),
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'High:',
          NumberFormatter.bdFormat(mData.high ?? 0.0),
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'Low:',
          NumberFormatter.bdFormat(mData.low ?? 0.0),
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'YCP:',
          NumberFormatter.bdFormat(mData.reference ?? 0.0),
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'Vol:',
          NumberFormatter.bdFormat(mData.volume ?? 0.0, decimalPlaces: 0),
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          '52W H:',
          NumberFormatter.bdFormat("${mData.wk52High ?? 0.0}"),
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          '52W L:',
          NumberFormatter.bdFormat("${mData.wk52Low ?? 0.0}"),
        ),

        QuoteUIHelper.buildPerformanceItem(
          context,
          'Crct Lw:',
          NumberFormatter.bdFormat(mData.dl ?? 0.0),
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'Circuit Up:',
          '${mData.dh ?? '0'}',
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'Value:',
          NumberFormatter.croreFormat("${mData.val}"),
        ),

        QuoteUIHelper.buildPerformanceItemWithTooltip(
          context,
          'P/E(TTM):',
          "${cData?.marketData?.valuation?.peRatio ?? 0.0}",
          showInfo: true,
          infoText:
              'Unaudited P/E : ${NumberFormatter.bdFormat(cData?.marketData?.valuation?.peRatio ?? 0.0)}',
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'EPS (TTM)',
          epsTTM.toStringAsFixed(2), // দশমিকের পর ২ ঘর পর্যন্ত দেখানোর জন্য
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'NAV:',
          '${cData?.financials?.perShareMetrics?.navTk ?? 0.0}',
        ),
        QuoteUIHelper.buildPerformanceItemWithTooltip(
          context,
          'Ttl Share:',
          '${cData?.shareholding?.totalSharesMillions ?? 0.0}',
          showInfo: true,
          infoText:
              'Total no of Share : ${NumberFormatter.croreFormat("${cData?.shareholding?.totalSharesMillions}")}',
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'Yr end:',
          cData?.corporateActions?.financialYearEnd ?? "",
        ),

        QuoteUIHelper.buildPerformanceItem(
          context,
          'EPS Ann-${homeCon.epsData['Q4']?.year ?? ""}',
          '${homeCon.epsData['Q4']?.epsContinuing ?? 0.0}',
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'EPS ${homeCon.epsData['Q1']?.quarter ?? ""}-${homeCon.epsData['Q1']?.year ?? ""}',
          '${homeCon.epsData['Q1']?.epsContinuing ?? 0.0}',
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'EPS ${homeCon.epsData['Q2']?.quarter ?? ""}-${homeCon.epsData['Q2']?.year ?? ""}',
          '${homeCon.epsData['Q2']?.epsContinuing ?? 0.0}',
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'EPS ${homeCon.epsData['Q3']?.quarter ?? ""}-${homeCon.epsData['Q3']?.year ?? ""}',
          '${homeCon.epsData['Q3']?.epsContinuing ?? 0.0}',
        ),

        QuoteUIHelper.buildPerformanceItem(
          context,
          'Div-${homeCon.dividendObj?.fiscalYear?.yearEnd.toString().substring(0, 4)}',
          '${homeCon.dividendObj?.dividend?.cashPercent ?? 0.0}% csh',
        ),

        QuoteUIHelper.buildPerformanceItem(
          context,
          'NOCFPS Ann-2024',
          '0% csh',
        ),
        QuoteUIHelper.buildPerformanceItem(context, 'NOCFPS Q1-2024', '0% csh'),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'NOCFPS Q2-6mnth-',
          '0% csh',
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'NOCFPS Q3-9mnth-',
          '0% csh',
        ),
        QuoteUIHelper.buildPerformanceItem(
          context,
          'Div Yield ${cData?.corporateActions?.financialYear ?? ""}',
          '${(cData?.marketData?.valuation?.dividendYieldPct ?? 0.0).toStringAsFixed(2)}% csh',
        ),

      ],
    );
  }
}

/// ডিভিডেন্ড ও রেকর্ড ডেট
class _DividendInfo extends StatelessWidget {
  final HomeController homeCon;
  const _DividendInfo({required this.homeCon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDateText(
          context,
          "Last AGM:",
          homeCon.dividendObj?.fiscalYear?.agmDate?.yyyDDmm ?? 'N/A',
        ),
        _buildDateText(
          context,
          "Record date:",
          homeCon.dividendObj?.recordDates?.general?.yyyDDmm ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildDateText(BuildContext context, String label, String value) {
    return RichText(
      text: TextSpan(
        text: label,
        style: Get.textTheme.bodySmall?.copyWith(
          fontSize: AppDimens.space14,
          fontWeight: FontWeight.w600,
          color: HexColor('#9C9FA4'),
        ),
        children: [
          TextSpan(
            text: ' $value',
            style: Get.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: AppDimens.space14,
              color: context.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// শেয়ারহোল্ডিং সেকশন
class _ShareholdingInfo extends StatelessWidget {
  final HomeController homeCon;
  const _ShareholdingInfo({required this.homeCon});

  @override
  Widget build(BuildContext context) {
    final sData = homeCon.company?.shareholding?.ownershipBreakdown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share Holding as on (30,sep 25)',
          style: Get.textTheme.bodyMedium?.copyWith(color: HexColor('#A8A8AA')),
        ),
        AppSpace.spaceH10,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            QuoteUIHelper.build4Item(
              context,
              'Director:',
              '${NumberFormatter.bdFormat(sData?.sponsorsDirectorsPct ?? 0.0)}%',
              '0.0cr',
            ),
            QuoteUIHelper.build4Item(
              context,
              'Govt:',
              '${NumberFormatter.bdFormat(sData?.governmentPct ?? 0.0)}%',
              '0.0cr',
            ),
            QuoteUIHelper.build4Item(
              context,
              'Institute:',
              '${NumberFormatter.bdFormat(sData?.institutionalPct ?? 0.0)}%',
              '0.0cr',
            ),
            QuoteUIHelper.build4Item(
              context,
              'Foreign:',
              '${NumberFormatter.bdFormat(sData?.foreignPct ?? 0.0)}%',
              '0.0cr',
            ),
            QuoteUIHelper.build4Item(
              context,
              'Public:',
              '${NumberFormatter.bdFormat(sData?.publicPct ?? 0.0)}%',
              '0.0cr',
            ),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// ==========================================
class QuoteUIHelper {
  static Widget buildSingleItem(
    BuildContext context,
    String period,
    String value,
    Color? color,
  ) {
    return SizedBox(
      width: 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(period, style: Get.textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: Get.textTheme.bodySmall?.copyWith(
              color: color ?? context.textColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildPerformanceItem(
    BuildContext context,
    String period,
    String value, {
    double width = 62,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(period, style: Get.textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: Get.textTheme.bodySmall?.copyWith(color: context.textColor),
          ),
        ],
      ),
    );
  }

  static Widget buildPerformanceItemWithTooltip(
    BuildContext context,
    String period,
    String value, {
    double width = 62,
    required bool showInfo,
    required String infoText,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: Get.textTheme.labelSmall,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  NumberFormatter.croreFormat(value),
                  overflow: TextOverflow.ellipsis,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: context.textColor,
                  ),
                ),
              ),
              if (showInfo) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InfoTooltipIcon(
                    infoText: infoText,
                    size: 13,
                    color: Colors.blue,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static Widget build4Item(
    BuildContext context,
    String period,
    String value,
    String value2,
  ) {
    return SizedBox(
      width: 62,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              color: HexColor('#9C9FA4'),
            ),
          ),
          AppSpace.spaceH2,
          Text(
            value,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
          AppSpace.spaceH2,
          Text(
            value2,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
        ],
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
                    color: Colors.grey.withOpacity(0.5),
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
          separatorBuilder: (_, __) => dividerWidget,
          itemBuilder: (context, index) {
            final NewsModel? model = homeCon.newsSingleItem[index];
            if (model == null || model.tl == null)
              return const SizedBox.shrink();
            return NewsItemWidget(model: model);
          },
        );
      },
    );
  }
}

class NewsItemWidget extends StatelessWidget {
  final NewsModel model;
  const NewsItemWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    printLog('model news: ${model.toMap()}');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((model.tl ?? "").isNotEmpty)
            Text(
              model.tl!,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: context.buttonColor,
              ),
            ),
          if (model.dt != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  Helpers.getTimeAgoFromDateTime('${model.dt}', '${model.t}'),
                  style: Get.textTheme.bodySmall,
                ),
                Text(
                  "${model.dt?.standardDate}",
                  style: Get.textTheme.bodySmall,
                ),
              ],
            ),
          ],
          if ((model.nt ?? "").isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              model.nt!,
              textAlign: TextAlign.justify,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: context.textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==========================================
// 5. Global/Helper functions
// ==========================================
void favouriteBottomSheet(BuildContext ctx, MarketModel model) {
  Helpers.customShowDialog(
    ctx,
    barrierDismissible: false,
    children: [
      Flexible(
        child: GetBuilder<HomeController>(
          builder: (homeCont) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shrinkWrap: true,
              itemCount: homeCont.favCatList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  key: ValueKey(homeCont.favCatList.elementAt(index)),
                  onTap: () {
                    homeCont.changeFavCatId(
                      homeCont.favCatList.elementAt(index).id!,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          homeCont.selectFavCatId ==
                              homeCont.favCatList.elementAt(index).id
                          ? context.evenColor
                          : context.oddColor,
                    ),
                    child: Text(
                      '${homeCont.favCatList.elementAt(index).name}',
                      style: Get.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color:
                            homeCont.selectFavCatId ==
                                homeCont.favCatList.elementAt(index).id
                            ? ColorConstants.secondaryColorLight
                            : context.textColor,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      AppSpace.spaceH10,
      GetBuilder<HomeController>(
        builder: (homeCon) {
          return Container(
            padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
            child: homeCon.isAddFavCat
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(80, 40),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            textStyle: const TextStyle(fontSize: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.0),
                            ),
                          ),
                          child: const Text(
                            "No",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      AppSpace.spaceW20,
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (homeCon.selectFavCatId == 0) {
                              Helpers.snackbarForErorr2(
                                bodyText: 'Please select name',
                              );
                            } else {
                              var requestData = AddFavItemRequest(
                                tableId: homeCon.selectFavCatId,
                                ticker: '${model.ticker}',
                                group: '${model.group}',
                                oderBook: model.orderBook!,
                              );
                              printLog('requestData ${requestData.toJson()}');
                              homeCon.addMarketDataToFav(requestData);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.greenColor,
                            minimumSize: const Size(80, 40),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            textStyle: const TextStyle(fontSize: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.0),
                            ),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
      AppSpace.spaceH10,
    ],
  );
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
