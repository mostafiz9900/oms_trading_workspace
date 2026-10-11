import '../../../core/utils/extensions/app_context.dart';
import '../../../core/utils/extensions/market_model_extensions.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/space.dart';
import '../../../global_widgets/common_market_logic.dart';
import '../../../global_widgets/custom_app_bar.dart';
import '../../../global_widgets/shared_market_components.dart';
import '../../home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global_widgets/appbar_right_search_tap.dart';
import '../controllers/top_share_controller.dart';
import '../../../global_widgets/loaders/watchlist_loader.dart';

class TopShareView extends GetView<TopShareController> {
  const TopShareView({super.key});

  @override
  Widget build(BuildContext context) {
    final dividerWidget = Divider(height: 1, color: context.dividerColor);

    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Top Shares',
        isBackButtonIcon: true,
        backButtonOnClick: () => Get.back(),
        right: AppbarRightSearchTapWidget(shouldPop: true),
      ),
      body: GetBuilder<TopShareController>(
        builder: (topShareCon) {
          if (topShareCon.pageLoad) {
            return const WatchlistLoader();
          }
          return Column(
            children: [
              _ShareSituationWidget(topShareCon: topShareCon),
              const SizedBox(height: 8),
              const _DurationFilterWidget(),
              AppSpace.spaceH4,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Expanded(child: _CustomShareFilterWidget()),
                    AppSpace.spaceW4,
                    CommonMinimalDropdown(
                      currentValue: topShareCon.currentViewMode,
                      items: topShareCon.viewModes,
                      onSelected: topShareCon.updateViewMode,
                      widthDropdown: 100,
                    ),
                  ],
                ),
              ),
              AppSpace.spaceH4,
              Expanded(
                child: ListView.separated(
                  itemCount: topShareCon.marketFeedSortList.length,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  itemBuilder: (context, index) {
                    final initialModel = topShareCon.marketFeedSortList[index];

                    if (initialModel.orderBook == null) return const SizedBox.shrink();

                    return GetBuilder<TopShareController>(
                      id: '${initialModel.orderBook}',
                      builder: (controller) {
                        // ইনডেক্সের ওপর ভরসা না করে সরাসরি orderBook দিয়ে লেটেস্ট ডাটা খুঁজুন
                        final latestModel = controller.marketFeedSortList.firstWhere(
                          (e) => e.orderBook == initialModel.orderBook,
                          orElse: () => initialModel, // যদি কোনো কারণে না পায়, তবে আগেরটাই দেখাবে
                        );

                        // 🚀 UI এর ডিউরেশন স্ট্রিং কে এক্সটেনশনের ফরমেটে ম্যাপ করার হেল্পার
                        String mapDurationToExt(String duration) {
                          switch (duration) {
                            case "Weekly":
                              return "1W";
                            case "15 Day":
                              return "2W";
                            case "Monthly":
                              return "1M";
                            case "6 Month":
                              return "6M";
                            case "Yearly":
                              return "1Y";
                            case "Daily":
                            default:
                              return "1D";
                          }
                        }

                        // 🚀 SharedMarketListItem কল করা হলো
                        return SharedMarketListItem(
                          model: latestModel,
                          index: index,
                          viewMode: controller.currentViewMode, // 🚀 কন্ট্রোলার থেকে ডাইনামিক ভিউ মোড
                          customPercentChange: latestModel.getChangeByDuration(
                            mapDurationToExt(controller.activeDurationFilter),
                          ), // 🚀 কাস্টম ডিউরেশনের ভ্যালু
                          onTap: () {
                            Get.find<HomeController>().goBottomNabBarPage(1, latestModel.orderBook!);
                            Get.find<HomeController>().loadComanyDividentEPS('${latestModel.shortName}');
                            Get.back();
                          },
                          onLongPress: () {
                            MarketDialogHelper.showBuySellDialog(
                              context: context,
                              orderBookId: latestModel.orderBook!,
                              shortName: latestModel.shortName ?? "",
                            );
                          },
                          onFavoriteTap: () {
                            MarketDialogHelper.showFavouriteBottomSheet(context, latestModel);
                          },
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, _) => dividerWidget,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DurationFilterWidget extends StatelessWidget {
  const _DurationFilterWidget();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TopShareController>(
      builder: (controller) {
        final List<String> mainFilters = const ["Daily", "Weekly", "15 Day", "Monthly"];
        final List<String> moreItems = const ["6 Month", "Yearly"];

        bool isMoreSelected = moreItems.contains(controller.activeDurationFilter);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              ...mainFilters.map((filter) {
                bool isSelected = controller.activeDurationFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (bool selected) => controller.setActiveDurationFilter(filter),
                    selectedColor: context.bgColor,
                    backgroundColor: context.bgColor,
                    visualDensity: const VisualDensity(horizontal: -2.0, vertical: -2.0),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.green : context.textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? Colors.green : context.borderColor),
                    ),
                    showCheckmark: false,
                  ),
                );
              }),

              PopupMenuButton<String>(
                offset: const Offset(0, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (String value) => controller.setActiveDurationFilter(value),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: isMoreSelected ? Colors.green : context.borderColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isMoreSelected ? controller.activeDurationFilter : "More",
                        style: TextStyle(
                          color: isMoreSelected ? Colors.green : context.textColor,
                          fontWeight: isMoreSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.unfold_more, size: 16, color: isMoreSelected ? Colors.green : Colors.blue.shade600),
                    ],
                  ),
                ),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      "More Options",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const PopupMenuDivider(),
                  ...moreItems.map((item) {
                    return PopupMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          fontWeight: controller.activeDurationFilter == item ? FontWeight.bold : FontWeight.normal,
                          color: controller.activeDurationFilter == item ? Colors.green : context.textColor,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CustomShareFilterWidget extends StatelessWidget {
  const _CustomShareFilterWidget();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TopShareController>(
      builder: (topShareCon) {
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 6,
          children: [
            InkWell(
              onTap: () {
                Helpers.openDropdownShare(
                  context,
                  height: Get.height * 0.6,
                  title: "Sector",
                  menuLists: topShareCon.sortByCompanyTypeMenuList,
                  selectedValue: topShareCon.activeSector,
                  onSelected: (value) => topShareCon.setActiveSector(value),
                );
              },
              child: _CustomChip(
                name: topShareCon.activeSector.isNotEmpty ? topShareCon.activeSector : "All",
                isShowIcon: true,
              ),
            ),
            InkWell(
              onTap: () {
                Helpers.openDropdownShare(
                  context,
                  height: 250,
                  title: "Sort By",
                  menuLists: topShareCon.sortByMenuList,
                  selectedValue: topShareCon.activeSortByCompany,
                  onSelected: (value) => topShareCon.setActiveSortByCompany(value),
                );
              },
              child: _CustomChip(name: topShareCon.activeSortByCompany, isShowIcon: true),
            ),
            InkWell(
              onTap: () {
                Helpers.openDropdownShare(
                  context,
                  height: 100,
                  title: "Order By",
                  menuLists: topShareCon.sortByAscDescMenuList,
                  selectedValue: topShareCon.activeSortByAscDesc,
                  onSelected: (value) => topShareCon.setActiveSortByAscDesc(value),
                );
              },
              child: _CustomChip(name: topShareCon.activeSortByAscDesc, isShowIcon: true),
            ),
          ],
        );
      },
    );
  }
}

class _CustomChip extends StatelessWidget {
  const _CustomChip({required this.name, this.isShowIcon = false});
  final String name;
  final bool isShowIcon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: context.bgColor,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      side: BorderSide(color: context.borderSideColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: Get.textTheme.bodyMedium?.copyWith(color: context.buttonColor, height: 1.1)),
          if (isShowIcon) ...[
            AppSpace.spaceW6,
            Icon(Icons.unfold_more_outlined, color: context.isDark ? Colors.white : hexToColor('#184A94'), size: 16),
          ],
        ],
      ),
    );
  }
}

class _ShareSituationWidget extends StatelessWidget {
  const _ShareSituationWidget({required this.topShareCon});
  final TopShareController topShareCon;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final double dynamicGap = MediaQuery.of(context).size.width * 0.02; // স্ক্রিনের ২%

