import 'package:broker_config/broker_config.dart';
import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();
  static BrokerHouseConfig? _current;
  static HouseProfile? _profile;

  /// Loads the environment profile supplied with `--dart-define-from-file`
  /// and binds it to the app's company profile.
  static void initialize({
    required String environment,
    required HouseProfile profile,
  }) {
    if (_current != null) {
      throw StateError('AppConfig has already been initialized.');
    }
    final house = BrokerHouseConfig.load(environment: environment);
    if (house.houseId != profile.houseId) {
      throw StateError(
        'OMS_HOUSE_ID "${house.houseId}" does not match the app profile '
        '"${profile.houseId}". Check --dart-define-from-file.',
      );
    }
    _bind(house, profile);
  }

  /// Test-only: binds a config without `--dart-define-from-file`.
  @visibleForTesting
  static void initializeForTesting(
    BrokerHouseConfig house,
    HouseProfile profile,
  ) => _bind(house, profile);

  static void _bind(BrokerHouseConfig house, HouseProfile profile) {
    _current = house;
    _profile = profile;
  }

  static BrokerHouseConfig get house =>
      _current ?? (throw StateError('AppConfig.initialize() must run first.'));

  static HouseProfile get profile =>
      _profile ?? (throw StateError('AppConfig.initialize() must run first.'));

  /// House id and name are compile-time defines, so these also work in
  /// background isolates (e.g. FCM handlers) where [initialize] never ran.
  static String get houseId =>
      _current?.houseId ?? const String.fromEnvironment('OMS_HOUSE_ID');
  static String get houseName =>
      _current?.displayName ?? const String.fromEnvironment('OMS_HOUSE_NAME');

  /// Exchanges of this house (`HouseProfile.exchangeMode`): DSE only (the
  /// default), CSE only, or both. Use these to show DSE- or CSE-specific UI.
  static ExchangeMode get exchangeMode => profile.exchangeMode;
  static Set<StockExchange> get exchanges => exchangeMode.exchanges;
  static bool get hasDse => exchangeMode.hasDse;
  static bool get hasCse => exchangeMode.hasCse;

  /// True when the house trades on both, e.g. to show an exchange picker.
  static bool get hasBothExchanges => exchangeMode.hasBoth;

  /// Exchange the UI starts on: DSE when the house has it, else CSE.
  static StockExchange get defaultExchange => exchangeMode.defaultExchange;

  static String get baseURLChart => house.chartBaseUrl;
  static String get baseURLItch => house.itchBaseUrl;
  static String get baseUrl => house.apiBaseUrl;
  static String get socketBaseUrl => house.socketBaseUrl;
  static String get marketUrl => house.marketSocketUrl;
  static String get newsUrl => house.newsSocketUrl;
  static String get indexUrl => house.indexSocketUrl;

  /// Market / index feed of [exchange]. CSE uses the DSE feed until
  /// `OMS_CSE_SOCKET_MARKET_URL` / `OMS_CSE_SOCKET_INDEX_URL` are set.
  static String marketUrlFor(StockExchange exchange) =>
      house.marketSocketUrlFor(exchange);
  static String indexUrlFor(StockExchange exchange) =>
      house.indexSocketUrlFor(exchange);
  static String get marketDepthUrl => house.marketDepthSocketUrl;
  static String get newsAndTimeAndSalesUrl => house.newsTimeSalesSocketUrl;
  static String marketDepthUrlFor(StockExchange exchange) =>
      house.marketDepthSocketUrlFor(exchange);
  static String newsAndTimeAndSalesUrlFor(StockExchange exchange) =>
      house.newsTimeSalesSocketUrlFor(exchange);
  static String get contractUrl => house.contractUrl;
  static bool get hasContractUrl => house.contractUrl.trim().isNotEmpty;

  // Socket IDs
  static const String marketSocketId = 'market_socket';
  static const String notificationSocketId = 'notification_socket';
  static const String newsSocketId = 'news_socket';
  static const String indexSocketId = 'index_socket';
  static const String marketDepthSocketId = 'market_depth_socket';
  static const String newsTimeSalesSocketId = 'news_time_sales_socket';
  static const String orderConfirmSocketId = 'ORDER_CONFIRM_SOCKET';
  static const String userBalanceSocketId = 'USER_BALANCE_SOCKET';
}
