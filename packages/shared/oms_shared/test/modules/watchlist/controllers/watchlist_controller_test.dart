import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/services/cse_market_service.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/modules/home/controllers/home_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/companies_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/market_index_controller.dart';
import 'package:oms_shared/app/modules/watchlist/controllers/watchlist_controller.dart';

import '../../../helpers/fake_socket.dart';
import '../../../helpers/fake_storage.dart';
import '../../../helpers/test_env.dart';

class _FakeHomeRepository implements HomeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _cseUrl = 'wss://cse.test/market';
const _gp = MarketModel(
  orderBook: 101,
  shortName: 'GP',
  group: 'PUBLIC',
  board: 'Main Board',
);

void main() {
  late List<FakeChannel> sockets;
  late HomeController home;

  setUpAll(initTestStorage);

  setUp(() async {
    await clearTestStorage();
    sockets = [];
  });

  tearDown(Get.reset);

  /// App running on DSE with GP in the DSE feed, Watch List open.
  Future<WatchListController> start(
    WidgetTester tester,
    ExchangeMode mode,
  ) async {
    initTestAppConfig(
      exchangeMode: mode,
      extra: const {'OMS_CSE_SOCKET_MARKET_URL': _cseUrl},
    );
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
    Get.put(CseMarketService());
    home = Get.put(HomeController(homeRepository: repo));
    await tester.pump();
    home.marketList.add(_gp);
    // Explicit type: in an async return the inferred type would be
    // FutureOr<WatchListController>, registering it under the wrong key.
    return Get.put<WatchListController>(WatchListController());
  }

  /// A message of the CSE service's own socket. (During the step-by-step
  /// move the shared feed also reconnects to the CSE URL, so the two sockets
  /// cannot be told apart by URL.)
  Future<void> cseSends(WidgetTester tester, String json) async {
    Get.find<CseMarketService>().onMessage(json);
    await tester.pump(CseMarketService.flushInterval);
  }

  Future<void> finish(WidgetTester tester) async {
    await Get.delete<WebSocketService>(force: true);
    await tester.pump(const Duration(seconds: 6));
  }

  List<String?> shown(WatchListController c) =>
      c.filteredItems.map((e) => e.shortName).toList();

  testWidgets('DSE selected: the DSE feed, as before', (tester) async {
    final watch = await start(tester, ExchangeMode.dseAndCse);
    watch.applyFilters();

    expect(watch.showsCse, isFalse);
    expect(shown(watch), ['GP']);
    await finish(tester);
  });

  testWidgets(
    'CSE selected: the CSE feed; the service never writes the DSE lists',
    (tester) async {
      final watch = await start(tester, ExchangeMode.dseAndCse);

      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();
      expect(shown(watch), isEmpty, reason: 'no DSE stocks under CSE');
      expect(watch.isLoading, isTrue);
      await cseSends(
        tester,
        '{"ob": 7, "sn": "SQURPHARMA", "g": "PUBLIC", "b": "Main Board"}',
      );

      expect(watch.showsCse, isTrue);
      expect(shown(watch), ['SQURPHARMA']);
      for (final list in [home.marketList, home.marketListAll]) {
        expect(list.where((m) => m.shortName == 'SQURPHARMA'), isEmpty);
      }
      await finish(tester);
    },
  );

  testWidgets('back to DSE: the DSE feed again', (tester) async {
    final watch = await start(tester, ExchangeMode.dseAndCse);
    final exchange = Get.find<ExchangeService>();
    exchange.select(StockExchange.cse);
    await tester.pump();
    await cseSends(
      tester,
      '{"ob": 7, "sn": "SQURPHARMA", "g": "PUBLIC", "b": "Main Board"}',
    );

    exchange.select(StockExchange.dse);
    await tester.pump();
    home.marketList.assignAll([_gp]); // DSE feed (re)filled
    watch.applyFilters();

    expect(shown(watch), ['GP']);
    await finish(tester);
  });

  for (final mode in [ExchangeMode.dseOnly, ExchangeMode.cseOnly]) {
    testWidgets('${mode.name}: HomeController feed, as before', (tester) async {
      final watch = await start(tester, mode);
      watch.applyFilters();

      expect(watch.showsCse, isFalse);
      expect(shown(watch), ['GP']);
      expect(Get.find<CseMarketService>().isOpen, isFalse);
      await finish(tester);
    });
  }

  group('Market tab feed (shownMarket)', () {
    for (final mode in [ExchangeMode.dseOnly, ExchangeMode.cseOnly]) {
      testWidgets('${mode.name}: HomeController fields, as before', (
        tester,
      ) async {
        await start(tester, mode);
        home.chartData = [
          {'sector': 'Bank'},
        ];
        home.currentSession.value = 'CONTINUOUS';

        final shown = home.shownMarket;
        expect(shown, isNot(isA<CseMarketService>()));
        expect(identical(shown.quotes, home.marketList), isTrue);
        expect(identical(shown.marqueeList, home.marqueeList), isTrue);
        expect(identical(shown.chartData, home.chartData), isTrue);
        expect(identical(shown.session, home.currentSession), isTrue);
        await finish(tester);
      });
    }

    testWidgets('DSE and CSE: DSE fields on DSE, the CSE service on CSE', (
      tester,
    ) async {
      await start(tester, ExchangeMode.dseAndCse);
      expect(identical(home.shownMarket.quotes, home.marketList), isTrue);

      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();
      expect(home.shownMarket, same(Get.find<CseMarketService>()));

      Get.find<ExchangeService>().select(StockExchange.dse);
      await tester.pump();
      expect(identical(home.shownMarket.quotes, home.marketList), isTrue);
      await finish(tester);
    });
  });
}
