part of '../home_controller.dart';

/// All HomeController state. Behaviour lives in the view-named mixins;
/// fields stay together here so their initialisation order is unchanged.
abstract class HomeState extends SuperController {
  HomeState({required this.homeRepository})
    : marketFavoritesRepository = homeRepository;

  final GetConnect _chartClient = GetConnect(timeout: const Duration(seconds: 30));

  final MarketSocketService marketService = Get.find<MarketSocketService>();

  final CompaniesController companiesController =
      Get.find<CompaniesController>();

  final WebSocketService _webSocketService = WebSocketService.instance;

  final HomeRepository homeRepository;

  final MarketFavoritesRepository marketFavoritesRepository;

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

  String selectSector = 'All';

  String searchQuery = '';

  SideType selectBuySell = SideType.buy;

  //filter data

  var currentIndex = 0;

  var previousIndex = 0;

  late ZoomPanBehavior zoomPanBehavior;

  late TooltipBehavior tooltipBehavior;

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

  //না, এই সেকশনটি (didChangeAppLifecycleState) আর একদমই থাকবে না!

  // ================= end index socket ========================
  var timerCont = Get.put<TokenController>(TokenController());

  bool isShowTimeSalesChart = false;

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

  // ক্লাসের শুরুতে ভ্যারিয়েবল ডিক্লেয়ার করুন
  // চার্ট ডেটা প্রসেস করার ক্লিন ফাংশন
  List<Map<String, dynamic>> chartData = [];

  List<Map<String, dynamic>> chartDataShareType = [];

  final MarketSectorSummaryAggregator _sectorSummaryAggregator =
      MarketSectorSummaryAggregator();

  final MarketSnapshotAnalytics _marketSnapshotAnalytics =
      MarketSnapshotAnalytics();

  List<SectorDataModel> sectorSummaryList = [];

  Timer? _marketUpdateTimer;

  DateTime _lastListUpdateTime = DateTime.now();

  DateTime _lastHeavyTaskTime = DateTime.now();

  //  Distribution Chart এর জন্য ভেরিয়েবল
  List<int> distributionCounts = [];

  int distributionTotal = 0;

  int distributionMaxCount = 0;

  //  সেফটি হেল্পার: ডুপ্লিকেট এড়ানোর জন্য লিস্টে টিক আপডেট বা ইনসার্ট করা

  // call this after you update _marketMap and marketList
  //  ১. O(1) স্পিড এবং জিরো-ল্যাগের জন্য Map এবং ValueNotifier
  final List<MarqueeHolder> marqueeList = [];

  DateTime? lastIndexUpdateTime;

  DateTime _lastIndexUIUpdateTime = DateTime.now();

  Timer? _indexUpdateTimer;

  bool isMarketDepthExpanded = false;

  int Function(int, int) calc = (a, b) => a + b;

  TradingChartModel? tradingChartModel;

  String currentSearchQuery = '';

  String currentSortOrder = 'ASC'; // ডিফল্ট ASC

  String currentSortCategory = 'A-Z';

  bool isGridView = false; // default shows list

  bool isCreateFavCat = false;

  bool isAddFavCat = false;

  var shortName = '';

  List<FavMarketResponse> favMarketData = [];

  List<MarketModel> favMarketParseList = [];

  List<FavMarketResponse> favAllMarketData = [];

  var selectedTableId = 0;

  bool loadingFav = false;

  bool isGetFavCat = false;

  final favCatList = <FavouriteModel>[];

  // chart data

  // process incoming tick / market data

  //2nd grop by

  // end
  Map<String, Map<String, int>> sectorCounts = {};

  Map<int, Map<String, dynamic>> stockDataMap = {};

  // convert sector summary to chart-friendly format

  //2nd one

  //new task end
  UserBalance? userBalanceData;

  // 🚀 লোডারের জন্য নতুন ভেরিয়েবল
  bool isUserBalanceLoading = false;

  List<int> tabHistory = [0];

  CompaniesModel? company;

  DividendModel? dividendObj;

  Map<String, EpsModel> epsData = {};

  MarketModel marketData = MarketModel();

  int totalBuyQty = 0;

  int totalSalesQty = 0;

  // =========================================================================
  // =========================================================================
  var userOrder = UserOrderModel();

  List<UserOrder> userOrderList = [];

  List<OrderAlertModel> orderAlertsList = [];

  bool isLoadingUserOrder = false;

  bool isOrderConfirmLoading = false;

  /// Releases the order button if the server never answers an order.
  Timer? _orderResponseTimer;

  void _endOrderConfirmLoading() {
    _orderResponseTimer?.cancel();
    isOrderConfirmLoading = false;
    update(['order_confirm_btn']);
  }

  /// Shows an order alert right away. GetX shows one snackbar at a time and
  /// queues the rest, so behind the persistent "No internet" bar an alert
  /// stayed hidden and then replayed once per tap after reconnecting.
  Future<void> _showOrderAlert(
    String title,
    String message, {
    Color color = Colors.red,
  }) async {
    if (Get.isSnackbarOpen) await Get.closeCurrentSnackbar();
    Get.snackbar(title, message, backgroundColor: color, colorText: Colors.white);
  }

  /// Connectivity check for order actions that always tells the user why
  /// nothing was sent.
  Future<bool> _orderNetworkAvailable() async {
    if (await NetworkUtil.isConnected()) return true;
    await _showOrderAlert(
      "No Internet",
      "Request not sent. Please check your internet connection.",
    );
    return false;
  }

  OrderStatusDetailsModel orderStatusDetails = OrderStatusDetailsModel();

  // Filter and Sorting state variables (No .obs needed)
  String selectedInstrument = 'All';

  bool isAscendingOrderList = true;

  String favCurrentViewMode = 'Default';

  final List<String> viewModes = ['Default', 'Small', 'Classic'];

  // Implemented by the view mixins; declared here so the mixins can call
  // each other.
  Future<void> loadTabData(int index);
  Future<void> _initializeOrderConfirmWebSocket();
  Future<void> _initializeUserBalanceWebSocket();
  void _handleMarketMessage(dynamic message);
  void _resetMarketState();
  void _initializeFilters();
  void _handleIndexMessage(String message);
  void _handleNewsTimeSalesMessage(String message);
  void subscribeTimeAndSales(String tp, String tid, String ob);
  void _handleMarketDepthMessage(String message);
  void _sendMarketDepthPayload(String type, int orderbookId);
  Future<void> manageMarketDepth(int newOrderBookId);
  void sendMessage(String socketId, String message);
  bool isSocketConnected(String socketId);
  bool get isOrderConfirmConnected;
  Future<void> tradingChart();
  void applyFilters();
  Future<void> getFavoriteAllMarketData();
  void selectTable(int tableId);
  Future<void> getFavCategory();
  void userBalance();
  void _handleUserBalanceMessage(dynamic message);
  void loadComanyDividentEPS(String shortName);
  void goBottomNabBarPage(int index, int orderBookId);
  Future<void> markerInfo();
  void getUserInfo();
  MarketModel getMarketByOrderBookId(int orderBookId);
  void _handleOrderConfirmMessage(String message);
  Future<void> getUserOrder();
  int? _parseNullableInt(String value);
  void clearAllFields();
}
