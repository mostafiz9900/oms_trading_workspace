import 'dart:convert';

import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/core/values/storage.dart';
import 'package:oms_shared/app/data/models/marquee_holder.dart';
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
import 'package:oms_shared/app/modules/top_share/controllers/top_share_controller.dart';
import 'package:oms_shared/app/modules/watchlist/controllers/watchlist_controller.dart';

import '../../../helpers/fake_socket.dart';
import '../../../helpers/fake_storage.dart';
import '../../../helpers/test_env.dart';

class _FakeHomeRepository implements HomeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _cseUrl = 'wss://cse.test/market';
const _cseDepthUrl = 'wss://cse.test/marketdepth';
const _dseDepthUrl = '${testSocketBaseUrl}depth';
const _cseTsUrl = 'wss://cse.test/events';
const _dseTsUrl = '${testSocketBaseUrl}news-time-sales';
const _dseUrl = '${testSocketBaseUrl}market';
const _gp = MarketModel(
  orderBook: 101,
  shortName: 'GP',
  ticker: 'GP',
  group: 'PUBLIC',
  board: 'Main Board',
  val: 10,
);

/// The DSE feed is live and must never be cleared or reconnected because the
/// user looked at CSE (CSE has its own service).
void main() {
  late List<FakeChannel> sockets;
  late HomeController home;
  late ExchangeService exchange;

  setUpAll(initTestStorage);

  setUp(() async {
    await clearTestStorage();
    sockets = [];
  });

  tearDown(Get.reset);

  /// The running app on DSE: GP in every DSE list, Quote on GP.
  Future<void> start(WidgetTester tester) async {
    initTestAppConfig(
      exchangeMode: ExchangeMode.dseAndCse,
      extra: const {
        'OMS_CSE_SOCKET_MARKET_URL': _cseUrl,
        'OMS_CSE_SOCKET_MARKET_DEPTH_URL': _cseDepthUrl,
        'OMS_CSE_SOCKET_NEWS_TIME_SALES_URL': _cseTsUrl,
      },
    );
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    final repo = _FakeHomeRepository();
    Get.put<HomeRepository>(repo);
    exchange = Get.put(ExchangeService());
    Get.put(MarketSocketService()).marketFeedList.assignAll([_gp]);
    Get.put(CompaniesController());
    Get.put(MarketIndexController(repo));
    Get.put(
      WebSocketService(
        connector: (uri) => (sockets..add(FakeChannel(uri))).last,
        onlineChanges: const Stream.empty(),
      ),
    );
    Get.put<CseMarketService>(CseMarketService());
    home = Get.put<HomeController>(HomeController(homeRepository: repo));
    await tester.pump();
    home.marketList.add(_gp);
    home.marketListAll.add(_gp);
    home.marqueeList.add(MarqueeHolder(shortName: 'GP'));
    home.chartData = [
      {'sector': 'Telecom'},
    ];
    home.currentSession.value = 'CONTINUOUS';
    await StorageService.save(StorageConstants.orderBookId, 101);
    await home.markerInfo();
  }

  List<String> dseSockets() =>
      sockets.map((s) => s.uri.toString()).where((u) => u == _dseUrl).toList();

  Future<void> finish(WidgetTester tester) async {
    await Get.delete<WebSocketService>(force: true);
    await tester.pump(const Duration(seconds: 11));
  }

  testWidgets('to CSE and back: DSE socket opened once, never reconnected', (
    tester,
  ) async {
    await start(tester);
    expect(dseSockets(), hasLength(1));

    exchange.select(StockExchange.cse);
    await tester.pump();
    exchange.select(StockExchange.dse);
    await tester.pump();

    expect(dseSockets(), hasLength(1));
    expect(
      sockets.map((s) => s.uri.toString()).where((u) => u == _cseUrl),
      hasLength(1),
      reason: 'only the CSE service connects to CSE',
    );
    await finish(tester);
  });

  testWidgets('on CSE: every DSE list and figure is kept', (tester) async {
    await start(tester);

    exchange.select(StockExchange.cse);
    await tester.pump();

    expect(home.marketList, [_gp]);
    expect(home.marketListAll, [_gp]);
    expect(home.marqueeList.single.shortName, 'GP');
    expect(home.chartData, isNotEmpty);
    expect(home.currentSession.value, 'CONTINUOUS');
    expect(Get.find<MarketSocketService>().marketFeedList, [_gp]);
    await finish(tester);
  });

  testWidgets('back to DSE: screens show DSE at once, no loader', (
    tester,
  ) async {
    await start(tester);
    final watch = Get.put<WatchListController>(WatchListController());
    final top = Get.put<TopShareController>(TopShareController())
      ..setActiveTopMenuTopShare('Value');
    exchange.select(StockExchange.cse);
    await tester.pump();
    Get.find<CseMarketService>().onMessage(
      '{"ob": 7, "sn": "GP", "t": "GP", "g": "PUBLIC", "b": "Main Board"}',
    );
    await tester.pump(CseMarketService.flushInterval);
    expect(home.marketData.orderBook, 7, reason: 'Quote on CSE GP');

    exchange.select(StockExchange.dse);
    await tester.pump(); // no DSE flush needed

    expect(watch.isLoading, isFalse);
    expect(watch.filteredItems.map((m) => m.shortName), ['GP']);
    expect(top.pageLoad, isFalse);
    expect(top.marketFeedSortList.map((m) => m.shortName), ['GP']);
    expect(home.marketData.orderBook, 101);
    expect(identical(home.shownMarket.quotes, home.marketList), isTrue);
    await finish(tester);
  });

  testWidgets('switch redraws the Market tab (marquee) from the shown feed', (
    tester,
  ) async {
    await start(tester);
    var draws = 0;
    await tester.pumpWidget(
      GetMaterialApp(
        home: GetBuilder<HomeController>(
          id: 'marquee',
          builder: (_) {
            draws++;
            return const SizedBox();
          },
        ),
      ),
    );
    final before = draws;

    exchange.select(StockExchange.cse);
    await tester.pump();

    expect(draws, greaterThan(before));
    await finish(tester);
  });

  testWidgets('app started on CSE: the DSE socket still uses the DSE URL', (
    tester,
  ) async {
    await StorageService.save(StorageConstants.selectedExchange, 'cse');
    await start(tester);

    expect(dseSockets(), hasLength(1));
    expect(exchange.selected.value, StockExchange.cse);
    await finish(tester);
  });

  group('market depth', () {
    List<FakeChannel> at(String url) =>
        sockets.where((s) => s.uri.toString() == url).toList();

    List<Map> sent(FakeChannel socket) =>
        socket.sent.map((m) => jsonDecode(m as String) as Map).toList();

    testWidgets('CSE depth on its own socket; DSE depth socket kept', (
      tester,
    ) async {
      await start(tester);
      for (final s in sockets) {
        s.open();
      }
      await tester.pump();
      final dseDepth = at(_dseDepthUrl).single;

      exchange.select(StockExchange.cse);
      await tester.pump();
      final cseDepth = at(_cseDepthUrl).single..open();
      await tester.pump();
      Get.find<CseMarketService>().onMessage(
        '{"ob": 7, "sn": "GP", "t": "GP", "g": "PUBLIC", "b": "Main Board"}',
      );
      await tester.pump(CseMarketService.flushInterval);

      expect(home.marketData.orderBook, 7);
      expect(
        sent(cseDepth),
        contains(
          allOf(containsPair('type', 'subscribe'), containsPair('ob', 7)),
        ),
      );
      expect(
        sent(dseDepth),
        contains(
          allOf(containsPair('type', 'unsubscribe'), containsPair('ob', 101)),
        ),
        reason: 'the DSE stock is unsubscribed on the DSE socket',
      );
      expect(sent(dseDepth).where((m) => m['ob'] == 7), isEmpty);

      exchange.select(StockExchange.dse);
      await tester.pump();
      expect(at(_dseDepthUrl), hasLength(1), reason: 'never reconnected');
      expect(
        sent(dseDepth).last,
        allOf(containsPair('type', 'subscribe'), containsPair('ob', 101)),
        reason: 'DSE stock depth again',
      );
      await finish(tester);
    });

    testWidgets('depth panels read the shown exchange', (tester) async {
      await start(tester);
      final cse = Get.find<CseMarketService>();
      expect(identical(home.shownMarket.buys, home.buys), isTrue);

      exchange.select(StockExchange.cse);
      await tester.pump();
      cse.sendDepth('subscribe', 7);
      cse.onDepthMessage('{"7": {"buy": [{"p": 10, "q": 100}], "sell": []}}');

      expect(home.shownMarket.buys, same(cse.buys));
      expect(home.shownMarket.buys.single.p, 10);
      await finish(tester);
    });
  });

  testWidgets('app paused / resumed: CSE sockets close and reopen with DSE', (
    tester,
  ) async {
    await start(tester);
    final cse = Get.find<CseMarketService>();
    exchange.select(StockExchange.cse);
    await tester.pump();
    expect(cse.isOpen, isTrue);

    home.onPaused(); // what the app does when it goes to the background
    expect(cse.isOpen, isFalse);
    expect(cse.isSuspended, isTrue);

    home.initConnect(); // part of onResumed
    await tester.pump();
    expect(cse.isOpen, isTrue);
    expect(cse.isSuspended, isFalse);
    await finish(tester);
  });

  group('time & sales', () {
    List<FakeChannel> at(String url) =>
        sockets.where((s) => s.uri.toString() == url).toList();

    List<Map> sent(FakeChannel socket) =>
        socket.sent.map((m) => jsonDecode(m as String) as Map).toList();

    testWidgets('CSE stock on the CSE socket; DSE socket kept for DSE', (
      tester,
    ) async {
      await start(tester);
      for (final s in sockets) {
        s.open();
      }
      await tester.pump();
      final dseTs = at(_dseTsUrl).single;

      exchange.select(StockExchange.cse);
      await tester.pump();
      final cseTs = at(_cseTsUrl).single..open();
      await tester.pump();
      Get.find<CseMarketService>().onMessage(
        '{"ob": 7, "sn": "GP", "t": "GP", "g": "PUBLIC", "b": "Main Board"}',
      );
      await tester.pump(CseMarketService.flushInterval);

      expect(home.marketData.orderBook, 7);
      expect(
        sent(cseTs).map((m) => '${m['tp']}:${m['ob']}'),
        containsAll(['tsm:7', 'tsb:7', 'news_hist:7']),
      );
      expect(sent(dseTs).where((m) => m['ob'] == 7), isEmpty);

      exchange.select(StockExchange.dse);
      await tester.pump();
      expect(at(_dseTsUrl), hasLength(1), reason: 'never reconnected');
      expect(
        sent(dseTs).map((m) => '${m['tp']}:${m['ob']}'),
        containsAll(['tsm:101', 'tsb:101', 'news_hist:101']),
        reason: 'DSE stock time & sales again',
      );
      await finish(tester);
    });

    testWidgets('Quote time & sales lists read the shown exchange', (
      tester,
    ) async {
      await start(tester);
      final cse = Get.find<CseMarketService>();
      expect(
        identical(home.shownMarket.timeAndSales, home.timeAndSales),
        isTrue,
      );

      exchange.select(StockExchange.cse);
      await tester.pump();
      cse.onTimeSalesMessage('{"tp": "tsm", "d": [{"p": 10, "q": 5}]}');

      expect(home.shownMarket.timeAndSales, same(cse.timeAndSales));
      expect(
        home.shownMarket.timeAndSalesHistory,
        same(cse.timeAndSalesHistory),
      );
      expect(home.shownMarket.newsSingleItem, same(cse.newsSingleItem));
      expect(home.timeAndSales, isEmpty, reason: 'DSE list not written');
      await finish(tester);
    });
  });

  group('switch speed: the whole Home screen is not rebuilt', () {
    /// A bare update() rebuilds HomeView (all six tabs); count those builds
    /// with an id-less builder like HomeView's.
    Future<int Function()> countHomeRebuilds(WidgetTester tester) async {
      var builds = 0;
      await tester.pumpWidget(
        GetMaterialApp(
          home: GetBuilder<HomeController>(
            builder: (_) {
              builds++;
              return const SizedBox();
            },
          ),
        ),
      );
      final before = builds;
      return () => builds - before;
    }

    Future<void> switchAndFeed(WidgetTester tester, StockExchange to) async {
      exchange.select(to);
      await tester.pump();
      if (to == StockExchange.cse) {
        Get.find<CseMarketService>().onMessage(
          '{"ob": 7, "sn": "GP", "t": "GP", "g": "PUBLIC", "b": "Main Board"}',
        );
        await tester.pump(CseMarketService.flushInterval);
        await tester.pump();
      }
    }

    testWidgets('Market tab: DSE -> CSE -> DSE rebuilds HomeView 0 times', (
      tester,
    ) async {
      await start(tester);
      home.currentIndex = 0;
      final rebuilds = await countHomeRebuilds(tester);

      await switchAndFeed(tester, StockExchange.cse);
      await switchAndFeed(tester, StockExchange.dse);

      expect(rebuilds(), 0);
      await finish(tester);
    });

    testWidgets('Favourites tab open: it is redrawn on the switch', (
      tester,
    ) async {
      await start(tester);
      home.currentIndex = 3;
      final rebuilds = await countHomeRebuilds(tester);

      await switchAndFeed(tester, StockExchange.cse);

      expect(rebuilds(), greaterThan(0));
      await finish(tester);
    });
  });
}
