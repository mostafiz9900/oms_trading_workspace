import 'package:broker_config/broker_config.dart';
import 'package:get/get.dart';

import '../../core/values/app_config.dart';
import '../../core/values/storage.dart';
import 'storage_service.dart';

/// The exchange whose market data the app shows (DSE or CSE).
///
/// A house on one exchange always stays on it. A house on both starts on the
/// exchange chosen last time (or [AppConfig.defaultExchange]) and changes it
/// with [select]; market screens listen to [selected].
class ExchangeService extends GetxService {
  ExchangeService() : selected = _restore().obs;

  final Rx<StockExchange> selected;

  /// Exchange of the running app, also before the service is registered
  /// (tests, background isolates): then the house default.
  static StockExchange get current => Get.isRegistered<ExchangeService>()
      ? Get.find<ExchangeService>().selected.value
      : AppConfig.defaultExchange;

  List<StockExchange> get available => AppConfig.exchanges.toList()
    ..sort((a, b) => a.index.compareTo(b.index));

  /// Switches to [exchange] and remembers it. Ignored when the house does not
  /// trade on it or it is already selected.
  void select(StockExchange exchange) {
    if (!AppConfig.exchanges.contains(exchange)) return;
    if (selected.value == exchange) return;
    selected.value = exchange;
    StorageService.save(StorageConstants.selectedExchange, exchange.name);
  }

  static StockExchange _restore() {
    final saved = StorageService.readSync<String>(
      StorageConstants.selectedExchange,
    );
    for (final exchange in AppConfig.exchanges) {
      if (exchange.name == saved) return exchange;
    }
    return AppConfig.defaultExchange;
  }
}