    return Container(
      height: 40, // প্রফেশনাল হাইট
      decoration: BoxDecoration(
        color: context.tapBg,
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white.withAlpha(13) : Colors.grey.shade200, width: 1),
        ),
      ),
      // গ্যাপ এবং আইটেম আলাদাভাবে ম্যানেজ করার জন্য ListView.separated বেস্ট
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: dynamicGap * 1.5),
        itemCount: topShareCon.shareSituationList.length,
        scrollDirection: Axis.horizontal,

        separatorBuilder: (context, index) {
          return Center(
            // ভার্টিক্যালি সেন্টারে রাখার জন্য
            child: Container(
              width: 1,
              height: 14, // স্লিক ডিভাইডার হাইট
              margin: EdgeInsets.symmetric(horizontal: dynamicGap), // ডাইনামিক গ্যাপ
              color: isDark ? Colors.white.withAlpha(38) : Colors.grey.shade300,
            ),
          );
        },

        // মেইন মেনু আইটেম
        itemBuilder: (context, index) {
          final model = topShareCon.shareSituationList[index];
          final isSelected = topShareCon.activeTopMenuTopShare == model.name;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => topShareCon.setActiveTopMenuTopShare(model.name ?? ""),
            child: Center(
              // আইটেমকে ভার্টিক্যালি সেন্টারে রাখার জন্য
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                // বাটনের ভেতরের প্যাডিংও ডাইনামিক করা হয়েছে
                padding: EdgeInsets.symmetric(horizontal: dynamicGap * 1.5, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? ColorConstants.buttonColorDark : ColorConstants.buttonColorLight)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  model.name ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? Colors.white : context.textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
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

