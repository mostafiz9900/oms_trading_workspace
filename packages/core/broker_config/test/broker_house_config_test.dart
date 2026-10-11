import 'package:broker_config/broker_config.dart';
import 'package:test/test.dart';

void main() {
  group('BrokerHouseConfig', () {
    test('loads a valid house config from fallback values', () {
      final config = BrokerHouseConfig.load(
        environment: 'uat',
        fallbackValues: {
          'OMS_HOUSE_ID': 'benemoy',
          'OMS_HOUSE_NAME': 'Benemoy',
          'BASE_URL': 'https://uat-api-admin.skytrade.us/',
          'BASE_URL_CHART': 'https://uat-itch-chart.skytrade.us/',
          'BASE_URL_ITCH': 'https://uat-itchservice.skytrade.us/',
          'SOCKET_BASE_URL': 'wss://uat-socket.skytrade.us/',
          'market_url': 'wss://uat-socket.skytrade.us/market',
          'NEWS_URL': 'wss://uat-socket.skytrade.us/news',
          'INDEX_URL': 'wss://uat-socket.skytrade.us/index',
          'MARKET_DEPTH': 'wss://uat-socket.skytrade.us/depth',
          'NEWS_URL_TIME_SALES': 'wss://uat-socket.skytrade.us/news-time-sales',
          'OMS_BRAND_APP_ICON_ASSET': 'assets/icons/ic_appicon.png',
          'OMS_BRAND_LOGO_ASSET': 'assets/svg_image/logoSvg.svg',
          'OMS_BRAND_DARK_LOGO_ASSET': 'assets/svg_image/logoSvgWhite.svg',
          'OMS_BRAND_SPLASH_ASSET': 'assets/svg_image/Splash.svg',
          'OMS_BRAND_DARK_SPLASH_ASSET': 'assets/svg_image/Splash-dart.svg',
          'OMS_BRAND_ONBOARDING_FIRST_ASSET': 'assets/images/onboard_01.png',
          'OMS_BRAND_ONBOARDING_SECOND_ASSET': 'assets/images/onboard_02.png',
          'OMS_DEFAULT_LOCALE': 'en_US',
          'OMS_BRAND_PRIMARY_COLOR': '#184A94',
          'OMS_BRAND_ACCENT_COLOR': '#177DFF',
          'OMS_BRAND_BUTTON_COLOR': '#177DFF',
        },
      );

      expect(config.houseId, 'benemoy');
      expect(config.displayName, 'Benemoy');
      expect(config.environment, 'uat');
      expect(config.defaultLocale, 'en_US');
      expect(config.apiBaseUrl, 'https://uat-api-admin.skytrade.us/');
      expect(config.primaryColor, '#184A94');
      expect(config.contractUrl, isEmpty);
    });

    test('supports a broker contract URL', () {
      final config = BrokerHouseConfig.load(
        environment: 'prod',
        fallbackValues: {
          'OMS_HOUSE_ID': 'demo',
          'OMS_HOUSE_NAME': 'Demo',
          'BASE_URL': 'https://api.example.com/',
          'BASE_URL_CHART': 'https://chart.example.com/',
          'BASE_URL_ITCH': 'https://itch.example.com/',
          'SOCKET_BASE_URL': 'wss://socket.example.com/',
          'market_url': 'wss://socket.example.com/market',
          'NEWS_URL': 'wss://socket.example.com/news',
          'INDEX_URL': 'wss://socket.example.com/index',
          'MARKET_DEPTH': 'wss://socket.example.com/depth',
          'NEWS_URL_TIME_SALES': 'wss://socket.example.com/news-time-sales',
          'OMS_BRAND_APP_ICON_ASSET': 'assets/icons/ic_appicon.png',
          'OMS_BRAND_LOGO_ASSET': 'assets/svg_image/logoSvg.svg',
          'OMS_BRAND_DARK_LOGO_ASSET': 'assets/svg_image/logoSvgWhite.svg',
          'OMS_BRAND_SPLASH_ASSET': 'assets/svg_image/Splash.svg',
          'OMS_BRAND_DARK_SPLASH_ASSET': 'assets/svg_image/Splash-dart.svg',
          'OMS_BRAND_ONBOARDING_FIRST_ASSET': 'assets/images/onboard_01.png',
          'OMS_BRAND_ONBOARDING_SECOND_ASSET': 'assets/images/onboard_02.png',
          'OMS_DEFAULT_LOCALE': 'en_US',
          'OMS_BRAND_PRIMARY_COLOR': '#184A94',
          'OMS_BRAND_ACCENT_COLOR': '#177DFF',
          'OMS_BRAND_BUTTON_COLOR': '#177DFF',
          'OMS_CONTRACT_URL': 'https://example.com/terms',
        },
      );

      expect(config.contractUrl, 'https://example.com/terms');
    });

    test('keeps legacy dotenv values as fallback when compile-time values are absent', () {
      final config = BrokerHouseConfig.load(
        environment: 'prod',
        fallbackValues: {
          'OMS_HOUSE_ID': 'demo',
          'OMS_HOUSE_NAME': 'Demo',
          'BASE_URL': 'https://api.example.com/',
          'BASE_URL_CHART': 'https://chart.example.com/',
          'BASE_URL_ITCH': 'https://itch.example.com/',
          'SOCKET_BASE_URL': 'wss://socket.example.com/',
          'market_url': 'wss://socket.example.com/market',
          'NEWS_URL': 'wss://socket.example.com/news',
          'INDEX_URL': 'wss://socket.example.com/index',
          'MARKET_DEPTH': 'wss://socket.example.com/depth',
          'NEWS_URL_TIME_SALES': 'wss://socket.example.com/news-time-sales',
          'OMS_BRAND_APP_ICON_ASSET': 'assets/icons/ic_appicon.png',
          'OMS_BRAND_LOGO_ASSET': 'assets/svg_image/logoSvg.svg',
          'OMS_BRAND_DARK_LOGO_ASSET': 'assets/svg_image/logoSvgWhite.svg',
          'OMS_BRAND_SPLASH_ASSET': 'assets/svg_image/Splash.svg',
          'OMS_BRAND_DARK_SPLASH_ASSET': 'assets/svg_image/Splash-dart.svg',
          'OMS_BRAND_ONBOARDING_FIRST_ASSET': 'assets/images/onboard_01.png',
          'OMS_BRAND_ONBOARDING_SECOND_ASSET': 'assets/images/onboard_02.png',
          'OMS_DEFAULT_LOCALE': 'en_US',
          'OMS_BRAND_PRIMARY_COLOR': '#184A94',
          'OMS_BRAND_ACCENT_COLOR': '#177DFF',
          'OMS_BRAND_BUTTON_COLOR': '#177DFF',
        },
      );

      expect(config.houseId, 'demo');
      expect(config.displayName, 'Demo');
      expect(config.apiBaseUrl, 'https://api.example.com/');
      expect(config.socketBaseUrl, 'wss://socket.example.com/');
    });
  });
}
