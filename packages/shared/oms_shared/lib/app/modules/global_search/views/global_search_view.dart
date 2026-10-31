import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../core/utils/extensions/app_context.dart';
import '../../../core/utils/extensions/market_model_extensions.dart';
import '../../../core/utils/helpers/formatter_helper.dart';
import '../../../core/values/assets.dart';
import '../../../core/values/space.dart';
import '../../../core/values/strings.dart';
import '../../../data/models/response/market_model.dart';
import '../../../global_widgets/common_market_logic.dart';
import '../../../global_widgets/shared_market_components.dart';
import '../controllers/global_search_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../top_share/views/live_value_blinker.dart';
import '../../../global_widgets/loaders/watchlist_loader.dart';
import '../../../global_widgets/exchange/exchange_switcher.dart';

class GlobalSearchScreen extends HookWidget {
  const GlobalSearchScreen({super.key});

  Widget _buildMinimalDropdown({
    required GlobalSearchController controller,
    required String id,
    required String currentValue,
    required List<String> items,
    required Function(String) onSelected,
    required BuildContext ctx,
    required double widthDropdown,
  }) {
    return GetBuilder<GlobalSearchController>(
      id: id,
      builder: (ctrl) {
        final isDark = ctx.isDark;

        return DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            customButton: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(13) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.white.withAlpha(20) : Colors.grey.shade200, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentValue,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ctx.textColor),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey[600]),
                ],
              ),
            ),
            items: items.map((item) {
              final isSelected = currentValue == item;
              final isLast = item == items.last;
              return DropdownItem<String>(
                value: item,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : Border(
                            bottom: BorderSide(color: isDark ? Colors.white.withAlpha(13) : Colors.grey.shade200),
                          ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? Colors.blueAccent : ctx.textColor,
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
                color: ctx.cardColor,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketRow(
    MarketModel model,
    int index,
    BuildContext context,
    GlobalSearchController searchCon,
    TextEditingController textCon,
  ) {
    final homeCon = Get.find<HomeController>();
    final favList = homeCon.isFav(model.orderBook ?? 0);

    // 🚀 Extension Properties ব্যবহার করা হয়েছে
    final double absoluteChange = model.absoluteChange;
    final double percentChange = model.percentageChange;
    final double currentPrice = model.activePrice;

    final String viewMode = searchCon.currentViewMode;

    Widget childWidget;

    if (viewMode == 'Classic') {
      final Color priceColor = absoluteChange > 0
          ? const Color(0xFF00A25B)
          : (absoluteChange < 0 ? const Color(0xFFE53935) : Colors.grey.shade500);
      childWidget = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    // 🚀 Extension displayName ব্যবহার করা হয়েছে
                    children: [
                      ...SharedMarketLogic.buildHighlightText(model.displayName, textCon.text, context, fontSize: 14),
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
                ),
                const SizedBox(height: 2),
                Text(
                  model.sector ?? model.group ?? "",
                  style: TextStyle(fontSize: 11, color: context.textColor.withAlpha(128)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentPrice.toStringAsFixed(2),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: priceColor),
              ),
              const SizedBox(height: 2),
              Text(
                '${absoluteChange > 0 ? "+" : ""}${absoluteChange.toStringAsFixed(2)} (${percentChange.toStringAsFixed(2)}%)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: priceColor),
              ),
            ],
          ),
        ],
      );
    } else if (viewMode == 'Small') {
      childWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    // 🚀 Extension displayName ব্যবহার করা হয়েছে
                    children: [
                      ...SharedMarketLogic.buildHighlightText(model.displayName, textCon.text, context, fontSize: 14),
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
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "Vol:${NumberFormatter.bdFormat((model.volume ?? 0).toDouble())}, ",
                      style: TextStyle(fontSize: 10, color: context.textColor.withAlpha(153)),
                    ),
                    Text(
                      "Val:${NumberFormatter.croreFormat(model.val ?? 0.0)}",
                      style: TextStyle(fontSize: 10, color: context.textColor.withAlpha(153)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: favList
                ? const Icon(Icons.favorite, color: Colors.red, size: 16)
                : SvgPicture.asset(AssetsConstants.loveIconSvg, width: 14, height: 14),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentPrice.toStringAsFixed(2),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textColor),
              ),
              const SizedBox(height: 2),
              Text(
                '${percentChange.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: NumberHelper.getColor(percentChange),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
                              textCon.text,
                              context,
                              fontSize: 14,
                            ),
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
              onTap: () => Get.snackbar("Watchlist", "${model.shortName} added!", snackPosition: SnackPosition.BOTTOM),
              child: favList
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
      onTap: () {
        // 🚀 아이টেম 탭 시 ID 저장
        searchCon.addToRecent(model);
        Get.back(result: model);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: viewMode == 'Small' ? 8.0 : (viewMode == 'Classic' ? 12.0 : 10.0),
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.borderColor.withAlpha(128), width: 1)),
        ),
        child: childWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchCon = Get.find<GlobalSearchController>();
    final textController = useTextEditingController();
    final focusNode = useFocusNode();

    // 🚀 Text Listener for dynamically showing/hiding Recents vs Live Search
    final textValue = useValueListenable(textController);
    final isTextEmpty = textValue.text.isEmpty;

    useEffect(() {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!focusNode.hasFocus && context.mounted) focusNode.requestFocus();
      });
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leadingWidth: 50,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 4),
              Text(
                "Back",
                style: TextStyle(color: context.buttonColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              // DSE | CSE; shows only for houses on both exchanges.
              const ExchangeSwitcher(padding: EdgeInsets.only(right: 8)),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.tapBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.borderColor, width: 0.5),
                  ),
                  child: TextField(
                    controller: textController,
                    focusNode: focusNode,
                    onChanged: searchCon.searchData,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(color: context.textColor, fontSize: 13, fontWeight: FontWeight.w600),
                    cursorColor: context.buttonColor,
                    decoration: InputDecoration(
                      hintText: StringConstants.stocksShares,
                      hintStyle: TextStyle(color: context.textColor.withAlpha(128), fontSize: 13),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: context.textColor.withAlpha(128), size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.horizontal,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: !isTextEmpty
                    ? GestureDetector(
                        key: const ValueKey('cancel_btn'),
                        onTap: () {
                          textController.clear();
                          searchCon.searchData('');
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: context.buttonColor, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty_btn')),
              ),
            ],
          ),
        ),
      ),
      body: GetBuilder<GlobalSearchController>(
        id: 'searchList',
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sorting and View Mode Dropdowns
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text("Sort:", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    const SizedBox(width: 8),
                    CommonMinimalDropdown(
                      currentValue: controller.currentSortCategory,
                      items: const ['A-Z', 'Change(%)', 'Value', 'Volume', 'Trade', 'Price', 'Paidup'],
                      onSelected: controller.updateSortCategory,
                      widthDropdown: 130,
                    ),
                    AppSpace.spaceW8,
                    _buildMinimalDropdown(
                      controller: controller,
                      id: 'sortOrderDropdown',
                      currentValue: controller.currentSortOrder,
                      items: const ['ASC', 'DESC'],
                      onSelected: controller.updateSortOrder,
                      ctx: context,
                      widthDropdown: 90,
                    ),
                    const SizedBox(width: 16),
                    Text("View:", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    const SizedBox(width: 8),
                    CommonMinimalDropdown(
                      currentValue: controller.currentViewMode,
                      items: controller.viewModes,
                      onSelected: controller.updateViewMode,
                      widthDropdown: 100,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: context.dividerColor),

              // Loading State
              if (controller.filteredItems.isEmpty && Get.find<HomeController>().shownMarket.quotes.isEmpty)
                const Expanded(
                  child: WatchlistLoader(), // 🚀 সাধারণ স্পিনারের বদলে প্রিমিয়াম শিমার লোডার
                )
              else if (isTextEmpty && controller.recentSearches.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 8.0, right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "RECENT SEARCHES",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: context.textColor.withAlpha(128),
                          letterSpacing: 0.5,
                        ),
                      ),
                      InkWell(
                        onTap: () => controller.clearRecent(),
                        child: Text(
                          "CLEAR",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: context.textColor.withAlpha(153),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.recentSearches.length,
                    itemBuilder: (context, index) =>
                        _buildMarketRow(controller.recentSearches[index], index, context, controller, textController),
                  ),
                ),
              ]
              else ...[
                if (controller.filteredItems.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 60, color: context.textColor.withAlpha(51)),
                          const SizedBox(height: 12),
                          Text(
                            "No stock found",
                            style: TextStyle(
                              color: context.textColor.withAlpha(128),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.filteredItems.length,
                      itemBuilder: (context, index) {
                        final model = controller.filteredItems[index];
                        return SharedMarketListItem(
                          model: model,
                          index: index,
                          viewMode: controller.currentViewMode,

                          searchQuery: controller.currentSearchQuery,

                          onTap: () {
                            controller.addToRecent(model);
                            Get.back(result: model);
                          },
                          onFavoriteTap: () => MarketDialogHelper.showFavouriteBottomSheet(context, model),
                        );
                      },
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
