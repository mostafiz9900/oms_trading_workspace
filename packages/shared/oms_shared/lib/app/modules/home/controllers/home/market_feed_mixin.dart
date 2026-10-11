part of '../home_controller.dart';

/// Market list feed for market_widget: ticks, marquee, sectors, distribution.
mixin MarketFeedMixin on HomeState {
  List<String> get filtersSectorList => _marketSectorFilterStore.sectors;

  @override
  void _handleMarketMessage(dynamic message) async {
    final MarketTickMessage event;
    try {
      event = MarketTickMessage.decode(message.toString());
    } on Exception catch (e) {
      printLog('Error processing market message: $e');
      return;
    }
    try {
      final jsonResponse = event.payload;
      // Handle different message types
      if (event.kind == MarketTickKind.session) {
        currentSession.value = jsonResponse['cs'];
        update(['marketSession']);
      } else if (event.kind == MarketTickKind.heartbeat) {
        // Handle heartbeat
      } else if (event.kind == MarketTickKind.marketIndex) {
        // Handle index data
      } else if (event.kind == MarketTickKind.quote) {
        _processMarketData(jsonResponse);
      }
      // Update sector filters
      _updateSectorFilters(jsonResponse);
    } on Exception catch (e) {
      printLog('Error processing market message: $e');
    }
    // Top Stocks uses the same feed; it used to open a second socket for it.
    // Kept separate so a failure there can never affect the home screen.
    try {
      marketService.onMarketPayload(event.payload);
    } catch (e) {
      printLog('Error in Top Stocks feed: $e');
    }
  }

  void _processMarketData(Map<String, dynamic> jsonResponse) {
    final incoming = _marketTickStore.apply(jsonResponse);

    if (incoming == null || incoming.orderBook == null) return;

    _updateMarqueeIncremental(incoming);

    final now = DateTime.now();
    bool isFirstTime = !_firstDataLoaded && marketList.isEmpty;

    // --- Helper 1: List Update Function ---
    void flushListDataToUI() {
      if (isClosed) return;

      final latestValues = _marketTickStore.quotes.toList();
      marketList.assignAll(latestValues);
      marketFeedList.assignAll(latestValues);
      marketListAll.assignAll(latestValues);
      marketListForDilog.assignAll(latestValues);

      if (!_firstDataLoaded && marketList.isNotEmpty) {
        _firstDataLoaded = true;
        _finalizeInitialData();
      }

      if (Get.isRegistered<WatchListController>()) {
        Get.find<WatchListController>().applyFilters();
      }
      if (Get.isRegistered<GlobalSearchController>()) {
        Get.find<GlobalSearchController>().syncLiveData();
      }
      if (Get.isRegistered<CandleChartController>()) {
        Get.find<CandleChartController>().updateLiveMarketData(
          marketData,
        ); //  Fix applied
      }

      update(['marketList', 'indexList']);
    }

    // --- Helper 2: Heavy Chart Calculation Function ---
    void runHeavyCalculations() {
      if (isClosed || marketListAll.isEmpty) return;

      //  Microtask: মেইন UI থ্রেডকে ব্লক না করে ব্যাকগ্রাউন্ডে ক্যালকুলেট করবে
      Future.microtask(() {
        chartData = _marketSnapshotAnalytics.calculateSectorGainers(
          marketListAll,
        );
        chartDataShareType = _marketSnapshotAnalytics
            .calculateSectorShareTypeValues(marketListAll);

        //  নতুন Distribution Calculation কল করা হলো
        _calculateDistributionCounts(marketListAll);
        sectorSummaryList = generateSectorSummary(marketListAll);

        //  distributionChartUpdate ট্যাগ যুক্ত করা হলো
        update([
          'marketListByGainer',
          'marketListByShareType',
          'sectorListUpdate',
          'distributionChartUpdate',
        ]);
      });
    }

    // ২. Medium Track (Throttling 500ms): লিস্ট আপডেট
    if (isFirstTime ||
        now.difference(_lastListUpdateTime).inMilliseconds > 500) {
      _marketUpdateTimer?.cancel();
      flushListDataToUI();
      _lastListUpdateTime = now;
    } else {
      _marketUpdateTimer?.cancel();
      _marketUpdateTimer = Timer(const Duration(milliseconds: 500), () {
        flushListDataToUI();
        runHeavyCalculations(); // মার্কেট শেষে চার্টও একবার ফাইনাল সিঙ্ক হবে
      });
    }

    // ৩. Slow Track (Throttling 2000ms): হেভি ক্যালকুলেশন
    if (isFirstTime ||
        now.difference(_lastHeavyTaskTime).inMilliseconds > 2000) {
      runHeavyCalculations();
      _lastHeavyTaskTime = now;
    }
  }

  // ==========================================================
  // ১. Gainer (Up/Down/Equal) চার্ট ডেটা জেনারেটর
  // ==========================================================

  // ==========================================================
  // ২. Share Type (Category) চার্ট ডেটা জেনারেটর
  // ==========================================================

  //  Sector Summary Generator Function (With Filter Condition)
  List<SectorDataModel> generateSectorSummary(List<MarketModel> allItems) =>
      _sectorSummaryAggregator.generate(allItems);

  //  নতুন ক্যালকুলেশন ফাংশন
  void _calculateDistributionCounts(List<MarketModel> list) {
    final summary = _marketSnapshotAnalytics.calculateMovementDistribution(
      list,
      buckets,
    );
    if (summary == null) return;
    distributionCounts = summary.counts;
    distributionTotal = summary.total;
    distributionMaxCount = summary.maxCount;
  }

  // =================================================================================
  // =================================================================================

  List<MarketModel> getRelatedAssets(
    MarketModel selectedItem,
    List<MarketModel> allItems,
  ) {
    if (selectedItem.sector == null || selectedItem.sector!.isEmpty) return [];

    final Set<String> seenShortNames = {}; //  ডুপ্লিকেট ট্র্যাক করার জন্য Set
    final List<MarketModel> uniqueRelatedList = [];

    for (var item in allItems) {
      // ১. একই সেক্টর হতে হবে
      bool isSameSector = item.sector == selectedItem.sector;

      // ২. একই ইন্সট্রুমেন্ট টাইপ হতে হবে
      bool isSameType = item.instrumentType == selectedItem.instrumentType;

      // ৩. নিজে নিজেকে যেন সাজেস্ট না করে
      bool isNotSelf = item.shortName != selectedItem.shortName;

      if (isSameSector && isSameType && isNotSelf) {
        //  ৪. ডুপ্লিকেট চেক: যদি shortName আগে থেকে Set-এ না থাকে, তবেই লিস্টে অ্যাড হবে
        if (item.shortName != null &&
            !seenShortNames.contains(item.shortName)) {
          seenShortNames.add(item.shortName!); // Set-এ নাম সেভ করে রাখা হলো
          uniqueRelatedList.add(item);
        }
      }
    }

    //  ৫. সবচেয়ে অ্যাক্টিভ রিলেটেড স্টকগুলো আগে দেখানোর জন্য ভলিউম অনুযায়ী সর্ট করা
    uniqueRelatedList.sort((a, b) => (b.volume ?? 0).compareTo(a.volume ?? 0));

    // টপ ১০টি ইউনিক রিলেটেড স্টক রিটার্ন করা
    return uniqueRelatedList.take(10).toList();
  }

  // call this after you update _marketMap and marketList
  void _updateMarqueeIncremental(MarketModel incoming) {
    if (incoming.group != "PUBLIC") return;
    final holder = MarqueeHolder(
      status: incoming.status,
      shortName: incoming.shortName,
      chg: incoming.chg,
      last: incoming.last,
      d: incoming.d,
    );
    // marqueeList is kept sorted by shortName, so the marquee can index it
    // directly instead of copying and sorting it for every item it builds.
    final idx = marqueeList.indexWhere((m) => m.shortName == holder.shortName);
    if (idx >= 0) {
      marqueeList[idx] = holder;
    } else {
      final key = holder.shortName ?? '';
      var lo = 0, hi = marqueeList.length;
      while (lo < hi) {
        final mid = (lo + hi) >> 1;
        if ((marqueeList[mid].shortName ?? '').compareTo(key) < 0) {
          lo = mid + 1;
        } else {
          hi = mid;
        }
      }
      marqueeList.insert(lo, holder);
    }
  }

  // Share Type (Category) চার্টের ডেটা

  // সরাসরি marketList থেকে Share Type ডেটা জেনারেট করার ফাংশন

  void _updateSectorFilters(Map<String, dynamic> jsonResponse) {
    // Same field MarketModel.fromJson reads, without building a whole model.
    if (_marketSectorFilterStore.addSector(jsonResponse['sc'] as String?)) {
      update(['sectorFilters']);
    }
  }

  void _finalizeInitialData() {
    isMarket = false;
    filteredItems = List.from(marketList);
    update(['marketList']);
    update();
    printLog('Market data initialized with ${marketList.length} items');
  }

  @override
  void _resetMarketState() {
    _firstDataLoaded = false;
    marketList.clear();
    filteredItems.clear();
    _marketTickStore.clear();
    isMarket = true;
    update(['marketList']);
  }

  @override
  void _initializeFilters() {
    _marketSectorFilterStore.reset();
  }

  // ================= index socket ========================

  // sector summary map
  Map<String, Map<String, int>> get sectorSummary =>
      _marketStatistics.sectorSummary;

}
