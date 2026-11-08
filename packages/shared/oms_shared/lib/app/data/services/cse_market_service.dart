import 'dart:async';
import 'dart:convert';

import 'package:broker_config/broker_config.dart';
import 'package:get/get.dart';

import '../../core/utils/helpers/log_helper.dart';
import '../../core/values/app_config.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../models/marquee_holder.dart';
import '../models/response/market_depth_model.dart';
import '../models/response/market_model.dart';
import '../models/response/market_tick_message.dart';
import '../models/response/news_model.dart';
import '../models/response/time_sales_model.dart';
import '../models/response/sector_data_model.dart';
import 'exchange_service.dart';
import 'market_feed_view.dart';
import 'market_sector_summary_aggregator.dart';
import 'market_snapshot_analytics.dart';
import 'market_tick_store.dart';
import 'socket_db_service.dart';

/// CSE market feed of a house on both exchanges, kept apart from the DSE
/// feed: its own socket, tick store and list. The DSE socket and lists
/// (HomeController) are never touched by it.
///
/// Connects while CSE is selected and closes (dropping its quotes) when DSE
/// is selected again, so on DSE only the DSE socket is open, as before.
/// Single-exchange houses never start it.
class CseMarketService extends GetxService implements MarketFeedView {
  /// A house on both exchanges with CSE selected: screens show this feed.
  /// False while the service is not registered (nothing to show).
  static bool get isShown =>
      Get.isRegistered<CseMarketService>() &&
      AppConfig.hasBothExchanges &&
      ExchangeService.current == StockExchange.cse;

  /// Latest CSE quote of every order book, refreshed at most every
  /// [flushInterval].
  @override
  final RxList<MarketModel> quotes = <MarketModel>[].obs;

  static const flushInterval = Duration(milliseconds: 500);

  /// Charts and sector figures are recomputed at most this often (as for
  /// DSE in HomeController).
  static const analyticsInterval = Duration(seconds: 2);

  @override
  final RxString session = ''.obs;
  @override
  List<MarqueeHolder> marqueeList = [];
  @override
  List<Map<String, dynamic>> chartData = [];
  @override
  List<Map<String, dynamic>> chartDataShareType = [];
  @override
  List<SectorDataModel> sectorSummaryList = [];
  @override
  List<int> distributionCounts = [];
  @override
  int distributionTotal = 0;
  @override
  int distributionMaxCount = 0;

  /// Depth of the CSE stock selected on Quote, from the CSE depth socket
  /// (same message format as DSE: `{"<ob>": {"buy": [...], "sell": [...]}}`).
  @override
  List<MarketDepthModel> buys = [];
  @override
  List<MarketDepthModel> sells = [];

  /// Order book whose depth is subscribed (re-sent when the socket connects).
  int? _depthOrderBook;

  /// Time & sales and news of the CSE stock selected on Quote, from the CSE
  /// time & sales socket (same messages as DSE: `tp` tsm / tsb / news_hist).
  @override
  final List<TimeAndSalesModel> timeAndSales = [];
  @override
  final List<TimeAndSalesModel> timeAndSalesHistory = [];
  @override
  final List<NewsModel> newsSingleItem = [];

  /// Subscriptions sent (re-sent when the socket connects), by `tp`.
  final Map<String, String> _timeSalesSubscriptions = {};
  Timer? _timeSalesRedraw;

  /// The CSE depth feed is configured (else depth stays empty on CSE rather
  /// than showing the DSE depth of the same order book id).
  static bool get hasDepthFeed =>
      AppConfig.marketDepthUrlFor(StockExchange.cse) !=
      AppConfig.marketDepthUrlFor(StockExchange.dse);

  final MarketSnapshotAnalytics _analytics = MarketSnapshotAnalytics();
  final MarketSectorSummaryAggregator _sectors =
      MarketSectorSummaryAggregator();
  DateTime? _lastAnalytics;

  final MarketTickStore _store = MarketTickStore();
  Timer? _pendingFlush;
  Worker? _exchangeWorker;
  bool _open = false;

  bool get isOpen => _open;

