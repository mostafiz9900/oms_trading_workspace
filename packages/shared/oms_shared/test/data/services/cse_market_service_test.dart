import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/core/utils/extensions/market_model_extensions.dart';
import 'package:oms_shared/app/core/values/app_config.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/services/cse_market_service.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';

import '../../helpers/fake_socket.dart';
import '../../helpers/fake_storage.dart';
import '../../helpers/test_env.dart';

const _cseUrl = 'wss://cse.test/market';
const _cseDepthUrl = 'wss://cse.test/marketdepth';
const _cseTsUrl = 'wss://cse.test/events';

void main() {
  late List<FakeChannel> sockets;

  setUpAll(initTestStorage);

  setUp(() async {
    await clearTestStorage();
    sockets = [];
  });

  tearDown(Get.reset);

  Future<CseMarketService> start(WidgetTester tester, ExchangeMode mode) async {
    initTestAppConfig(
      exchangeMode: mode,
      extra: const {
        'OMS_CSE_SOCKET_MARKET_URL': _cseUrl,
        'OMS_CSE_SOCKET_MARKET_DEPTH_URL': _cseDepthUrl,
        'OMS_CSE_SOCKET_NEWS_TIME_SALES_URL': _cseTsUrl,
      },
    );
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    Get.put(ExchangeService());
    Get.put(
      WebSocketService(
        connector: (uri) => (sockets..add(FakeChannel(uri))).last,
        onlineChanges: const Stream.empty(),
      ),
    );
    return Get.put<CseMarketService>(CseMarketService());
  }

  /// The CSE market socket (the depth socket opens right after it).
  FakeChannel market() => sockets.lastWhere((s) => s.uri.toString() == _cseUrl);

  Future<void> sends(WidgetTester tester, String json) async {
    market().serverSends(json);
    await tester.pump(CseMarketService.flushInterval);
  }

  Future<void> finish(WidgetTester tester) async {
    await Get.delete<WebSocketService>(force: true);
    await tester.pump(const Duration(seconds: 2));
  }

  for (final mode in [ExchangeMode.dseOnly, ExchangeMode.cseOnly]) {
    testWidgets('${mode.name}: never opens a socket', (tester) async {
      final service = await start(tester, mode);
      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();

      expect(sockets, isEmpty);
      expect(service.isOpen, isFalse);
      await finish(tester);
    });
  }

  group('DSE and CSE', () {
    testWidgets('DSE selected: no CSE socket (only DSE open, as before)', (
      tester,
    ) async {
      final service = await start(tester, ExchangeMode.dseAndCse);
      await tester.pump();

      expect(sockets, isEmpty);
      expect(service.isOpen, isFalse);
      await finish(tester);
    });

    testWidgets('CSE selected: its own socket on the CSE URL, quotes filled', (
      tester,
    ) async {
      final service = await start(tester, ExchangeMode.dseAndCse);

      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();
      market().open();
      await tester.pump();
      expect(market().uri.toString(), _cseUrl);
      expect(
        WebSocketService.instance.isConnected(AppConfig.cseMarketSocketId),
        isTrue,
      );

      await sends(tester, '{"cs": "end_message"}');
      await sends(
        tester,
        '{"ob": 7, "sn": "SQURPHARMA", "g": "PUBLIC", "b": "Main Board", "c": 210.5}',
      );
      await sends(tester, '{"ob": 7, "lp": 211.0}'); // partial update merges

      expect(service.quotes.single.shortName, 'SQURPHARMA');
      expect(service.quotes.single.last, 211.0);
      await finish(tester);
    });

    testWidgets('back to DSE: CSE socket closed and its quotes dropped', (
      tester,
    ) async {
      final service = await start(tester, ExchangeMode.dseAndCse);
      final exchange = Get.find<ExchangeService>();
      exchange.select(StockExchange.cse);
      await tester.pump();
      market().open();
      await tester.pump();
      await sends(
        tester,
        '{"ob": 7, "sn": "SQURPHARMA", "g": "PUBLIC", "b": "Main Board"}',
      );

      exchange.select(StockExchange.dse);
      await tester.pump();

      expect(service.isOpen, isFalse);
      expect(service.quotes, isEmpty);
      expect(
        WebSocketService.instance.isConnected(AppConfig.cseMarketSocketId),
        isFalse,
      );
      await finish(tester);
    });

    testWidgets('reconnect drops the quotes and opens a new socket', (
      tester,
    ) async {
      final service = await start(tester, ExchangeMode.dseAndCse);
      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();
      market().open();
      await tester.pump();
      await sends(
        tester,
        '{"ob": 7, "sn": "SQURPHARMA", "g": "PUBLIC", "b": "Main Board"}',
      );

      service.reconnect();
      await tester.pump();

      expect(service.quotes, isEmpty);
      expect(sockets.where((s) => s.uri.toString() == _cseUrl), hasLength(2));
      await finish(tester);
    });

    testWidgets('Market tab figures: session, marquee, charts, sectors', (
      tester,
    ) async {
      final service = await start(tester, ExchangeMode.dseAndCse);
      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();
      market().open();
      await tester.pump();

      market().serverSends('{"cs": "CONTINUOUS"}');
      market().serverSends(
        '{"ob": 2, "sn": "ZETA", "g": "PUBLIC", "b": "Main Board", '
        '"sc": "Bank", "st": "A", "it": "EQ", "v": 100, "lp": 10, "r": 9}',
      );
      market().serverSends(
        '{"ob": 1, "sn": "ALPHA", "g": "PUBLIC", "b": "Main Board", '
        '"sc": "IT", "st": "B", "it": "EQ", "v": 50, "lp": 5, "r": 5}',
      );
      market().serverSends(
        '{"ob": 3, "sn": "BOND", "g": "DEBT", "b": "Main Board", "sc": "Bond"}',
      );
      await tester.pump(CseMarketService.flushInterval);

      expect(service.session.value, 'CONTINUOUS');
      expect(service.marqueeList.map((m) => m.shortName), [
        'ALPHA',
        'ZETA',
      ], reason: 'PUBLIC only, sorted by name');
      expect(service.chartData, isNotEmpty);
      expect(service.sectorSummaryList, isNotEmpty);

      Get.find<ExchangeService>().select(StockExchange.dse);
      await tester.pump();
      expect(service.session.value, isEmpty);
      expect(service.marqueeList, isEmpty);
      expect(service.chartData, isEmpty);
      expect(service.sectorSummaryList, isEmpty);
      await finish(tester);
    });
  });

  group('CSE tick → DSE values', () {
    test('instrument type EQUITY / Mutual Fund → EQ / MF', () {
      expect(CseMarketService.normalizeCseTick({'it': 'EQUITY'})['it'], 'EQ');
      expect(
        CseMarketService.normalizeCseTick({'it': 'Mutual Fund'})['it'],
        'MF',
      );
      expect(CseMarketService.normalizeCseTick({'it': 'OPT'})['it'], 'OPT');
    });

    test('close = last traded price once there is one', () {
      // ASIAPACINS on CSE UAT: lp 53, c and r 48, d 10.4 %.
      final tick = CseMarketService.normalizeCseTick({
        'lp': 53,
        'c': 48,
        'r': 48,
      });
      expect(tick['c'], 53);
      expect(
        MarketModel.fromJson({'ob': 1, ...tick}).percentageChange,
        closeTo(10.4167, 0.001),
      );
    });

    test('no trade yet (lp 0): close stays as sent', () {
      expect(CseMarketService.normalizeCseTick({'lp': 0, 'c': 48})['c'], 48);
    });

    test('partial tick without lp keeps the close it has', () {
      expect(
        CseMarketService.normalizeCseTick({'c': 48}).containsKey('c'),
        isFalse,
      );
    });
  });

  group('CSE market depth', () {
    FakeChannel depthSocket(List<FakeChannel> all) =>
        all.lastWhere((s) => s.uri.toString() == _cseDepthUrl);

    testWidgets('own socket; subscribes the stock, re-sent on connect', (
      tester,
    ) async {
      final service = await start(tester, ExchangeMode.dseAndCse);
      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();

      service.sendDepth('subscribe', 7); // before the socket is open
      final socket = depthSocket(sockets)..open();
      await tester.pump();

      expect(socket.sent, ['{"type":"subscribe","ob":7}']);
      await finish(tester);
    });

    testWidgets('depth of the subscribed stock only; dropped on DSE', (
      tester,
    ) async {
      final service = await start(tester, ExchangeMode.dseAndCse);
      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();
      service.sendDepth('subscribe', 7);

      service.onDepthMessage(
        '{"9": {"buy": [{"price": 1, "qty": 1}], "sell": []}}',
      );
      expect(service.buys, isEmpty, reason: 'not the subscribed stock');

      service.onDepthMessage(
        '{"7": {"buy": [{"price": 10, "qty": 100}], '
        '"sell": [{"price": 11, "qty": 50}]}, "msg": "md", "ob": 7}',
      );
      expect(service.buys, hasLength(1));
      expect(service.sells, hasLength(1));

      Get.find<ExchangeService>().select(StockExchange.dse);
      await tester.pump();
      expect(service.buys, isEmpty);
      expect(service.sells, isEmpty);
      await finish(tester);
    });
  });

  group('app background / logout (like the DSE sockets)', () {
    List<FakeChannel> at(String url) =>
        sockets.where((s) => s.uri.toString() == url).toList();

    testWidgets('suspend closes both sockets, keeps quotes and depth', (
      tester,
    ) async {
      final service = await start(tester, ExchangeMode.dseAndCse);
      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();
      market().open();
      await tester.pump();
      await sends(
        tester,
        '{"ob": 7, "sn": "GP", "g": "PUBLIC", "b": "Main Board"}',
      );
      service.sendDepth('subscribe', 7);
      service.onDepthMessage('{"7": {"buy": [{"p": 10, "q": 1}], "sell": []}}');

      service.suspend();

      final ws = Get.find<WebSocketService>();
      expect(ws.isConnected(AppConfig.cseMarketSocketId), isFalse);
      expect(ws.isConnected(AppConfig.cseMarketDepthSocketId), isFalse);
      expect(service.isOpen, isFalse);
      expect(service.quotes, hasLength(1), reason: 'kept, as DSE lists are');
      expect(service.buys, hasLength(1));
      await finish(tester);
    });

    testWidgets('resume reconnects and re-subscribes the depth stock', (
      tester,
    ) async {
      final service = await start(tester, ExchangeMode.dseAndCse);
      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();
      service.sendDepth('subscribe', 7);
      service.suspend();
      final before = at(_cseDepthUrl).length;

      service.resume();
      await tester.pump();
      final depth = at(_cseDepthUrl).last..open();
      await tester.pump();

      expect(at(_cseDepthUrl), hasLength(before + 1));
      expect(at(_cseUrl), hasLength(2));
      expect(service.isOpen, isTrue);
      expect(depth.sent, ['{"type":"subscribe","ob":7}']);
      await finish(tester);
    });

    testWidgets('on DSE: suspend / resume open nothing', (tester) async {
      final service = await start(tester, ExchangeMode.dseAndCse);

      service.suspend();
      service.resume();
      await tester.pump();

      expect(sockets, isEmpty);
      await finish(tester);
    });

    testWidgets('switching to DSE while suspended drops the CSE data', (
      tester,
    ) async {
      final service = await start(tester, ExchangeMode.dseAndCse);
      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();
      market().open();
      await sends(
        tester,
        '{"ob": 7, "sn": "GP", "g": "PUBLIC", "b": "Main Board"}',
      );
      service.suspend();

      Get.find<ExchangeService>().select(StockExchange.dse);
      await tester.pump();
      service.resume();
      await tester.pump();

      expect(service.quotes, isEmpty);
      expect(service.isSuspended, isFalse);
      expect(service.isOpen, isFalse);
      await finish(tester);
    });
  });

  group('CSE time & sales', () {
    FakeChannel tsSocket() =>
        sockets.lastWhere((s) => s.uri.toString() == _cseTsUrl);

    Future<CseMarketService> onCse(WidgetTester tester) async {
      final service = await start(tester, ExchangeMode.dseAndCse);
      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();
      return service;
    }

    testWidgets('own socket; tsm / tsb / news_hist re-sent on connect', (
      tester,
    ) async {
      final service = await onCse(tester);

      service.subscribeTimeSales('tsm', '01', '7');
      service.subscribeTimeSales('tsb', '02', '7');
      service.subscribeTimeSales('news_hist', '04', '7');
      final socket = tsSocket()..open();
      await tester.pump();

      expect(socket.sent, [
        '{"ac":"subscribe","tp":"tsm","tid":1,"ob":7}',
        '{"ac":"subscribe","tp":"tsb","tid":2,"ob":7}',
        '{"ac":"subscribe","tp":"news_hist","tid":4,"ob":7}',
      ]);
      await finish(tester);
    });

    testWidgets('a new stock replaces the subscription of the same tp', (
      tester,
    ) async {
      final service = await onCse(tester);
      service.subscribeTimeSales('tsm', '01', '7');
      service.subscribeTimeSales('tsm', '01', '9');
      final socket = tsSocket()..open();
      await tester.pump();

      expect(socket.sent, ['{"ac":"subscribe","tp":"tsm","tid":1,"ob":9}']);
      await finish(tester);
    });

    testWidgets('messages fill the lists like DSE; dropped on DSE', (
      tester,
    ) async {
      final service = await onCse(tester);

      service.onTimeSalesMessage(
        '{"tp": "tsm", "d": [{"p": 10, "q": 5}, {"p": 11, "q": 6}]}',
      );
      service.onTimeSalesMessage('{"tp": "tsm", "d": {"p": 12, "q": 7}}');
      service.onTimeSalesMessage('{"tp": "tsb", "d": [{"p": 9, "q": 1}]}');
      service.onTimeSalesMessage('{"tp": "news_hist", "d": [{"title": "N"}]}');

      expect(service.timeAndSales.map((t) => t.p), [12, 10, 11]);
      expect(service.timeAndSalesHistory, hasLength(1));
      expect(service.newsSingleItem, hasLength(1));

      Get.find<ExchangeService>().select(StockExchange.dse);
      await tester.pump();
      expect(service.timeAndSales, isEmpty);
      expect(service.timeAndSalesHistory, isEmpty);
      expect(service.newsSingleItem, isEmpty);
      await finish(tester);
    });

    testWidgets('no CSE time & sales URL: no socket opened', (tester) async {
      initTestAppConfig(
        exchangeMode: ExchangeMode.dseAndCse,
        extra: const {'OMS_CSE_SOCKET_MARKET_URL': _cseUrl},
      );
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
      Get.put(ExchangeService());
      Get.put(
        WebSocketService(
          connector: (uri) => (sockets..add(FakeChannel(uri))).last,
          onlineChanges: const Stream.empty(),
        ),
      );
      Get.put<CseMarketService>(CseMarketService());
      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();

      expect(sockets.map((s) => s.uri.toString()), [_cseUrl]);
      await finish(tester);
    });
  });
}
