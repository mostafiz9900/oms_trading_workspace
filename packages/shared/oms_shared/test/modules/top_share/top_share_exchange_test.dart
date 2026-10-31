import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/services/cse_market_service.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/modules/top_share/controllers/top_share_controller.dart';

import '../../helpers/fake_socket.dart';
import '../../helpers/fake_storage.dart';
import '../../helpers/test_env.dart';

void main() {
  late ExchangeService exchange;
  late MarketSocketService market;
  late CseMarketService cse;

  const dseRows = [
    MarketModel(orderBook: 1, shortName: 'GP', sector: 'Telecom', val: 50),
    MarketModel(orderBook: 2, shortName: 'BATBC', sector: 'Food', val: 90),
  ];

  setUpAll(() async {
    await initTestStorage();
    initTestAppConfig(
      exchangeMode: ExchangeMode.dseAndCse,
      extra: const {'OMS_CSE_SOCKET_MARKET_URL': 'wss://cse.test/market'},
    );
  });

  tearDown(Get.reset);

  Future<void> setUpFeeds(WidgetTester tester) async {
    await clearTestStorage();
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    exchange = Get.put(ExchangeService());
    Get.put(
      WebSocketService(
        connector: FakeChannel.new,
        onlineChanges: const Stream.empty(),
      ),
    );
    market = Get.put(MarketSocketService());
    market.marketFeedList.assignAll(dseRows);
    cse = Get.put<CseMarketService>(CseMarketService());
  }

  /// A CSE quote (same order book id as DSE GP, another instrument).
  Future<void> cseSends(WidgetTester tester, String json) async {
    cse.onMessage(json);
    await tester.pump(CseMarketService.flushInterval);
  }

  const squrPharma =
      '{"ob": 1, "sn": "SQURPHARMA", "sc": "Pharma", "vl": 70, '
      '"g": "PUBLIC", "b": "Main Board"}';

  TopShareController start() {
    final controller = Get.put(TopShareController());
    controller.setActiveTopMenuTopShare('Value');
    return controller;
  }

  Future<void> finish(WidgetTester tester) async {
    await Get.delete<WebSocketService>(force: true);
    await tester.pump(TopShareController.exchangeLoadTimeout);
  }

  testWidgets('DSE: the DSE feed, as before', (tester) async {
    await setUpFeeds(tester);
    final controller = start();

    expect(controller.marketFeedSortList.map((e) => e.shortName), [
      'BATBC',
      'GP',
    ]);
    await finish(tester);
  });

  testWidgets('to CSE: old rows dropped, loader, filters kept', (tester) async {
    await setUpFeeds(tester);
    final controller = start();
    controller.setActiveSector('Food');

    exchange.select(StockExchange.cse);
    await tester.pump();

    expect(controller.marketFeedSortList, isEmpty);
    expect(controller.pageLoad, isTrue);
    expect(controller.activeSector, 'All');
    expect(controller.sortByCompanyTypeMenuList, ['All']);
    expect(controller.activeTopMenuTopShare, 'Value');
    await finish(tester);
  });

  testWidgets('CSE feed builds the list and sectors; DSE lists untouched', (
    tester,
  ) async {
    await setUpFeeds(tester);
    final controller = start();
    exchange.select(StockExchange.cse);
    await tester.pump();

    // One flush with a non-PUBLIC row too (the list is built once).
    cse.onMessage(
      '{"ob": 5, "sn": "CSEBOND", "vl": 80, "g": "DEBT", "b": "Main Board"}',
    );
    await cseSends(tester, squrPharma);

    expect(controller.pageLoad, isFalse);
    expect(controller.marketFeedSortList.map((e) => e.shortName), [
      'SQURPHARMA',
    ]);
    expect(controller.sortByCompanyTypeMenuList, ['All', 'Pharma']);
    expect(market.marketFeedList, dseRows, reason: 'DSE feed not touched');
    await finish(tester);
  });

  testWidgets('on CSE: rows refresh from the CSE feed, DSE ticks ignored', (
    tester,
  ) async {
    await setUpFeeds(tester);
    final controller = start();
    exchange.select(StockExchange.cse);
    await tester.pump();
    await cseSends(tester, squrPharma);

    controller.updateSingleRowFromService(dseRows.first); // DSE GP, ob 1
    expect(controller.marketFeedSortList.single.shortName, 'SQURPHARMA');

    await cseSends(tester, '{"ob": 1, "vl": 99}');
    expect(controller.marketFeedSortList.single.val, 99);
    await finish(tester);
  });

  testWidgets('back to DSE: the DSE list again', (tester) async {
    await setUpFeeds(tester);
    final controller = start();
    exchange.select(StockExchange.cse);
    await tester.pump();
    await cseSends(tester, squrPharma);

    exchange.select(StockExchange.dse);
    await tester.pump();
    market.marketFeedList.assignAll(dseRows); // DSE feed flushes

    expect(controller.marketFeedSortList.map((e) => e.shortName), [
      'BATBC',
      'GP',
    ]);
    await finish(tester);
  });

  testWidgets('loader stops after the timeout when no feed arrives', (
    tester,
  ) async {
    await setUpFeeds(tester);
    final controller = start();
    exchange.select(StockExchange.cse);
    await tester.pump();

    await tester.pump(TopShareController.exchangeLoadTimeout);

    expect(controller.pageLoad, isFalse);
    expect(controller.marketFeedSortList, isEmpty);
    await finish(tester);
  });

  testWidgets('without a switch, feed updates do not rebuild the list', (
    tester,
  ) async {
    await setUpFeeds(tester);
    final controller = start();
    final before = controller.marketFeedSortList.map((e) => e.shortName);

    market.marketFeedList.assignAll(const [
      MarketModel(orderBook: 9, shortName: 'NEW', val: 1),
    ]);

    expect(controller.marketFeedSortList.map((e) => e.shortName), before);
    await finish(tester);
  });
}