  @override
  void onInit() {
    super.onInit();
    if (!AppConfig.hasBothExchanges || !Get.isRegistered<ExchangeService>()) {
      return;
    }
    final exchange = Get.find<ExchangeService>();
    _exchangeWorker = ever(exchange.selected, _follow);
    _follow(exchange.selected.value);
  }

  void _follow(StockExchange exchange) =>
      exchange == StockExchange.cse ? _connect() : _close();

  void _connect() {
    if (_open) return;
    _open = true;
    WebSocketService.instance.connect(
      socketId: AppConfig.cseMarketSocketId,
      url: AppConfig.marketUrlFor(StockExchange.cse),
      onMessage: onMessage,
      onConnected: () => printLog('✅ CSE market socket connected'),
      onError: (error) => printLog('⚠️ CSE market socket error: $error'),
    );
    if (hasDepthFeed) {
      WebSocketService.instance.connect(
        socketId: AppConfig.cseMarketDepthSocketId,
        url: AppConfig.marketDepthUrlFor(StockExchange.cse),
        onMessage: onDepthMessage,
        onConnected: () {
          printLog('✅ CSE market depth socket connected');
          final orderBook = _depthOrderBook;
          if (orderBook != null) _sendDepth('subscribe', orderBook);
        },
        onError: (error) => printLog('⚠️ CSE depth socket error: $error'),
      );
    }
    if (AppConfig.hasCseTimeSalesFeed) {
      WebSocketService.instance.connect(
        socketId: AppConfig.cseNewsTimeSalesSocketId,
        url: AppConfig.newsAndTimeAndSalesUrlFor(StockExchange.cse),
        onMessage: onTimeSalesMessage,
        onConnected: () {
          printLog('✅ CSE time & sales socket connected');
          _timeSalesSubscriptions.values.forEach(_sendTimeSales);
        },
        onError: (error) => printLog('⚠️ CSE time & sales error: $error'),
      );
    }
  }

  /// Subscribes [tp] (`tsm`, `tsb`, `news_hist`) of [orderBook], as
  /// HomeController.subscribeTimeAndSales does on the DSE socket.
  void subscribeTimeSales(String tp, String tid, String orderBook) {
    final body = jsonEncode({
      'ac': 'subscribe',
      'tp': tp,
      'tid': int.parse(tid),
      'ob': int.parse(orderBook),
    });
    _timeSalesSubscriptions[tp] = body;
    _sendTimeSales(body);
  }

  void _sendTimeSales(String body) {
    if (!_open || !AppConfig.hasCseTimeSalesFeed) return;
    WebSocketService.instance.sendMessage(
      AppConfig.cseNewsTimeSalesSocketId,
      body,
    );
  }

  /// One message of the CSE time & sales socket; same handling as DSE
  /// (TimeSalesMixin) for the stock's lists.
  void onTimeSalesMessage(String message) {
    final Object? decoded;
    try {
      decoded = jsonDecode(message);
    } on FormatException catch (e) {
      printLog('CSE time & sales message skipped: $e');
      return;
    }
    if (decoded is! Map<String, dynamic>) return;
    final data = decoded['d'];
    try {
      switch (decoded['tp']) {
        case 'tsm':
          if (data is List) {
            timeAndSales
              ..clear()
              ..addAll(timeAndSalesModelFromMap(data));
            _redraw(['timeAndSales'], now: true);
          } else if (data is Map<String, dynamic>) {
            timeAndSales.insert(0, TimeAndSalesModel.fromMap(data));
            _redraw(['timeAndSales'], now: false);
          } else {
            _redraw(['timeAndSales'], now: true);
          }
        case 'tsb':
          if (data is List) {
            timeAndSalesHistory
              ..clear()
              ..addAll(data.map((e) => TimeAndSalesModel.fromMap(e)));
          } else if (data is Map<String, dynamic>) {
            timeAndSalesHistory.insert(0, TimeAndSalesModel.fromMap(data));
          } else {
            timeAndSalesHistory.clear();
          }
          _redraw(['timeAndSalesHistory'], now: true);
        case 'news_hist':
          if (data is List) {
            newsSingleItem
              ..clear()
              ..addAll(newsModelFromMap(data));
          } else if (data is Map<String, dynamic>) {
            newsSingleItem.insert(0, NewsModel.fromMap(data));
          } else {
            newsSingleItem.clear();
          }
          _redraw(['newsSingleItem'], now: true);
      }
    } catch (e) {
      printLog('❌ CSE time & sales parse error: $e');
    }
  }

