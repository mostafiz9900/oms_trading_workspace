import 'dart:convert';

import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/core/utils/extensions/market_model_extensions.dart';
import 'package:oms_shared/app/data/models/marquee_holder.dart';
import 'package:oms_shared/app/data/models/response/fav_market_response.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/repositories/market_chart_repository.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/recent_search_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/modules/global_search/controllers/global_search_controller.dart';
import 'package:oms_shared/app/modules/home/controllers/home_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/companies_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/market_index_controller.dart';
import 'package:oms_shared/app/modules/portfolio/controllers/position_controller.dart';
import 'package:oms_shared/app/modules/quote/controllers/historical_volume_controller.dart';

import '../../../helpers/fake_socket.dart';
import '../../../helpers/fake_storage.dart';
import '../../../helpers/test_env.dart';

class _FakeHomeRepository implements HomeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeChartRepository implements MarketChartRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Records what the Price Table tab is asked to load.
class _RecordingHistory extends HistoricalVolumeController {
  _RecordingHistory() : super(repository: _FakeChartRepository());

  final loads = <String>[];

  // The real one loads at once.
  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> loadData(String ticket, int orderbookId) async =>
      loads.add('$ticket#$orderbookId');
}

/// Counts redraws of the Position tab.
class _CountingPositions extends PositionController {
  int redraws = 0;

  @override
  // ignore: must_call_super
  void onInit() {} // the real one loads positions over REST

  @override
  void update([List<Object>? ids, bool condition = true]) => redraws++;
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
    // Lets the switch windows (Quote fallback, favourites) run out.
    await tester.pump(QuoteMixin.quoteSwitchFallback);
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
    home.marqueeList.add(MarqueeHolder(shortName: 'GP'));

    Get.find<ExchangeService>().select(StockExchange.cse);
    home.reloadMarketForExchange();
    await tester.pump();

