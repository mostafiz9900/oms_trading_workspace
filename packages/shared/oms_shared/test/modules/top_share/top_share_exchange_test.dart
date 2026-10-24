import 'package:broker_config/broker_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/modules/top_share/controllers/top_share_controller.dart';

import '../../helpers/fake_storage.dart';
import '../../helpers/test_env.dart';

void main() {
  late ExchangeService exchange;
  late MarketSocketService market;

  const dseRows = [
    MarketModel(orderBook: 1, shortName: 'GP', sector: 'Telecom', val: 50),
    MarketModel(orderBook: 2, shortName: 'BATBC', sector: 'Food', val: 90),
  ];
  // Same order book id as GP on DSE, different instrument.
  const cseRows = [
    MarketModel(orderBook: 1, shortName: 'SQURPHARMA', sector: 'Pharma', val: 70),
  ];

  setUpAll(() async {
    await initTestStorage();
    initTestAppConfig(exchangeMode: ExchangeMode.dseAndCse);
  });

  setUp(() async {
    await clearTestStorage();
    exchange = Get.put(ExchangeService());
    market = Get.put(MarketSocketService());
    market.marketFeedList.assignAll(dseRows);
  });

  tearDown(Get.reset);

  TopShareController start() {
    final controller = Get.put(TopShareController());
    controller.setActiveTopMenuTopShare('Value');
    return controller;
  }

  testWidgets('switching drops the old rows and shows the loader', (tester) async {
    final controller = start();
    controller.setActiveSector('Food');
    expect(controller.marketFeedSortList.map((e) => e.shortName), ['BATBC']);

    exchange.select(StockExchange.cse);
    market.clear(); // what HomeController does on the switch

    expect(controller.marketFeedSortList, isEmpty);
    expect(controller.pageLoad, isTrue);
    expect(controller.activeSector, 'All');
    expect(controller.sortByCompanyTypeMenuList, ['All']);
    expect(controller.activeTopMenuTopShare, 'Value');
    await tester.pump(TopShareController.exchangeLoadTimeout);
  });

  testWidgets('the new exchange feed rebuilds list and sectors', (tester) async {
    final controller = start();
    exchange.select(StockExchange.cse);
    market.clear();

    market.marketFeedList.assignAll(cseRows);

    expect(controller.pageLoad, isFalse);
    expect(controller.marketFeedSortList.map((e) => e.shortName), ['SQURPHARMA']);
    expect(controller.sortByCompanyTypeMenuList, ['All', 'Pharma']);
  });

  testWidgets('loader stops after the timeout when no feed arrives', (tester) async {
    final controller = start();
    exchange.select(StockExchange.cse);
    market.clear();

    await tester.pump(TopShareController.exchangeLoadTimeout);

    expect(controller.pageLoad, isFalse);
    expect(controller.marketFeedSortList, isEmpty);
  });

  testWidgets('without a switch, feed updates do not rebuild the list', (tester) async {
    final controller = start();
    final before = controller.marketFeedSortList.map((e) => e.shortName).toList();

    market.marketFeedList.assignAll(cseRows);

    expect(controller.marketFeedSortList.map((e) => e.shortName), before);
  });
}
