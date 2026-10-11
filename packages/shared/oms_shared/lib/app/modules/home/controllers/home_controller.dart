import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import '../../../data/models/response/order_alert_model.dart';
import '/app/modules/home/controllers/historical_volume_controller.dart';

import '/app/modules/home/controllers/position_controller.dart';

import 'package:flutter/material.dart' hide Actions;
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:market/market.dart'
    show
        AddFavItemRequest,
        FavMarketResponse,
        MarketDepthData,
        MarketDepthModel,
        MarketStatisticsAggregator,
        MarketFavoritesRepository,
        MarketSectorFilterStore,
        MarketSectorSummaryAggregator,
        MarketSnapshotAnalytics,
        SectorDataModel,
        MarketTickKind,
        MarketTickMessage,
        MarketTickStore,
        TradingChartModel;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '/app/data/models/request/update_order_holder.dart';
import '../../../app_pkg.dart';
import '../../../data/models/marquee_holder.dart';

import '../../../data/models/response/companies_model.dart';
import '../../../data/models/response/dividend_model.dart';
import '../../../data/models/response/eps_model.dart';
import '../../../data/models/response/order_status_details_model.dart';
import '../../../data/models/response/user_balance.dart';
import '../../../data/services/market_socket.service.dart';
import '../../auth/controllers/biometric_controller.dart';
import '../../auth/controllers/token_controller.dart';
import '../views/order_status_details_view.dart';
import 'candle_chart_controller.dart';
import 'companies_controller.dart';
import 'global_search_controller.dart';
import 'market_index_controller.dart';
import 'watchlist_controller.dart';

final userInfoProvider = Provider<UserProfile>((ref) {
  printLog('user profile:: ');
  var res = StorageService.getMap(StorageConstants.userInfo);
  UserProfile? user = UserProfile.fromJson(res!);
  printLog(user.toJson());
  printLog('user profile:: ');
  return user;
});
final userNotifierProvider = NotifierProvider<UserNotifier, UserProfile>(
  () => UserNotifier(),
);

class UserNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    printLog('user profile:: ');
    var res = StorageService.getMap(StorageConstants.userInfo);
    UserProfile? user = UserProfile.fromJson(res!);
    printLog(user.toJson());
    printLog('user profile:: ');
    return user;
  }
}

final watchListOnProvider = NotifierProvider<WatchListOnNotifier, bool>(
  () => WatchListOnNotifier(),
);

class WatchListOnNotifier extends Notifier<bool> {
  @override
  bool build() {
    return true;
  }

  void changeValue(bool value) => state = value;
}

final timeAndSalesProvider = FutureProvider<dynamic>((ref) async {
  return;
});

class HomeController extends SuperController {
  final MarketSocketService marketService = Get.find<MarketSocketService>();
  final CompaniesController companiesController =
      Get.find<CompaniesController>();
  final WebSocketService _webSocketService = WebSocketService.instance;
  final HomeRepository homeRepository;
  final MarketFavoritesRepository marketFavoritesRepository;
  HomeController({required this.homeRepository})
    : marketFavoritesRepository = homeRepository;
  final marketIndexController = Get.find<MarketIndexController>();
  // Socket data storage
  final Map<String, String> _socketData = {};
  final Map<String, bool> _socketStatus = {};
  final Map<String, String> _socketUrls = {};
  //filter start
  final bioCon = Get.put(BiometricController(), tag: 'biometric_Con');
  final ScrollController scrollController = ScrollController();
  final searchTextEditCont = TextEditingController();
  final double itemHeight = 100.0;
  String? filterName;
  final MarketSectorFilterStore _marketSectorFilterStore =
      MarketSectorFilterStore();
  List<String> get filtersSectorList => _marketSectorFilterStore.sectors;
  String selectSector = 'All';
  String searchQuery = '';
  SideType selectBuySell = SideType.buy;
  //filter data

  var currentIndex = 0;
  var previousIndex = 0;
  late ZoomPanBehavior zoomPanBehavior;
  late TooltipBehavior tooltipBehavior;
  CategoryAxisController?
  axisController1; // create instance to axis controller for first chart
  CategoryAxisController? axisController2;
  int currentTabIndex = 0;

  SideType2 buySellTabActive = SideType2.BUY;
  int selectFavCatId = 0;
  String? selectOrderType;
  String? selectType;
  String? selectValidity;

  List<MarketDepthModel> buys = [];
  List<MarketDepthModel> sells = [];
  List<IndexModel> indexList = <IndexModel>[];
  String selectedSn = 'DSEX';
  IndexModel? newArr;
  //time and salse
  List<TimeAndSalesModel> timeAndSales = [];
  List<TimeAndSalesModel> timeAndSalesHistory = [];
  List<NewsModel> news = [];
  List<NewsModel> newsSingleItem = [];
  bool isLoadTimeSales = false;

  // Market Socket Data (Your existing variables)
  MarketModel market = MarketModel();
  List<MarketModel> marketList = <MarketModel>[];
  List<MarketModel> marketFeedList = <MarketModel>[];
  var filteredItems = <MarketModel>[];
  List<MarketModel> marketListAll = <MarketModel>[];
  List<MarketModel> marketListForDilog = <MarketModel>[];
  TextEditingController searchController = TextEditingController();
  bool isMarket = false;
  bool _firstDataLoaded = false;
  String watchListFilterBoard = 'Main Board';
  String watchListFilterPublic = 'Public';
  int watchListFilterFavorite = 0;
  String watchListFilterFavoriteName = "";
  String watchListFilterSetting = 'New Watch List';
  Map<String, List<MarketModel>>? groupedSectionMarketData;
  final currentSession = "".obs;

  final MarketTickStore _marketTickStore = MarketTickStore();
  final MarketStatisticsAggregator _marketStatistics =
      MarketStatisticsAggregator();
  UserProfile userInfo = UserProfile();
  var isUserInfoLoaded = false;
  var currentTabIndexQuote = 0;
  var currentTabIndexPortfolio = 0;

  final watchlistTextEditField = TextEditingController();
  late TextEditingController disclosedQtyTextEditField;
  late TextEditingController qtyTextEditField;
  late TextEditingController minQtyTextEditField;
  late TextEditingController tradPriceTextEditField;
  late FocusNode tradePriceFocusNode;
  double tradPrice = 0.0;
  int _priceCents = 0;
  var totalAmount = 0.0;

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

  void changeTabPortfolio(int index) {
    currentTabIndexPortfolio = index;
    update();
  }

  void setBuySellActive(SideType2 value) {
    buySellTabActive = value;
    update();
    update(['buy_sell_tab']);
  }

