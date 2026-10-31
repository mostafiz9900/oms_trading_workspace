import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/core/values/storage.dart';
import 'package:oms_shared/app/data/models/response/fav_market_response.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/services/cse_market_service.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/data/services/storage_service.dart';
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
  ticker: 'GP',
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

  testWidgets('favourites re-matched from the CSE feed after a switch', (
    tester,
  ) async {
    await start(tester, ExchangeMode.dseAndCse);
    // Saved as (ticker, order book); this one exists with the same pair on
    // the CSE feed only.
    home.favMarketData = [FavMarketResponse(ticker: 'CSESTOCK', oderBook: '9')];

    exchange.select(StockExchange.cse);
    await tester.pump();
    await cseSends(
      tester,
      '{"ob": 9, "sn": "CSESTOCK", "t": "CSESTOCK", "g": "PUBLIC", '
      '"b": "Main Board"}',
    );

    expect(home.favMarketParseList.map((m) => m.shortName), ['CSESTOCK']);
    await finish(tester);
  });

  testWidgets('DSE: favourites matched from the DSE feed, as before', (
    tester,
  ) async {
    await start(tester, ExchangeMode.dseAndCse);
    home.favMarketData = [FavMarketResponse(ticker: 'GP', oderBook: '101')];

    final parsed = home.parseFavMarketList(
      favMarketData: home.favMarketData,
      marketList: home.shownMarket.quotes,
    );

    expect(identical(home.shownMarket.quotes, home.marketList), isTrue);
    expect(parsed.map((m) => m.orderBook), [101]);
    await finish(tester);
  });
}
