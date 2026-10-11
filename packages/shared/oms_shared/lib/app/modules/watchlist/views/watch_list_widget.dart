import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/watchlist_controller.dart';
import '../../../core/utils/extensions/app_context.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/utils/helpers/log_helper.dart';
import '../../../core/values/assets.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/space.dart';
import '../../../core/values/storage.dart';
import '../../../core/values/strings.dart';
import '../../../data/models/response/market_model.dart';
import '../../../data/services/storage_service.dart';
import '../../../global_widgets/common_market_logic.dart';
import '../../../global_widgets/custom_app_bar.dart';
import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/custom_drawer.dart';
import '../../../global_widgets/custom_edit_text_form_field.dart';
import '../../../global_widgets/shared_market_components.dart';
import '../../../global_widgets/visible_get_builder.dart';
import '../../home/controllers/home_controller.dart';

import '../../../data/models/request/add_fav_item_request.dart' show AddFavItemRequest;

import '../../../global_widgets/empty_widget.dart';
import '../../../global_widgets/loaders/watchlist_loader.dart';

class WatchListWidget extends StatelessWidget {
  const WatchListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<WatchListController>()) Get.put(WatchListController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final dividerWidget = Divider(height: 1, color: context.dividerColor);

    return VisibleGetBuilder<WatchListController>(
      id: 'watchListUI',
      builder: (controller) {
        return Scaffold(
          key: scaffoldKey,
          drawer: const CustomDrawer(),
          appBar: CustomAppBar(
            titleText: 'Watch List',
            backButtonOnClick: () {
              final state = scaffoldKey.currentState;
              if (state == null) return;
              state.isDrawerOpen ? state.openEndDrawer() : state.openDrawer();
            },
            right: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () async {
                      if (await StorageService.read(StorageConstants.token) ==
                          null) {
                        Helpers.showLoginRequiredDialog();
                      } else {
                        _showCreateWatchListDialog(context, controller);
                      }
                    },
                    child: SvgPicture.asset(
                      AssetsConstants.addIconSvg,
                      height: 18,
                      width: 18,
                      colorFilter: ColorFilter.mode(
                        context.iconDefColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.toggleListGrid,
                    icon: Icon(
                      controller.isGridView ? Icons.view_list : Icons.grid_view,
                      color: context.iconDefColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.refreshWatchList();
            },
            child: Column(
              children: [
                if (controller.homeCon.filtersSectorList.length > 1)
                  CommonHorizontalTabList(
                    items: controller.homeCon.filtersSectorList
                        .map((e) => e.toString())
                        .toList(),
                    selectedItem: controller.selectSector,
                    onSelected: (val) {
                      controller.searchSector(val);
                      controller.searchController.clear();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                AppSpace.spaceH6,
                _WatchListSearchBar(watchCon: controller),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Board:",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 6),
                        CommonMinimalDropdown(
                          currentValue:
                              controller.selectedBoard, // All, Main, SME
                          items: const ['All', 'Main', 'SME'],
                          onSelected: controller.updateBoardFilter,
                          widthDropdown: 80,
                        ),
                        const SizedBox(width: 12),

                        Text(
                          "Type:",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 6),
                        CommonMinimalDropdown(
                          currentValue: controller
                              .selectedMarketType, // All, Public, Spot
                          items: const ['All', 'Public', 'Spot'],
                          onSelected: controller.updateMarketTypeFilter,
                          widthDropdown: 90,
                        ),
                        const SizedBox(width: 12),

                        Text(
                          "Category:",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 6),
                        CommonMinimalDropdown(
                          currentValue: controller
                              .selectedShareType, // All, A, B, N, P, S, Z
                          items: const ['All', 'A', 'B', 'N', 'P', 'S', 'Z'],
                          onSelected: controller.updateShareTypeFilter,
                          widthDropdown: 70,
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Sort by:",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        CommonMinimalDropdown(
                          currentValue: controller.currentSortCategory,
                          items: const [
                            'A-Z',
                            'Change(%)',
                            'Value',
                            'Volume',
                            'Trade',
                            'Price',
                            'Paidup',
                          ],
                          onSelected: controller.updateSortCategory,
                          widthDropdown: 130,
                        ),
                        AppSpace.spaceW8,
                        CommonMinimalDropdown(
                          currentValue: controller.currentSortOrder,
                          items: const ['ASC', 'DESC'],
                          onSelected: controller.updateSortOrder,
                          widthDropdown: 90,
                        ),
                        const SizedBox(width: 8),
                        CommonMinimalDropdown(
                          currentValue: controller.currentViewMode,
                          items:
                              controller.viewModes, // Default, Small, Classic
                          onSelected: controller.updateViewMode,
                          widthDropdown: 100,
                        ),
                        const SizedBox(width: 12),

                        // 🚀 Reset Filter Button
                        InkWell(
                          onTap: controller.resetFilters,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ), // 👈 ড্রপডাউনের সাইজের সাথে মিল রাখা হয়েছে
                            decoration: BoxDecoration(
                              color: context.isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: context.isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.refresh_rounded,
                                  size: 15,
                                  color: Colors.blueAccent,
                                ), // 👈 সফট ব্লু কালার
                                const SizedBox(width: 4),
                                Text(
                                  "Reset",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: context
                                        .textColor, // 👈 থিমের টেক্সট কালার
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpace.spaceH6,
                dividerWidget,
                Expanded(
                  child: controller.isLoading
                      ? const WatchlistLoader()
                      : controller.filteredItems.isEmpty
                      ? const Center(
                          child: EmptyWidget(title: 'No items found.'),
                        )
                      : (!controller.isGridView
                            ? ListView.separated(
                                controller: controller.scrollController,
                                itemCount: controller.filteredItems.length,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 8,
                                ),
                                separatorBuilder: (_, __) => dividerWidget,
                                itemBuilder: (context, index) {
                                  final model = controller.filteredItems[index];

                                  return SharedMarketListItem(
                                    model: model,
                                    index: index,
                                    viewMode: controller.currentViewMode,
                                    searchQuery: controller.currentSearchQuery, // 🚀 Highlights search query
                                    onTap: () {
                                      if (model.orderBook != null) {
                                        printLog(
                                          'item list::: ${model.toJson()}',
                                        );
                                        controller.homeCon.goBottomNabBarPage(
                                          1,
                                          model.orderBook!,
                                        );
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        controller.searchController.clear();
                                        controller.homeCon
                                            .loadComanyDividentEPS(
                                              model.shortName ?? "",
                                            );
                                      }
                                    },
                                    onLongPress: () {
                                      if (model.orderBook != null) {
                                        MarketDialogHelper.showBuySellDialog(
                                          context: context,
                                          orderBookId: model.orderBook!,
                                          shortName: model.shortName ?? "",
                                        );
                                      }
                                    },
                                    onFavoriteTap: () =>
                                        MarketDialogHelper.showFavouriteBottomSheet(
                                          context,
                                          model,
                                        ),
                                  );
                                },
                              )
                            : GridView.builder(
                                controller: controller.scrollController,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 6,
                                      crossAxisSpacing: 10,
                                      childAspectRatio: 1.30,
                                    ),
                                itemCount: controller.filteredItems.length,
                                itemBuilder: (context, idx) {
                                  final model = controller.filteredItems[idx];
                                  return SharedMarketGridItem(
                                    model: model,
                                    onTap: () {
                                      if (model.orderBook != null) {
                                        controller.homeCon.goBottomNabBarPage(
                                          1,
                                          model.orderBook!,
                                        );
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        controller.searchController.clear();
                                      }
                                    },
                                    onLongPress: () {
                                      if (model.orderBook != null) {
                                        MarketDialogHelper.showBuySellDialog(
                                          context: context,
                                          orderBookId: model.orderBook!,
                                          shortName: model.shortName ?? "",
                                        );
                                      }
                                    },
                                    onFavoriteTap: () =>
                                        MarketDialogHelper.showFavouriteBottomSheet(
                                          context,
                                          model,
                                        ),
                                  );
                                },
                              )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateWatchListDialog(
    BuildContext context,
    WatchListController watchCon,
  ) {
    Helpers.customShowDialog(
      context,
      title: 'Create New Watchlist',
      fontSize: 15,
      barrierDismissible: false,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: context.tapBg,
            ),
            child: SizedBox(
              height: 105,
              width: MediaQuery.sizeOf(context).width,
              child: TextFormField(
                controller: watchCon.watchlistTextEditField,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(
                    left: 15,
                    bottom: 11,
                    top: 11,
                    right: 15,
                  ),
                  hintText: "DSES ..",
                  hintStyle: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
        ),
        AppSpace.spaceH20,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    Get.back();
                    if (watchCon.watchlistTextEditField.text.isNotEmpty) {
                      watchCon.watchlistTextEditField.clear();
                    }
                  },
                  title: "Cancel",
                  backgroundColor: ColorConstants.error,
                ),
              ),
              AppSpace.spaceW10,
              Expanded(
                child: GetBuilder<HomeController>(
                  builder: (homeLogic) {
                    if (homeLogic.isCreateFavCat) {
                      return const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Colors.red,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    return CustomButton(
                      isLoading: homeLogic.isCreateFavCat,
                      onPressed: () {
                        if (watchCon.watchlistTextEditField.text.isEmpty) {
                          Helpers.snackbarForErorr2(
                            bodyText: 'Please enter a name',
                          );
                        } else {
                          homeLogic.watchlistTextEditField.text =
                              watchCon.watchlistTextEditField.text;
                          homeLogic.createFavCategory();
                        }
                      },
                      title: "Save",
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        AppSpace.spaceH20,
      ],
    );
  }

}

class _WatchListSearchBar extends StatelessWidget {
  const _WatchListSearchBar({required this.watchCon});
  final WatchListController watchCon;

  @override
  Widget build(BuildContext context) {
    return VisibleGetBuilder<WatchListController>(
      id: 'watchListUI',
      builder: (controller) {
        final bool hasText = controller.searchController.text.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: CustomEditTextFormField(
                    controller: controller.searchController,
                    cursorHeight: 16,
                    cursorWidth: 1.5,
                    prefixIcon: AssetsConstants.searchIconSvg,
                    hintText: StringConstants.stocksShares,
                    hintStyle: TextStyle(
                      color: context.textColor.withOpacity(0.5),
                      fontSize: 13,
                    ),
                    onChanged: (String value) {
                      // Handled by listener
                    },
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: hasText ? 65 : 0,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      controller.searchController.clear();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Container(
                      height: 42,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(left: 12.0),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
                final favCat = homeCont.favCatList.elementAt(index);
                final isSelected = homeCont.selectFavCatId == favCat.id;

                return InkWell(
                  key: ValueKey(favCat),
                  onTap: () => homeCont.changeFavCatId(favCat.id!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? context.evenColor : context.oddColor,
                    ),
                    child: Text(
                      '${favCat.name}',
                      style: Get.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: isSelected
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
          return Padding(
            padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
            child: homeCon.isAddFavCat
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(80, 40),
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
                              homeCon.addMarketDataToFav(requestData);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.greenColor,
                            minimumSize: const Size(80, 40),
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
