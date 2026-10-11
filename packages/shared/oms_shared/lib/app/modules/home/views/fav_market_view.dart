import 'package:oms_shared/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../core/utils/helpers/formatter_helper.dart';
import '../../../global_widgets/empty_widget.dart';
import 'local_widgets/appbar_right_search_tap.dart';
import 'local_widgets/index_value_loader.dart';
// আপনার MarketModelExtensions ইম্পোর্ট করে নিবেন

class FavMarketView extends StatelessWidget {
  const FavMarketView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        titleText: 'Favourites',
        backButtonOnClick: () {
          final state = scaffoldKey.currentState;
          if (state == null) return;

          if (state.isDrawerOpen) {
            state.openEndDrawer();
          } else {
            state.openDrawer();
          }
        },
        right: Row(
          children: [
            CommonWidget.buySell(context: context, onTap: () => Get.find<HomeController>().changeCurrentIndex(5)),
            AppbarRightSearchTapWidget(),
          ],
        ),
      ),
      body: GetBuilder<HomeController>(
        builder: (homeCon) {
          if (homeCon.isGetFavCat && homeCon.favCatList.isEmpty) {
            return const WatchlistLoader();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonHorizontalTabList(
                items: homeCon.favCatList.map((e) => e.name ?? "").toList(),
                selectedItem: homeCon.favCatList.firstWhereOrNull((e) => e.id == homeCon.selectedTableId)?.name ?? "",
                onSelected: (val) {
                  final table = homeCon.favCatList.firstWhereOrNull((e) => e.name == val);
                  if (table != null) homeCon.selectTable(table.id ?? 0);
                },
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CommonMinimalDropdown(
                  currentValue: homeCon.favCurrentViewMode,
                  items: homeCon.viewModes,
                  onSelected: homeCon.updateFavViewMode,
                  widthDropdown: 100,
                ),
              ),

              const Divider(height: 1),

              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: homeCon.favCatList.map((table) {
              //       final isSelected = homeCon.selectedTableId == table.id;
              //       return Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //         child: InkWell(
              //           onTap: () => homeCon.selectTable(table.id ?? 0),
              //           child: Container(
              //             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              //             decoration: BoxDecoration(
              //               color: isSelected
              //                   ? Colors.blue
              //                   : context.isDark
              //                   ? context.unselectColor
              //                   : context.tableLightColor,
              //               borderRadius: BorderRadius.circular(12),
              //             ),
              //             child: Text(
              //               table.name ?? "",
              //               style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 14),
              //             ),
              //           ),
              //         ),
              //       );
              //     }).toList(),
              //   ),
              // ),

              // Market data list
              Expanded(
                child: homeCon.loadingFav
                    ? const WatchlistLoader()
                    : homeCon.favMarketParseList.isEmpty
                    ? const Center(child: EmptyWidget(title: "No favorite items yet"))
                    : ListView.builder(
                        itemCount: homeCon.favMarketParseList.length,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        itemBuilder: (context, index) {
                          final item = homeCon.favMarketParseList[index];
                          // return _MarketItemWidget(index: index, model: item);
                          return SharedMarketListItem(
                            model: item,
                            index: index,
                            viewMode: homeCon.favCurrentViewMode,
                            onTap: () {
                              homeCon.goBottomNabBarPage(1, item.orderBook!);
                              homeCon.loadComanyDividentEPS(item.shortName!);
                              FocusScope.of(context).unfocus();
                            },
                            onLongPress: () => MarketDialogHelper.showBuySellDialog(
                              context: context,
                              orderBookId: item.orderBook!,
                              shortName: item.shortName ?? "",
                            ),
                            onFavoriteTap: () {
                              // 🚀 এখানে ফেভারিট রিমুভ করার লজিক
                              Helpers.openCustomAlertDialog(() {
                                homeCon.unfavoriteMarketData(item.fvbId!);
                              }, title: 'Are You Sure Delete?');
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FavMarketFAB(
        onCreate: () {
          homeController.watchlistTextEditField.text = "";
          Helpers.customShowDialog(
            context,
            title: 'Create New List',
            fontSize: 15,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Container(
                  height: 105,
                  width: Get.width,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: context.tapBg),
                  child: TextFormField(
                    controller: homeController.watchlistTextEditField,
                    maxLines: 10,
                    onChanged: (String value) {},
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                      hintText: "Name ..",
                      hintStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
              AppSpace.spaceH20,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          homeController.watchlistTextEditField.clear();
                          Get.back();
                        },
                        title: "Cancel",
                        backgroundColor: ColorConstants.error,
                      ),
                    ),
                    AppSpace.spaceW10,
                    Expanded(
                      child: GetBuilder<HomeController>(
                        builder: (logic) {
                          return logic.isCreateFavCat == true
                              ? const Center(
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(color: Colors.red),
                                  ),
                                )
                              : CustomButton(
                                  isLoading: logic.isCreateFavCat,
                                  onPressed: () {
                                    if (homeController.watchlistTextEditField.text.isEmpty) {
                                      Helpers.snackbarForErorr2(bodyText: 'Please enter a name');
                                    } else {
                                      homeController.createFavCategory();
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
        },
        onRename: () {
          final selectedItem = homeController.favCatList.firstWhereOrNull(
            (item) => item.id == homeController.selectedTableId,
          );
          homeController.watchlistTextEditField.text = '${selectedItem?.name}';
          Helpers.customShowDialog(
            context,
            title: 'Rename List',
            fontSize: 15,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Container(
                  height: 105,
                  width: Get.width,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: context.tapBg),
                  child: TextFormField(
                    controller: homeController.watchlistTextEditField,
                    maxLines: 10,
                    onChanged: (String value) {},
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                      hintText: "DSES ..",
                      hintStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
              AppSpace.spaceH20,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          homeController.watchlistTextEditField.clear();
                          Get.back();
                        },
                        title: "Cancel",
                        backgroundColor: ColorConstants.error,
                      ),
                    ),
                    AppSpace.spaceW10,
                    Expanded(
                      child: GetBuilder<HomeController>(
                        builder: (logic) {
                          return logic.isCreateFavCat == true
                              ? const Center(
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(color: Colors.red),
                                  ),
                                )
                              : CustomButton(
                                  isLoading: logic.isCreateFavCat,
                                  onPressed: () {
                                    if (homeController.watchlistTextEditField.text.isEmpty) {
                                      Helpers.snackbarForErorr2(bodyText: 'Please enter a name');
                                    } else {
                                      homeController.updateFavTableName();
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
        },
        onDelete: () {
          var tableId = homeController.selectedTableId;
          printLog('table id:$tableId');
          Helpers.openCustomAlertDialog(() {
            homeController.deleteFavTable();
          });
        },
        goTo: () {
          homeController.changeCurrentIndex(2);
        },
      ),
    );
  }
}

class _WitchListItemWidget extends StatelessWidget {
  const _WitchListItemWidget({required this.index, required this.model});

  final int index;
  final MarketModel model;

  @override
  Widget build(BuildContext context) {
    // 🚀 Extension Properties
    final double absoluteChange = model.absoluteChange;
    final double percentChange = model.percentageChange;
    final double currentPrice = model.activePrice;

    return GetBuilder<HomeController>(
      builder: (homeCon) {
        void showBuySellDialog(int orderBookId) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Choose Action"),
              content: const Text("Do you want to Buy or Sell?"),
              actions: [
                TextButton(
                  style: ElevatedButton.styleFrom(backgroundColor: HexColor("#22C665")),
                  onPressed: () {
                    printLog('orderBookId::=== $orderBookId');
                    Get.back();
                    homeCon.goBottomNabBarPage(4, orderBookId);
                    homeCon.setBuySellActive(SideType2.BUY);
                    Get.back();
                  },
                  child: Text("Buy", style: Get.textTheme.bodyLarge!.copyWith(color: ColorConstants.white)),
                ),
                AppSpace.spaceW10,
                TextButton(
                  style: ElevatedButton.styleFrom(backgroundColor: HexColor("#F70042")),
                  onPressed: () {
                    Get.back();
                    homeCon.goBottomNabBarPage(4, orderBookId);
                    homeCon.setBuySellActive(SideType2.SELL);
                    Get.back();
                  },
                  child: Text("Sell", style: Get.textTheme.bodyLarge!.copyWith(color: ColorConstants.white)),
                ),
              ],
            ),
          );
        }

        return InkWell(
          onLongPress: () {
            printLog('logon press');
            showBuySellDialog(model.orderBook!);
          },
          onTap: () {
            homeCon.goBottomNabBarPage(1, model.orderBook!);
            FocusScope.of(context).unfocus();
            homeCon.searchController.clear();
          },
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                // 🚀 Extension displayName
                                text: model.displayName,
                                style: Get.textTheme.titleMedium?.copyWith(
                                  color: context.textColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: ' [${model.group}]',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400,
                                  fontFeatures: [const FontFeature.superscripts()],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Vol: ${model.volume ?? "0"}, Val: ${model.val ?? "0"}, Trd: ${model.trades ?? "0"}, CP: ${currentPrice.toStringAsFixed(2)}',
                          style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  AppSpace.spaceW6,
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          model.trades?.toStringAsFixed(2) ?? "0.0",
                          style: Get.textTheme.bodyLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          model.volume?.toStringAsFixed(2) ?? "0.0",
                          maxLines: 2,
                          style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  AppSpace.spaceW6,
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        printLog('model.id :: ${model.id}');
                        printLog('orderBook.id :: ${model.orderBook}');
                        printLog('fvbId.id :: ${model.fvbId}');
                        Helpers.openCustomAlertDialog(() {
                          homeCon.unfavoriteMarketData(model.fvbId!);
                        }, title: 'Are You Sure Delete?');
                      },
                      child: Icon(Icons.favorite, color: Colors.red.shade500),
                    ),
                  ),
                  AppSpace.spaceW8,
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          height: 24,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: absoluteChange > 0
                                ? ColorConstants.greenColor
                                : absoluteChange < 0
                                ? ColorConstants.redColor
                                : ColorConstants.blueColor,
                          ),
                          child: Text(
                            '${absoluteChange.toStringAsFixed(2)}',
                            style: Get.textTheme.bodyLarge?.copyWith(
                              color: ColorConstants.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          NumberFormatter.croreFormat(model.val ?? 0.0),
                          style: Get.textTheme.bodyLarge?.copyWith(
                            color: percentChange > 0
                                ? ColorConstants.greenColor
                                : percentChange < 0
                                ? ColorConstants.redColor
                                : ColorConstants.blueColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpace.spaceH10,
            ],
          ),
        );
      },
    );
  }
}

class _MarketItemWidget extends StatelessWidget {
  const _MarketItemWidget({required this.model, required this.index});
  final MarketModel model;
  final int index;

  @override
  Widget build(BuildContext context) {
    final homeCon = Get.find<HomeController>();
    var favList = homeCon.isFav(model.orderBook!);

    // 🚀 Extension Properties
    final double absoluteChange = model.absoluteChange;
    final double percentChange = model.percentageChange;
    final double currentPrice = model.activePrice;

    void showBuySellDialog(int orderBookId) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Choose Action"),
          content: const Text("Do you want to Buy or Sell?"),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(backgroundColor: HexColor("#22C665")),
              onPressed: () {
                printLog('orderBookId::=== $orderBookId');
                homeCon.goBottomNabBarPage(5, orderBookId);
                homeCon.setBuySellActive(SideType2.BUY);
                homeCon.loadComanyDividentEPS('${model.shortName}');
                Get.back();
              },
              child: Text("Buy", style: Get.textTheme.bodyLarge!.copyWith(color: ColorConstants.white)),
            ),
            AppSpace.spaceW10,
            TextButton(
              style: ElevatedButton.styleFrom(backgroundColor: HexColor("#F70042")),
              onPressed: () {
                homeCon.goBottomNabBarPage(5, orderBookId);
                homeCon.setBuySellActive(SideType2.SELL);
                homeCon.loadComanyDividentEPS('${model.shortName}');
                Get.back();
              },
              child: Text("Sell", style: Get.textTheme.bodyLarge!.copyWith(color: ColorConstants.white)),
            ),
          ],
        ),
      );
    }

    return GetBuilder<HomeController>(
      builder: (homeCon) {
        return GestureDetector(
          onTap: () {
            homeCon.goBottomNabBarPage(1, model.orderBook!);
            homeCon.loadComanyDividentEPS('${model.shortName}');
            FocusScope.of(context).unfocus();
            homeCon.searchController.clear();
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: context.dividerColor, width: 1.0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
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
                                  TextSpan(
                                    // 🚀 Extension displayName
                                    text: model.displayName,
                                    style: Get.textTheme.titleMedium?.copyWith(
                                      color: context.textColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (model.shareType != null) ...[
                                    TextSpan(
                                      text: ' [${model.shareType ?? ""}]',
                                      style: Get.textTheme.bodySmall?.copyWith(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w400,
                                        color: context.textColor,
                                        fontFeatures: [const FontFeature.superscripts()],
                                      ),
                                    ),
                                  ],
                                  model.tradingState == "Suspended"
                                      ? TextSpan(
                                          text: ' ',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontSize: 8,
                                            color: ColorConstants.redColor,
                                            fontWeight: FontWeight.w400,
                                            fontFeatures: [const FontFeature.superscripts()],
                                          ),
                                        )
                                      : TextSpan(
                                          text: '',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w400,
                                            fontFeatures: [const FontFeature.superscripts()],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            NumberHelper.formatSigned(absoluteChange),
                            style: Get.textTheme.titleSmall!.copyWith(
                              color: NumberHelper.getColor(absoluteChange),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Vol:${NumberFormatter.fixedDecimal2(model.volume ?? 0.0, decimal: 0)},",
                            style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, fontSize: 12),
                          ),
                          Text(
                            "Val:${NumberFormatter.croreFormat(model.val ?? 0.0)},",
                            style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, fontSize: 12),
                          ),
                          Flexible(
                            child: Text(
                              'Trd:${(model.trades ?? 0).toStringAsFixed(0)}',
                              maxLines: 1,
                              style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, fontSize: 12),
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
                    onTap: () {
                      printLog('model.id :: ${model.id}');
                      printLog('orderBook.id :: ${model.orderBook}');
                      printLog('fvbId.id :: ${model.fvbId}');
                      Helpers.openCustomAlertDialog(() {
                        homeCon.unfavoriteMarketData(model.fvbId!);
                      }, title: 'Are You Sure Delete?');
                    },
                    child: favList
                        ? Icon(Icons.favorite, color: Colors.red, size: 20)
                        : SvgPicture.asset(AssetsConstants.loveIconSvg, width: 16, height: 16),
                  ),
                ),
                AppSpace.spaceW6,
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentPrice.toStringAsFixed(2),
                        style: Get.textTheme.titleSmall!.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      AppSpace.spaceH2,
                      Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: NumberHelper.getColor(percentChange),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          '${NumberHelper.formatSigned(percentChange)}%',
                          style: Get.textTheme.titleSmall!.copyWith(
                            color: ColorConstants.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FavMarketFAB extends StatelessWidget {
  final void Function()? onCreate;
  final void Function()? onRename;
  final void Function()? onDelete;
  final void Function()? goTo;

  const FavMarketFAB({super.key, this.onCreate, this.onRename, this.onDelete, this.goTo});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: ColorConstants.secondaryColorLight,
      iconTheme: IconThemeData(color: Colors.white),
      children: [
        SpeedDialChild(child: const Icon(Icons.create), label: 'Create', onTap: onCreate),
        SpeedDialChild(child: const Icon(Icons.drive_file_rename_outline), label: 'Rename', onTap: onRename),
        SpeedDialChild(child: const Icon(Icons.delete), label: 'Delete', onTap: onDelete),
        SpeedDialChild(child: const Icon(Icons.list), label: 'Watch List', onTap: goTo),
      ],
    );
  }
}
