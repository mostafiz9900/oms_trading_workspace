import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/core/values/app_config.dart';
import 'package:oms_shared/app/data/services/cse_market_service.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';

import '../../helpers/fake_socket.dart';
import '../../helpers/fake_storage.dart';
import '../../helpers/test_env.dart';

const _cseUrl = 'wss://cse.test/market';

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
    return Get.put<CseMarketService>(CseMarketService());
  }

  Future<void> sends(WidgetTester tester, String json) async {
    sockets.last.serverSends(json);
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
      sockets.single.open();
      await tester.pump();
      expect(sockets.single.uri.toString(), _cseUrl);
      expect(
        WebSocketService.instance.isConnected(AppConfig.cseMarketSocketId),
        isTrue,
      );

      await sends(tester, '{"cs": "end_message"}');
      await sends(tester, '{"ob": 7, "sn": "SQURPHARMA", "g": "PUBLIC", "b": "Main Board", "c": 210.5}');
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
      sockets.single.open();
      await tester.pump();
      await sends(tester, '{"ob": 7, "sn": "SQURPHARMA", "g": "PUBLIC", "b": "Main Board"}');

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
      sockets.single.open();
      await tester.pump();
      await sends(tester, '{"ob": 7, "sn": "SQURPHARMA", "g": "PUBLIC", "b": "Main Board"}');

      service.reconnect();
      await tester.pump();

      expect(service.quotes, isEmpty);
      expect(sockets, hasLength(2));
      expect(sockets.last.uri.toString(), _cseUrl);
      await finish(tester);
    });
  });
}
