import 'package:broker_config/broker_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/core/values/app_config.dart';

const testSocketBaseUrl = 'wss://socket.test/';

/// Binds a UAT-like house config, as `--dart-define-from-file` does in the app.
/// [exchangeMode] picks DSE / CSE / both; [extra] adds env keys (e.g. CSE URLs).
void initTestAppConfig({
  ExchangeMode exchangeMode = ExchangeMode.dseOnly,
  Map<String, String> extra = const {},
}) {
  AppConfig.initializeForTesting(
    BrokerHouseConfig.load(
      environment: 'uat',
      fallbackValues: {
        'OMS_HOUSE_ID': 'testhouse',
        'OMS_HOUSE_NAME': 'Test House',
        'BASE_URL': 'https://api.test/',
        'BASE_URL_CHART': 'https://chart.test/',
        'BASE_URL_ITCH': 'https://itch.test/',
        'SOCKET_BASE_URL': testSocketBaseUrl,
        'market_url': '${testSocketBaseUrl}market',
        'NEWS_URL': '${testSocketBaseUrl}news',
        'INDEX_URL': '${testSocketBaseUrl}index',
        'MARKET_DEPTH': '${testSocketBaseUrl}depth',
        'NEWS_URL_TIME_SALES': '${testSocketBaseUrl}news-time-sales',
        'OMS_DEFAULT_LOCALE': 'en_US',
        'OMS_BRAND_PRIMARY_COLOR': '#184A94',
        'OMS_BRAND_ACCENT_COLOR': '#177DFF',
        'OMS_BRAND_BUTTON_COLOR': '#177DFF',
        ...extra,
      },
    ),
    HouseProfile(
      houseId: 'testhouse',
      legalName: 'Test House Ltd',
      companyName: 'Test House',
      contact: const HouseContact(
        phone: '0',
        whatsApp: '0',
        email: 'support@house.test',
        websiteUrl: 'https://house.test',
        officeAddressShort: 'Dhaka',
        officeAddressFull: 'Dhaka',
        tradingHours: '10-2',
      ),
      exchangeMode: exchangeMode,
      store: const HouseStoreListing(
        androidPackageId: 'test.house',
        iosBundleId: 'test.house',
        appStoreId: '0',
        playStoreShareUrl: 'https://play.test',
        appStoreShareUrl: 'https://apps.test',
      ),
    ),
  );
}

/// Makes connectivity_plus report the given network ('wifi', 'none', ...).
void setTestNetwork(String state) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/connectivity'),
        (call) async => call.method == 'check' ? [state] : null,
      );
}