  Future<void> loadTabData(int index) async {
    if (index == 0) {
      int orderBook =
          await StorageService.read(StorageConstants.orderBookId) ?? 0;
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

  @override
  void onInit() async {
    super.onInit();
    if (!searchController.hasListeners) {
      searchController.addListener(_onSearchChanged);
    }
    printLog('home repository :: ${homeRepository.hashCode}');
    if (Get.arguments != null) {
      currentIndex = Get.arguments;
      update();
    }
    printLog('home controller initialized:: on init');
    _firstDataLoaded = false;
    initConnect();
    // যেকোনো ফিল্ডে চেঞ্জ আসলে ক্যালকুলেশন ট্রিগার হবে
    disclosedQtyTextEditField = TextEditingController();
    qtyTextEditField = TextEditingController();
    minQtyTextEditField = TextEditingController();
    tradPriceTextEditField = TextEditingController();
    tradePriceFocusNode = FocusNode();
    update();
  }

  //না, এই সেকশনটি (didChangeAppLifecycleState) আর একদমই থাকবে না!

  // ================= end index socket ========================
  var timerCont = Get.put<TokenController>(TokenController());
  @override
  Future<void> onReady() async {
    super.onReady();
    reloadHome();
    qtyTextEditField.addListener(calculateTotal);
    tradPriceTextEditField.addListener(calculateTotal);
    final container = ProviderContainer();
    var value = container.read(orderTypeProvider);
    selectOrderType = value.first;
    var types = container.read(typeProvider);
    selectType = types.first;
    var validity = container.read(validityProvider);
    selectValidity = validity.first;
    marketIndexController.loadData('${newArr?.sn}');
    update();
    update(['total_amount_update']);
    printLog("on ready home controller");
  }

  @override
  void onClose() {
    disconnect();
    Future.delayed(const Duration(milliseconds: 100), () {
      _disconnectAll();
      searchController.removeListener(_onSearchChanged);
      searchController.dispose();
      disclosedQtyTextEditField.dispose();
      qtyTextEditField.dispose(); // শুধুমাত্র একবার কল হবে ✅
      minQtyTextEditField.dispose();
      tradPriceTextEditField.dispose();
      tradePriceFocusNode.dispose();
    });

    super.onClose();
  }

  bool isShowTimeSalesChart = false;

  void toggleTimeSalesChart() {
    isShowTimeSalesChart = !isShowTimeSalesChart;
    update(['timeAndSales']); // UI আপডেট করার জন্য
  }
  //new socket code start

  void _initializeAllWebSockets() {
    _initializeMarketWebSocket();
    _initializeNotificationWebSocket();
    _initializeNewsWebSocket();
    _initializeMarketDepthWebSocket();
    _initializeNewsTimeSalesWebSocket();
    printLog('All WebSockets initialized');
  }

  void _initializeSocket({
    required String socketId,
    required String url,
    required Function(String) messageHandler,
  }) {
    if (url.isEmpty || url == 'null') {
      printLog('URL not available for: $socketId');
      _socketData[socketId] = 'URL not available';
      _socketStatus[socketId] = false;
      update([socketId]);
      return;
    }

    _socketUrls[socketId] = url;
    _socketData[socketId] = 'Connecting...';
    _socketStatus[socketId] = false;

    _webSocketService.connect(
      socketId: socketId,
      url: url,
      onMessage: (message) {
        _handleSocketMessage(socketId, message, messageHandler);
      },
      onConnected: () {
        _handleSocketConnected(socketId);
      },
      onDisconnected: () {
        _handleSocketDisconnected(socketId);
      },
      onError: (error) {
        _handleSocketError2(socketId, error);
      },
    );
  }

  void _initializeSSE({
    required String socketId,
    required String url,
    required Function(String) messageHandler,
  }) {
    if (url.isEmpty || url == 'null') {
      printLog('URL not available for: $socketId');
      return;
    }

    _socketUrls[socketId] = url;
    _socketData[socketId] = '';
    _socketStatus[socketId] = false;
  }

  void _handleSocketMessage(
    String socketId,
    String message,
    Function(String) handler,
  ) {
    try {
      _socketData[socketId] = 'Connected';
      handler(message);
      update([socketId]);
    } catch (e) {
      printLog('Error handling message for $socketId: $e');
      _socketData[socketId] = 'Error processing data';
      update([socketId]);
    }
  }

  void _handleSocketConnected(String socketId) {
    _socketStatus[socketId] = true;
    _socketData[socketId] = 'Connected';
    printLog('✅ $socketId connected successfully');

    // অ্যাপ মিনিমাইজ করে আবার ওপেন করলে সকেট অটোমেটিক আগের আইটেমের ডেটা চাইবে
    if (marketData.orderBook != null) {
      if (socketId == AppConfig.marketDepthSocketId) {
        printLog(
          '🔄 Auto Re-subscribing Market Depth for: ${marketData.orderBook}',
        );
        _sendMarketDepthPayload(AppConstants.subscribe, marketData.orderBook!);
      } else if (socketId == AppConfig.newsTimeSalesSocketId) {
        printLog(
          '🔄 Auto Re-subscribing Time & Sales for: ${marketData.orderBook}',
        );
        subscribeTimeAndSales('tsm', '01', "${marketData.orderBook}");
        subscribeTimeAndSales('tsb', '02', "${marketData.orderBook}");
        subscribeTimeAndSales('news_hist', '04', "${marketData.orderBook}");
      }
    }
    update([socketId]);
  }

  void _handleSocketDisconnected(String socketId) {
    _socketStatus[socketId] = false;
    _socketData[socketId] = 'Disconnected';
    printLog('📡 $socketId disconnected (this is normal during refresh)');
    update([socketId]);
  }

  void _handleSocketError2(String socketId, dynamic error) {
    _socketStatus[socketId] = false;
    _socketData[socketId] = 'Connection error';
    printLog('⚠️ $socketId error: $error');
    update([socketId]);
  }

  // Message buckets for market movement

  List<Bucket> buckets = [
    Bucket('< -10', double.negativeInfinity, -10),
    Bucket('-10-7', -10, -7),
    Bucket('-7-5', -7, -5),
    Bucket('-5-2', -5, -2),
    Bucket('-2-0', -2, 0),
    Bucket('0', 0, 0, isCenter: true),
    Bucket('0-2', 0, 2),
    Bucket('2-5', 2, 5),
    Bucket('5-7', 5, 7),
    Bucket('7-10', 7, 10),
    Bucket('> 10', 10, double.infinity),
  ];

  // Individual WebSocket initializations
  void _initializeMarketWebSocket() async {
    printLog(AppConfig.marketUrl);
    try {
      _resetMarketState();
      _initializeFilters();
      _initializeSocket(
        socketId: AppConfig.marketSocketId,
        url: AppConfig.marketUrl,
        messageHandler: _handleMarketMessage,
      );
    } catch (e) {
      printLog('Market socket initialization error: $e');
      _scheduleReconnection();
    }
  }

  void _initializeNotificationWebSocket() {
  }

  void _initializeNewsWebSocket() {
  }

  void _initializeIndexWebSocket() {
    indexList = [];
    newArr = IndexModel(sn: "DSEX");
    update(['indexList']);
    _initializeSocket(
      socketId: AppConfig.indexSocketId,
      url: AppConfig.indexUrl,
      messageHandler: _handleIndexMessage,
    );
  }

  void _initializeMarketDepthWebSocket() {
    _initializeSocket(
      socketId: AppConfig.marketDepthSocketId,
      url: AppConfig.marketDepthUrl,
      messageHandler: _handleMarketDepthMessage,
    );
  }

  void _initializeNewsTimeSalesWebSocket() {
    _initializeSocket(
      socketId: AppConfig.newsTimeSalesSocketId,
      url: AppConfig.newsAndTimeAndSalesUrl,
      messageHandler: _handleNewsTimeSalesMessage,
    );
  }

  //  ১. এই ফাংশনটি অ্যাপ ওপেন হওয়ার সাথে সাথেই কল হবে
  Future<void> _initializeOrderConfirmWebSocket() async {
    printLog('Initializing Order Confirm WebSocket...');
    var deviceId = await Helpers.getDeviceIdUuid();
    var boId = userInfo.userDetail?.boId;
    var token = await StorageService.read(StorageConstants.token);

    if (boId == null || token == null) {
      printLog('❌ Cannot connect Order Confirm Socket: missing parameters');
      return;
    }

    final wsUrl =
        '${AppConfig.socketBaseUrl}order/$boId/?token=$token&individual_id=$deviceId';
    printLog('Initializing Order Confirm Socket: $wsUrl');

    //  আপনার কমন _initializeSocket ফাংশনটি ব্যবহার করা হলো
    _initializeSocket(
      socketId: AppConfig.orderConfirmSocketId,
      url: wsUrl,
      messageHandler: _handleOrderConfirmMessage,
    );
  }

  Future<void> _initializeUserBalanceWebSocket() async {
    printLog('Initializing User Balance WebSocket...');
    var token = await StorageService.read(StorageConstants.token);
    final boId = userInfo.userDetail?.boId;

    if (token == null || boId == null) {
      printLog('❌ Cannot connect balance socket. Missing token or boId');
      return;
    }

    final url = '${AppConfig.socketBaseUrl}cash/$boId/?token=$token';
    printLog('🔗 Initializing Balance Socket: $url');

    // 🚀 আপনার কমন _initializeSocket ফাংশনটি ব্যবহার করা হলো
    _initializeSocket(
      socketId: AppConfig.userBalanceSocketId,
      url: url,
      messageHandler: _handleUserBalanceMessage,
    );
  }

  void _handleMarketMessage(dynamic message) async {
    try {
      final event = MarketTickMessage.decode(message.toString());
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
  }

  // ক্লাসের শুরুতে ভ্যারিয়েবল ডিক্লেয়ার করুন
  // চার্ট ডেটা প্রসেস করার ক্লিন ফাংশন
  List<Map<String, dynamic>> chartData = [];
  List<Map<String, dynamic>> chartDataShareType = [];
  List<Map<String, dynamic>> chartDataVolumeLeaders = [];
  List<Map<String, dynamic>> chartData52WeekProximity = [];
  List<Map<String, dynamic>> chartDataPerformanceHorizon = [];
  List<Map<String, dynamic>> chartDataBidAskRatio = [];
  List<Map<String, dynamic>> chartDataVolumeComparison = [];
  final MarketSectorSummaryAggregator _sectorSummaryAggregator =
      MarketSectorSummaryAggregator();
  final MarketSnapshotAnalytics _marketSnapshotAnalytics =
      MarketSnapshotAnalytics();
  List<SectorDataModel> sectorSummaryList = [];
  Timer? _marketUpdateTimer;
  DateTime _lastListUpdateTime = DateTime.now();
  DateTime _lastHeavyTaskTime = DateTime.now();

  void _processMarketData(Map<String, dynamic> jsonResponse) {
    final incoming = _marketTickStore.apply(jsonResponse);

    if (incoming == null || incoming.orderBook == null) return;

    update(['ITEM_${incoming.orderBook}']);
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

  //  Distribution Chart এর জন্য ভেরিয়েবল
  List<int> distributionCounts = [];
  int distributionTotal = 0;
  int distributionMaxCount = 0;

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
  List<Map<String, dynamic>> _calculateVolumeLeaders(List<MarketModel> list) {
    var filteredList = list.where((m) {
      //  StockNow Filters
      if ((m.volume ?? 0) <= 0 && (m.trades ?? 0) <= 0 && (m.val ?? 0) <= 0)
        return false;
      if (m.board != "Main Board" && m.board != "Small Cap Board") return false;
      if (m.instrumentType != "EQ" && m.instrumentType != "MF") return false;
      return true;
    }).toList();

    filteredList.sort((a, b) => (b.val ?? 0.0).compareTo(a.val ?? 0.0));

    return filteredList.take(10).map((m) {
      //  MAGIC FIX: ভ্যালুকে ১০ লক্ষ (1 Million) দিয়ে ভাগ!
      double stockValue = m.val ?? 0.0;
      if (stockValue.isNaN || stockValue.isInfinite) stockValue = 0.0;
      double valueInMillions = stockValue / 1000000;

      return {
        'sn': m.shortName ?? '',
        'val': valueInMillions, // এখন ডেটা মিলিয়নে আছে (যেমন 15.5)
        'vol': (m.volume ?? 0).toDouble(),
      };
    }).toList();
  }

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

  //  সেফটি হেল্পার: ডুপ্লিকেট এড়ানোর জন্য লিস্টে টিক আপডেট বা ইনসার্ট করা
  void _updateOrAddToList(List<MarketModel> list, MarketModel incoming) {
    final index = list.indexWhere((e) => e.orderBook == incoming.orderBook);
    if (index != -1) {
      list[index] = incoming; // ডুপ্লিকেট না করে আপডেট করা হলো (Memory Safe)
    } else {
      list.add(incoming);
    }
  }

  // call this after you update _marketMap and marketList
  //  ১. O(1) স্পিড এবং জিরো-ল্যাগের জন্য Map এবং ValueNotifier
  final List<MarqueeHolder> marqueeList = [];

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
    // If marqueeList is RxList:
    final idx = marqueeList.indexWhere((m) => m.shortName == holder.shortName);
    if (idx >= 0) {
      marqueeList[idx] = holder;
    } else {
      // add new entry
      marqueeList.add(holder);
    }
    // If you use GetBuilder or manual update
    update(['indexList']); // uncomment if you rely on GetBuilder with id
  }

  void processTick2(String message) {
    final tick = Map<String, dynamic>.from(jsonDecode(message) as Map);
    if (!_marketStatistics.processGainerTick(tick)) return;
    chartData = _marketStatistics.chartData;
    update(['marketListByGainer']);
  }

  void processShareTypeTick(String message) {
    final tick = Map<String, dynamic>.from(jsonDecode(message) as Map);
    if (!_marketStatistics.processShareTypeTick(tick)) return;
    chartDataShareType = _marketStatistics.chartDataShareType;
    update(['marketListByShareType']);
  }

  // Share Type (Category) চার্টের ডেটা

  // সরাসরি marketList থেকে Share Type ডেটা জেনারেট করার ফাংশন
  List<Map<String, dynamic>> _calculateSectorShareTypeData(
    List<MarketModel> marketList,
  ) {
    final Map<String, Map<String, int>> sectorStats = {};

    for (final MarketModel model in marketList) {
      String? sectorName = model.sector; //[cite: 1]
      String? shareType = model.shareType?.toUpperCase(); //[cite: 1]

      // অবৈধ সেক্টর বা শেয়ার টাইপ বাদ দেওয়া হচ্ছে
      if (sectorName == null || sectorName.isEmpty || sectorName == "TBond")
        continue;
      if (shareType == null || !["A", "B", "N", "Z"].contains(shareType))
        continue;

      // Small Cap Board এর নাম পরিবর্তন
      if (model.board == "Small Cap Board") {
        sectorName = "SME";
      }

      // সেক্টর ম্যাপে না থাকলে ডিফল্ট ভ্যালু দিয়ে ইনিশিয়ালাইজ করা
      sectorStats.putIfAbsent(
        sectorName,
        () => {"A": 0, "B": 0, "N": 0, "Z": 0},
      );

      // শেয়ার টাইপ অনুযায়ী কাউন্ট বাড়ানো
      sectorStats[sectorName]![shareType] =
          sectorStats[sectorName]![shareType]! + 1;
    }

    // Chart-এর ফরম্যাটে কনভার্ট এবং টোটাল হিসাব করা
    final List<Map<String, dynamic>> formattedData = sectorStats.entries.map((
      entry,
    ) {
      final int aCount = entry.value["A"]!;
      final int bCount = entry.value["B"]!;
      final int nCount = entry.value["N"]!;
      final int zCount = entry.value["Z"]!;
      final int totalCount = aCount + bCount + nCount + zCount;

      return {
        "sector": entry.key,
        "A": aCount.toDouble(),
        "B": bCount.toDouble(),
        "N": nCount.toDouble(),
        "Z": zCount.toDouble(),
        "total": totalCount.toDouble(),
      };
    }).toList();

    // Total অনুযায়ী Descending অর্ডারে সর্ট করা
    formattedData.sort((a, b) => b["total"].compareTo(a["total"]));

    return formattedData;
  }

  void _updateSectorFilters(Map<String, dynamic> jsonResponse) {
    final marketDataObj = MarketModel.fromJson(jsonResponse);
    if (_marketSectorFilterStore.addSector(marketDataObj.sector)) {
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

  void _scheduleReconnection() {
    Future.delayed(const Duration(seconds: 5), () {
      printLog('Attempting to reconnect market socket...');
    });
  }

  void _resetMarketState() {
    _firstDataLoaded = false;
    marketList.clear();
    filteredItems.clear();
    _marketTickStore.clear();
    isMarket = true;
    update(['marketList']);
  }

  void _initializeFilters() {
    _marketSectorFilterStore.reset();
  }

  void _handleNotificationMessage(String message) {
    // Process notification
    printLog('Notification: $message');
  }

  void _handleNewsMessage(String message) {
    // Process news
    printLog('News: $message');
  }

  DateTime? lastIndexUpdateTime;
  DateTime _lastIndexUIUpdateTime = DateTime.now();
  Timer? _indexUpdateTimer;

  List<IndexModel> get visibleIndexList {
    return indexList
        .where(
          (m) =>
              m.sn != null &&
              m.sn != 'DSE SME Index' &&
              m.sn != 'CDSET' &&
              m.sn!.isNotEmpty,
        )
        .toList();
  }

  void _handleIndexMessage(String message) {
    try {
      final jsonResponse = jsonDecode(message); //  একবারই পার্স হবে
      final messageType = jsonResponse['message_type'];

      if (messageType == 'connection' || messageType == 'itch_heartbeat') {
        return; // অপ্রয়োজনীয় ডেটা সরাসরি রিটার্ন
      }

      if (messageType == null) {
        const baseIndices = ['DSEX', 'DSES', 'DS30', 'DSMEX'];
        var index = IndexModel.fromJson(
          jsonResponse,
        ); //  ডাবল jsonDecode বন্ধ করা হলো

        // Existing list logic
        if (baseIndices.contains(index.sn)) {
          final indexPos = baseIndices.indexOf(index.sn!);
          final existingIndex = indexList.indexWhere((r) => r.sn == index.sn);
          if (existingIndex != -1) {
            indexList[existingIndex] = index;
          } else {
            while (indexList.length <= indexPos) {
              indexList.add(IndexModel.empty());
            }
            indexList[indexPos] = index;
          }
        } else {
          final existingIndex = indexList.indexWhere((r) => r.sn == index.sn);
          if (existingIndex != -1) {
            indexList[existingIndex] = index;
          } else {
            indexList.add(index);
          }
        }

        if (newArr?.sn == index.sn) {
          newArr = index;
          selectedSn = index.sn ?? "${newArr?.sn}";
        }

        lastIndexUpdateTime = DateTime.now();

        //  ২. Throttling: ইনডেক্স দ্রুত পরিবর্তন হলেও UI আপডেট হবে প্রতি ৫০০ms এ
        final now = DateTime.now();
        if (now.difference(_lastIndexUIUpdateTime).inMilliseconds > 500) {
          _indexUpdateTimer?.cancel();
          update(['indexList']);
          _lastIndexUIUpdateTime = now;
        } else {
          _indexUpdateTimer?.cancel();
          _indexUpdateTimer = Timer(const Duration(milliseconds: 500), () {
            if (!isClosed) update(['indexList']);
          });
        }
      }
    } catch (e) {
      printLog('❌ Error parsing index data: $e');
    }
  }

  void selectSn(String sn) {
    selectedSn = sn;
    update(['indexList', AppConfig.indexSocketId, 'indexChartTap']);
  }

  IndexModel? get selectedIndexData {
    try {
      return indexList.firstWhere((element) => element.sn == selectedSn);
    } catch (e) {
      return null;
    }
  }

  List<String> get availableSns {
    return indexList
        .map((e) => e.sn) // Get the sn value (could be null)
        .where((sn) => sn != null && sn.isNotEmpty) // Filter out null and empty
        .cast<String>() // Cast to non-nullable String
        .toList();
  }

  int get up => newArr?.u ?? 0;
  int get down => newArr?.d ?? 0;
  int get unchanged => newArr?.uc ?? 0;
  void getSumOfAllIndex(IndexModel? newIndexData) {
    newArr = newIndexData;
    selectedSn = newIndexData!.sn!;
    printLog('getSumOfAllIndex called -> ${newArr?.toJson()}');
    update(['indexList']);
  }

  void _handleNewsTimeSalesMessage(String message) {
    // Process news and time sales
    try {
      final jsonResponse = jsonDecode(message);
      final messageType = jsonResponse['tp'];
      final data = jsonResponse['d'];

      if (messageType == 'tsm') {
        if (data is List) {
          var timeAndSalesData = timeAndSalesModelFromMap(data);
          timeAndSales.clear();
          timeAndSales.addAll(timeAndSalesData);
        } else if (data is Map<String, dynamic>) {
          timeAndSales.insert(0, TimeAndSalesModel.fromMap(data));
        }
        update(['timeAndSales']);
      } else if (messageType == 'tsb') {
        if (data is List) {
          var timeAndSalesData = data
              .map((e) => TimeAndSalesModel.fromMap(e))
              .toList();
          timeAndSalesHistory.clear();
          timeAndSalesHistory.addAll(timeAndSalesData);
        } else if (data is Map<String, dynamic>) {
          timeAndSalesHistory.insert(0, TimeAndSalesModel.fromMap(data));
        } else {
          timeAndSalesHistory.clear();
        }
        update([
          'timeAndSalesHistory',
        ]); // Add this if you have a widget using this data
      } else if (messageType == 'news') {
        if (data is List) {
          var allNews = newsModelFromMap(data);
          news.clear();
          news.addAll(allNews);
        } else if (data is Map<String, dynamic>) {
          news.insert(0, NewsModel.fromMap(data));
          //condition order book id jodi match kore tobe add hboe
        } else {
          news.clear();
        }
        update(['news']); // Add this if you have a widget using news data
      } else if (messageType == 'news_hist') {
        printLog("newsSingleItem: $data");
        if (data is List) {
          var allNews = newsModelFromMap(data);
          newsSingleItem.clear();
          newsSingleItem.addAll(allNews);
        } else if (data is Map<String, dynamic>) {
          newsSingleItem.insert(0, NewsModel.fromMap(data));
        } else {
          newsSingleItem.clear();
        }
        update([
          'newsSingleItem',
        ]); // Add this if you have a widget using this data
      }
    } catch (e) {
      printLog('❌ Error parsing Time & Sales data: $e');
    }
  }

  // Your existing subscribe methods (updated for WebSocketService)
  void subscribeTimeAndSales(String tp, String tid, String ob) {
    final body = jsonEncode({
      "ac": "subscribe",
      "tp": tp,
      "tid": int.parse(tid),
      "ob": int.parse(ob),
    });
    _webSocketService.sendMessage(AppConfig.newsTimeSalesSocketId, body);
    printLog("Time & Sales Sent subscribe: $body");
  }

  void subscribeTimeAndSalesNews(String tp, String tid) {
    final body = jsonEncode({
      "ac": "subscribe",
      "tp": tp,
      "tid": int.parse(tid),
    });
    printLog("Time & Sales Sent subscribe news: $body");
    _webSocketService.sendMessage(AppConfig.newsTimeSalesSocketId, body);
  }

  // https://bnpnama.info/
  void _handleMarketDepthMessage(String message) {
    try {
      final jsonResponse = jsonDecode(message);

      if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse.containsKey('message')) {
          printLog('✅ Connected Market Depth: ${jsonResponse['message']}');
          return;
        }
        if (jsonResponse['type'] == 'heartbeat') return;

        jsonResponse.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            try {
              final depth = MarketDepthData.fromJson(value);
              buys = depth.buy; // Removed ?? [] as the model already handles it
              sells = depth.sell;
            } catch (e) {
              printLog('❌ Error parsing depth key $key: $e');
            }
          }
        });
        update(["market_depth"]);
      }
    } catch (e) {
      printLog('❌ Error parsing market depth data: $e');
    }
  }

