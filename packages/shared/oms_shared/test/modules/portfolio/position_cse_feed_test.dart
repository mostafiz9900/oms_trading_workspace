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
import 'package:oms_shared/app/modules/portfolio/controllers/position_controller.dart';

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
  isinCode: 'BD0001GP0001',
  last: 300,
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

  /// Portfolio open; its REST load is not needed to value a holding.
  PositionController openPortfolio() =>
      Get.put<PositionController>(_PositionsWithoutLoad());

  testWidgets('DSE: holding valued at the DSE price, as before', (
    tester,
  ) async {
    await start(tester, ExchangeMode.dseAndCse);
    final positions = openPortfolio();

    expect(positions.getMarketData('BD0001GP0001').last, 300);
    await finish(tester);
  });

  testWidgets('CSE selected: the same ISIN at the CSE price', (tester) async {
    await start(tester, ExchangeMode.dseAndCse);
    final positions = openPortfolio();

    exchange.select(StockExchange.cse);
    await tester.pump();
    await cseSends(
      tester,
      '{"ob": 7, "sn": "GP", "ic": "BD0001GP0001", "lp": 250, '
      '"g": "PUBLIC", "b": "Main Board"}',
    );

    expect(positions.getMarketData('BD0001GP0001').last, 250);

    exchange.select(StockExchange.dse);
    await tester.pump();
    home.marketList.assignAll([_dseGp]); // DSE feed flushes
    expect(positions.getMarketData('BD0001GP0001').last, 300);
    await finish(tester);
  });
}

class _PositionsWithoutLoad extends PositionController {
  @override
  // ignore: must_call_super
  void onInit() {}
}
