import 'package:broker_config/broker_config.dart';
import 'package:getxify/getxify.dart';

import 'exchange_service.dart';
import 'storage_service.dart';
import '../models/market_identifier.dart';

/// Last searched stocks (by order book id), kept per exchange: the same
/// order book id can be another stock on DSE and CSE.
class RecentSearchService extends GetxService {
  static RecentSearchService get to => Get.find();

  final Map<StockExchange, List<MarketIdentifier>> _recentByExchange = {
    for (final exchange in StockExchange.values) exchange: <MarketIdentifier>[],
  };

  /// Recent order book ids of the selected exchange, newest first.
  List<MarketIdentifier> get recentOrderBookIds =>
      _recentByExchange[ExchangeService.current]!;

  /// DSE keeps the original key, so searches saved before CSE stay.
  static String storageKey(StockExchange exchange) => switch (exchange) {
    StockExchange.dse => 'recent_search_ids',
    StockExchange.cse => 'recent_search_ids_cse',
  };

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    for (final exchange in StockExchange.values) {
      final savedData = await StorageService.read(storageKey(exchange));
      if (savedData != null) {
        _recentByExchange[exchange] = savedData
            .map(marketIdentifierFromJson)
            .whereType<MarketIdentifier>()
            .toList();
      }
    }
  }

  void addToRecentSearch(MarketIdentifier orderBook) {
    final recent = recentOrderBookIds;
    recent.removeWhere((id) => id == orderBook);
    recent.insert(0, orderBook);

    if (recent.length > 10) {
      recent.removeLast();
    }

    StorageService.save(storageKey(ExchangeService.current), recent);
  }

  void clearRecentSearches() {
    recentOrderBookIds.clear();
    StorageService.remove(storageKey(ExchangeService.current));
  }
}
