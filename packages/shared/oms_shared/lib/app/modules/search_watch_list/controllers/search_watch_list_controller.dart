import 'package:flutter/material.dart';

import '/app/app_pkg.dart';
import 'package:get/get.dart';

class SearchWatchListController extends GetxController {
  final homeController = Get.find<HomeController>();
  final TextEditingController textController = TextEditingController();

  List<MarketModel> allItems = [];
  var filteredItems = <MarketModel>[];
  String? selectSector;

  @override
  void onInit() {
    super.onInit();
    allItems.addAll(homeController.marketList);
    filteredItems = List.from(allItems);
    selectSector = homeController.filtersSectorList.first;
    textController.addListener(() {
      search(textController.text);
    });
    update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void search(String query) {
    printLog('data: ${allItems.first.toJson()}');
    if (query.isEmpty) {
      filteredItems = allItems;
    } else {
      filteredItems = allItems
          .where((item) => (item.filterName ?? "").toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    update();
  }

  void searchSector(String query) {
    printLog('data: ${allItems.first.toJson()}');
    selectSector = query;
    if (query == 'All') {
      filteredItems = allItems;
    } else {
      filteredItems = allItems
          .where((item) => (item.sector ?? "").toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    update();
  }
}
