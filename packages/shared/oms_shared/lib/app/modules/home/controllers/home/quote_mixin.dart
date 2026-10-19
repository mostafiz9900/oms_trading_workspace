part of '../home_controller.dart';

/// Selected instrument for quote_widget: company, dividend, EPS, chart.
mixin QuoteMixin on HomeState {
  void changeTabQuote(int index) {
    currentTabIndexQuote = index;
    loadTabData(index);
    if (currentTabIndexQuote == 3) {
      Get.find<HistoricalVolumeController>().loadData(
        marketData.shortName ?? '',
        marketData.orderBook ?? 0,
      );
    }
    update();
  }

  void changeShortName(String name) {
    shortName = name;
    update();
    printLog('shortName: $shortName');
    String input = "Hello World! Welcome to Flutter.";
    String firstWord = getFirstWord(input);
    printLog(firstWord);
  }

  String getFirstWord(String text) {
    if (text.isEmpty) {
      return '';
    }
    List<String> words = text.split(' ');
    return words.isNotEmpty ? words[0] : '';
  }

  Future<void> loadCompany(String symbol) async {
    printLog('model.shortName: == $symbol');
    company = await companiesController.getCompanies(symbol.toUpperCase());
    printLog('resul====:${company?.toJson()}');
    update(['marketList']);
  }

  Future<void> loadDividend(String symbol) async {
    printLog('model.shortName: == $symbol');
    dividendObj = await companiesController.getDividend(symbol.toUpperCase());
    printLog('resul====:${dividendObj?.toMap()}');
    update(['marketList']);
  }

  Future<void> loadEPS(String symbol) async {
    int year = DateTime.now().year;
    epsData = await companiesController.getYearlyEPS(symbol, year);
    update(['marketList']);
  }

  @override
  void loadComanyDividentEPS(String shortName) async {
    await loadCompany(shortName);
    // await loadDividend(shortName);
    // await loadEPS(shortName);
  }

  @override
  Future<void> markerInfo() async {
    int orderBook =
        await StorageService.read(StorageConstants.orderBookId) ?? 0;

    if (marketList.isEmpty) {
      update(['marketList', "trade_ticker_data"]);
      return;
    }

    // ১. প্রথমে নির্ধারণ করুন কোন marketData সিলেক্ট হবে
    if (orderBook == 0) {
      marketData = marketList.first;
    } else {
      marketData = marketList.firstWhere(
        (c) => c.orderBook == orderBook,
        // যদি সেভ করা orderBook লিস্টে না থাকে, তাহলে ডিফল্ট হিসেবে প্রথম আইটেম নিয়ে নিবে
        orElse: () => marketList.first,
      );
    }

    // ২. এবার নির্বাচিত marketData এর ডাটাগুলো ফেচ করুন এবং লোকাল স্টোরেজ আপডেট করুন
    if (marketData.orderBook != null) {
      await StorageService.save(
        StorageConstants.orderBookId,
        marketData.orderBook,
      );

      // এই মেথডগুলো সব কন্ডিশনেই কল হতে হবে যেন অ্যাপ স্টার্টেই ডাটা লোড হয়
      _sendMarketDepthPayload(AppConstants.subscribe, marketData.orderBook!);
      loadComanyDividentEPS('${marketData.shortName}');
    }

    // ৩. UI আপডেট করুন
    update(['marketList', 'trade_ticker_data']);
  }

  @override
  MarketModel getMarketByOrderBookId(int orderBookId) {
    return marketListAll.firstWhere(
      (market) => market.orderBook == orderBookId,
      orElse: () => MarketModel(),
    );
  }
}
