import 'dart:math' as math;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../app_pkg.dart';
import 'google_finance_sparkline.dart';
import '../modules/top_share/views/live_value_blinker.dart';

// ==========================================
// 🚀 ১. Common Minimal Dropdown
// ==========================================
class CommonMinimalDropdown extends StatelessWidget {
  final String currentValue;
  final List<String> items;
  final Function(String) onSelected;
  final double widthDropdown;
  final double? heightDropdownButton;
  final bool isExpanded;

  const CommonMinimalDropdown({
    super.key,
    required this.currentValue,
    required this.items,
    required this.onSelected,
    this.widthDropdown = 100,
    this.heightDropdownButton = 30,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        customButton: Container(
          height: heightDropdownButton,
          width: isExpanded ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : context.tapBg,
            borderRadius: BorderRadius.circular(heightDropdownButton! >= 50 ? 14 : 8),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200, width: 1),
          ),
          child: Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: isExpanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                currentValue,
                style: TextStyle(
                  fontSize: heightDropdownButton! >= 50 ? 13 : 12,
                  fontWeight: FontWeight.w600,
                  color: context.textColor,
                ),
              ),
              if (!isExpanded) const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: heightDropdownButton! >= 50 ? 20 : 16,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        items: items.map((item) {
          final isSelected = currentValue == item;
          final isLast = item == items.last;
          return DropdownItem<String>(
            value: item,
            child: Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
                        ),
                      ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.blueAccent : context.textColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_rounded, color: Colors.blueAccent, size: 16),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) onSelected(value);
        },
        dropdownStyleData: DropdownStyleData(
          width: widthDropdown,
          padding: EdgeInsets.zero,
          offset: const Offset(0, -4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: context.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// ==========================================
class CommonHorizontalTabList extends StatelessWidget {
  final List<String> items;
  final String selectedItem;
  final Function(String) onSelected;

  const CommonHorizontalTabList({super.key, required this.items, required this.selectedItem, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final double dynamicGap = MediaQuery.of(context).size.width * 0.02;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.tapBg,
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200, width: 1),
        ),
      ),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: dynamicGap * 1.5),
        itemCount: items.length,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) {
          return Center(
            child: Container(
              width: 1,
              height: 14,
              margin: EdgeInsets.symmetric(horizontal: dynamicGap),
              color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey.shade300,
            ),
          );
        },
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedItem == item;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(item),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(horizontal: dynamicGap * 1.5, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? ColorConstants.buttonColorDark : ColorConstants.buttonColorLight)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? Colors.white : context.textColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// ==========================================

class SharedMarketListItem extends StatelessWidget {
  final MarketModel model;
  final int index;
  final String viewMode;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onFavoriteTap;
  final double? customPercentChange;
  final double? customAbsoluteChange;

  const SharedMarketListItem({
    super.key,
    required this.model,
    required this.index,
    required this.onTap,
    required this.onFavoriteTap,
    this.onLongPress,
    this.viewMode = 'Default',
    this.searchQuery = '',
    this.customPercentChange,
    this.customAbsoluteChange,
  });

