import 'package:broker_config/broker_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/recent_search_service.dart';
import 'package:oms_shared/app/data/services/storage_service.dart';

import '../../helpers/fake_storage.dart';
import '../../helpers/test_env.dart';

void main() {
  late ExchangeService exchange;

  setUpAll(() async {
    await initTestStorage();
    initTestAppConfig(exchangeMode: ExchangeMode.dseAndCse);
  });

  setUp(() async {
    await clearTestStorage();
    exchange = Get.put(ExchangeService());
  });

  tearDown(Get.reset);

  Future<RecentSearchService> start() async {
    final service = Get.put(RecentSearchService());
    await Future<void>.delayed(Duration.zero); // load from storage
    return service;
  }

  test('searches saved before CSE stay on DSE (same storage key)', () async {
    await StorageService.save('recent_search_ids', [101, 202]);

    final service = await start();

    expect(service.recentOrderBookIds, [101, 202]);
  });

  test('each exchange keeps its own recent list', () async {
    final service = await start();
    service.addToRecentSearch(101); // DSE

    exchange.select(StockExchange.cse);
    expect(service.recentOrderBookIds, isEmpty, reason: '101 may be another stock on CSE');
    service.addToRecentSearch(7);
    expect(service.recentOrderBookIds, [7]);

    exchange.select(StockExchange.dse);
    expect(service.recentOrderBookIds, [101]);
  });

  test('both lists survive a restart', () async {
    final first = await start();
    first.addToRecentSearch(101);
    exchange.select(StockExchange.cse);
    first.addToRecentSearch(7);
    await Future<void>.delayed(Duration.zero);
    Get.delete<RecentSearchService>(force: true);

    final again = await start();

    expect(again.recentOrderBookIds, [7]);
    exchange.select(StockExchange.dse);
    expect(again.recentOrderBookIds, [101]);
  });

  test('clearing CSE leaves DSE untouched', () async {
    final service = await start();
    service.addToRecentSearch(101);
    exchange.select(StockExchange.cse);
    service.addToRecentSearch(7);

    service.clearRecentSearches();

    expect(service.recentOrderBookIds, isEmpty);
    exchange.select(StockExchange.dse);
    expect(service.recentOrderBookIds, [101]);

    // And in storage, after a restart.
    await Future<void>.delayed(Duration.zero);
    Get.delete<RecentSearchService>(force: true);
    final again = await start();
    expect(again.recentOrderBookIds, [101]);
    exchange.select(StockExchange.cse);
    expect(again.recentOrderBookIds, isEmpty);
  });
}
