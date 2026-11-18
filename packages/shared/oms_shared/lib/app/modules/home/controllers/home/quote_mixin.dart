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
    // An explicit saved/search selection supersedes any pending exchange
    // reselection waiting for the previous venue's feed.
    _quoteInstrumentAfterSwitch = null;
    final MarketIdentifier orderBook =
        await StorageService.read(_selectedOrderBookKey) ?? 0;
    final marketList = shownMarket.quotes;

    if (orderBook == 0 || marketList.isEmpty) {
      _clearSelectedInstrument();
      return;
    }

    // Restore only the saved item for this exchange; never choose index 0 as
    // a fallback when there is no saved or matching selection.
    final selected = marketList.firstWhereOrNull(
      (quote) => quote.orderBook == orderBook,
    );
    if (selected == null) {
      _clearSelectedInstrument();
      return;
    }
    marketData = selected;

    await StorageService.save(_selectedOrderBookKey, marketData.orderBook);
    _sendMarketDepthPayload(AppConstants.subscribe, marketData.orderBook!);
    loadComanyDividentEPS('${marketData.shortName}');

    update(['marketList', 'trade_ticker_data']);
    update(['selectedInstrument']);
    update(['trade_root']);
  }

  void _clearSelectedInstrument() {
    marketData = MarketModel();
    company = null;
    dividendObj = null;
    epsData.clear();
    buys.clear();
    sells.clear();
    timeAndSales.clear();
    timeAndSalesHistory.clear();
    newsSingleItem.clear();
    update(['marketList', 'trade_ticker_data', 'market_depth']);
    update(['trade_root']);
    update(['selectedInstrument']);
  }

  /// Restores a saved item only after it arrives in the selected feed. If
  /// there is no saved item, Details/Trade stay empty for an explicit search.
  @override
  Future<void> restoreSelectedInstrumentIfAvailable() async {
    if (marketData.orderBook != null ||
        (currentIndex != 1 && currentIndex != 5)) {
      return;
    }
    final savedOrderBook = await StorageService.read(_selectedOrderBookKey);
    if (savedOrderBook == null || savedOrderBook == 0) return;
    if (shownMarket.quotes.any((quote) => quote.orderBook == savedOrderBook)) {
      await markerInfo();
    }
  }

  /// Listing shown before a successful Details/Trade exchange switch.
  MarketModel? _quoteInstrumentAfterSwitch;

  @override
  bool get _quoteReselectPending => _quoteInstrumentAfterSwitch != null;

  /// Lets the favorites page settle after an exchange switch.
  static const exchangeViewStabilityWindow = Duration(seconds: 5);

  /// DSE/CSE switch: drops the old stock's depth and time & sales. The stock
  /// itself stays selected (Trade uses it) until the new feed has it.
  @override
  void _resetQuoteForExchange() {
    final orderBook = marketData.orderBook;
    if (orderBook == null) return;
    // The old stock is on the previous exchange: unsubscribe it there.
    if (!_cseFeedApart) {
      _sendMarketDepthPayload(AppConstants.unsubscribe, orderBook);
    } else if (CseMarketService.isShown) {
      _sendDseDepthPayload(AppConstants.unsubscribe, orderBook);
    } // back on DSE: the CSE depth socket closed with CseMarketService
    _quoteInstrumentAfterSwitch = marketData;
    _clearSelectedInstrument();
  }

  /// Called on feed flushes to reselect the same listing or restore the saved
  /// selection. No unrelated first-row fallback is allowed.
  @override
  Future<void> _selectQuoteAfterExchangeSwitch() async {
    if (_quoteInstrumentAfterSwitch != null) {
      await _pickQuoteAfterSwitch();
    } else {
      await restoreSelectedInstrumentIfAvailable();
    }
  }

  /// The CSE feed (CseMarketService) flushed while shown: what a DSE list
  /// flush does for the stock and favourites after a switch.
  @override
  void onShownFeedFlushed() {
    _selectQuoteAfterExchangeSwitch();
  }

  /// Finds the exact listing in the new exchange. It never picks an unrelated
  /// first item if the same ISIN and board are unavailable.
  Future<void> _pickQuoteAfterSwitch() async {
    final source = _quoteInstrumentAfterSwitch;
    final marketList = shownMarket.quotes;
    if (source == null || isClosed || marketList.isEmpty) return;
    final match = MarketListingMatcher.findSameListing(source, marketList);
    if (match == null || match.orderBook == null) return;
    _quoteInstrumentAfterSwitch = null;
    await StorageService.save(_selectedOrderBookKey, match.orderBook);
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
  MarketModel getMarketByOrderBookId(MarketIdentifier orderBookId) {
    return marketListAll.firstWhere(
      (market) => market.orderBook == orderBookId,
      orElse: () => MarketModel(),
    );
  }
}
