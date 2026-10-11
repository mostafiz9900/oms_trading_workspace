import 'package:broker_config/broker_config.dart';

class FakhrulConfig {
  static BrokerHouseConfig? _house;

  static BrokerHouseConfig get house {
    _house ??= BrokerHouseConfig.load(
      environment: 'uat',
      fallbackValues: {
        'OMS_HOUSE_ID': 'fakhrul',
        'OMS_HOUSE_NAME': 'Fakhrul',
        'BASE_URL': 'https://api.fakhrul.example',
        'BASE_URL_CHART': 'https://chart.fakhrul.example',
        'BASE_URL_ITCH': 'https://itch.fakhrul.example',
        'SOCKET_BASE_URL': 'wss://socket.fakhrul.example',
        'market_url': 'wss://socket.fakhrul.example/market',
        'NEWS_URL': 'wss://socket.fakhrul.example/news',
        'INDEX_URL': 'wss://socket.fakhrul.example/index',
        'MARKET_DEPTH': 'wss://socket.fakhrul.example/depth',
        'NEWS_URL_TIME_SALES': 'wss://socket.fakhrul.example/time-sales',
        'OMS_CONTRACT_URL': 'https://fakhrul.example/contract',
      },
    );

    return _house!;
  }

  static void initialize() {
    _house = BrokerHouseConfig.load(
      environment: 'uat',
      fallbackValues: {
        'OMS_HOUSE_ID': 'fakhrul',
        'OMS_HOUSE_NAME': 'Fakhrul',
        'BASE_URL': 'https://api.fakhrul.example',
        'BASE_URL_CHART': 'https://chart.fakhrul.example',
        'BASE_URL_ITCH': 'https://itch.fakhrul.example',
        'SOCKET_BASE_URL': 'wss://socket.fakhrul.example',
        'market_url': 'wss://socket.fakhrul.example/market',
        'NEWS_URL': 'wss://socket.fakhrul.example/news',
        'INDEX_URL': 'wss://socket.fakhrul.example/index',
        'MARKET_DEPTH': 'wss://socket.fakhrul.example/depth',
        'NEWS_URL_TIME_SALES': 'wss://socket.fakhrul.example/time-sales',
        'OMS_CONTRACT_URL': 'https://fakhrul.example/contract',
      },
    );
  }
}
