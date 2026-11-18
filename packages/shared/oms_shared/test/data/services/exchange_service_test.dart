import 'package:broker_config/broker_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';
import 'package:oms_shared/app/core/values/app_config.dart';
import 'package:oms_shared/app/core/values/storage.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/storage_service.dart';

import '../../helpers/fake_storage.dart';
import '../../helpers/test_env.dart';

void main() {
  setUpAll(initTestStorage);
  setUp(clearTestStorage);
  tearDown(Get.reset);

  group('house on DSE and CSE', () {
    setUp(() => initTestAppConfig(exchangeMode: ExchangeMode.dseAndCse));

    test('starts on DSE and offers both exchanges', () {
      final service = ExchangeService();
      expect(service.selected.value, StockExchange.dse);
      expect(service.available, [StockExchange.dse, StockExchange.cse]);
    });

    test('switching remembers the exchange for the next start', () async {
      ExchangeService().select(StockExchange.cse);
      await Future<void>.delayed(Duration.zero);

      expect(
        StorageService.readSync<String>(StorageConstants.selectedExchange),
        'cse',
      );
      expect(ExchangeService().selected.value, StockExchange.cse);
    });

    test('current follows the registered service', () {
      final service = Get.put(ExchangeService());
      expect(ExchangeService.current, StockExchange.dse);
      service.select(StockExchange.cse);
      expect(ExchangeService.current, StockExchange.cse);
    });

    test('page scopes are independent; Quote and Trade share one scope', () {
      final service = Get.put(ExchangeService());

      service.select(StockExchange.cse, scope: ExchangeScope.watchlist);
      expect(service.exchangeFor(ExchangeScope.watchlist), StockExchange.cse);
      expect(service.exchangeFor(ExchangeScope.quoteTrade), StockExchange.dse);

      service.select(StockExchange.cse, scope: ExchangeScope.quoteTrade);
      expect(service.exchangeFor(ExchangeScope.quoteTrade), StockExchange.cse);
      expect(service.exchangeFor(ExchangeScope.market), StockExchange.dse);
      expect(ExchangeService.current, StockExchange.cse);
    });

    test('each page scope persists its own exchange', () async {
      final service = ExchangeService();
      service.select(StockExchange.cse, scope: ExchangeScope.portfolio);
      await Future<void>.delayed(Duration.zero);

      expect(
        StorageService.readSync<String>(
          '${StorageConstants.selectedExchange}_portfolio',
        ),
        'cse',
      );
      expect(
        StorageService.readSync<String>(StorageConstants.selectedExchange),
        isNull,
      );
    });
  });

  group('house on one exchange', () {
    test('DSE-only cannot switch to CSE', () {
      initTestAppConfig();
      final service = ExchangeService()..select(StockExchange.cse);
      expect(service.selected.value, StockExchange.dse);
      expect(service.available, [StockExchange.dse]);
    });

    test('CSE-only starts on CSE', () {
      initTestAppConfig(exchangeMode: ExchangeMode.cseOnly);
      expect(ExchangeService().selected.value, StockExchange.cse);
    });

    test('a saved exchange the house no longer has is ignored', () async {
      await StorageService.save(StorageConstants.selectedExchange, 'cse');
      initTestAppConfig();
      expect(ExchangeService().selected.value, StockExchange.dse);
    });

    test(
      'new page scopes start on DSE even if legacy Quote/Trade saved CSE',
      () async {
        initTestAppConfig(exchangeMode: ExchangeMode.dseAndCse);
        await StorageService.save(StorageConstants.selectedExchange, 'cse');
        final service = ExchangeService();

        expect(
          service.exchangeFor(ExchangeScope.quoteTrade),
          StockExchange.cse,
        );
        expect(service.exchangeFor(ExchangeScope.market), StockExchange.dse);
        expect(service.exchangeFor(ExchangeScope.watchlist), StockExchange.dse);
        expect(service.exchangeFor(ExchangeScope.favorites), StockExchange.dse);
      },
    );
  });

  test('without a registered service, current is the house default', () {
    initTestAppConfig(exchangeMode: ExchangeMode.cseOnly);
    expect(ExchangeService.current, AppConfig.defaultExchange);
  });

  group('socket URLs', () {
    test('CSE uses the DSE feeds until CSE URLs are configured', () {
      initTestAppConfig(exchangeMode: ExchangeMode.dseAndCse);
      expect(AppConfig.marketUrlFor(StockExchange.cse), AppConfig.marketUrl);
      expect(AppConfig.indexUrlFor(StockExchange.cse), AppConfig.indexUrl);
    });

    test('CSE uses its own feeds once configured', () {
      initTestAppConfig(
        exchangeMode: ExchangeMode.dseAndCse,
        extra: const {
          'OMS_CSE_SOCKET_MARKET_URL': 'wss://cse.test/market',
          'OMS_CSE_SOCKET_INDEX_URL': 'wss://cse.test/index',
        },
      );
      expect(
        AppConfig.marketUrlFor(StockExchange.cse),
        'wss://cse.test/market',
      );
      expect(AppConfig.indexUrlFor(StockExchange.cse), 'wss://cse.test/index');
      expect(AppConfig.marketUrlFor(StockExchange.dse), AppConfig.marketUrl);
    });
  });
}
