import 'package:flutter/material.dart';
import 'package:market/market.dart' show MarketDepthModel;
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../app_pkg.dart';
import '../../../top_share/views/live_value_blinker.dart';

// =============================================================================
// Main Market Depth Widget (Ultra Responsive & Overflow-Proof)
// =============================================================================
class MarketDeptSingleWidget extends StatelessWidget {
  const MarketDeptSingleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'market_depth',
      builder: (homeCon) {
        final List<MarketDepthModel> buys = homeCon.buys;
        final List<MarketDepthModel> sells = homeCon.sells;

        final int totalBuyQty = buys.isNotEmpty ? (buys.last.cq ?? 0) : 0;
        final int totalSellQty = sells.isNotEmpty ? (sells.last.cq ?? 0) : 0;

        final int maxBuyQty = buys.fold(
          0,
          (max, e) => (e.q ?? 0) > max ? (e.q ?? 0) : max,
        );
        final int maxSellQty = sells.fold(
          0,
          (max, e) => (e.q ?? 0) > max ? (e.q ?? 0) : max,
        );

        return CustomScrollView(
          key: const PageStorageKey<String>('market_depth_scroll'),
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  AppSpace.spaceH8,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _MarketDepthSummaryCard(
                      totalBuyQty: totalBuyQty,
                      totalSellQty: totalSellQty,
                    ),
                  ),
                  AppSpace.spaceH10,
                  const DepthTableHeader(),
                ],
              ),
            ),

            _OrderBookSliverList(
              buys: buys,
              sells: sells,
              maxBuyQty: maxBuyQty,
              maxSellQty: maxSellQty,
            ),

            // NEW: লিস্টের ঠিক নিচে Market Depth Mountain Chart যুক্ত করা হলো
            if (buys.isNotEmpty || sells.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  child: _MarketDepthChart(buys: buys, sells: sells),
                ),
              ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// 1. Summary Card & Buy/Sell Ratio Bar
// =============================================================================
class _MarketDepthSummaryCard extends StatelessWidget {
  final int totalBuyQty;
  final int totalSellQty;

  const _MarketDepthSummaryCard({
    required this.totalBuyQty,
    required this.totalSellQty,
  });