  bool isMarketDepthExpanded = false;

  void toggleMarketDepth() {
    isMarketDepthExpanded = !isMarketDepthExpanded;
    update(["market_depth"]);
  }

  // Message send
  void _sendMarketDepthPayload(String type, int orderbookId) {
    final payload = {"type": type, "ob": orderbookId}; //ob orderbook
    //change for new
    printLog('SendPayload :: $payload');
    _webSocketService.sendMessage(
      AppConfig.marketDepthSocketId,
      jsonEncode(payload),
    );
  }

  Future<void> manageMarketDepth(int newOrderBookId) async {
    printLog('newOrderBookId:: $newOrderBookId');
    int oldOrderBookId =
        await StorageService.read(StorageConstants.orderBookId) ?? 0;
    printLog('old order book id:: $oldOrderBookId');
    if (oldOrderBookId != newOrderBookId) {
      _sendMarketDepthPayload(AppConstants.unsubscribe, oldOrderBookId);
      _sendMarketDepthPayload(AppConstants.subscribe, newOrderBookId);
      await StorageService.save(StorageConstants.orderBookId, newOrderBookId);
      await markerInfo();
    } else {
      _sendMarketDepthPayload(AppConstants.subscribe, newOrderBookId);
      await markerInfo();
    }
  }

  //end market depth
  Function(String) _getMessageHandler(String socketId) {
    switch (socketId) {
      case AppConfig.marketSocketId:
        return _handleMarketMessage;
      case AppConfig.marketDepthSocketId:
        return _handleMarketDepthMessage;
      case AppConfig.indexSocketId:
        return _handleIndexMessage;
      case AppConfig.notificationSocketId:
        return _handleNotificationMessage;
      case AppConfig.newsSocketId:
        return _handleNewsMessage;
      case AppConfig.newsTimeSalesSocketId:
        return _handleNewsTimeSalesMessage;
      case AppConfig.orderConfirmSocketId: //  এটি নতুন অ্যাড হলো
        return _handleOrderConfirmMessage;
      case AppConfig.userBalanceSocketId: //  এটি নতুন অ্যাড হলো
        return _handleUserBalanceMessage;
      default:
        return (message) {};
    }
  }

  int Function(int, int) calc = (a, b) => a + b;
  // Public API
  void sendMessage(String socketId, String message) {
    _webSocketService.sendMessage(socketId, message);
  }

  void reconnectSocket(String socketId) {
  }

  void reconnectMarketDepth() {
    reconnectSocket(AppConfig.marketDepthSocketId);
  }

  void reconnectIndex() {
    reconnectSocket(AppConfig.indexSocketId);
  }

  void reconnectAllSockets() {
    for (var socketId in _socketUrls.keys) {
      reconnectSocket(socketId);
    }
  }

