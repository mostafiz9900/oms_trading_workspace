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
    int orderBook = await StorageService.read(_selectedOrderBookKey) ?? 0;
    // Stocks of the shown exchange (on DSE: marketList, as before).
    final marketList = shownMarket.quotes;

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
      await StorageService.save(_selectedOrderBookKey, marketData.orderBook);

      // এই মেথডগুলো সব কন্ডিশনেই কল হতে হবে যেন অ্যাপ স্টার্টেই ডাটা লোড হয়
      _sendMarketDepthPayload(AppConstants.subscribe, marketData.orderBook!);
      loadComanyDividentEPS('${marketData.shortName}');
    }

    // ৩. UI আপডেট করুন
    update(['marketList', 'trade_ticker_data']);
  }

  /// Symbol shown on Quote when the user switched DSE/CSE; picked again from
  /// the new exchange's feed (order book ids can differ between exchanges).
  String? _quoteSymbolAfterSwitch;
  Timer? _quoteSwitchFallback;

  @override
  bool get _quoteReselectPending => _quoteSymbolAfterSwitch != null;

  /// How long to wait for the same symbol on the new exchange before showing
  /// its first stock instead.
  static const quoteSwitchFallback = Duration(seconds: 5);

  /// DSE/CSE switch: drops the old stock's depth and time & sales. The stock
  /// itself stays selected (Trade uses it) until the new feed has it.
  @override
  void _resetQuoteForExchange() {
    final orderBook = marketData.orderBook;
    if (orderBook == null) return;
    _sendMarketDepthPayload(AppConstants.unsubscribe, orderBook);
    buys.clear();
    sells.clear();
    timeAndSales.clear();
    timeAndSalesHistory.clear();
    newsSingleItem.clear();
    _quoteSymbolAfterSwitch = marketData.shortName ?? '';
    _quoteSwitchFallback?.cancel();
    _quoteSwitchFallback = Timer(
      quoteSwitchFallback,
      () => _pickQuoteAfterSwitch(force: true),
    );
    update(['marketList', 'trade_ticker_data', 'market_depth']);
  }

  /// Called on every market list flush: after a switch, selects the same
  /// symbol once the new feed has it.
  @override
  Future<void> _selectQuoteAfterExchangeSwitch() =>
      _pickQuoteAfterSwitch(force: false);

  /// The CSE feed (CseMarketService) flushed while shown: what a DSE list
  /// flush does for the stock and favourites after a switch.
  @override
  void onShownFeedFlushed() {
    _selectQuoteAfterExchangeSwitch();
    _rebuildFavAfterExchangeSwitch();
    // Open search screen: results from the CSE feed.
    if (Get.isRegistered<GlobalSearchController>()) {
      Get.find<GlobalSearchController>().syncLiveData();
    }
  }

  /// With [force], falls back to the new exchange's first stock.
  Future<void> _pickQuoteAfterSwitch({required bool force}) async {
    final symbol = _quoteSymbolAfterSwitch;
    final marketList = shownMarket.quotes;
    if (symbol == null || isClosed || marketList.isEmpty) return;
    final match = marketList.firstWhereOrNull((m) => m.shortName == symbol);
    if (match == null && !force) return;
    _quoteSymbolAfterSwitch = null;
    _quoteSwitchFallback?.cancel();
    await StorageService.save(_selectedOrderBookKey, match?.orderBook ?? 0);
    await markerInfo(); // selects it, subscribes depth, loads company
    // On Trade, show the new stock's price, as opening Trade does.
    if (currentIndex == 5) {
      tradPriceTextEditField.text = marketData.activePrice.toStringAsFixed(2);
      update(['buy_sell_tab']);
    }
    final orderBook = marketData.orderBook;
    // Price Table tab open: load the new stock's history, as tapping it does.
    if (currentTabIndexQuote == 3 &&
        Get.isRegistered<HistoricalVolumeController>()) {
      Get.find<HistoricalVolumeController>().loadData(
        marketData.shortName ?? '',
        orderBook ?? 0,
      );
    }
    if (orderBook != null) {
      subscribeTimeAndSales('tsm', '01', '$orderBook');
      subscribeTimeAndSales('tsb', '02', '$orderBook');
      subscribeTimeAndSales('news_hist', '04', '$orderBook');
    }
  }

  @override
  MarketModel getMarketByOrderBookId(int orderBookId) {
    return marketListAll.firstWhere(
      (market) => market.orderBook == orderBookId,
      orElse: () => MarketModel(),
    );
  }
}
