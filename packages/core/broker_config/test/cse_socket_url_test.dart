import 'package:broker_config/broker_config.dart';
import 'package:test/test.dart';

const _dse = {
  'OMS_HOUSE_ID': 'testhouse',
  'OMS_HOUSE_NAME': 'Test House',
  'BASE_URL': 'https://api.test/',
  'BASE_URL_CHART': 'https://chart.test/',
  'BASE_URL_ITCH': 'https://itch.test/',
  'SOCKET_BASE_URL': 'wss://socket.test/',
  'market_url': 'wss://dse.test/market',
  'NEWS_URL': 'wss://dse.test/news',
  'INDEX_URL': 'wss://dse.test/index',
  'MARKET_DEPTH': 'wss://dse.test/depth',
  'NEWS_URL_TIME_SALES': 'wss://dse.test/news-time-sales',
};

BrokerHouseConfig _load([Map<String, String> extra = const {}]) =>
    BrokerHouseConfig.load(
      environment: 'uat',
      fallbackValues: {..._dse, ...extra},
    );

void main() {
  group('CSE socket URLs', () {
    test('fall back to the DSE feeds while no CSE URL is configured', () {
      final config = _load();
      expect(config.cseMarketSocketUrl, isEmpty);
      expect(
        config.marketSocketUrlFor(StockExchange.cse),
        'wss://dse.test/market',
      );
      expect(
        config.indexSocketUrlFor(StockExchange.cse),
        'wss://dse.test/index',
      );
    });

    test('use the CSE feeds once they are configured', () {
      final config = _load({
        'OMS_CSE_SOCKET_MARKET_URL': 'wss://cse.test/market',
        'OMS_CSE_SOCKET_INDEX_URL': 'wss://cse.test/index',
      });
      expect(
        config.marketSocketUrlFor(StockExchange.cse),
        'wss://cse.test/market',
      );
      expect(
        config.indexSocketUrlFor(StockExchange.cse),
        'wss://cse.test/index',
      );
    });

    test('DSE always uses the DSE feeds', () {
      final config = _load({
        'OMS_CSE_SOCKET_MARKET_URL': 'wss://cse.test/market',
        'OMS_CSE_SOCKET_INDEX_URL': 'wss://cse.test/index',
      });
      expect(
        config.marketSocketUrlFor(StockExchange.dse),
        'wss://dse.test/market',
      );
      expect(
        config.indexSocketUrlFor(StockExchange.dse),
        'wss://dse.test/index',
      );
    });

    test('a CSE URL must be a websocket URL', () {
      expect(
        () => _load({'OMS_CSE_SOCKET_MARKET_URL': 'https://cse.test/market'}),
        throwsStateError,
      );
      expect(
        () => _load({'OMS_CSE_SOCKET_INDEX_URL': 'not a url'}),
        throwsStateError,
      );
    });

    test('depth and time & sales: DSE feed until CSE URLs are set', () {
      final unset = _load();
      expect(
        unset.marketDepthSocketUrlFor(StockExchange.cse),
        'wss://dse.test/depth',
      );
      expect(
        unset.newsTimeSalesSocketUrlFor(StockExchange.cse),
        'wss://dse.test/news-time-sales',
      );

      final set = _load({
        'OMS_CSE_SOCKET_MARKET_DEPTH_URL': 'wss://cse.test/depth',
        'OMS_CSE_SOCKET_NEWS_TIME_SALES_URL': 'wss://cse.test/events',
      });
      expect(set.marketDepthSocketUrlFor(StockExchange.cse), 'wss://cse.test/depth');
      expect(
        set.newsTimeSalesSocketUrlFor(StockExchange.cse),
        'wss://cse.test/events',
      );
      expect(set.marketDepthSocketUrlFor(StockExchange.dse), 'wss://dse.test/depth');
      expect(
        set.newsTimeSalesSocketUrlFor(StockExchange.dse),
        'wss://dse.test/news-time-sales',
      );
    });

    test('CSE depth / time & sales URLs must be websocket URLs', () {
      expect(
        () => _load({'OMS_CSE_SOCKET_MARKET_DEPTH_URL': 'https://cse.test/d'}),
        throwsStateError,
      );
      expect(
        () => _load({'OMS_CSE_SOCKET_NEWS_TIME_SALES_URL': 'nope'}),
        throwsStateError,
      );
    });
  });
}
