import 'package:broker_config/broker_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();
  static BrokerHouseConfig? _current;

  static void initialize({required String environment}) {
    if (_current != null) {
      throw StateError('AppConfig has already been initialized.');
    }
    _current = BrokerHouseConfig.load(
      environment: environment,
      fallbackValues: dotenv.env,
    );
  }

  static BrokerHouseConfig get house =>
      _current ?? (throw StateError('AppConfig.initialize() must run first.'));

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
