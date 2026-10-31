import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/core/values/storage.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/services/cse_market_service.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/data/services/storage_service.dart';
import 'package:oms_shared/app/data/services/recent_search_service.dart';
import 'package:oms_shared/app/modules/global_search/controllers/global_search_controller.dart';
import 'package:oms_shared/app/modules/home/controllers/home_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/companies_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/market_index_controller.dart';

import '../../helpers/fake_socket.dart';
import '../../helpers/fake_storage.dart';
import '../../helpers/test_env.dart';

class _FakeHomeRepository implements HomeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// GP on DSE (order book 101).
const _dseGp = MarketModel(
  orderBook: 101,
  shortName: 'GP',
  group: 'PUBLIC',
  board: 'Main Board',
);

void main() {
  late HomeController home;
  late CseMarketService cse;
  late ExchangeService exchange;

  setUpAll(initTestStorage);
  setUp(clearTestStorage);
  tearDown(Get.reset);

  /// App on DSE showing GP on Quote; HomeController's DSE lists hold GP.
  Future<void> start(WidgetTester tester, ExchangeMode mode) async {
    initTestAppConfig(
      exchangeMode: mode,
      extra: const {'OMS_CSE_SOCKET_MARKET_URL': 'wss://cse.test/market'},
    );
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    final repo = _FakeHomeRepository();
    Get.put<HomeRepository>(repo);
    exchange = Get.put(ExchangeService());
    Get.put(MarketSocketService());
    Get.put(CompaniesController());
    Get.put(MarketIndexController(repo));
    Get.put(
      WebSocketService(
        connector: FakeChannel.new,
        onlineChanges: const Stream.empty(),
      ),
    );
    cse = Get.put<CseMarketService>(CseMarketService());
    home = Get.put<HomeController>(HomeController(homeRepository: repo));
    await tester.pump();
    home.marketList.add(_dseGp);
    home.marketListAll.add(_dseGp);
    await StorageService.save(StorageConstants.orderBookId, 101);
    await home.markerInfo();
  }

  Future<void> cseSends(WidgetTester tester, String json) async {
    cse.onMessage(json);
    await tester.pump(CseMarketService.flushInterval);
  }

  Future<void> finish(WidgetTester tester) async {
    await Get.delete<WebSocketService>(force: true);
    await tester.pump(const Duration(seconds: 6));
  }

  List<String?> results(GlobalSearchController c) =>
      c.filteredItems.map((m) => m.shortName).toList();

  Future<GlobalSearchController> openSearch() async {
    Get.put<RecentSearchService>(RecentSearchService());
    return Get.put<GlobalSearchController>(GlobalSearchController());
  }

  testWidgets('DSE: results from the DSE feed, as before', (tester) async {
    await start(tester, ExchangeMode.dseAndCse);
    final search = await openSearch();

    expect(results(search), ['GP']);
    await finish(tester);
  });

  testWidgets('CSE: results from the CSE feed, refreshed as it arrives', (
    tester,
  ) async {
    await start(tester, ExchangeMode.dseAndCse);
    final search = await openSearch();

    exchange.select(StockExchange.cse);
    await tester.pump();
    expect(results(search), isEmpty, reason: 'no DSE stocks under CSE');

    await cseSends(
      tester,
      '{"ob": 9, "sn": "CSESTOCK", "g": "PUBLIC", "b": "Main Board"}',
    );
    expect(results(search), ['CSESTOCK']);

    search.addToRecent(search.filteredItems.single);
    expect(search.recentSearches.map((m) => m.shortName), ['CSESTOCK']);
    await finish(tester);
  });

  testWidgets('back to DSE: DSE results and DSE recents again', (
    tester,
  ) async {
    await start(tester, ExchangeMode.dseAndCse);
    final search = await openSearch();
    search.addToRecent(_dseGp);
    exchange.select(StockExchange.cse);
    await tester.pump();
    await cseSends(
      tester,
      '{"ob": 9, "sn": "CSESTOCK", "g": "PUBLIC", "b": "Main Board"}',
    );

    exchange.select(StockExchange.dse);
    await tester.pump();
    home.marketList.assignAll([_dseGp]); // DSE feed flushes
    search.syncLiveData();

    expect(results(search), ['GP']);
    expect(search.recentSearches.map((m) => m.shortName), ['GP']);
    await finish(tester);
  });
}
