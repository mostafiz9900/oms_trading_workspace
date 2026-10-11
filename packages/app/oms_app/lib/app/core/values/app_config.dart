import 'package:broker_config/broker_config.dart';

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

  static String get baseURLChart => house.chartBaseUrl;
  static String get baseURLItch => house.itchBaseUrl;
  static String get baseUrl => house.apiBaseUrl;
  static String get socketBaseUrl => house.socketBaseUrl;
  static String get marketUrl => house.marketSocketUrl;
  static String get newsUrl => house.newsSocketUrl;
  static String get indexUrl => house.indexSocketUrl;
  static String get marketDepthUrl => house.marketDepthSocketUrl;
  static String get newsAndTimeAndSalesUrl => house.newsTimeSalesSocketUrl;
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