  @override
  Widget build(BuildContext context) {
    final int grandTotal = totalBuyQty + totalSellQty;
    final double buyRatio = grandTotal > 0 ? (totalBuyQty / grandTotal) : 0.5;

    final int buyFlex = (buyRatio * 100).round();
    final int sellFlex = 100 - buyFlex;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.tapBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Buy",
                      style: Get.textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        NumberFormatter.bdFormatInt(totalBuyQty),
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.isDark ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "VS",
                  style: Get.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Total Sell",
                      style: Get.textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        NumberFormatter.bdFormatInt(totalSellQty),
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpace.spaceH8,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 5,
              child: Row(
                children: [
                  if (buyFlex > 0)
                    Expanded(
                      flex: buyFlex,
                      child: Container(color: ColorConstants.success),
                    ),
                  const SizedBox(width: 2),
                  if (sellFlex > 0)
                    Expanded(
                      flex: sellFlex,
                      child: Container(color: ColorConstants.error),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 2. Minimalist Depth Table Header
// =============================================================================
class DepthTableHeader extends StatelessWidget {
  const DepthTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.isDark ? Colors.black12 : Colors.grey[100],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Qty',
                  style: Get.textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
                Text(
                  'Bid',
                  style: Get.textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ask',
                  style: Get.textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
                Text(
                  'Qty',
                  style: Get.textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 3. Order Book List (Converted to SliverList to fix Overflow)
// =============================================================================
class _OrderBookSliverList extends StatelessWidget {
  final List<MarketDepthModel> buys;
  final List<MarketDepthModel> sells;
  final int maxBuyQty;
  final int maxSellQty;

  const _OrderBookSliverList({
    required this.buys,
    required this.sells,
    required this.maxBuyQty,
    required this.maxSellQty,
  });

  @override
  Widget build(BuildContext context) {
    final int itemLength = buys.length > sells.length
        ? buys.length
        : sells.length;

    if (itemLength == 0) {
      // 👈 Empty state now uses SliverToBoxAdapter
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Center(
            child: Text(
              'No Market Depth Available',
              style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // 👈 ListView.builder এর বদলে SliverList ব্যবহার করা হলো
    return SliverPadding(
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final buyItem = index < buys.length ? buys[index] : null;
            final sellItem = index < sells.length ? sells[index] : null;

            return SizedBox(
              height: 26,
              child: Row(
                children: [
                  Expanded(
                    child: buyItem != null
                        ? BidRowItem(model: buyItem, maxQty: maxBuyQty)
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: sellItem != null
                        ? AskRowItem(model: sellItem, maxQty: maxSellQty)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
          childCount: itemLength, // মোট আইটেম সংখ্যা
        ),
      ),
    );
  }
}

// =============================================================================
// Bid (Buy) Row Item (Centered Gradient Depth Bar)
// =============================================================================
class BidRowItem extends StatelessWidget {
  final MarketDepthModel model;
  final int maxQty;
  final VoidCallback? onTap;

  const BidRowItem({
    super.key,
    required this.model,
    required this.maxQty,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int qty = model.q ?? 0;
    final double fillPercentage = maxQty > 0
        ? (qty / maxQty).clamp(0.0, 1.0)
        : 0.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: fillPercentage,
            heightFactor: 0.85,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorConstants.success.withOpacity(0.05),
                    ColorConstants.success.withOpacity(0.25),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(4),
                ),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 3,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: LiveProBlinker(
                      // ব্লিঙ্কার অ্যাড করা হলো
                      trackValue: qty.toDouble(),
                      child: Text(
                        NumberFormatter.bdFormatInt(qty),
                        style: Get.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                // Flexible(
                //   flex: 3,
                //   child: FittedBox(
                //     fit: BoxFit.scaleDown,
                //     alignment: Alignment.centerLeft,
                //     child: Text(
                //       NumberFormatter.bdFormatInt(qty),
                //       style: Get.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
                //     ),
                //   ),
                // ),
                const SizedBox(width: 4),
                Flexible(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      model.p != null ? model.p!.toStringAsFixed(2) : '0.00',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: ColorConstants.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Ask (Sell) Row Item (Centered Gradient Depth Bar)
// =============================================================================
class AskRowItem extends StatelessWidget {
  final MarketDepthModel model;
  final int maxQty;
  final VoidCallback? onTap;
  const AskRowItem({
    super.key,
    required this.model,
    required this.maxQty,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int qty = model.q ?? 0;
    final double fillPercentage = maxQty > 0
        ? (qty / maxQty).clamp(0.0, 1.0)
        : 0.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: fillPercentage,
            heightFactor: 0.80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorConstants.error.withOpacity(0.25),
                    ColorConstants.error.withOpacity(0.05),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(4),
                ),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      model.p != null ? model.p!.toStringAsFixed(2) : '0.00',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: ColorConstants.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  flex: 3,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: LiveProBlinker(
                      trackValue: qty.toDouble(),
                      child: Text(
                        NumberFormatter.bdFormatInt(qty),
                        style: Get.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MarketDepthChart extends StatelessWidget {
  final List<MarketDepthModel> buys;
  final List<MarketDepthModel> sells;

  const _MarketDepthChart({required this.buys, required this.sells});

  @override
  Widget build(BuildContext context) {
    final List<MarketDepthModel> chartBuys = buys.reversed.toList();
    final List<MarketDepthModel> chartSells = sells;

    // পারফেক্ট Mid-Price ক্যালকুলেশন
    final double highestBid = chartBuys.isNotEmpty
        ? (chartBuys.last.p ?? 0.0)
        : 0.0;
    final double lowestAsk = chartSells.isNotEmpty
        ? (chartSells.first.p ?? 0.0)
        : 0.0;

    double midPrice = 0.0;
    if (highestBid > 0 && lowestAsk > 0) {
      midPrice = (highestBid + lowestAsk) / 2;
    } else if (highestBid > 0) {
      midPrice = highestBid;
    } else {
      midPrice = lowestAsk;
    }

    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: context.isDark ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      // FIX: বামদিকে (left: 10) প্যাডিং দেওয়া হলো যাতে চার্ট বর্ডারের সাথে না লেগে থাকে
      padding: const EdgeInsets.only(top: 15, right: 10, bottom: 5, left: 10),
      child: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,

        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enablePanning: true,
          zoomMode: ZoomMode.x,
        ),

        trackballBehavior: TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          lineType: TrackballLineType.vertical,
          lineColor: context.isDark ? Colors.white30 : Colors.black26,
          tooltipSettings: InteractiveTooltip(
            enable: true,
            color: context.isDark ? Colors.grey.shade900 : Colors.black87,
            format: 'series.name\nPrice: point.x\nQty: point.y',
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            borderRadius: 6,
          ),
        ),

        primaryXAxis: NumericAxis(
          // FIX: X-অক্ষের শেষের দিকের লেবেলগুলো যেন বাইরে না যায় (Shift to inside)
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 0.5, color: Colors.grey),
          labelStyle: Get.textTheme.labelSmall?.copyWith(
            color: Colors.grey,
            fontSize: 10,
          ),

          axisLabelFormatter: (AxisLabelRenderDetails details) {
            return ChartAxisLabel(
              details.value.toStringAsFixed(2),
              details.textStyle,
            );
          },

          plotBands: <PlotBand>[
            if (midPrice > 0)
              PlotBand(
                isVisible: true,
                start: midPrice,
                end: midPrice,
                borderColor: context.isDark ? Colors.white54 : Colors.black54,
                borderWidth: 1.5,
                dashArray: const <double>[4, 4],
                text: 'Mid',
                textStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                verticalTextAlignment: TextAnchor.end,
                horizontalTextAlignment: TextAnchor.start,
              ),
          ],
        ),

        primaryYAxis: NumericAxis(
          opposedPosition: true,
          // FIX: Y-অক্ষের লেবেল যেন ডানদিকের বর্ডারের বাইরে না যায়
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          majorGridLines: MajorGridLines(
            width: 0.5,
            color: Colors.grey.withOpacity(0.15),
            dashArray: const [4, 4],
          ),
          axisLine: const AxisLine(width: 0),
          labelStyle: Get.textTheme.labelSmall?.copyWith(
            color: Colors.grey,
            fontSize: 10,
          ),

          // PRO FORMATTER: Y-অক্ষের কোয়ান্টিটিকে স্মার্ট K, M, B ফরম্যাটে দেখানো
          axisLabelFormatter: (AxisLabelRenderDetails details) {
            double value = details.value.toDouble();
            String formattedValue = '';

            if (value >= 1000000000) {
              formattedValue = '${(value / 1000000000).toStringAsFixed(1)}B';
            } else if (value >= 1000000) {
              formattedValue = '${(value / 1000000).toStringAsFixed(1)}M';
            } else if (value >= 1000) {
              formattedValue = '${(value / 1000).toStringAsFixed(1)}K';
            } else {
              formattedValue = value.toInt().toString();
            }

            // ক্লিনিং: যদি 1.0K বা 5.0M আসে, তবে .0 মুছে দিয়ে 1K বা 5M বানাবে
            formattedValue = formattedValue
                .replaceAll('.0K', 'K')
                .replaceAll('.0M', 'M')
                .replaceAll('.0B', 'B');

            return ChartAxisLabel(formattedValue, details.textStyle);
          },
        ),

        series: <CartesianSeries>[
          StepAreaSeries<MarketDepthModel, double>(
            dataSource: chartBuys,
            xValueMapper: (MarketDepthModel data, _) => data.p ?? 0.0,
            yValueMapper: (MarketDepthModel data, _) => data.cq ?? 0,
            name: 'Bid',
            borderColor: ColorConstants.success,
            borderWidth: 1.5,
            animationDuration: 0,
            gradient: LinearGradient(
              colors: [
                ColorConstants.success.withOpacity(0.3),
                ColorConstants.success.withOpacity(0.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          StepAreaSeries<MarketDepthModel, double>(
            dataSource: chartSells,
            xValueMapper: (MarketDepthModel data, _) => data.p ?? 0.0,
            yValueMapper: (MarketDepthModel data, _) => data.cq ?? 0,
            name: 'Ask',
            borderColor: ColorConstants.error,
            borderWidth: 1.5,
            animationDuration: 0,
            gradient: LinearGradient(
              colors: [
                ColorConstants.error.withOpacity(0.3),
                ColorConstants.error.withOpacity(0.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
        annotations: <CartesianChartAnnotation>[
          if (highestBid > 0 && lowestAsk > 0)
            CartesianChartAnnotation(
              widget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? Colors.grey.shade800.withOpacity(0.8)
                      : Colors.grey.shade200.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Text(
                  'Spread: ${(lowestAsk - highestBid).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              coordinateUnit: CoordinateUnit.percentage,
              x: '50%', // X-অক্ষের ঠিক মাঝখানে
              y: '10%', // Y-অক্ষের একদম ওপরে
            ),
        ],
      ),
    );
  }
}