  List<num> _generateSparklineData(MarketModel item, double currentPrice, double absoluteChange) {
    final double ycp = (item.reference != null && item.reference! > 0) ? item.reference! : currentPrice;
    if (ycp == 0 || currentPrice == 0) return [10, 10, 10];

    final double open = (item.open != null && item.open! > 0) ? item.open! : ycp;
    double high = (item.high != null && item.high! > 0) ? item.high! : math.max(open, currentPrice);
    double low = (item.low != null && item.low! > 0) ? item.low! : math.min(open, currentPrice);

    if (low > high) {
      double temp = low;
      low = high;
      high = temp;
    }

    double minVisualSpread = ycp * 0.005;
    if ((high - low) < minVisualSpread) {
      double mid = (high + low) / 2;
      high = mid + (minVisualSpread / 2);
      low = mid - (minVisualSpread / 2);
    }

    final double chartHigh = math.max(high, ycp);
    final double chartLow = math.min(low, ycp);

    final int seed = item.orderBook ?? (item.shortName?.hashCode ?? 0);
    final random = math.Random(seed);

    // 🚀 সরাসরি absoluteChange থেকে বুলিশ/বেয়ারিশ নির্ণয়
    bool isBullish = absoluteChange >= 0;
    List<double> keyAnchors = [];

    if (isBullish) {
      keyAnchors = [
        ycp,
        ycp - (ycp - low) * 0.4,
        low,
        ycp + (high - ycp) * 0.6,
        high,
        high - (high - currentPrice) * 0.3,
        currentPrice,
      ];
    } else {
      keyAnchors = [
        ycp,
        ycp + (high - ycp) * 0.4,
        high,
        ycp - (ycp - low) * 0.6,
        low,
        low + (currentPrice - low) * 0.3,
        currentPrice,
      ];
    }

    List<num> finalPath = [];
    int totalSteps = 20;

    for (int i = 0; i <= totalSteps; i++) {
      double t = i / totalSteps;
      double segment = t * (keyAnchors.length - 1);
      int idx = segment.floor();
      int nextIdx = math.min(idx + 1, keyAnchors.length - 1);
      double localT = segment - idx;

      double smoothT = (1 - math.cos(localT * math.pi)) / 2;
      double point = keyAnchors[idx] + (keyAnchors[nextIdx] - keyAnchors[idx]) * smoothT;

      if (i > 0 && i < totalSteps) {
        double noise = ((random.nextDouble() * 2) - 1) * ((high - low) * 0.15);
        point += noise;
      }

      finalPath.add(point.clamp(chartLow, chartHigh));
    }

    return finalPath;
  }

