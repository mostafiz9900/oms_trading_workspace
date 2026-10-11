import 'package:oms_shared/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../global_widgets/empty_widget.dart';
import '../../../global_widgets/appbar_right_search_tap.dart';
import '../../../global_widgets/index_value_loader.dart';
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

              //                   ? Colors.blue
              //                   : context.isDark
              //                   ? context.unselectColor

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