  /// Redraws the Quote builders while CSE is shown; single trades at most
  /// every 500 ms (as DSE throttles them).
  void _redraw(List<String> ids, {required bool now}) {
    if (!isShown || !Get.isRegistered<HomeController>()) return;
    if (now) {
      _timeSalesRedraw?.cancel();
      _timeSalesRedraw = null;
      Get.find<HomeController>().update(ids);
      return;
    }
    _timeSalesRedraw ??= Timer(flushInterval, () {
      _timeSalesRedraw = null;
      if (isShown && Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().update(ids);
      }
    });
  }

  /// Subscribes [orderBook]'s depth (unsubscribing the previous one) or, with
  /// `unsubscribe`, stops it.
  void sendDepth(String type, int orderBook) {
    if (type == 'subscribe') {
      _depthOrderBook = orderBook;
    } else if (_depthOrderBook == orderBook) {
      _depthOrderBook = null;
    }
    _sendDepth(type, orderBook);
  }

  void _sendDepth(String type, int orderBook) {
    if (!_open || !hasDepthFeed) return;
    WebSocketService.instance.sendMessage(
      AppConfig.cseMarketDepthSocketId,
      jsonEncode({'type': type, 'ob': orderBook}),
    );
  }

  /// One message of the CSE depth socket.
  void onDepthMessage(String message) {
    final Object? decoded;
    try {
      decoded = jsonDecode(message);
    } on FormatException catch (e) {
      printLog('CSE depth message skipped: $e');
      return;
    }
    if (decoded is! Map<String, dynamic>) return;
    if (decoded.containsKey('message') || decoded['type'] == 'heartbeat') {
      return;
    }
    var changed = false;
    decoded.forEach((key, value) {
      if (value is! Map<String, dynamic>) return;
      // Only the subscribed stock (an older one may still be in flight).
      if (_depthOrderBook != null && key != '$_depthOrderBook') return;
      try {
        final depth = MarketDepthData.fromJson(value);
        buys = depth.buy;
        sells = depth.sell;
        changed = true;
      } catch (e) {
        printLog('CSE depth parse error for $key: $e');
      }
    });
    if (changed && isShown && Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().update(['market_depth']);
    }
  }

  /// Closed for the app's background / logout (see [suspend]).
  bool _suspended = false;

  bool get isSuspended => _suspended;

  /// App paused or HomeController closed: closes the CSE sockets as
  /// HomeController closes the DSE ones (battery). Quotes and depth are kept,
  /// as the DSE lists are; [resume] connects again.
  void suspend() {
    if (!_open) return;
    _open = false;
    _suspended = true;
    _pendingFlush?.cancel();
    _pendingFlush = null;
    _timeSalesRedraw?.cancel();
    _timeSalesRedraw = null;
    WebSocketService.instance.disconnect(AppConfig.cseMarketSocketId);
    WebSocketService.instance.disconnect(AppConfig.cseMarketDepthSocketId);
    WebSocketService.instance.disconnect(AppConfig.cseNewsTimeSalesSocketId);
  }

  /// App resumed / HomeController connected again: reconnects if CSE is still
  /// selected (the depth stock is re-subscribed on connect).
  void resume() {
    if (!_suspended) return;
    _suspended = false;
    if (isShown) _connect();
  }

  void _close() {
    if (!_open && !_suspended) return;
    _open = false;
    _suspended = false;
    WebSocketService.instance.disconnect(AppConfig.cseMarketSocketId);
    WebSocketService.instance.disconnect(AppConfig.cseMarketDepthSocketId);
    WebSocketService.instance.disconnect(AppConfig.cseNewsTimeSalesSocketId);
    _timeSalesRedraw?.cancel();
    _timeSalesRedraw = null;
    _timeSalesSubscriptions.clear();
    timeAndSales.clear();
    timeAndSalesHistory.clear();
    newsSingleItem.clear();
    _depthOrderBook = null;
    buys = [];
    sells = [];
    _pendingFlush?.cancel();
    _pendingFlush = null;
    _store.clear();
    quotes.clear();
    session.value = '';
    marqueeList = [];
    chartData = [];
    chartDataShareType = [];
    sectorSummaryList = [];
    distributionCounts = [];
    distributionTotal = 0;
    distributionMaxCount = 0;
    _lastAnalytics = null;
  }