    expect(feed.marketFeedList, isEmpty, reason: 'same ob may mean another stock on CSE');
    expect(home.marketListAll, isEmpty, reason: 'watchlist / quote lookup');
    expect(home.marqueeList, isEmpty, reason: 'marquee is keyed by name');
    expect(sockets.last.uri.toString(), 'wss://cse.test/market');
    await finish(tester);
  });

  testWidgets('open search screen drops the old exchange results', (
    tester,
  ) async {
    final home = await startHome(tester);
    Get.put<HomeController>(home);
    Get.put(RecentSearchService());
    const gp = MarketModel(orderBook: 101, shortName: 'GP', group: 'PUBLIC');
    home.marketList.add(gp);
    final search = Get.put(GlobalSearchController());
    expect(search.filteredItems, [gp]);

    Get.find<ExchangeService>().select(StockExchange.cse);
    home.reloadMarketForExchange();
    await tester.pump();

    expect(search.filteredItems, isEmpty);
    await finish(tester);
  });

  group('Quote', () {
    // GP is order book 101 on DSE; on CSE order book 101 is another stock.
    Future<HomeController> onGpThenSwitch(WidgetTester tester) async {
      final home = await startHome(tester);
      home.marketData = const MarketModel(orderBook: 101, shortName: 'GP');
      Get.find<ExchangeService>().select(StockExchange.cse);
      home.reloadMarketForExchange();
      await tester.pump();
      sockets.last.open();
      await tester.pump();
      return home;
    }

    Future<void> cseSends(WidgetTester tester, int ob, String name) async {
      sockets.last.serverSends(
        '{"ob": $ob, "sn": "$name", "g": "PUBLIC", "b": "Main Board"}',
      );
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('keeps the stock (Trade uses it) until the new feed has it', (
      tester,
    ) async {
      final home = await onGpThenSwitch(tester);
      expect(home.marketData.orderBook, 101);

      await cseSends(tester, 101, 'SQURPHARMA');
      await cseSends(tester, 7, 'GP');
      await tester.pump(const Duration(milliseconds: 600));

      expect(home.marketData.shortName, 'GP');
      expect(home.marketData.orderBook, 7, reason: 'CSE order book for GP');
      await finish(tester);
    });

    testWidgets('on Trade, the price box shows the new stock price', (
      tester,
    ) async {
      final home = await startHome(tester);
      home.tradPriceTextEditField = TextEditingController(text: '999.00');
      home.currentIndex = 5;
      home.marketData = const MarketModel(orderBook: 101, shortName: 'GP');
      Get.find<ExchangeService>().select(StockExchange.cse);
      home.reloadMarketForExchange();
      await tester.pump();
      sockets.last.open();
      await tester.pump();

      await cseSends(tester, 7, 'GP');

      expect(home.marketData.orderBook, 7);
      expect(
        home.tradPriceTextEditField.text,
        home.marketData.activePrice.toStringAsFixed(2),
      );
      expect(home.tradPriceTextEditField.text, isNot('999.00'));
      await finish(tester);
    });

    testWidgets('symbol not on the new exchange: its first stock after '
        'the fallback', (tester) async {
      final home = await onGpThenSwitch(tester);

      await cseSends(tester, 5, 'BATBC');
      expect(home.marketData.shortName, 'GP', reason: 'still waiting');

      await tester.pump(QuoteMixin.quoteSwitchFallback);

      expect(home.marketData.shortName, 'BATBC');
      expect(home.marketData.orderBook, 5);
      await finish(tester);
    });
  });

  group('Favourites, sectors, Price Table', () {
    Future<HomeController> switchToCse(WidgetTester tester, HomeController home) async {
      Get.find<ExchangeService>().select(StockExchange.cse);
      home.reloadMarketForExchange();
      await tester.pump();
      sockets.last.open();
      await tester.pump();
      return home;
    }

    Future<void> cseSends(WidgetTester tester, Map<String, Object> quote) async {
      sockets.last.serverSends(jsonEncode({'g': 'PUBLIC', 'b': 'Main Board', ...quote}));
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('favourites drop the old prices and re-match the new feed', (
      tester,
    ) async {
      final home = await startHome(tester);
      home.favMarketData = [FavMarketResponse(ticker: 'GP', oderBook: '7')];
      home.favMarketParseList = [const MarketModel(orderBook: 7, ticker: 'GP', reference: 300)];
      await switchToCse(tester, home);

      expect(home.favMarketParseList, isEmpty, reason: 'no old-exchange prices');

      await cseSends(tester, {'ob': 7, 'sn': 'GP', 't': 'GP'});
      expect(home.favMarketParseList.single.orderBook, 7);
      await finish(tester);
    });

    testWidgets('after the switch window, favourites are a snapshot again '
        '(as on DSE)', (tester) async {
      final home = await startHome(tester);
      home.favMarketData = [FavMarketResponse(ticker: 'GP', oderBook: '7')];
      await switchToCse(tester, home);
      await tester.pump(QuoteMixin.quoteSwitchFallback);
      const snapshot = MarketModel(orderBook: 7, ticker: 'GP', reference: 300);
      home.favMarketParseList = [snapshot]; // as getFavMarketData sets it

      await cseSends(tester, {'ob': 7, 'sn': 'GP', 't': 'GP'});

      expect(identical(home.favMarketParseList.single, snapshot), isTrue);
      await finish(tester);
    });

    testWidgets('Position is redrawn with the new feed after a switch, '
        'and only then', (tester) async {
      final home = await startHome(tester);
      Get.put<HomeController>(home);
      final positions =
          Get.put<PositionController>(_CountingPositions()) as _CountingPositions;
      await switchToCse(tester, home);

      await cseSends(tester, {'ob': 7, 'sn': 'GP', 't': 'GP'});
      expect(positions.redraws, greaterThan(0), reason: 'CSE prices shown');

      await tester.pump(QuoteMixin.quoteSwitchFallback);
      final afterWindow = positions.redraws;
      await cseSends(tester, {'ob': 8, 'sn': 'BATBC', 't': 'BATBC'});
      expect(positions.redraws, afterWindow, reason: 'as before outside a switch');
      await finish(tester);
    });

    testWidgets('sector and distribution figures are cleared on a switch', (
      tester,
    ) async {
      final home = await startHome(tester);
      home.chartData = [{'sector': 'Bank'}];
      home.chartDataShareType = [{'type': 'A'}];
      home.distributionCounts = [1, 2];
      home.distributionTotal = 3;
      home.distributionMaxCount = 2;
      await switchToCse(tester, home);

      expect(home.chartData, isEmpty);
      expect(home.chartDataShareType, isEmpty);
      expect(home.sectorSummaryList, isEmpty);
      expect(home.distributionCounts, isEmpty);
      expect(home.distributionTotal, 0);
      await finish(tester);
    });

    testWidgets('sector details screen refreshes once the new sectors exist', (
      tester,
    ) async {
      final home = await startHome(tester);
      Get.put<HomeController>(home);
      var builds = 0;
      await tester.pumpWidget(
        GetMaterialApp(
          home: GetBuilder<HomeController>(
            id: 'sectorSummary',
            builder: (_) {
              builds++;
              return const SizedBox();
            },
          ),
        ),
      );
      await switchToCse(tester, home);
      final afterSwitch = builds;

      await cseSends(tester, {'ob': 7, 'sn': 'GP', 't': 'GP', 'sc': 'Telecom'});
      await tester.pump(const Duration(seconds: 3));

      expect(home.sectorSummaryList, isNotEmpty);
      expect(builds, greaterThan(afterSwitch));
      await finish(tester);
    });

    testWidgets('Price Table tab open: loads the new stock history', (
      tester,
    ) async {
      final home = await startHome(tester);
      Get.put<HomeController>(home);
      final history = Get.put<HistoricalVolumeController>(_RecordingHistory())
          as _RecordingHistory;
      home.marketData = const MarketModel(orderBook: 101, shortName: 'GP');
      home.currentTabIndexQuote = 3;
      await switchToCse(tester, home);

      await cseSends(tester, {'ob': 7, 'sn': 'GP', 't': 'GP'});
      await tester.pump(const Duration(milliseconds: 600));

      expect(history.loads, ['GP#7']);
      await finish(tester);
    });
  });

  group('Stock details (depth, time & sales)', () {
    const cseFeeds = {
      'OMS_CSE_SOCKET_MARKET_URL': 'wss://cse.test/market',
      'OMS_CSE_SOCKET_MARKET_DEPTH_URL': 'wss://cse.test/depth',
      'OMS_CSE_SOCKET_NEWS_TIME_SALES_URL': 'wss://cse.test/events',
    };

    /// Home with every socket open (as after onInit), showing DSE GP (101).
    Future<HomeController> runningOnGp(
      WidgetTester tester,
      Map<String, String> extra,
    ) async {
      initTestAppConfig(exchangeMode: ExchangeMode.dseAndCse, extra: extra);
      addTearDown(
        () => initTestAppConfig(
          exchangeMode: ExchangeMode.dseAndCse,
          extra: const {'OMS_CSE_SOCKET_MARKET_URL': 'wss://cse.test/market'},
        ),
      );
      final home = await startHome(tester);
      Get.put<HomeController>(home); // onInit opens the sockets
      await tester.pump();
      for (final s in sockets) {
        s.open();
      }
      await tester.pump();
      home.marketData = const MarketModel(orderBook: 101, shortName: 'GP');
      return home;
    }

    FakeChannel socketAt(String url) =>
        sockets.lastWhere((s) => s.uri.toString() == url);

    List<Map> sentTo(String url) => socketAt(
      url,
    ).sent.map((m) => jsonDecode(m as String) as Map).toList();

    testWidgets('a CSE stock shows CSE depth and time & sales', (tester) async {
      final home = await runningOnGp(tester, cseFeeds);

      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();
      for (final url in cseFeeds.values) {
        socketAt(url).open();
      }
      await tester.pump();

      expect(
        sentTo('wss://cse.test/depth').where((m) => m['ob'] == 101),
        isEmpty,
        reason: 'DSE GP id is another stock on CSE',
      );

      socketAt('wss://cse.test/market').serverSends(
        '{"ob": 7, "sn": "GP", "t": "GP", "g": "PUBLIC", "b": "Main Board"}',
      );
      await tester.pump(const Duration(milliseconds: 600));

      expect(home.marketData.orderBook, 7);
      expect(
        sentTo('wss://cse.test/depth'),
        contains(allOf(containsPair('type', 'subscribe'), containsPair('ob', 7))),
      );
      expect(
        sentTo('wss://cse.test/events').where((m) => m['ob'] == 7),
        isNotEmpty,
      );
      await finish(tester);
    });

    testWidgets('no CSE depth / T&S URL: those connections are kept', (
      tester,
    ) async {
      await runningOnGp(tester, const {
        'OMS_CSE_SOCKET_MARKET_URL': 'wss://cse.test/market',
      });
      final before = sockets.length;

      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();

      expect(sockets.length, before + 1, reason: 'only the market feed');
      expect(sockets.last.uri.toString(), 'wss://cse.test/market');
      await finish(tester);
    });
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
