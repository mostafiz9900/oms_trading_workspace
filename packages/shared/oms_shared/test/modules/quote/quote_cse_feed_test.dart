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

/// GP on DSE (order book 101); the same symbol is 7 on CSE.
const _dseGp = MarketModel(
  orderBook: 101,
  shortName: 'GP',
  group: 'PUBLIC',
  board: 'Main Board',
);
const _cseGp =
    '{"ob": 7, "sn": "GP", "g": "PUBLIC", "b": "Main Board", "lp": 250}';
const _cseKey = '${StorageConstants.orderBookId}_cse';

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

  testWidgets('DSE: Quote stock from the DSE feed, saved under the old key', (
    tester,
  ) async {
    await start(tester, ExchangeMode.dseAndCse);

    expect(home.marketData.orderBook, 101);
    expect(await StorageService.read(StorageConstants.orderBookId), 101);
    expect(await StorageService.read(_cseKey), isNull);
    await finish(tester);
  });

  testWidgets('to CSE: same symbol from the CSE feed; DSE choice kept', (
    tester,
  ) async {
    await start(tester, ExchangeMode.dseAndCse);

    exchange.select(StockExchange.cse);
    await tester.pump();
    expect(home.marketData.orderBook, 101, reason: 'kept until CSE has it');

    await cseSends(tester, _cseGp);

    expect(home.marketData.orderBook, 7);
    expect(home.marketData.last, 250);
    expect(await StorageService.read(_cseKey), 7);
    expect(
      await StorageService.read(StorageConstants.orderBookId),
      101,
      reason: 'the DSE stock is not overwritten by the CSE id',
    );
    expect(identical(home.shownMarket.quotes, cse.quotes), isTrue);
    await finish(tester);
  });

  testWidgets('back to DSE: the DSE stock again', (tester) async {
    await start(tester, ExchangeMode.dseAndCse);
    exchange.select(StockExchange.cse);
    await tester.pump();
    await cseSends(tester, _cseGp);

    exchange.select(StockExchange.dse);
    await tester.pump();
    home.marketList.assignAll([_dseGp]); // DSE feed flushes
    home.onShownFeedFlushed();
    await tester.pump();

    expect(home.marketData.orderBook, 101);
    expect(identical(home.shownMarket.quotes, home.marketList), isTrue);
    expect(await StorageService.read(StorageConstants.orderBookId), 101);
    await finish(tester);
  });

  testWidgets('dseOnly: Quote as before, CSE key never written', (
    tester,
  ) async {
    await start(tester, ExchangeMode.dseOnly);

    exchange.select(StockExchange.cse); // ignored for a DSE-only house
    await tester.pump();

    expect(home.marketData.orderBook, 101);
    expect(await StorageService.read(_cseKey), isNull);
    await finish(tester);
  });
}