  /// Pull-to-refresh: drop the quotes and connect again.
  void reconnect() {
    if (!_open) return;
    _close();
    _connect();
  }

  /// One message of the CSE market socket (same format as the DSE feed).
  void onMessage(String message) {
    final MarketTickMessage event;
    try {
      event = MarketTickMessage.decode(message);
    } on Exception catch (e) {
      printLog('CSE market message skipped: $e');
      return;
    }
    if (event.kind == MarketTickKind.session) {
      session.value = '${event.payload['cs']}';
      return;
    }
    if (event.kind != MarketTickKind.quote) return;
    if (_store.apply(normalizeCseTick(event.payload)) == null) return;
    _pendingFlush ??= Timer(flushInterval, _flush);
  }

  /// CSE tick → the values the DSE feed uses, so the same screens and
  /// calculations work (only the CSE feed is changed):
  /// - instrument type `EQUITY` / `Mutual Fund` → `EQ` / `MF`;
  /// - `c` (close) comes equal to the reference price, so change and
  ///   gainer / loser read 0; the last traded price `lp` is used as close
  ///   once there is one, and a tick without `lp` keeps the close it has.
  static Map<String, dynamic> normalizeCseTick(Map<String, dynamic> tick) {
    final type = tick['it'];
    if (type is String) {
      tick['it'] = _cseInstrumentTypes[type] ?? type;
    }
    final last = tick['lp'];
    if (last is num && last > 0) {
      tick['c'] = last;
    } else if (!tick.containsKey('lp')) {
      tick.remove('c');
    }
    return tick;
  }

  static const _cseInstrumentTypes = {'EQUITY': 'EQ', 'Mutual Fund': 'MF'};

  void _flush() {
    _pendingFlush = null;
    if (!_open) return;
    quotes.assignAll(_store.quotes);
    marqueeList = _marquee(quotes);
    final now = DateTime.now();
    final analytics =
        _lastAnalytics == null ||
        now.difference(_lastAnalytics!) >= analyticsInterval;
    if (analytics) {
      _lastAnalytics = now;
      _computeAnalytics();
    }
    _redrawMarketScreens(analytics: analytics);
  }

  /// PUBLIC stocks, sorted by short name (as the DSE marquee).
  static List<MarqueeHolder> _marquee(List<MarketModel> all) =>
      [
        for (final m in all)
          if (m.group == 'PUBLIC')
            MarqueeHolder(
              status: m.status,
              shortName: m.shortName,
              chg: m.chg,
              last: m.last,
              d: m.d,
            ),
      ]..sort((a, b) => (a.shortName ?? '').compareTo(b.shortName ?? ''));

  void _computeAnalytics() {
    chartData = _analytics.calculateSectorGainers(quotes);
    chartDataShareType = _analytics.calculateSectorShareTypeValues(quotes);
    sectorSummaryList = _sectors.generate(quotes);
    final buckets = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>().buckets
        : const <Bucket>[];
    final summary = _analytics.calculateMovementDistribution(quotes, buckets);
    if (summary != null) {
      distributionCounts = summary.counts;
      distributionTotal = summary.total;
      distributionMaxCount = summary.maxCount;
    }
  }

  /// The market screens are GetBuilders of HomeController; redraw them while
  /// they show this feed.
  void _redrawMarketScreens({required bool analytics}) {
    if (!isShown || !Get.isRegistered<HomeController>()) return;
    final home = Get.find<HomeController>()..onShownFeedFlushed();
    home.update([
      'marketList',
      'marquee',
      if (analytics) ...[
        'marketListByGainer',
        'marketListByShareType',
        'sectorListUpdate',
        'sectorSummary',
        'distributionChartUpdate',
      ],
    ]);
  }

  @override
  void onClose() {
    _exchangeWorker?.dispose();
    _close();
    super.onClose();
  }
}
