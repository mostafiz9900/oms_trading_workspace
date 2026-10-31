import 'dart:async';

import 'package:broker_config/broker_config.dart';
import 'package:get/get.dart';

import '../../core/utils/helpers/log_helper.dart';
import '../../core/values/app_config.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../models/marquee_holder.dart';
import '../models/response/market_model.dart';
import '../models/response/market_tick_message.dart';
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
  }

  void _close() {
    if (!_open) return;
    _open = false;
    WebSocketService.instance.disconnect(AppConfig.cseMarketSocketId);
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
    if (_store.apply(event.payload) == null) return;
    _pendingFlush ??= Timer(flushInterval, _flush);
  }

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
