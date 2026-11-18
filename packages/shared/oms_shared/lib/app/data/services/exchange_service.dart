import 'package:broker_config/broker_config.dart';
import 'package:getxify/getxify.dart';

import '../../core/values/app_config.dart';
import '../../core/values/storage.dart';
import 'storage_service.dart';

/// Exchange selections are independent per screen scope, except Quote and
/// Trade, which share one selection because they operate on the same stock.
enum ExchangeScope {
  quoteTrade,
  market,
  watchlist,
  favorites,
  portfolio,
  topShare,
  search,
}

class ExchangeService extends GetxService {
  ExchangeService() : _selectedByScope = _restoreSelections();

  final Map<ExchangeScope, Rx<StockExchange>> _selectedByScope;

  /// Backward-compatible Quote/Trade selection for order and detail logic.
  Rx<StockExchange> get selected => selection(ExchangeScope.quoteTrade);

  Rx<StockExchange> selection(ExchangeScope scope) => _selectedByScope[scope]!;

  Iterable<Rx<StockExchange>> get selections => _selectedByScope.values;

  StockExchange exchangeFor(ExchangeScope scope) => selection(scope).value;

  bool get cseIsSelectedByAnyScope => _selectedByScope.values.any(
    (exchange) => exchange.value == StockExchange.cse,
  );

  /// Exchange of the running trading context, also before registration.
  static StockExchange get current => Get.isRegistered<ExchangeService>()
      ? Get.find<ExchangeService>().exchangeFor(ExchangeScope.quoteTrade)
      : AppConfig.defaultExchange;

  static StockExchange currentFor(ExchangeScope scope) =>
      Get.isRegistered<ExchangeService>()
      ? Get.find<ExchangeService>().exchangeFor(scope)
      : AppConfig.defaultExchange;

  List<StockExchange> get available =>
      AppConfig.exchanges.toList()..sort((a, b) => a.index.compareTo(b.index));

  /// Changes just [scope]. Quote and Trade use the same [quoteTrade] scope.
  void select(
    StockExchange exchange, {
    ExchangeScope scope = ExchangeScope.quoteTrade,
  }) {
    if (!AppConfig.exchanges.contains(exchange)) return;
    final selected = selection(scope);
    if (selected.value == exchange) return;
    selected.value = exchange;
    StorageService.save(_storageKey(scope), exchange.name);
  }

  static String _storageKey(ExchangeScope scope) =>
      scope == ExchangeScope.quoteTrade
      ? StorageConstants.selectedExchange
      : '${StorageConstants.selectedExchange}_${scope.name}';

  static Map<ExchangeScope, Rx<StockExchange>> _restoreSelections() {
    final selections = <ExchangeScope, Rx<StockExchange>>{};
    for (final scope in ExchangeScope.values) {
      final hasScopedValue =
          StorageService.readSync<String>(_storageKey(scope)) != null;
      final exchange = _restore(scope);
      selections[scope] = exchange.obs;
      if (scope != ExchangeScope.quoteTrade && !hasScopedValue) {
        // New independent page scopes start on DSE, regardless of the legacy
        // global Quote/Trade choice, and stay independent after restart.
        StorageService.save(_storageKey(scope), exchange.name);
      }
    }
    return selections;
  }

  static StockExchange _restore(ExchangeScope scope) {
    final scopedSaved = StorageService.readSync<String>(_storageKey(scope));
    final saved =
        scopedSaved ??
        (scope == ExchangeScope.quoteTrade
            ? StorageService.readSync<String>(StorageConstants.selectedExchange)
            : null);
    for (final exchange in AppConfig.exchanges) {
      if (exchange.name == saved) return exchange;
    }
    return AppConfig.hasDse ? StockExchange.dse : AppConfig.defaultExchange;
  }
}