  // Reinitialize specific socket
  void _reinitializeSocket(String socketId) {
    final url = _socketUrls[socketId];
    if (url != null) {
      printLog('🔄 Reinitializing socket: $socketId');
      // Clear existing data
      _clearSocketData(socketId);
      // Update UI to show loading
      _socketStatus[socketId] = false;
      _socketData[socketId] = 'Reconnecting...';
      update([socketId]);
      // Disconnect first
      _webSocketService.disconnect(socketId);
      // Reinitialize after short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _initializeSocket(
          socketId: socketId,
          url: url,
          messageHandler: _getMessageHandler(socketId),
        );
      });
    }
  }

  // Refresh methods for public use
  Future<void> refreshMarket() async {
    await _refreshSocket(AppConfig.marketSocketId);
    isMarket = false;
    update(['marketList']);
  }

  Future<void> refreshIndex() async {
    await _refreshSocket(AppConfig.indexSocketId);
  }

  Future<void> refreshMarketDepth() async {
    await _refreshSocket(AppConfig.marketDepthSocketId);
  }

  Future<void> refreshTimeAndSales() async {
    await _refreshSocket(AppConfig.newsTimeSalesSocketId);
  }

  Future<void> _refreshSocket(String socketId) async {
    printLog('🎯 Refreshing socket: $socketId');
    _reinitializeSocket(socketId);
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _clearSocketData(String socketId) {
    switch (socketId) {
      case AppConfig.marketSocketId:
        _resetMarketState();
        printLog('🧹 Cleared market data');
        break;
      case AppConfig.indexSocketId:
        indexList.clear();
        newArr = IndexModel(sn: "DSEX");
        break;
      case AppConfig.marketDepthSocketId:
        buys.clear();
        sells.clear();
        break;
      case AppConfig.newsTimeSalesSocketId:
        timeAndSales.clear();
        timeAndSalesHistory.clear();
        news.clear();
        newsSingleItem.clear();
        printLog('🧹 Cleared time & sales data');
      case AppConfig.orderConfirmSocketId:
        orderAlertsList.clear();
        break;
      // Add other socket types as needed
    }
  }

  // Check if any socket is loading (for RefreshIndicator)
  bool get isLoading {
    return _socketUrls.keys.any((socketId) => !_socketStatus[socketId]!);
  }
  // Refresh all sockets

  // Connection status checkers
  bool isSocketConnected(String socketId) => _socketStatus[socketId] ?? false;
  bool get isMarketConnected => isSocketConnected(AppConfig.marketSocketId);
  bool get isMarketDepthConnected =>
      isSocketConnected(AppConfig.marketDepthSocketId);
  bool get isIndexConnected => isSocketConnected(AppConfig.indexSocketId);
  bool get isTimeAndSalesConnected =>
      isSocketConnected(AppConfig.newsTimeSalesSocketId);
  bool get isOrderConfirmConnected =>
      isSocketConnected(AppConfig.orderConfirmSocketId);
  // Data getters
  String getSocketData(String socketId) => _socketData[socketId] ?? '';
  String get marketStatus => getSocketData(AppConfig.marketSocketId);
  String get marketDepthStatus => getSocketData(AppConfig.marketDepthSocketId);
  String get indexStatus => getSocketData(AppConfig.indexSocketId);
  String get timeAndSalesStatus =>
      getSocketData(AppConfig.newsTimeSalesSocketId);
  String get orderConfirmStatus =>
      getSocketData(AppConfig.orderConfirmSocketId);

  void disconnectSocket(String socketId) {
    _webSocketService.disconnect(socketId);
    _socketData.remove(socketId);
    _socketStatus.remove(socketId);
    update([socketId]);
  }

  void _disconnectAll() {
    for (var socketId in _socketUrls.keys) {
      _webSocketService.disconnect(socketId);
    }
    _socketData.clear();
    _socketStatus.clear();
  }

  //new socket code end
  void reconnect() {
    Future.delayed(const Duration(seconds: 3), initConnect);
  }

  void disconnect() {
    _disconnectAll();
  }

  void _onSearchChanged() {
    search(searchController.text);
  }

  void initConnect() async {
    zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.x,
      enablePanning: true,
    );
    tooltipBehavior = TooltipBehavior(enable: true);
    _initializeAllWebSockets();

    await tradingChart();

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

  Future<bool> enableDisableBiometric2(BuildContext ctx) async {
    try {
      // Step 1: Authenticate
      printLog('user info b:::${userInfo.b}');
      bool isBioUser = userInfo.b!;
      final authenticated = await bioCon.authenticate();
      printLog('authenticated::::::: $authenticated');
      if (!authenticated) return false;

      // Step 2: Get device ID
      final deviceId = await Helpers.getSecureDeviceId();
      printLog('deviceId::::::: $deviceId');
      // Step 3: Check current biometric status
      final isEnable = await bioCon.isBiometricEnabled();
      final isBio = await Helpers.isBiometricEnabled();
      printLog('isEnable;::::::: $isEnable');
      printLog('isBio;::::::: $isBio');
      if (isBioUser == true && deviceId != null) {
        printLog('Biometric disabled locally');
        await biometricActive(null, false);
        await logout(ctx);
      } else {
        printLog('Biometric enabled locally');
        await biometricActive(deviceId, true);
        await logout(ctx);
      }

      // Step 4: Update storage if needed
      await Helpers.setBiometricEnabled(!isEnable);

      return true;
    } catch (e) {
      printLog('Error in enableDisableBiometric: $e');
      return false;
    }
  }

  Future<bool> enableDisableBiometric(BuildContext ctx) async {
    try {
      // Safely check if user has biometric enabled on backend (defaults to false if null)
      bool isBioUser = userInfo.b ?? false;
      printLog('user info b::: $isBioUser');

      // Step 1: Authenticate before allowing them to change the setting
      final authenticated = await bioCon.authenticate();
      printLog('authenticated::::::: $authenticated');
      if (!authenticated) return false;

      // Step 2: Get device ID
      final deviceId = await Helpers.getSecureDeviceId();
      printLog('deviceId::::::: $deviceId');

      if (deviceId == null) {
        Helpers.snackbarForErorr2(
          bodyText: "Device ID not found. Cannot update biometric.",
        );
        return false;
      }

      // Step 3: Call backend to update status & update Local GetX State
      if (isBioUser == true) {
        printLog('Disabling Biometric locally and on backend...');

        // Call backend to disable
        await biometricActive(null, false);

        // Update GetX Controller & Local Storage
        await bioCon.disableBiometric();
      } else {
        printLog('Enabling Biometric locally and on backend...');

        // Call backend to enable
        await biometricActive(deviceId, true);

        // Update GetX Controller & Local Storage
        await bioCon.enableBiometric();
      }

      // Step 4: Handle Logout
      // NOTE: Consider removing this unless your app strictly requires
      // a fresh login immediately after toggling biometrics.
      await logout(ctx);

      return true;
    } catch (e) {
      printLog('Error in enableDisableBiometric: $e');
      return false;
    }
  }

  TradingChartModel? tradingChartModel;
  int visibleCount = 50;

  Future<void> tradingChart() async {
    DateTime now = DateTime.now();
    DateTime threeMonthsAgo = DateTime(now.year, now.month - 6, now.day);
    int fromTimestamp = (threeMonthsAgo.millisecondsSinceEpoch / 1000).round();
    int toTimestamp = (now.millisecondsSinceEpoch / 1000).round();
    var sortName = marketData.shortName;
    printLog(" from:  $fromTimestamp ");
    printLog("to  '$toTimestamp");
    printLog("symbole  '$sortName");
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 30);
      final url = 'https://itch-chart.skytrade.us/history';
      final response = await connect.get(
        url,
        query: {
          'symbol': 'GP',
          'resolution': '1D',
          'from': '$fromTimestamp',
          'to': '$toTimestamp',
          'countback': '330',
        },
      );
      if (response.isOk) {
        final Map<String, dynamic> jsonMap = json.decode(response.bodyString!);
        final chart = TradingChartModel.fromJson(jsonMap);
        printLog("Open: ${chart.o?.first}");
        printLog("Close: ${chart.c?.first}");
        printLog(
          "Date: ${DateTime.fromMillisecondsSinceEpoch((chart.t?.first ?? 0) * 1000)}",
        );
        tradingChartModel = chart;
        printWrapped('tradingChartModel :: ${tradingChartModel?.toJson()}');
      } else {
        printLog('error :::::: ${response.statusText}');
      }
    } catch (e) {
      printLog('tradingChart error :: $e');
    }
    update(['interactive_charts']);
  }

  void setFilterName(String name) {
    filterName = name;
    scrollToMatch();
    update();
  }

  void scrollToMatch() {
    final model = marketList.firstWhere(
      (market) => market.filterName == filterName,
      orElse: () => MarketModel(),
    );
    final index = marketList.indexOf(model);
    if (index == -1) return;
    const itemHeight = 90.0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        final topOffset = index * itemHeight;
        final safeOffset = topOffset.clamp(
          scrollController.position.minScrollExtent,
          scrollController.position.maxScrollExtent,
        );
        scrollController.animateTo(
          safeOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    });

    update();
  }

  void toggleSide(SideType name) {
    selectBuySell = name;
    update(['market_depth']);
  }

  void changeTextNotifier() {
    var value = providerContainer.read(watchListOnProvider);
    printLog(value);
    printLog('notifier get controller');
  }

  void changeOrderType(String data) {
    selectOrderType = data;
    update(['trade_dropdowns']);
  }

  void changeOrderTypeOrderList(String data) {
    selectOrderType = data;
    update([AppConstants.orderList]);
  }

  void changeType(String data) {
    selectType = data;
    update(['trade_dropdowns']);
  }

  void changeTypeOrderList(String data) {
    selectType = data;
    update([AppConstants.orderList]);
  }

  void changeValidity(String data) {
    selectValidity = data;
    update(['trade_dropdowns']);
  }

  void changeValidityOrderList(String data) {
    selectValidity = data;
    update([AppConstants.orderList]);
  }

  String currentSearchQuery = '';
  String currentSortOrder = 'ASC'; // ডিফল্ট ASC
  String currentSortCategory = 'A-Z';
  void searchOld(String query) {
    if (query.isEmpty) {
      filteredItems = marketList;
    } else {
      filteredItems = marketList
          .where(
            (item) => (item.filterName ?? "").toLowerCase().startsWith(
              query.toLowerCase(),
            ),
          )
          .toList();
    }

    update(['marketList']);
  }

  void searchSectorOld(String query) {
    printLog('data: ${marketList.first.toJson()}');
    selectSector = query;
    if (query == 'All') {
      filteredItems = marketList;
      update(['marketList']);
    } else {
      filteredItems = marketList
          .where(
            (item) =>
                (item.sector ?? "").toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

    update(['marketList']);
  }

  // আপনার এই ফাংশনটি ঠিক রাখুন
  void search(String query) {
    currentSearchQuery = query; // নিশ্চিত করুন এই ভেরিয়েবলটি গ্লোবালি আছে
    applyFilters();
  }

  // আপনার এই ফাংশনটি ঠিক রাখুন
  void searchSector(String query) {
    selectSector = query; // আপনার বর্তমান ভেরিয়েবল নাম ব্যবহার করুন
    applyFilters();
  }

  void updateSortCategory(String category) {
    currentSortCategory = category;
    update(['sortCategoryDropdown']); // Category ড্রপডাউন আপডেট হবে
    applyFilters();
  }

  void updateSortOrder(String order) {
    currentSortOrder = order;
    update(['sortOrderDropdown']); // Order ড্রপডাউন আপডেট হবে
    applyFilters();
  }

  void applyFilters() {
    List<MarketModel> results = List.from(marketList);

    // ১. সার্চ ফিল্টার
    if (currentSearchQuery.isNotEmpty) {
      results = results
          .where(
            (item) => (item.filterName ?? "").toLowerCase().startsWith(
              currentSearchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    // ২. সেক্টর ফিল্টার
    if (selectSector != 'All' && selectSector.isNotEmpty) {
      results = results
          .where(
            (item) => (item.sector ?? "").toLowerCase().contains(
              selectSector.toLowerCase(),
            ),
          )
          .toList();
    }

    results.sort((a, b) {
      int comparison = 0;

      // ক্যাটাগরি অনুযায়ী ডাটা কম্পেয়ার করা
      switch (currentSortCategory) {
        case 'A-Z':
          comparison = (a.shortName ?? "").compareTo(b.shortName ?? "");
          break;
        case 'Change(%)':
          comparison = (a.chg ?? 0).compareTo(b.chg ?? 0);
          break;
        case 'Value':
          comparison = (a.val ?? 0).compareTo(b.val ?? 0);
          break;
        case 'Volume':
          comparison = (a.volume ?? 0).compareTo(b.volume ?? 0);
          break;
        case 'Trade':
          comparison = (a.trades ?? 0).compareTo(b.trades ?? 0);
          break;
        case 'Price':
          comparison = (a.last ?? 0).compareTo(b.last ?? 0);
          break;
        case 'Paidup':
          comparison = (a.sp ?? 0).compareTo(b.sp ?? 0);
          break;
        default:
          comparison = (a.shortName ?? "").compareTo(b.shortName ?? "");
      }

      // অর্ডার অনুযায়ী রেজাল্ট রিটার্ন করা
      return (currentSortOrder == 'ASC') ? comparison : -comparison;
    });

    filteredItems.assignAll(results);
    update(['marketList']);
  }

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

  bool isGridView = false; // default shows list

  void toggleListGrid() {
    isGridView = !isGridView;
    update(['marketList']); // update only widgets with id 'watchList'
  }

  // optionally explicit setters
  void setGridView(bool value) {
    isGridView = value;
    update(['marketList']);
  }

  /// Call ONCE when page opens (or when marketData arrives)
  void setInitialPrice(double? reference) {
    _priceCents = ((reference ?? 0.0) * 100).round();
    _updateText();
  }

  void incrementTradValue() {
    _syncFromText();
    _priceCents += 10; // +0.10
    _updateText();
  }

  void decrementTradValue() {
    _syncFromText();
    _priceCents = (_priceCents - 10).clamp(0, 1 << 31); // -0.10, not below 0
    _updateText();
  }

  /// Read current text safely into cents
  void _syncFromText() {
    final raw = tradPriceTextEditField.text.trim();
    final parsed = double.tryParse(raw.replaceAll(',', '')) ?? 0.0;
    _priceCents = (parsed * 100).round();
  }

  /// Write back as 2 decimals and keep cursor at end
  void _updateText() {
    final newText = (_priceCents / 100).toStringAsFixed(2);
    if (tradPriceTextEditField.text != newText) {
      tradPriceTextEditField.value = tradPriceTextEditField.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
        composing: TextRange.empty,
      );
    }
    update();
  }

  void onRowTapUpdatePrice(double? price) {
    if (price != null) {
      tradPriceTextEditField.text = price.toStringAsFixed(2);
    }
    update(['total_amount_update']);
  }

  void onChanged(String value) {
    tradPrice = double.tryParse(value) ?? 0.0;
    update();
    calculateTotal();
  }

  void calculateTotal() {
    double qty = double.tryParse(qtyTextEditField.text) ?? 0.0;
    double price = double.tryParse(tradPriceTextEditField.text) ?? 0.0;
    totalAmount = qty * price;
    update(['total_amount_update']);
  }

  void updateQuantity(String value) {
    double currentValue = double.tryParse(qtyTextEditField.text) ?? 0.0;

    double newValue = (value == '1K')
        ? 1000.0
        : (double.tryParse(value) ?? 0.0);

    // ৩. যোগফল বের করা
    double total = currentValue + newValue;

    // যদি আপনার কোয়ান্টিটি দশমিক হতে পারে তবে .toInt() বাদ দিবেন
    qtyTextEditField.text = total.toInt().toString();

    // ৫. কার্সার শেষে রাখা
    qtyTextEditField.selection = TextSelection.collapsed(
      offset: qtyTextEditField.text.length,
    );

    // আপনার লিসেনার অটোমেটিক calculateTotal() কল করবে এবং টোটাল আপডেট হবে।
  }

  Future<bool?> refreshTokenIfNeeded() async {
    final res = await homeRepository.refreshTokenIfNeeded(
      watchlistTextEditField.text,
    );
    printLog(res?.success);
    printLog(res?.data);
    if (res?.success == true) {
      await StorageService.save(StorageConstants.token, res?.data['access']);
      await StorageService.save(
        StorageConstants.refreshToken,
        res?.data['refresh'],
      );
      return true;
    }
    return null;
  }

  bool isCreateFavCat = false;
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

  Future<bool> biometricActive(String? bioToken, bool isActive) async {
    if (await NetworkUtil.checkInternetConnection()) {
      isCreateFavCat = true;
      update();
      final res = await homeRepository.biometricActive(bioToken, isActive);
      printLog(
        'res?.success biometricActive: ${res?.success}:  ${res?.errorMessage}',
      );
      if (res?.success == true) {
        isCreateFavCat = false;
        update();
        Get.back();
        return true;
      } else {
        isCreateFavCat = false;
        update();
        return false;
      }
    } else {
      NetworkUtil.networkErrorMessage();
      isCreateFavCat = false;
      update();
      return false;
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

  bool isAddFavCat = false;
  var shortName = '';
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

  void changeFavFilter(int filter) {
    watchListFilterFavorite = filter;
    var item = favCatList.where((o) => o.id == filter).first;
    watchListFilterFavoriteName = item.name!;
    update();
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

  bool isFavourite(int orderBookId) {
    // favMarketData এর মধ্যে check
    return favMarketData.any(
      (fav) =>
          fav.oderBook != null &&
          fav.oderBook.toString() == orderBookId.toString(),
    );
  }

  List<FavMarketResponse> favMarketData = [];
  List<MarketModel> favMarketParseList = [];
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

  List<FavMarketResponse> favAllMarketData = [];
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

  var selectedTableId = 0;
  bool loadingFav = false;
  void selectTable(int tableId) {
    selectedTableId = tableId;
    getFavMarketData(tableId);
    update(); // update button selection
  }

  bool isGetFavCat = false;
  final favCatList = <FavouriteModel>[];

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
        watchListFilterFavoriteName = favCatList.elementAt(0).name!;
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

  void showBuySellDialog(BuildContext ctx, int orderBookId) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text("Choose Action"),
        content: const Text("Do you want to Buy or Sell?"),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor("#22C665"),
            ),
            onPressed: () {
              Get.back();
              setBuySellActive(SideType2.BUY);
              goBottomNabBarPage(5, orderBookId);
            },
            child: Text(
              "Buy",
              style: Get.textTheme.bodyLarge!.copyWith(
                color: ColorConstants.white,
              ),
            ),
          ),
          AppSpace.spaceW10,
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor("#F70042"),
            ),
            onPressed: () {
              Get.back();
              setBuySellActive(SideType2.SELL);
              goBottomNabBarPage(5, orderBookId);
            },
            child: Text(
              "Sell",
              style: Get.textTheme.bodyLarge!.copyWith(
                color: ColorConstants.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= index socket ========================

  List<IndexModel> uniqueArray(List<IndexModel> arr) {
    List<IndexModel> newArr = [];
    for (var obj in arr) {
      if (newArr.contains(obj)) {
        continue;
      }
      newArr.add(obj);
    }
    return newArr;
  }

  // sector summary map
  Map<String, Map<String, int>> get sectorSummary =>
      _marketStatistics.sectorSummary;
  final Map<String, double> lastPrices = {};
  final Map<String, String> lastStatus = {};

  // chart data

  // process incoming tick / market data

  //2nd grop by
  List<Map<String, dynamic>> getChartData3() {
    return _marketStatistics.getGainerChartData();
  }

  List<Map<String, dynamic>> getChartData2() =>
      _marketStatistics.getGainerCountsChartData();

  // end
  Map<String, Map<String, int>> sectorCounts = {};
  Map<int, Map<String, dynamic>> stockDataMap = {};
  void countStockChanges(dynamic message) {
    final tick = jsonDecode(message);
    if (tick["sn"] == null) {
      printLog("⚠️ Tick missing symbol: $tick");
      return; // বা continue; যদি loop এর মধ্যে হয়
    }
    final int orderBookId = tick["ob"];
    final String sector = tick["sc"];
    final double price = (tick["lp"] as num).toDouble();
    final double prev = (tick["r"] as num).toDouble();

    // Initialize sector if not already present in sectorCounts
    if (!stockDataMap.containsKey(orderBookId)) {
      // Initialize sector if not already present in sectorCounts
      if (!sectorCounts.containsKey(sector)) {
        sectorCounts[sector] = {'up': 0, 'down': 0, 'equal': 0};
      }

      // Determine if stock price is up, down, or unchanged
      if (price > prev) {
        sectorCounts[sector]!['up'] = sectorCounts[sector]!['up']! + 1;
      } else if (price < prev) {
        sectorCounts[sector]!['down'] = sectorCounts[sector]!['down']! + 1;
      } else {
        sectorCounts[sector]!['equal'] = sectorCounts[sector]!['equal']! + 1;
      }

      // Store the tick in stockDataMap using the unique orderBookId
      stockDataMap[orderBookId] = tick;
      // Prepare data for chart update
      List<Map<String, dynamic>> chartData2 = [];
      sectorCounts.forEach((sector, counts) {
        chartData2.add({
          'sector': sector,
          'up': counts['up'],
          'down': counts['down'],
          'equal': counts['equal'],
        });
      });

      // Update the chart data source (this is where homeCon.chartData comes in)
      chartData = chartData2;
      update(['marketList']);
    }
  }

  // convert sector summary to chart-friendly format

  Set<String> processedOrderBookIds = {}; // ✅ to avoid duplicates
  //2nd one
  Map<String, Map<String, int>> get sectorShareTypeSummary =>
      _marketStatistics.sectorShareTypeSummary;
  Map<String, String> get lastShareType => _marketStatistics.lastShareType;

  List<Map<String, dynamic>> getShareTypeChartData() =>
      _marketStatistics.getShareTypeChartData();

  //new task end
  UserBalance? userBalanceData;
  // 🚀 লোডারের জন্য নতুন ভেরিয়েবল
  bool isUserBalanceLoading = false;
  void userBalance() async {
    // 🚀 ১. MAGIC FIX: উইজেট বিল্ড হওয়ার সময় "markNeedsBuild" ক্র্যাশ ঠেকানোর জন্য
    await Future.delayed(Duration.zero);

    isUserBalanceLoading = true;
    update(); // এখন নিশ্চিন্তে আপডেট কল করতে পারেন, ক্র্যাশ করবে না!

    try {
      // 🛡️ সেফটি চেক: যদি সকেট ডিসকানেক্ট থাকে, তবে রিকানেক্ট করবে
      if (!isSocketConnected(AppConfig.userBalanceSocketId)) {
        printLog('🔌 Balance socket disconnected. Reconnecting...');
        await _initializeUserBalanceWebSocket();

        // 🚀 ২. SMART RETRY: সার্ভার স্লো থাকলে ১ সেকেন্ডে কানেক্ট নাও হতে পারে।
        // তাই আমরা ১ সেকেন্ড করে সর্বোচ্চ ৩ বার (Total 3 seconds) চেক করবো।
        int retryCount = 0;
        while (!isSocketConnected(AppConfig.userBalanceSocketId) &&
            retryCount < 3) {
          await Future.delayed(const Duration(seconds: 1));
          retryCount++;
          printLog(
            '⏳ Waiting for balance socket connection... Attempt: $retryCount',
          );
        }
      }

      // 🛡️ ডাবল ভেরিফিকেশন: লুপ শেষ হওয়ার পর চেক করা যে কানেক্ট হলো কি না
      if (isSocketConnected(AppConfig.userBalanceSocketId)) {
        printLog('🔄 ✅ User balance socket is successfully connected.');

        // যদি আগে থেকেই কানেক্টেড থাকে এবং ডেটা থাকে, তবে অযথাই লোডার ঘুরবে না
        if (userBalanceData != null) {
          isUserBalanceLoading = false;
          update();
          return;
        }
      } else {
        // ৩ সেকেন্ড পরও যদি কানেক্ট না হয়, তবেই ফেইল দেখাবে
        printLog(
          '❌ Failed to connect User Balance Socket after 3 seconds of delay.',
        );
        isUserBalanceLoading = false;
        update();
      }
    } catch (e) {
      printLog('❌ Exception in userBalance: $e');
      isUserBalanceLoading = false;
      update();
    }
  }

  // ==========================================
  // ==========================================
  void _handleUserBalanceMessage(dynamic message) {
    printLog('📩 User Balance Socket Message Received: $message');
    try {
      final jsonResponse = jsonDecode("$message");
      final data = jsonResponse[AppConstants.data];

      if (data != null) {
        printLog('🧾 User Balance Data :: $data');
        var response = userBalanceFromJson(data);

        // সেফটি চেক: রেসপন্স List ফাঁকা কি না চেক করা
        if (response.isNotEmpty) {
          userBalanceData = response.first;
        }
      }
    } catch (e) {
      printLog('❌ Error parsing user balance socket data: $e');
    } finally {
      // 🚀 finally ব্লক ব্যবহার করা হলো, যাতে ডাটা আসুক বা এরর হোক—
      // সব শেষেই যেন গ্যারান্টিডভাবে লোডার অফ হয় এবং UI আপডেট হয়।
      isUserBalanceLoading = false;
      update(['user_balance_update']);
    }
  }

  List<StackedColumnSeries<MarketModel, String>> buildStackedColumnSeries() {
    List<StackedColumnSeries<MarketModel, String>> seriesList = [];
    groupedSectionMarketData?.forEach((session, models) {
      printLog(session);
      printLog('section : ${models.length}');
    });
    return seriesList;
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      marketListForDilog = marketListAll;
    } else {
      marketListForDilog = marketListAll
          .where(
            (item) => (item.shortName ?? "").toUpperCase().startsWith(
              query.toUpperCase(),
            ),
          )
          .toList();
    }
    update();
  }

  void newMarketInfo(int orderBookId) async {
    printLog(orderBookId);
    searchController.clear();
    await manageMarketDepth(orderBookId);
    subscribeTimeAndSales('tsm', '01', '$orderBookId');
    subscribeTimeAndSales('tsb', '02', '$orderBookId');
    subscribeTimeAndSales('news_hist', '04', '$orderBookId');
    update(['marketList']);

    if (!isClosed) {
      // update data
    }
    Get.back();
    marketListForDilog = marketListAll;
    await Future.delayed(Duration(seconds: 1));
    setInitialPrice(marketData.last);
  }

  Future<void> OrderBookForChange(int orderBookId) async {
    await manageMarketDepth(orderBookId);
    subscribeTimeAndSales('tsm', '01', '$orderBookId');
    subscribeTimeAndSales('tsb', '02', '$orderBookId');
    subscribeTimeAndSales('news_hist', '04', '$orderBookId');
    update(['marketList']);
  }

  void filterWatchListMain(String data) {
    watchListFilterBoard = data;
    isMarket = true;
    update();
    Get.back();
    printLog('data --- :: $watchListFilterBoard ::  ');
    marketList = [];
    update();
    for (var i = 0; i < marketListAll.length; i++) {
      if (watchListFilterBoard.toUpperCase() ==
          marketListAll[i].board?.toUpperCase()) {
        marketList.add(marketListAll[i]);
      }
    }

    update();

    Future.delayed(const Duration(seconds: 1), () {
      isMarket = false;
      update();
    });

    printWrapped("----------9999999--------s");
  }

  void filterWatchListPublic(String data) {
    Get.back();
    watchListFilterPublic = data;
    update();
    printLog('data --- :: $watchListFilterPublic ::  ');
    marketList = [];
    update();
    for (var i = 0; i < marketListAll.length; i++) {
      if (watchListFilterPublic.toUpperCase() ==
          marketListAll[i].marketType?.toUpperCase()) {
        marketList.add(marketListAll[i]);
      }
    }
    update();
  }

  void changeTabIndex(int index) {
    printLog('changeTabIndex -- :: ');
    printLog(marketList.isEmpty);
    if (marketList.isEmpty) {
    }
    if (watchListFilterFavorite == 0 && favCatList.isNotEmpty) {
      watchListFilterFavorite = favCatList.elementAt(0).id!;
    }
    currentTabIndex = index;
    update();
  }

  List<int> tabHistory = [0];

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
      applyFilters();
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

  CompaniesModel? company;
  DividendModel? dividendObj;
  Future<void> loadCompany(String symbol) async {
    printLog('model.shortName: == $symbol');
    company = await companiesController.getCompanies(symbol.toUpperCase());
    printLog('resul====:${company?.toMap()}');
    update(['marketList']);
  }

  Future<void> loadDividend(String symbol) async {
    printLog('model.shortName: == $symbol');
    dividendObj = await companiesController.getDividend(symbol.toUpperCase());
    printLog('resul====:${dividendObj?.toMap()}');
    update(['marketList']);
  }

  Map<String, EpsModel> epsData = {};

  Future<void> loadEPS(String symbol) async {
    int year = DateTime.now().year;
    epsData = await companiesController.getYearlyEPS(symbol, year);
    update(['marketList']);
  }

  void loadComanyDividentEPS(String shortName) async {
    await loadCompany(shortName);
    await loadDividend(shortName);
    await loadEPS(shortName);
  }

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

  Map<double, List<MarketOrderModel>> orderMap = {};
  Map<double, List<MarketOrderModel>> orderDepthMap = {};
  MarketModel marketData = MarketModel();

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

  int totalBuyQty = 0;
  int totalSalesQty = 0;
  Map<double, List<OrderModel>> findSamePriceProducts(List<OrderModel> orders) {
    Map<double, List<OrderModel>> priceMap = {};

    for (var order in orders) {
      printLog('available key Is ${order.side}');
      printLog('available key Is');
      printLog(!priceMap.containsKey(order.price));

      final isBuyOrder = order.side?.trim().toUpperCase() == "B";
      final isEligibleStatus =
          order.status == AppConstants.pendingOrderStatus ||
          order.status == AppConstants.updatedOrderStatus ||
          order.status == AppConstants.partiallyFilledOrderStatus;
      if (isBuyOrder && isEligibleStatus && order.price != null) {
        if (!priceMap.containsKey(order.price)) {
          priceMap[order.price!] = [];
        }
        priceMap[order.price]!.add(order);
      }
    }

    // Remove entries with only one product (no duplicates)
    for (var item in priceMap.values) {
      for (var i in item) {
        printLog(i.price);
        printLog(i.qty);
        printLog(i.executedQty);
        printLog('i.side');
        totalBuyQty += i.qty!;
      }
    }
    update();
    return priceMap;
  }

  Map<double, List<MarketOrderModel>> findSomeSalesItem(
    List<MarketOrderModel> orders,
  ) {
    Map<double, List<MarketOrderModel>> priceMap = {};
    for (var order in orders) {}

    // Remove entries with only one product (no duplicates)
    for (var item in priceMap.values) {
      for (var i in item) {
        printLog(i.price);
        printLog(i.quantity);
        printLog('i.side');
        totalSalesQty += i.quantity!;
        update();
      }
    }
    return priceMap;
  }

  void getUserInfo() async {
    try {
      var res = StorageService.getMap(StorageConstants.userInfo);
      if (res != null) {
        UserProfile? user = UserProfile.fromJson(res);
        printLog('User profile loaded: ${user.toJson()}');
        userInfo = user;
        isUserInfoLoaded = true;
        update();
      } else {
        printLog('User info not found in storage');
        isUserInfoLoaded = true; // Still mark as loaded but empty
      }
    } catch (e) {
      printLog('Error loading user info: $e');
      isUserInfoLoaded = true;
    }
  }

  String? getBoId() {
    return userInfo.userDetail?.boId;
  }

  Future<AppExitResponse> _onExitRequested() async {
    final response = await showDialog<AppExitResponse>(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Are you sure you want to quit this app?'),
        content: const Text('All unsaved progress will be lost.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(AppExitResponse.cancel);
            },
          ),
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop(AppExitResponse.exit);
            },
          ),
        ],
      ),
    );

    return response ?? AppExitResponse.exit;
  }

  Future<bool> showExitDialog(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Do you really want to exit the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes"),
              ),
            ],
          ),
        )) ??
        false;
  }

  MarketModel getMarketByOrderBookId(int orderBookId) {
    return marketListAll.firstWhere(
      (market) => market.orderBook == orderBookId,
      orElse: () => MarketModel(),
    );
  }

  // =========================================================================
  // =========================================================================
  var userOrder = UserOrderModel();
  List<UserOrder> userOrderList = [];
  List<OrderAlertModel> orderAlertsList = [];
  bool isLoadingUserOrder = false;
  bool isOrderConfirmLoading = false;

  // =========================================================================
  // =========================================================================
  void _handleOrderConfirmMessage(String message) {
    printLog(' RAW Socket Message: $message');

    try {
      final jsonResponse = jsonDecode(message);

      //  Safe Type Casting
      final messageType = jsonResponse['message_type']?.toString();
      final dataPayload = jsonResponse['data'];
      final alertPayload = jsonResponse['alert'];

      final rawMessage = jsonResponse['message'];
      String messageText = "Unknown Error";
      if (rawMessage is List && rawMessage.isNotEmpty) {
        messageText = rawMessage[0]
            .toString(); // যদি Array হয়, তবে প্রথম এররটি নিবে
      } else if (rawMessage != null) {
        messageText = rawMessage.toString(); // যদি সাধারণ String হয়
      }

      //  DRY Principle: ব্যাকগ্রাউন্ড ইভেন্ট (connection/alert) ছাড়া বাকি সব রেসপন্সেই লোডিং অফ হবে
      if (messageType != AppConstants.connection &&
          messageType != 'connection' &&
          messageType != AppConstants.alert &&
          messageType != 'alert') {
        isOrderConfirmLoading = false;
        update(['order_confirm_btn']);
      }

      //  Switch-Case Architecture
      switch (messageType) {
        // ==========================================
        // 🟢 ১. Connection State
        // ==========================================
        case AppConstants.connection:
          debugPrint('✅ Order Socket Connected: $messageText');

          if (alertPayload is List) {
            orderAlertsList = alertPayload
                .map((item) => OrderAlertModel.fromJson(item))
                .toList();
          }

          if (dataPayload is List) {
            userOrder = UserOrderModel.fromJson(jsonResponse);
            userOrderList = dataPayload
                .map((order) => UserOrder.fromJson(order))
                .toList();
            printLog('📦 Initial Orders loaded: ${userOrderList.length}');
          }

          isLoadingUserOrder = false;
          update([AppConstants.orderList, AppConstants.orderAlertsUpdate]);
          break;

        // ==========================================
        // 🟢 ২. Order Submitted Success
        // ==========================================
        case AppConstants.orderSubmitted:
          printLog("✅ Order Success: $messageText");

          Get.snackbar(
            "Success",
            messageText.isNotEmpty
                ? messageText
                : "Action completed successfully.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          clearAllFields();
          currentIndex = 4;
          currentTabIndexPortfolio = 1;
          update();
          if (Get.currentRoute != Routes.HOME) {
            printLog('🔄 Redirecting to Home Page from: ${Get.currentRoute}');
            Get.offNamed(Routes.HOME);
          } else {
            printLog('🏠 User is already on Home Page. Skipping navigation.');
          }
          break;
        // ==========================================
        // ==========================================
        case AppConstants.orderError:
          printLog("❌ Order Error: $messageText");
          Get.snackbar(
            "Order Failed",
            messageText,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          update();
          break;

        // ==========================================
        // 🗑️ ৪. Order Report Remove
        // ==========================================
        case AppConstants.orderReportRemove:
          if (messageText != "Unknown Error" && messageText.isNotEmpty) {
            Get.snackbar(
              "Order Removed",
              messageText,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
          if (dataPayload is Map<String, dynamic>) {
            _removeOrderFromList(UserOrder.fromJson(dataPayload));
          }
          update([AppConstants.orderList]);
          break;

        // ==========================================
        // 🔔 ৫. Single Alert
        // ==========================================
        case AppConstants.alert:
          if (dataPayload is Map<String, dynamic>) {
            orderAlertsList.insert(0, OrderAlertModel.fromJson(dataPayload));
            printLog('🔔 New Single Alert Added: ${dataPayload['status']}');
          }
          update([AppConstants.orderAlertsUpdate]);
          break;

        // ==========================================
        // ==========================================
        case AppConstants.orderReport:
          if (dataPayload is Map<String, dynamic>) {
            final rejectionReason = dataPayload['rejectionReason']?.toString();
            if (rejectionReason != null && rejectionReason.isNotEmpty) {
              Get.snackbar(
                "Order Rejected",
                rejectionReason,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
            _updateOrInsertOrder(UserOrder.fromJson(dataPayload));
          }
          update([AppConstants.orderList]);
          break;

        // ==========================================
        // 📊 ৭. Order Status
        // ==========================================
        case AppConstants.orderStatus: // অথবা case 'order_status':
          printLog("✅ orderStatus Success Received");

          if (dataPayload is Map<String, dynamic>) {
            // এরর মেসেজ থাকলে দেখাবে
            final rejectionReason = dataPayload['rejectionReason']?.toString();
            if (rejectionReason != null && rejectionReason.isNotEmpty) {
              Get.snackbar(
                "Status Error",
                rejectionReason,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }

            // সাকসেস হলে ডিটেইলস পেজে পাঠাবে
            final execType =
                dataPayload['execType'] ?? dataPayload['exec_type'];
            if (execType == 'ORDER_STATUS' || execType != null) {
              orderStatusDetails = OrderStatusDetailsModel.fromJson(
                dataPayload,
              );

              clearAllFields(); //  আপনার রিকোয়ারমেন্ট অনুযায়ী ফিল্ড ক্লিয়ার করা হলো
              Get.to(
                () => OrderStatusDetailsView(order: orderStatusDetails),
                fullscreenDialog: true,
              );
            }
          }
          update([AppConstants.orderList]);
          break;

        // ==========================================
        // 🚫 ৮. Session Reject
        // ==========================================
        case 'session_reject':
          String rejectMsg = (dataPayload is Map<String, dynamic>)
              ? (dataPayload['reason']?.toString() ?? "Session Rejected")
              : "Session Rejected";
          Get.snackbar(
            "Session Error",
            rejectMsg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          update();
          break;

        // ==========================================
        // ⚠️ Default / Unknown Type
        // ==========================================
        default:
          printLog('⚠️ Unknown Message Type received: $messageType');
          break;
      }
    } catch (e) {
      isOrderConfirmLoading = false;
      isLoadingUserOrder = false;
      update([AppConstants.orderList, 'order_confirm_btn']);
      printLog("❌ Error parsing socket message: $e");
    }
  }
  // =========================================================================
  // =========================================================================

  void _removeOrderFromList(UserOrder singleData) {
    final clientId = singleData.clientOrderId?.trim();
    if (clientId == null || clientId.isEmpty) return;

    // Remove from main model safely
    if (userOrder.data != null) {
      userOrder.data!.removeWhere(
        (element) => element.clientOrderId?.trim() == clientId,
      );
    }
    // Remove from active list
    userOrderList.removeWhere((e) => e.clientOrderId?.trim() == clientId);
  }

  void _updateOrInsertOrder(UserOrder singleData) {
    final clientId = singleData.clientOrderId?.trim();
    if (clientId == null || clientId.isEmpty) return;

    //  ১. Update Main Model (userOrder) efficiently
    final currentData = userOrder.data ?? [];
    final modelIndex = currentData.indexWhere(
      (e) => e.clientOrderId?.trim() == clientId,
    );

    if (modelIndex != -1) {
      // Create a mutable copy, update it, and pass it to copyWith (More efficient than .map)
      final newData = List<UserOrder>.from(currentData);
      newData[modelIndex] = singleData;
      userOrder = userOrder.copyWith(data: newData);
    } else {
      userOrder = userOrder.copyWith(data: [singleData, ...currentData]);
    }

    final listIndex = userOrderList.indexWhere(
      (e) => e.clientOrderId?.trim() == clientId,
    );
    if (listIndex != -1) {
      userOrderList[listIndex] = singleData;
    } else {
      userOrderList.insert(0, singleData); // New orders go to the top
    }
  }

  //  আপনার ডুপ্লিকেট সকেট মুছে ফেলা হলো। এখন এটি শুধু কমন সকেটটি কানেক্ট করবে।
  Future<void> getUserOrder() async {
    printLog('Fetching User Orders...');
    isLoadingUserOrder = true;
    update([AppConstants.orderList]);

    // যদি আগে থেকে কানেক্ট করা না থাকে, তবে কানেকশন তৈরি করবে
    if (!isOrderConfirmConnected) {
      await _initializeOrderConfirmWebSocket();
    } else {
      isLoadingUserOrder = false;
      update([AppConstants.orderList]);
    }
  }

  void orderConfirmSubmitted(
    SideType2 sideType,
    ActionsType action, {
    UserOrder? order,
  }) async {
    if (!await checkInternet()) return;

    isOrderConfirmLoading = true;
    update(['order_confirm_btn']);

    try {
      //  সেফটি চেক: যদি কোনো কারণে সকেট ডিসকানেক্ট হয়ে থাকে, তাহলে আবার কানেক্ট করে নিবে
      if (!isOrderConfirmConnected) {
        await _initializeOrderConfirmWebSocket();
        await Future.delayed(
          const Duration(milliseconds: 500),
        ); // কানেকশনের জন্য আধা সেকেন্ড অপেক্ষা
      }

      var marketPrice = marketData.reference;
      var price = double.tryParse(tradPriceTextEditField.text) ?? 0.0;
      var qty = int.tryParse(qtyTextEditField.text) ?? 0;

      final sendPrice =
          (selectOrderType?.toUpperCase() != 'LIMIT' &&
              sideType == SideType2.BUY)
          ? marketPrice
          : price;

      final reqBody = _buildReqBody(action, sideType, qty, sendPrice);
      var actionData = action == ActionsType.ORDER
          ? reqBody.toJson()
          : reqBody.toJsonReplaceOrder();

      printLog('📤 Sending Order Data: ${jsonEncode(actionData)}');
      sendMessage(AppConfig.orderConfirmSocketId, jsonEncode(actionData));
    } catch (e) {
      isOrderConfirmLoading = false;
      update(['order_confirm_btn']);
      printLog('❌ WebSocket connection failed: $e');
    }
  }

  void orderDuplicateSubmitted(ActionsType action, {UserOrder? order}) async {
    //  ১. ইন্টারনেট চেক
    if (!await checkInternet()) return;

    //  ২. অর্ডার ডেটা ভ্যালিডেশন
    if (order == null) {
      printLog(
        '❌ Error: Cannot duplicate order because original order data is missing.',
      );
      return;
    }

    var clientCode = userInfo.userDetail?.investorCode ?? '';
    final safeOrderBookId = order.orderBookId ?? 0;
    final marketFindByOrderBookId = getMarketByOrderBookId(safeOrderBookId);

    //  ৩. মার্কেট ডেটা ভ্যালিডেশন
    if (marketFindByOrderBookId.orderBook == null ||
        marketFindByOrderBookId.shortName == null) {
      printLog(
        '❌ Error: Market data not found for OrderBookId: $safeOrderBookId',
      );
      Get.snackbar(
        "Invalid Market Data",
        "Market data not found for this order. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return; // অবৈধ ডেটা সকেটে পাঠানো বন্ধ করা হলো
    }

    // .parse এর বদলে .tryParse ব্যবহার করা হয়েছে, যাতে null/ফাঁকা আসলে ক্র্যাশ না করে 0.0 বসিয়ে দেয়।
    var price = double.tryParse('${order.limit}') ?? 0.0;
    var qty = int.tryParse('${order.sentQty}') ?? 0;

    OrderConfirmRequest requestBody = OrderConfirmRequest(
      action: actionValues[action],
      traderPk: userInfo.userDetail?.traderId,
      traderId: userInfo.userDetail?.traderCode,
      boId: "${userInfo.userDetail?.boId}",
      clientCode: clientCode,
      branchId: userInfo.userDetail?.branchId,
      userId: userInfo.id,
      orderType: order.ordType?.toUpperCase(),
      qty: qty,
      price: price,
      symbol: marketFindByOrderBookId.shortName,
      side: order.side, // 'BUY':'SELL',
      isin: marketFindByOrderBookId.isinCode,
      assetClass: marketFindByOrderBookId.instrumentType,
      securityCode: marketFindByOrderBookId.ticker,
      orderBookId: marketFindByOrderBookId.orderBook,
      board: marketFindByOrderBookId.board,
      session: currentSession.value,
      category: marketFindByOrderBookId.shareType?.toUpperCase(),
      marketType: marketFindByOrderBookId.marketType,
      group: marketFindByOrderBookId.group?.toUpperCase(),
      timeInForce: "0",
      displayQty: order.displayQty == 0 ? null : order.displayQty,
      minQty: order.minQty == 0 ? null : order.minQty,
    );

    final jsonRequest = jsonEncode(requestBody.toJson());
    printWrapped('📤 Sending duplicate order: $jsonRequest');

    try {
      //  ৫. Socket Connection Check & Auto-Reconnect
      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        printLog('🔌 Order Socket is disconnected. Reconnecting...');
        await _initializeOrderConfirmWebSocket();

        // রিকানেক্ট হওয়ার জন্য ১ সেকেন্ড অপেক্ষা
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        Get.snackbar(
          "Connection Failed",
          "Unable to connect to the trading server. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return; // ডেটা সেন্ড করবে না
      }

      //  ৭. Send Data via Common Socket
      sendMessage(AppConfig.orderConfirmSocketId, jsonRequest);
      printLog('✅ Duplicate order request sent successfully.');

      currentTabIndexPortfolio = 1;
      update([AppConstants.orderList]);

      // অপশনাল: ইউজারকে একটি সাকসেস স্নাইকবার দেখানো যেতে পারে
    } catch (e) {
      printLog('❌ Unknown exception during duplicate order: $e');
      Get.snackbar(
        "Submission Failed",
        "Failed to send duplicate order. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    update();
  }

  void orderDuplicateSubmittedOld(
    ActionsType action, {
    UserOrder? order,
  }) async {
    if (!await checkInternet()) return;
    var clientCode = userInfo.userDetail?.investorCode;
    final marketFindByOrderBookId = getMarketByOrderBookId(
      order?.orderBookId ?? 0,
    );
    // If it returned an empty MarketModel, the ticker or orderBook will likely be null.
    if (marketFindByOrderBookId.orderBook == null ||
        marketFindByOrderBookId.shortName == null) {
      printLog(
        'Error: Market data not found for OrderBookId: ${order?.orderBookId}',
      );
      // ⚠️ Show a Toast/SnackBar here: "Market data not found, please try again."
      return; // Stop execution here. Do not send invalid data to the socket!
    }
    var price = double.parse('${order?.limit}');
    var qty = int.parse('${order?.sentQty}');
    OrderConfirmRequest requestBody = OrderConfirmRequest(
      action: actionValues[action],
      traderPk: userInfo.userDetail?.traderId,
      traderId: userInfo.userDetail?.traderCode,
      boId: "${userInfo.userDetail?.boId}",
      clientCode: '$clientCode',
      branchId: userInfo.userDetail?.branchId,
      userId: userInfo.id,
      orderType: order?.ordType?.toUpperCase(),
      qty: qty,
      price: price,
      symbol: marketFindByOrderBookId.shortName,
      side: order?.side, // 'BUY':'SELL',
      isin: marketFindByOrderBookId.isinCode,
      assetClass: marketFindByOrderBookId.instrumentType,
      securityCode: marketFindByOrderBookId.ticker,
      orderBookId: marketFindByOrderBookId.orderBook,
      board: marketFindByOrderBookId.board,
      session: currentSession.value,
      category: marketFindByOrderBookId.shareType?.toUpperCase(),
      marketType: marketFindByOrderBookId.marketType,
      group: marketFindByOrderBookId.group?.toUpperCase(),
      timeInForce: "0",
      displayQty: order?.displayQty == 0 ? null : order?.displayQty,
      minQty: order?.minQty == 0 ? null : order?.minQty,
    );
    printWrapped(
      'Sending replace order----: ${jsonEncode(requestBody.toJson())}',
    );
    try {
      sendMessage(
        AppConfig.orderConfirmSocketId,
        jsonEncode(requestBody.toJson()),
      );
      currentTabIndexPortfolio = 1;
      update([AppConstants.orderList]);
    }
    catch (e) {
      printLog('Unknown exception: $e');
    }
    update();
  }

  void orderConfirmSubmittedReplaceOrder(
    SideType2 sideType,
    ActionsType action, {
    UserOrder? order,
  }) async {
    //  1. SAFEGUARD: Check internet
    if (!await checkInternet()) return;

    //  2. SAFEGUARD: A replace order MUST have an existing order to replace.
    if (order == null || order.orderId == null || order.orderId!.isEmpty) {
      printLog(
        '❌ Error: Cannot replace order because original order data is missing.',
      );
      Get.snackbar(
        "Invalid Order",
        "Cannot replace this order because original data is missing.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    printLog('🔄 Initiating Replace Order Request...');

    //  3. SAFEGUARD: Handle orderBookId safely.
    final safeOrderBookId = order.orderBookId ?? 0;
    final marketFindByOrderBookId = getMarketByOrderBookId(safeOrderBookId);

    //  4. SAFEGUARD: Check if market data was actually found
    if (marketFindByOrderBookId.orderBook == null ||
        marketFindByOrderBookId.shortName == null) {
      printLog(
        '❌ Error: Market data not found for OrderBookId: $safeOrderBookId',
      );
      Get.snackbar(
        "Invalid Market Data",
        "Market data not found for this order. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return; // Stop execution here. Do not send invalid data to the socket!
    }

    final userDetail = userInfo.userDetail;
    final traderCode = userDetail?.traderCode ?? '';
    final boId = userDetail?.boId ?? '';
    final clientCode = userDetail?.investorCode ?? '';

    //  5. SAFEGUARD: Ensure price and qty are parsed safely.
    final price = double.tryParse(tradPriceTextEditField.text) ?? 0.0;
    final qty = int.tryParse(qtyTextEditField.text) ?? 0;

    // Fetch the reference price safely
    final marketPrice = marketFindByOrderBookId.reference ?? 0.0;

    final sendPrice =
        (selectOrderType?.toUpperCase() != 'LIMIT' && sideType == SideType2.BUY)
        ? marketPrice
        : price;

    final requestBody = OrderConfirmRequest(
      action: actionValues[action],
      traderPk: userDetail?.traderId,
      traderId: traderCode,
      boId: boId,
      clientCode: clientCode,
      orderId: order.orderId ?? '',
      clientOrderId: order.clientOrderId ?? '',
      branchId: userDetail?.branchId,
      userId: userInfo.id,
      orderType: selectOrderType?.toUpperCase(),
      qty: qty,
      price: sendPrice,
      symbol: marketFindByOrderBookId.shortName,
      side: sideTypeEnumMap[sideType],
      isin: marketFindByOrderBookId.isinCode,
      assetClass: marketFindByOrderBookId.instrumentType,
      securityCode: marketFindByOrderBookId.ticker,
      orderBookId: marketFindByOrderBookId.orderBook,
      board: marketFindByOrderBookId.board,
      session: currentSession.value,
      category: marketFindByOrderBookId.shareType?.toUpperCase(),
      marketType: marketFindByOrderBookId.marketType,
      group: marketFindByOrderBookId.group?.toUpperCase(),
      timeInForce: "0",
      displayQty: _parseNullableInt(disclosedQtyTextEditField.text),
      minQty: _parseNullableInt(minQtyTextEditField.text),
    );

    final jsonRequest = jsonEncode(requestBody.toJsonReplaceOrder());
    printWrapped('📤 Sending replace order: $jsonRequest');

    try {
      //  6. SAFEGUARD: Socket Connection Check & Auto-Reconnect
      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        printLog('🔌 Order Socket is disconnected. Reconnecting...');
        await _initializeOrderConfirmWebSocket();

        // রিকানেক্ট হওয়ার জন্য ১ সেকেন্ড অপেক্ষা
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        Get.snackbar(
          "Connection Failed",
          "Unable to connect to the trading server. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return; // ডেটা সেন্ড করবে না
      }

      //  8. Send Data via Common Socket
      sendMessage(AppConfig.orderConfirmSocketId, jsonRequest);
      printLog('✅ Replace order request sent successfully.');

      // Only update UI if the send attempt didn't throw an error
      currentTabIndexPortfolio = 1;
      update([AppConstants.orderList]);

    } catch (e) {
      printLog('❌ WebSocket send failed: $e');
      Get.snackbar(
        "Modification Failed",
        "Failed to send order modification. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void orderConfirmSubmittedReplaceOrderOld(
    SideType2 sideType,
    ActionsType action, {
    UserOrder? order,
  }) async {
    // 1. SAFEGUARD: Check internet
    if (!await checkInternet()) return;

    // 2. SAFEGUARD: A replace order MUST have an existing order to replace.
    if (order == null || order.orderId == null || order.orderId!.isEmpty) {
      printLog(
        'Error: Cannot replace order because original order data is missing.',
      );
      return;
    }

    printLog('order confirm socket called::::::::');

    // 3. SAFEGUARD: Handle orderBookId safely.
    final safeOrderBookId = order.orderBookId ?? 0;
    final marketFindByOrderBookId = getMarketByOrderBookId(safeOrderBookId);

    //  NEW SAFEGUARD: Check if market data was actually found
    // If it returned an empty MarketModel, the ticker or orderBook will likely be null.
    if (marketFindByOrderBookId.orderBook == null ||
        marketFindByOrderBookId.shortName == null) {
      printLog(
        'Error: Market data not found for OrderBookId: $safeOrderBookId',
      );
      // ⚠️ Show a Toast/SnackBar here: "Market data not found, please try again."
      return; // Stop execution here. Do not send invalid data to the socket!
    }

    final userDetail = userInfo.userDetail;
    final traderCode = userDetail?.traderCode ?? '';
    final boId = userDetail?.boId ?? '';
    final clientCode = userDetail?.investorCode ?? '';

    // 4. SAFEGUARD: Ensure price and qty are parsed safely.
    final price = double.tryParse(tradPriceTextEditField.text) ?? 0.0;
    final qty = int.tryParse(qtyTextEditField.text) ?? 0;

    // Fetch the reference price safely
    final marketPrice = marketFindByOrderBookId.reference ?? 0.0;

    final sendPrice =
        (selectOrderType?.toUpperCase() != 'LIMIT' && sideType == SideType2.BUY)
        ? marketPrice
        : price;

    final requestBody = OrderConfirmRequest(
      action: actionValues[action],
      traderPk: userDetail?.traderId,
      traderId: traderCode,
      boId: boId,
      clientCode: clientCode,
      orderId: order.orderId ?? '',
      clientOrderId: order.clientOrderId ?? '',
      branchId: userDetail?.branchId,
      userId: userInfo.id,
      orderType: selectOrderType?.toUpperCase(),
      qty: qty,
      price: sendPrice,
      symbol: marketFindByOrderBookId.shortName,
      side: sideTypeEnumMap[sideType],
      isin: marketFindByOrderBookId.isinCode,
      assetClass: marketFindByOrderBookId.instrumentType,
      securityCode: marketFindByOrderBookId.ticker,
      orderBookId: marketFindByOrderBookId.orderBook,
      board: marketFindByOrderBookId.board,
      session: currentSession.value,
      category: marketFindByOrderBookId.shareType?.toUpperCase(),
      marketType: marketFindByOrderBookId.marketType,
      group: marketFindByOrderBookId.group?.toUpperCase(),
      timeInForce: "0",
      displayQty: _parseNullableInt(disclosedQtyTextEditField.text),
      minQty: _parseNullableInt(minQtyTextEditField.text),
    );

    final jsonRequest = jsonEncode(requestBody.toJsonReplaceOrder());
    printWrapped('Sending replace order: $jsonRequest');

    try {
      // 5. SAFEGUARD: Check if the socket is actually available before sending

      sendMessage(AppConfig.orderConfirmSocketId, jsonRequest);

      // Only update UI if the send attempt didn't throw an error
      currentTabIndexPortfolio = 1;
      update([AppConstants.orderList]);
    } catch (e) {
      printLog('WebSocket send failed: $e');
      // Show error to user: "Failed to send order modification"
    }
  }

  int? _parseNullableInt(String value) {
    if (value.isEmpty || value == '0') return null;
    return int.tryParse(value);
  }

  OrderConfirmRequest _buildReqBody(
    ActionsType type,
    SideType2? side,
    dynamic qty,
    dynamic sendPrice,
  ) {
    var traderCode = userInfo.userDetail?.traderCode;
    var boId = "${userInfo.userDetail?.boId}";
    var clientCode = userInfo.userDetail?.investorCode;
    var traderId = userInfo.userDetail?.traderId;
    switch (type) {
      case ActionsType.ORDER:
        return OrderConfirmRequest(
          action: actionValues[type],
          traderPk: traderId,
          traderId: traderCode,
          boId: boId,
          clientCode: '$clientCode',
          branchId: userInfo.userDetail?.branchId,
          userId: userInfo.id,
          orderType: selectOrderType?.toUpperCase(),
          qty: int.parse(qtyTextEditField.text),
          price: double.parse(tradPriceTextEditField.text),
          symbol: marketData.shortName,
          side: sideTypeEnumMap[side], // 'BUY':'SELL',
          isin: marketData.isinCode,
          assetClass: marketData.instrumentType,
          securityCode: marketData.ticker,
          orderBookId: marketData.orderBook,
          board: marketData.board,
          session: currentSession.value,
          category: marketData.shareType?.toUpperCase(),
          marketType: marketData.marketType,
          group: marketData.group?.toUpperCase(),
          timeInForce: "0",
          displayQty:
              disclosedQtyTextEditField.text == "" ||
                  disclosedQtyTextEditField.text == '0'
              ? null
              : int.parse(disclosedQtyTextEditField.text),
          minQty:
              minQtyTextEditField.text == '' || minQtyTextEditField.text == '0'
              ? null
              : int.parse(minQtyTextEditField.text),
        );
      case ActionsType.REPLACE_ORDER:
        return OrderConfirmRequest(
          action: actionValues[type],
          traderPk: userInfo.userDetail?.traderId,
          traderId: userInfo.userDetail?.traderCode,
          boId: "${userInfo.userDetail?.boId}",
          clientCode: '$clientCode',
          branchId: userInfo.userDetail?.branchId,
          userId: userInfo.id,
          orderType: selectOrderType?.toUpperCase(),
          qty: int.parse(qtyTextEditField.text),
          price: double.parse(tradPriceTextEditField.text),
          symbol: marketData.shortName,
          side: sideTypeEnumMap[side], // 'BUY':'SELL',
          isin: marketData.isinCode,
          assetClass: marketData.instrumentType,
          securityCode: marketData.ticker,
          orderBookId: marketData.orderBook,
          board: marketData.board,
          session: currentSession.value,
          category: marketData.shareType?.toUpperCase(),
          marketType: marketData.marketType,
          group: marketData.group?.toUpperCase(),
          timeInForce: "0",
          displayQty:
              disclosedQtyTextEditField.text == "" ||
                  disclosedQtyTextEditField.text == '0'
              ? null
              : int.parse(disclosedQtyTextEditField.text),
          minQty:
              minQtyTextEditField.text == '' || minQtyTextEditField.text == '0'
              ? null
              : int.parse(minQtyTextEditField.text),
        );
      case ActionsType.CANCEL_ORDER:
        return OrderConfirmRequest();
      case ActionsType.ORDER_STATUS:
        return OrderConfirmRequest();
    }
  }

  void orderCancelSubmitted(String action, UserOrder order) async {
    //  ১. ইন্টারনেট চেক
    if (!await checkInternet()) return;

    if (order.orderId == null || order.orderId!.isEmpty) {
      printLog('❌ Error: Cannot cancel order because Order ID is missing.');
      Get.snackbar(
        "Invalid Order",
        "Cannot cancel this order because the Order ID is missing.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    printLog('🔄 Initiating Order Cancel Request...');

    var clientCode = userInfo.userDetail?.investorCode ?? '';

    //  ৩. Symbol (shortName) বের করা হচ্ছে
    final shortName =
        marketListAll
            .firstWhereOrNull((market) => market.orderBook == order.orderBookId)
            ?.shortName ??
        '';

    if (shortName.isEmpty) {
      printLog(
        '⚠️ Warning: ShortName (Symbol) not found for OrderBookId: ${order.orderBookId}',
      );
    }

    UpdateOrderHolder requestBody = UpdateOrderHolder(
      action: action,
      traderId: userInfo.userDetail?.traderCode,
      boId: "${userInfo.userDetail?.boId}",
      clientCode: clientCode,
      userId: userInfo.id,
      symbol: shortName,
      side: order.side ?? '', // Safe null check
      orderId: order.orderId ?? '',
      origClientOrderId: order.clientOrderId ?? "",
      clientOrderId: "", // ক্যান্সেলের সময় নতুন ক্লায়েন্ট আইডি লাগে না
      session: currentSession.value,
    );

    final jsonRequest = jsonEncode(requestBody.toJson());
    printWrapped('📤 Sending Cancel Order: $jsonRequest');

    try {
      //  ৪. Socket Connection Check & Auto-Reconnect
      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        printLog('🔌 Order Socket is disconnected. Reconnecting...');
        await _initializeOrderConfirmWebSocket();

        // রিকানেক্ট হওয়ার জন্য ১ সেকেন্ড অপেক্ষা
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        Get.snackbar(
          "Connection Failed",
          "Unable to connect to the trading server. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return; // ডেটা সেন্ড করবে না
      }

      //  ৬. Send Data via Common Socket
      sendMessage(AppConfig.orderConfirmSocketId, jsonRequest);
      printLog('✅ Cancel order request sent successfully.');

      // 🔄 UI Update
      currentTabIndexPortfolio = 1;
      update([AppConstants.orderList]);

      // অপশনাল: ইউজারকে একটি ওয়ার্নিং/সাকসেস স্নাইকবার দেখানো যেতে পারে
    } catch (e) {
      printLog('❌ Unknown exception during order cancel: $e');
      Get.snackbar(
        "Cancellation Failed",
        "Failed to send cancel request. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void orderCancelSubmittedOld(String action, UserOrder order) async {
    if (!await checkInternet()) return;
    printLog(
      'update order confirm socket called::::::::  ORDER_CANCEL_REQUEST',
    );
    var traderCode = userInfo.userDetail?.traderCode;
    var boId = userInfo.userDetail?.boId;
    var clientCode = userInfo.userDetail?.investorCode;
    var token = await StorageService.read(StorageConstants.token);
    final shortName =
        marketListAll
            .firstWhereOrNull((market) => market.orderBook == order.orderBookId)
            ?.shortName ??
        '';
    printLog('market.orderBook:: ${order.orderBookId}');
    printLog('shortName:: $shortName');
    final wsUrl = Uri.parse(
      '${AppConfig.socketBaseUrl}order/$boId/?token=$token',
    );
    printLog(wsUrl);
    printLog(clientCode);
    printLog(traderCode);
    UpdateOrderHolder requestBody = UpdateOrderHolder(
      action: action,
      traderId: userInfo.userDetail?.traderCode,
      boId: "${userInfo.userDetail?.boId}",
      clientCode: '$clientCode',
      userId: userInfo.id,
      symbol: shortName,
      side: '${order.side}', // 'BUY':'SELL',
      orderId: '${order.orderId}',
      origClientOrderId: order.clientOrderId ?? "",
      clientOrderId: "",
      session: currentSession.value,
    );
    var reqData = requestBody.toJson();
    printWrapped('cancle order::::: ${jsonEncode(reqData)}');
    try {
      sendMessage(
        AppConfig.orderConfirmSocketId,
        jsonEncode(requestBody.toJson()),
      );
    } catch (e) {
      printLog('WebSocket connection failed: $e');
    }
    Future.delayed(const Duration(seconds: 1), () {});
    printLog('Socket db service initialized=  ${marketList.length}=');
    currentTabIndexPortfolio = 1;
    update([AppConstants.orderList]);
  }

  OrderStatusDetailsModel orderStatusDetails = OrderStatusDetailsModel();
  void orderStatusChangeConfirmSubmitted(
    ActionsType action,
    UserOrder order,
  ) async {
    //  ১. ইন্টারনেট চেক
    if (!await checkInternet()) return;

    printLog('🔄 Initiating Order Status Change Request...');

    var traderCode = userInfo.userDetail?.traderCode ?? '';
    var boId = userInfo.userDetail?.boId ?? '';
    var clientCode = userInfo.userDetail?.investorCode ?? '';

    //  ২. Symbol (shortName) বের করা হচ্ছে
    final shortName =
        marketListAll
            .firstWhereOrNull((market) => market.orderBook == order.orderBookId)
            ?.shortName ??
        '';

    if (shortName.isEmpty) {
      printLog(
        '⚠️ Warning: ShortName (Symbol) not found for OrderBookId: ${order.orderBookId}',
      );
    }

    //  ৩. Request Body তৈরি
    var requestBody = {
      'action': actionValues[action],
      'trader_id': traderCode,
      'request_sender': boId,
      'client_order_id': order.clientOrderId,
      'symbol': shortName,
      'side': order.side,
      'session': "continuous",
    };

    final jsonRequest = jsonEncode(requestBody);
    printWrapped('📤 Sending Status Change Request: $jsonRequest');

    try {
      //  ৪. Socket Connection Check & Auto-Reconnect
      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        printLog('🔌 Order Socket is disconnected. Reconnecting...');
        await _initializeOrderConfirmWebSocket();

        // রিকানেক্ট হওয়ার জন্য ১ সেকেন্ড অপেক্ষা
        await Future.delayed(const Duration(seconds: 1));
      }

      //  ৫. Final Verification
      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        Get.snackbar(
          "Connection Failed",
          "Unable to connect to the trading server. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return; // ডেটা সেন্ড করবে না
      }

      sendMessage(AppConfig.orderConfirmSocketId, jsonRequest);
      printLog('✅ Order status change request sent successfully.');

      // 🔄 UI Update
      currentTabIndexPortfolio = 1;
      update([AppConstants.orderList]);
    } catch (e) {
      printLog('❌ WebSocket connection failed: $e');
      Get.snackbar(
        "Request Failed",
        "Failed to send status change request. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void clearAllFields() {
    tradPriceTextEditField.clear();
    disclosedQtyTextEditField.clear();
    qtyTextEditField.clear();
    minQtyTextEditField.clear();
  }

  Future<void> logout(BuildContext context) async {
    final refreshToken = await StorageService.read(
      StorageConstants.refreshToken,
    );
    if (refreshToken == null) {
      _clearLocal(context);
      return;
    }
    try {
      var response = await homeRepository.logout();
      if (response.success) {
        _clearLocal(context);
      } else {
        throw Exception('Logout failed');
      }
    } catch (e) {
      printLog('Logout error: $e');
      _clearLocal(context); // still logout locally on error
    }
  }

  void _clearLocal(BuildContext context) {
    // ১. লোকাল স্টোরেজ ক্লিয়ার করা
    StorageService.remove(StorageConstants.token);
    StorageService.remove(StorageConstants.refreshToken);
    StorageService.remove(StorageConstants.userInfo);
    StorageService.remove(StorageConstants.orderBookId);

    // ২. অন্যান্য কন্ট্রোলার ডিলিট করা
    Get.delete<TokenController>();

    Helpers.snackBarForSuccess2(bodyText: "Logged out successfully");

    // ৩. পুরো রাউট স্ট্যাক ক্লিয়ার করে লগইন পেজে পাঠানো
    Get.offAllNamed(Routes.LOGIN);

    //  ৪. Permanent HomeController-কে জোরপূর্বক ডিলিট করা
    Get.delete<HomeController>(force: true);
  }

  // Filter and Sorting state variables (No .obs needed)
  String selectedInstrument = 'All';
  bool isAscendingOrderList = true;

  // Change instrument filter and refresh UI
  void changeInstrument(String instrument) {
    selectedInstrument = instrument;
    // Ekhane obossoi orderList tag diye update dite hobe, taholei list re-render hobe
    update([AppConstants.orderList]);
  }

  // Toggle sorting order
  void toggleSorting() {
    isAscendingOrderList = !isAscendingOrderList;
    update(['order_list_tag']);
  }

  @override
  void onResumed() {
    printLog("▶️ App resumed (GetX Lifecycle) → Reconnecting Sockets");
    initConnect();
    reloadHome();
  }

  @override
  void onPaused() {
    printLog(
      "⏸️ App paused (GetX Lifecycle) → Closing Sockets to save battery",
    );
    disconnect();
  }

  @override
  void onDetached() {
    printLog('⏹️ App detached ::::');
    disconnect();
  }

  @override
  void onHidden() {
    printLog('👁️‍🗨️ App hidden ::::');
  }

  @override
  void onInactive() {
    printLog('💤 App Inactive ::::');
  }

  String favCurrentViewMode = 'Default';
  final List<String> viewModes = ['Default', 'Small', 'Classic'];

  void updateFavViewMode(String mode) {
    favCurrentViewMode = mode;
    update(); // UI রিবিল্ড করার জন্য
  }
}
