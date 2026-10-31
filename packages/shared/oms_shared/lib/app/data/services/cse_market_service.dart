import 'dart:async';

import 'package:broker_config/broker_config.dart';
import 'package:get/get.dart';

import '../../core/utils/helpers/log_helper.dart';
import '../../core/values/app_config.dart';
import '../models/response/market_model.dart';
import '../models/response/market_tick_message.dart';
import 'exchange_service.dart';
import 'market_tick_store.dart';
import 'socket_db_service.dart';

/// CSE market feed of a house on both exchanges, kept apart from the DSE
/// feed: its own socket, tick store and list. The DSE socket and lists
/// (HomeController) are never touched by it.
///
/// Connects while CSE is selected and closes (dropping its quotes) when DSE
/// is selected again, so on DSE only the DSE socket is open, as before.
/// Single-exchange houses never start it.
class CseMarketService extends GetxService {
  /// Latest CSE quote of every order book, refreshed at most every
  /// [flushInterval].
  final RxList<MarketModel> quotes = <MarketModel>[].obs;

  static const flushInterval = Duration(milliseconds: 500);

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
    if (event.kind != MarketTickKind.quote) return;
    if (_store.apply(event.payload) == null) return;
    _pendingFlush ??= Timer(flushInterval, _flush);
  }

  void _flush() {
    _pendingFlush = null;
    if (!_open) return;
    quotes.assignAll(_store.quotes);
  }

  @override
  void onClose() {
    _exchangeWorker?.dispose();
    _close();
    super.onClose();
  }
}