  @override
  Widget build(BuildContext context) {
    final isFav = Get.find<HomeController>().isFav(model.orderBook ?? 0);

    final double absoluteChange = customAbsoluteChange ?? model.absoluteChange;
    final double percentChange = customPercentChange ?? model.percentageChange;
    final double currentPrice = model.activePrice;

    Widget childWidget;

    if (viewMode == 'Classic') {
      childWidget = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Name & Sector
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      ...SharedMarketLogic.buildHighlightText(model.displayName, searchQuery, context, fontSize: 14),
                      if (model.shareType != null)
                        TextSpan(
                          text: ' [${model.shareType}]',
                          style: Get.textTheme.bodySmall?.copyWith(
                            fontSize: 8,
                            color: context.textColor,
                            fontFeatures: const [FontFeature.superscripts()],
                          ),
                        ),
                      if (model.marketType != null)
                        TextSpan(
                          text: ' [${model.marketType}]',
                          style: Get.textTheme.bodySmall?.copyWith(
                            fontSize: 8,
                            color: context.textColor,
                            fontFeatures: const [FontFeature.superscripts()],
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  model.sector ?? model.group ?? "",
                  style: TextStyle(fontSize: 11, color: context.textColor.withOpacity(0.5)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          //Google Finance Sparkline Chart
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GoogleFinanceSparkline(
                data: _generateSparklineData(model, currentPrice, absoluteChange),
                change: absoluteChange,
              ),
            ),
          ),

          // Price & Change
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LiveProBlinker(
                  trackValue: currentPrice,
                  child: Text(
                    currentPrice.toStringAsFixed(2),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textColor),
                  ),
                ),
                const SizedBox(height: 2),
                LiveProBlinker(
                  trackValue: absoluteChange,
                  child: Text(
                    '${NumberHelper.formatSigned(absoluteChange)} (${NumberHelper.formatSigned(percentChange)}%)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: NumberHelper.getColor(absoluteChange),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (viewMode == 'Small') {
      childWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //  1. Name, Vol, Val & Bid/Ask Pressure Bar
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      ...SharedMarketLogic.buildHighlightText(model.displayName, searchQuery, context, fontSize: 14),
                      if (model.shareType != null)
                        TextSpan(
                          text: ' [${model.shareType}]',
                          style: Get.textTheme.bodySmall?.copyWith(
                            fontSize: 8,
                            color: context.textColor,
                            fontFeatures: const [FontFeature.superscripts()],
                          ),
                        ),
                      if (model.marketType != null)
                        TextSpan(
                          text: ' [${model.marketType}]',
                          style: Get.textTheme.bodySmall?.copyWith(
                            fontSize: 8,
                            color: context.textColor,
                            fontFeatures: const [FontFeature.superscripts()],
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "Vol:${NumberFormatter.bdFormat((model.volume ?? 0).toDouble())}, ",
                      style: TextStyle(fontSize: 9, color: context.textColor.withOpacity(0.6)),
                    ),
                    Text(
                      "Val:${NumberFormatter.croreFormat(model.val ?? 0.0)}",
                      style: TextStyle(fontSize: 9, color: context.textColor.withOpacity(0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 🚀 Bid/Ask Pressure Bar যুক্ত করা হলো
                Row(
                  children: [
                    Text("B/A: ", style: TextStyle(fontSize: 9, color: context.textColor.withOpacity(0.5))),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: BidAskPressureBar(buyQty: model.bq ?? 0, sellQty: model.aq ?? 0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🚀 2. Day's Range Indicator
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: DayRangeIndicator(
                low: model.low ?? 0.0,
                high: model.high ?? 0.0,
                current: currentPrice,
                isPositive: absoluteChange >= 0,
              ),
            ),
          ),

          // 🚀 3. Favorite Icon
          Expanded(
            flex: 1,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onFavoriteTap,
              child: Center(
                child: isFav
                    ? const Icon(Icons.favorite, color: Colors.red, size: 16)
                    : SvgPicture.asset(AssetsConstants.loveIconSvg, width: 14, height: 14),
              ),
            ),
          ),

          // 🚀 4. Price & Percentage
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LiveProBlinker(
                  trackValue: currentPrice,
                  child: Text(
                    currentPrice.toStringAsFixed(2),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textColor),
                  ),
                ),
                const SizedBox(height: 2),
                LiveProBlinker(
                  trackValue: percentChange,
                  child: Text(
                    '${percentChange > 0 ? "+" : ""}${percentChange.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: NumberHelper.getColor(percentChange),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      childWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            ...SharedMarketLogic.buildHighlightText(
                              model.displayName,
                              searchQuery,
                              context,
                              fontSize: 14,
                            ),
                            TextSpan(
                              text: ' [${model.shareType}]',
                              style: Get.textTheme.bodySmall?.copyWith(
                                fontSize: 8,
                                color: context.textColor,
                                fontFeatures: const [FontFeature.superscripts()],
                              ),
                            ),
                            TextSpan(
                              text: ' [${model.marketType}]',
                              style: Get.textTheme.bodySmall?.copyWith(
                                fontSize: 8,
                                color: context.textColor,
                                fontFeatures: const [FontFeature.superscripts()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    LiveProBlinker(
                      trackValue: absoluteChange,
                      child: Text(
                        NumberHelper.formatSigned(absoluteChange),
                        style: Get.textTheme.titleSmall!.copyWith(
                          color: NumberHelper.getColor(absoluteChange),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpace.spaceH2,
                Row(
                  children: [
                    LiveProBlinker(
                      trackValue: (model.volume ?? 0).toDouble(),
                      child: Text(
                        "${index + 1} | Vol:${NumberFormatter.fixedDecimal2(model.volume ?? 0.0, decimal: 0)}, ",
                        style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                      ),
                    ),
                    LiveProBlinker(
                      trackValue: model.val ?? 0.0,
                      child: Text(
                        "Val:${NumberFormatter.croreFormat(model.val ?? 0.0)}, ",
                        style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                      ),
                    ),
                    Flexible(
                      child: LiveProBlinker(
                        trackValue: (model.trades ?? 0).toDouble(),
                        child: Text(
                          'Trd:${(model.trades ?? 0).toStringAsFixed(0)}',
                          maxLines: 1,
                          style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpace.spaceW6,
          Expanded(
            flex: 2,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onFavoriteTap,
              child: isFav
                  ? const Icon(Icons.favorite, color: Colors.red, size: 20)
                  : SvgPicture.asset(AssetsConstants.loveIconSvg, width: 16, height: 16),
            ),
          ),
          AppSpace.spaceW6,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              LiveProBlinker(
                trackValue: currentPrice,
                child: Text(
                  currentPrice.toStringAsFixed(2),
                  style: Get.textTheme.titleSmall!.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              AppSpace.spaceH2,
              LiveProBlinker(
                trackValue: percentChange,
                defaultColor: NumberHelper.getColor(percentChange),
                borderRadius: BorderRadius.circular(6),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  '${NumberHelper.formatSigned(percentChange)}%',
                  style: Get.textTheme.titleSmall!.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: viewMode == 'Small' ? 10.0 : (viewMode == 'Classic' ? 12.0 : 8.0),
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.borderColor.withOpacity(0.5), width: 1)),
        ),
        child: childWidget,
      ),
    );
  }
}

// ==========================================
// ==========================================
class SharedMarketGridItem extends StatelessWidget {
  final MarketModel model;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onFavoriteTap;

  const SharedMarketGridItem({
    super.key,
    required this.model,
    required this.onTap,
    required this.onFavoriteTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = Get.find<HomeController>().isFav(model.orderBook ?? 0);
    final double absoluteChange = model.absoluteChange;
    final double percentChange = model.percentageChange;
    final double currentPrice = model.activePrice;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.isDark ? ColorConstants.tapBgDark : ColorConstants.tapBgLight,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      model.displayName,
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: context.textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppSpace.spaceW4,
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onFavoriteTap,
                    child: isFav
                        ? const Icon(Icons.favorite, color: Colors.red, size: 20)
                        : SvgPicture.asset(AssetsConstants.loveIconSvg, width: 18, height: 18),
                  ),
                ],
              ),
              AppSpace.spaceH6,
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LiveProBlinker(
                            trackValue: (model.volume ?? 0).toDouble(),
                            child: Text(
                              'Vol: ${model.volume ?? '0'}',
                              style: Get.textTheme.bodyMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.w300),
                            ),
                          ),
                          LiveProBlinker(
                            trackValue: model.val ?? 0.0,
                            child: Text(
                              'Val: ${NumberFormatter.croreFormat(model.val ?? 0.0)}',
                              style: Get.textTheme.bodyMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.w300),
                            ),
                          ),
                          LiveProBlinker(
                            trackValue: (model.trades ?? 0).toDouble(),
                            child: Text(
                              'Trd: ${model.trades ?? "0"}',
                              style: Get.textTheme.bodyMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.w300),
                            ),
                          ),
                          AppSpace.spaceH4,
                          LiveProBlinker(
                            trackValue: percentChange,
                            defaultColor: NumberHelper.getColor(percentChange),
                            borderRadius: BorderRadius.circular(6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Text(
                              '${percentChange.toStringAsFixed(2)}%',
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpace.spaceW6,
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          LiveProBlinker(
                            trackValue: currentPrice,
                            child: Text(
                              NumberFormatter.bdFormat(currentPrice),
                              style: Get.textTheme.bodyMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                          AppSpace.spaceH2,
                          Text(
                            Helpers.formatTimeToString(model.lastTradeTime ?? ''),
                            style: Get.textTheme.bodyMedium?.copyWith(fontSize: 11),
                          ),
                          AppSpace.spaceH2,
                          Text(
                            model.group ?? "",
                            style: Get.textTheme.bodyMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.w300),
                          ),
                          AppSpace.spaceH4,
                          LiveProBlinker(
                            trackValue: absoluteChange,
                            defaultColor: NumberHelper.getColor(absoluteChange),
                            borderRadius: BorderRadius.circular(6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Text(
                              absoluteChange.toStringAsFixed(2),
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
