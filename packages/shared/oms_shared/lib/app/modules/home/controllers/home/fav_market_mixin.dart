part of '../home_controller.dart';

/// Favourite lists for fav_market_view.
mixin FavMarketMixin on HomeState {
  /// Changes the favorite cat ID to the provided value and updates the state.
  ///
  /// This method sets the `selectFavCatId` to the given `id`, calls the `update`
  /// method to refresh the state, and logs the new favorite cat ID.
  ///
  /// @param id The new favorite cat ID to be set.
  void changeFavCatId(int id) {
    selectFavCatId = id;
    update();
    printLog(selectFavCatId);
  }

  Future<void> createFavCategory() async {
    if (await NetworkUtil.checkInternetConnection()) {
      isCreateFavCat = true;
      update();
      final res = await marketFavoritesRepository.createFavCategory(
        watchlistTextEditField.text,
      );
      printLog(res?.success);
      if (res?.success == true) {
        watchlistTextEditField.clear();
        isCreateFavCat = false;
        update();
        getFavCategory();
        Get.back();
      } else {
        Helpers.snackbarForErorr2(bodyText: res?.errorMessage ?? "");
        isCreateFavCat = false;
        update();
      }
    } else {
      NetworkUtil.networkErrorMessage();
      isCreateFavCat = false;
      update();
    }
  }

  Future<void> updateFavTableName() async {
    if (await NetworkUtil.checkInternetConnection()) {
      isCreateFavCat = true;
      update();
      final res = await marketFavoritesRepository.updateFavTableName(
        selectedTableId,
        watchlistTextEditField.text,
      );
      printLog(res?.success);
      if (res?.success == true) {
        watchlistTextEditField.clear();
        isCreateFavCat = false;
        update();
        getFavCategory();
        Get.back();
        Helpers.snackBarForSuccess2(bodyText: res?.data ?? "");
      } else {
        Helpers.snackbarForErorr2(bodyText: res?.errorMessage ?? "");
        isCreateFavCat = false;
        update();
      }
    } else {
      NetworkUtil.networkErrorMessage();
      isCreateFavCat = false;
      update();
    }
  }

  Future<void> deleteFavTable() async {
    if (await NetworkUtil.checkInternetConnection()) {
      isCreateFavCat = true;
      update();
      final res = await marketFavoritesRepository.deleteFavTable(
        selectedTableId,
      );
      printLog(res?.success);
      if (res?.success == true) {
        watchlistTextEditField.clear();
        isCreateFavCat = false;
        update();
        getFavCategory();
        Get.back();
        Helpers.snackBarForSuccess2(bodyText: res?.data ?? "");
      } else {
        Helpers.snackbarForErorr2(bodyText: res?.errorMessage ?? "");
        isCreateFavCat = false;
        update();
      }
    } else {
      NetworkUtil.networkErrorMessage();
      isCreateFavCat = false;
      update();
    }
  }

  Future<void> addMarketDataToFav(AddFavItemRequest requestData) async {
    if (await NetworkUtil.checkInternetConnection()) {
      isAddFavCat = true;
      update();
      final res = await marketFavoritesRepository.addMarketDataToFav(
        requestData,
      );
      printLog('res?.data?.toMap()');
      if (res?.success == true) {
        selectFavCatId = 0;
        isAddFavCat = false;
        update();
        Get.back();
        Helpers.snackBarForSuccess2(bodyText: '${res?.data}');
        getFavoriteAllMarketData();
      } else {
        Helpers.snackbarForErorr2(bodyText: '${res?.errorMessage}');
        printLog('set forget password error :: ${res?.errorMessage}');
        isAddFavCat = false;
        update();
      }
    } else {
      NetworkUtil.networkErrorMessage();
      isAddFavCat = false;
      update();
    }
  }

  Future<void> getFavMarketData(int tableId) async {
    if (await NetworkUtil.checkInternetConnection()) {
      loadingFav = true;
      update();
      final res = await marketFavoritesRepository.favMarketData(tableId);
      printLog(res?.success);
      if (res?.success == true) {
        favMarketData = res!.data!;
        favMarketParseList = parseFavMarketList(
          marketList: marketList,
          favMarketData: favMarketData,
        );
        loadingFav = false;
        update();
      } else {
        Helpers.snackbarForErorr2(bodyText: '${res?.errorMessage}');
        printLog('get Fav Market Data error :: ${res?.errorMessage}');
        loadingFav = false;
        update();
      }
    } else {
      NetworkUtil.networkErrorMessage();
      loadingFav = false;
      update();
    }
  }

  @override
  Future<void> getFavoriteAllMarketData() async {
    if (await NetworkUtil.checkInternetConnection()) {
      final res = await marketFavoritesRepository.favoriteAllMarketData();
      if (res?.success == true) {
        favAllMarketData = res!.data!;
        update();
      }
    } else {
      NetworkUtil.networkErrorMessage();
    }
  }

  bool isFav(int orderBookId) {
    if (favAllMarketData == []) {
      getFavoriteAllMarketData();
    }
    return favAllMarketData.any(
      (fav) => int.parse('${fav.oderBook}') == orderBookId,
    );
  }

  Future<void> unfavoriteMarketData(int favId) async {
    if (await NetworkUtil.checkInternetConnection()) {
      loadingFav = true;
      update();
      final res = await marketFavoritesRepository.unfavoriteMarketData(favId);
      printLog(res?.success);
      if (res?.success == true) {
        loadingFav = false;
        update();
        Get.back();
        getFavMarketData(selectedTableId);
        Helpers.snackBarForSuccess2(bodyText: '${res?.data}');
      } else {
        Get.back();
        Helpers.snackbarForErorr2(bodyText: '${res?.errorMessage}');
        printLog('get Fav Market Data error :: ${res?.errorMessage}');
        loadingFav = false;
        update();
      }
    } else {
      NetworkUtil.networkErrorMessage();
      loadingFav = false;
      update();
    }
  }

  List<MarketModel> parseFavMarketList({
    required List<FavMarketResponse> favMarketData,
    required List<MarketModel> marketList,
  }) {
    // map করে দ্রুত lookup করার জন্য
    final favMap = {
      for (var fav in favMarketData) "${fav.ticker}_${fav.oderBook}": fav,
    };

    // market list থেকে শুধু সেগুলো রাখবো যেগুলো fav এর সাথে match করে
    final favMarketParseList = marketList
        .where((market) {
          final key = "${market.ticker}_${market.orderBook}";
          return favMap.containsKey(key);
        })
        .map((market) {
          final fav = favMap["${market.ticker}_${market.orderBook}"]!;
          // চাইলে merge করতে পারো
          return market.copyWith(
            group: fav.group,
            fvbId: fav.id,
            orderBook: int.tryParse(fav.oderBook ?? ""),
          );
        })
        .toList();

    return favMarketParseList;
  }

  /// Open for a short while after a DSE/CSE switch: the favourites are
  /// re-matched against the new feed as it fills (over a few flushes).
  /// Otherwise they stay a snapshot, as before.
  Timer? _favRebuildWindow;

  /// DSE/CSE switch: the shown favourites carry the old exchange's prices.
  /// Favourites are saved by (ticker, order book), so on the other exchange
  /// they only match where both are the same.
  @override
  void _resetFavForExchange() {
    favMarketParseList = [];
    _favRebuildWindow?.cancel();
    _favRebuildWindow = Timer(QuoteMixin.quoteSwitchFallback, () {});
    update();
  }

  @override
  void _rebuildFavAfterExchangeSwitch() {
    if (_favRebuildWindow?.isActive != true) return;
    favMarketParseList = parseFavMarketList(
      marketList: marketList,
      favMarketData: favMarketData,
    );
    update();
    // Holdings are valued from the selected exchange's feed; redraw them as
    // it fills (on DSE they redraw on their own updates, as before).
    if (Get.isRegistered<PositionController>()) {
      Get.find<PositionController>().update();
    }
  }

  @override
  void selectTable(int tableId) {
    selectedTableId = tableId;
    getFavMarketData(tableId);
    update(); // update button selection
  }

  @override
  Future<void> getFavCategory() async {
    printLog('get fav category');
    if (await NetworkUtil.checkInternetConnection()) {
      favCatList.clear();
      isGetFavCat = true;
      update();
      final res = await marketFavoritesRepository.getFavTables();
      printLog(res?.data);
      if (res?.success == true) {
        printLog('res::: ${res?.data}');
        List<FavouriteModel>? result = res?.data;
        isGetFavCat = false;
        favCatList.assignAll(result!);
        selectedTableId = favCatList.first.id!;
        getFavMarketData(favCatList.first.id!);
        update();
        for (var item in favCatList) {
          printLog(item.toJson());
        }
      } else {
        isGetFavCat = false;
        update();
      }
    } else {
      NetworkUtil.networkErrorMessage();
      isGetFavCat = false;
      update();
    }
  }

  void updateFavViewMode(String mode) {
    favCurrentViewMode = mode;
    update(); // UI রিবিল্ড করার জন্য
  }

}
