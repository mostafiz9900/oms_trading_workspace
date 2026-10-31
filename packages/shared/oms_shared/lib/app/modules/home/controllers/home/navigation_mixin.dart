part of '../home_controller.dart';

/// Bottom navigation and tab history for home_view.
mixin HomeNavigationMixin on HomeState {
  @override
  Future<void> loadTabData(int index) async {
    if (index == 0) {
      int orderBook =
          await StorageService.read(_selectedOrderBookKey) ?? 0;
      await manageMarketDepth(orderBook);
    } else if (index == 1) {
      subscribeTimeAndSales('tsm', '01', "${marketData.orderBook}");
      subscribeTimeAndSales('tsb', '02', "${marketData.orderBook}");
      subscribeTimeAndSales('news_hist', '04', "${marketData.orderBook}");
    } else if (index == 2 && timeAndSales.isEmpty) {
      subscribeTimeAndSales('tsm', '01', "${marketData.orderBook}");
      subscribeTimeAndSales('tsb', '02', "${marketData.orderBook}");
      subscribeTimeAndSales('news_hist', '04', "${marketData.orderBook}");
    }
  }

  Future<void> reloadHome() async {
    String? deviceId;
    try {
      deviceId = await Helpers.getSecureDeviceId();
    } catch (e) {
      printLog('❌ Could not get deviceId: $e');
      deviceId = null;
    }

    printLog('deviceId :::: $deviceId');

    var isToken = await StorageService.read(StorageConstants.token);

    printLog('isToken home controller::::: $isToken');

    if (isToken != null) {
      timerCont.startTokenCountdown('$isToken');
    }

    // Delay 1 second before loading user info
    Future.delayed(const Duration(seconds: 1), () async {
      if (isToken != null) {
        getUserInfo();
        getFavCategory();
        getFavoriteAllMarketData();
        userBalance();
        await getUserOrder();
      }
    });
  }

  void changeCurrentIndex(int index) async {
    printLog("CurrentIndex before: $currentIndex");
    printLog("Tapped index: $index");

    // একই ট্যাবে আবার ক্লিক করলে কিছুই হবে না
    if (currentIndex == index) return;

    if (index >= 3) {
      if (await StorageService.read(StorageConstants.token) == null) {
        Helpers.showLoginRequiredDialog();
        return; // এখানেই থেমে যাবে, ইনডেক্স চেঞ্জ হবে না
      }
    }

    tabHistory.remove(
      index,
    ); // যদি আগে থেকেই লিস্টে থাকে, সেটা রিমুভ করবে (যাতে ডুপ্লিকেট না হয়)
    tabHistory.add(index);
    if (index == 0) {
      currentIndex = index;
      update();
      if (marketList.isEmpty) {
      }
    } else if (index == 1) {
      printLog('change tab index $index');
      currentIndex = index;
    } else if (index == 2) {
      currentIndex = index;
    } else if (index == 3) {
      if (await StorageService.read(StorageConstants.token) == null) {
        Helpers.showLoginRequiredDialog();
      } else {
        currentIndex = index;
        final controller = Get.put(PositionController());
        controller.initializePosition();
      }
    } else if (index == 4) {
      if (await StorageService.read(StorageConstants.token) == null) {
        Helpers.showLoginRequiredDialog();
      } else {
        currentIndex = index;
      }
    } else if (index == 5) {
      if (await StorageService.read(StorageConstants.token) == null) {
        Helpers.showLoginRequiredDialog();
      } else {
        currentIndex = index;
        tradPriceTextEditField.text = (marketData.activePrice.toStringAsFixed(
          2,
        ));
      }
    }
    update();
  }

  bool goBack() {
    if (tabHistory.length > 1) {
      // যদি হিস্ট্রিতে ১টির বেশি ট্যাব থাকে, তাহলে বর্তমান ট্যাব রিমুভ করে আগেরটিতে ফিরে যাবে
      tabHistory.removeLast();
      currentIndex = tabHistory.last;
      update();
      return false; // false মানে অ্যাপ থেকে বের হবে না
    } else {
      return true; // true মানে হিস্ট্রি শেষ, এখন অ্যাপ থেকে বের হওয়ার ডায়ালগ দেখাবে
    }
  }

  void changeCurrentIndex2(int index) async {
    previousIndex = currentIndex;

    if (index == 0) {
      currentIndex = index;
      update();
      if (marketList.isEmpty) {
      }
    } else if (index == 1) {
      printLog('change tab index $index');
      currentIndex = index;
      currentTabIndexQuote = 0;
      if (marketData.orderBook == null) {
        await markerInfo();
      }
      loadTabData(1);
    } else if (index == 2) {
      currentIndex = index;
      update(['marketList']);
    } else if (index == 3) {
      if (await StorageService.read(StorageConstants.token) == null) {
        Helpers.showLoginRequiredDialog();
      } else {
        currentIndex = index;
        if (favCatList.isNotEmpty) {
          selectTable(favCatList.first.id!);
        } else {
          await getFavCategory();
          if (favCatList.isNotEmpty) {
            selectTable(favCatList.first.id!);
          }
        }
      }
    } else if (index == 4) {
      if (await StorageService.read(StorageConstants.token) == null) {
        Helpers.showLoginRequiredDialog();
      } else {
        currentIndex = index;
        final controller = Get.put(PositionController());
        controller.initializePosition();
      }
    } else if (index == 5) {
      if (await StorageService.read(StorageConstants.token) == null) {
        Helpers.showLoginRequiredDialog();
      } else {
        currentIndex = index;
        if (marketData.orderBook == null) {
          await markerInfo();
        }
        tradPriceTextEditField.text = (marketData.activePrice.toStringAsFixed(
          2,
        ));
      }
    }
    printLog("previseIndex index: $previousIndex");
    printLog("CurrentIndex before: $currentIndex");
    printLog("Tapped index: $index");

    update();
  }

  @override
  void goBottomNabBarPage(int index, int orderBookId) async {
    printLog('index nab bar :: $index');
    previousIndex = currentIndex;

    try {
      if (index == 0) {
        printLog('change tab index $index');
        currentIndex = index;
      } else if (index == 1) {
        currentIndex = index;
        currentTabIndexQuote = 0;
        update();
        printLog('orderBookId:: $orderBookId');
        await manageMarketDepth(orderBookId);
        subscribeTimeAndSales("tsm", "01", "$orderBookId");
        subscribeTimeAndSales("tsb", "02", "$orderBookId");
        subscribeTimeAndSales("news_hist", "04", "$orderBookId");
      } else if (index == 2) {
        printLog('change tab index $index');
        currentIndex = index;
      } else if (index == 3) {
        printLog('change tab index $index');
        if (await StorageService.read(StorageConstants.token) == null) {
          Helpers.showLoginRequiredDialog();
        } else {
          currentIndex = index;
        }
      } else if (index == 4) {
        if (await StorageService.read(StorageConstants.token) == null) {
          Helpers.showLoginRequiredDialog();
        } else {
          currentIndex = index;
          printLog('change tab index=== $currentIndex');
          await manageMarketDepth(orderBookId);
          loadComanyDividentEPS('${marketData.shortName}');
          update();
        }
      } else if (index == 5) {
        if (await StorageService.read(StorageConstants.token) == null) {
          Helpers.showLoginRequiredDialog();
        } else {
          currentIndex = index;
          await manageMarketDepth(orderBookId);
          printLog('change tab index=== $currentIndex');
          update();
        }
      }
    } catch (error) {
      printLog('og bottom nab $error');
    }
    printLog('currentIndex :: $currentIndex');
    update();
  }

}
