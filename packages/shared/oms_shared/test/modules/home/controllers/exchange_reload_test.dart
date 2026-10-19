import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/models/marquee_holder.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/modules/home/controllers/home_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/companies_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/market_index_controller.dart';

import '../../../helpers/fake_socket.dart';
import '../../../helpers/fake_storage.dart';
import '../../../helpers/test_env.dart';

class _FakeHomeRepository implements HomeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late List<FakeChannel> sockets;

  setUpAll(() async {
    await initTestStorage();
    initTestAppConfig(
      exchangeMode: ExchangeMode.dseAndCse,
      extra: const {'OMS_CSE_SOCKET_MARKET_URL': 'wss://cse.test/market'},
    );
  });

  setUp(() async {
    await clearTestStorage();
    sockets = [];
  });

  tearDown(Get.reset);

  Future<HomeController> startHome(WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    final repo = _FakeHomeRepository();
    Get.put<HomeRepository>(repo);
    Get.put(ExchangeService());
    Get.put(MarketSocketService());
    Get.put(CompaniesController());
    Get.put(MarketIndexController(repo));
    Get.put(
      WebSocketService(
        connector: (uri) => (sockets..add(FakeChannel(uri))).last,
        onlineChanges: const Stream.empty(),
      ),
    );
    return HomeController(homeRepository: repo);
  }

  Future<void> finish(WidgetTester tester) async {
    await Get.delete<WebSocketService>(force: true);
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('switching to CSE reconnects the market feed to the CSE URL '
      'and drops the DSE quotes', (tester) async {
    final home = await startHome(tester);
    final feed = Get.find<MarketSocketService>();

    // DSE quotes are on screen (Top Stocks, watchlist/quote lists, marquee).
    feed.onMarketPayload({'ob': 101, 'sn': 'GP', 'g': 'PUBLIC', 'b': 'Main Board'});
    await tester.pump(const Duration(seconds: 1));
    expect(feed.marketFeedList, hasLength(1));
    const gp = MarketModel(orderBook: 101, shortName: 'GP');
    home.marketListAll.add(gp);
    home.marketFeedList.add(gp);
    home.marketListForDilog.add(gp);
    home.marqueeList.add(MarqueeHolder(shortName: 'GP'));

    Get.find<ExchangeService>().select(StockExchange.cse);
    home.reloadMarketForExchange();
    await tester.pump();

    expect(feed.marketFeedList, isEmpty, reason: 'same ob may mean another stock on CSE');
    expect(home.marketListAll, isEmpty, reason: 'watchlist / quote lookup');
    expect(home.marketFeedList, isEmpty);
    expect(home.marketListForDilog, isEmpty, reason: 'search dialog');
    expect(home.marqueeList, isEmpty, reason: 'marquee is keyed by name');
    expect(sockets.last.uri.toString(), 'wss://cse.test/market');
    await finish(tester);
  });

  testWidgets('switching back to DSE uses the DSE feed again', (tester) async {
    final home = await startHome(tester);
    final exchange = Get.find<ExchangeService>();

    exchange.select(StockExchange.cse);
    home.reloadMarketForExchange();
    exchange.select(StockExchange.dse);
    home.reloadMarketForExchange();
    await tester.pump();

    expect(sockets.last.uri.toString(), '${testSocketBaseUrl}market');
    await finish(tester);
  });
}
