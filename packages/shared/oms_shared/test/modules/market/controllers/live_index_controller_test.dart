import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/modules/market/controllers/live_index_controller.dart';

import '../../../helpers/fake_socket.dart';
import '../../../helpers/fake_storage.dart';
import '../../../helpers/test_env.dart';

void main() {
  late List<FakeChannel> sockets;

  setUpAll(initTestStorage);

  setUp(() async {
    await clearTestStorage();
    sockets = [];
  });

  tearDown(Get.reset);

  /// Index controller of a house on [mode], index socket open.
  Future<LiveIndexController> start(
    WidgetTester tester,
    ExchangeMode mode,
  ) async {
    initTestAppConfig(exchangeMode: mode);
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    Get.put(ExchangeService());
    Get.put(
      WebSocketService(
        connector: (uri) => (sockets..add(FakeChannel(uri))).last,
        onlineChanges: const Stream.empty(),
      ),
    );
    final controller = Get.put(LiveIndexController());
    await tester.pump();
    sockets.last.open();
    await tester.pump();
    return controller;
  }

  Future<void> sends(WidgetTester tester, String sn) async {
    sockets.last.serverSends('{"sn": "$sn", "civ": 100, "u": 5, "d": 3}');
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> finish(WidgetTester tester) async {
    await Get.delete<WebSocketService>(force: true);
    await tester.pump(const Duration(seconds: 2));
  }

  group('DSE only (as before)', () {
    testWidgets('starts on DSEX and keeps it, whatever else arrives', (
      tester,
    ) async {
      final index = await start(tester, ExchangeMode.dseOnly);
      expect(index.selectedSn, 'DSEX');

      await sends(tester, 'DS30');
      await sends(tester, 'CASPI');

      expect(index.selectedSn, 'DSEX');
      expect(index.newArr?.sn, 'DSEX');
      await finish(tester);
    });
  });

  group('CSE only', () {
    testWidgets('starts on CASPI and follows it when the feed sends it', (
      tester,
    ) async {
      final index = await start(tester, ExchangeMode.cseOnly);
      expect(index.selectedSn, 'CASPI');

      await sends(tester, 'CASPI');

      expect(index.selectedSn, 'CASPI');
      expect(index.newArr?.u, 5, reason: 'advance/decline of CASPI');
      await finish(tester);
    });

    testWidgets('feed with other names: its first index is selected, the '
        'main one once it arrives', (tester) async {
      final index = await start(tester, ExchangeMode.cseOnly);

      await sends(tester, 'CSE30');
      expect(index.selectedSn, 'CSE30');

      await sends(tester, 'CASPI');
      expect(index.selectedSn, 'CASPI');
      await finish(tester);
    });

    testWidgets('an index the user picked is kept', (tester) async {
      final index = await start(tester, ExchangeMode.cseOnly);
      await sends(tester, 'CASPI');
      await sends(tester, 'CSE30');

      index.selectSn('CSE30');
      await sends(tester, 'CASPI');

      expect(index.selectedSn, 'CSE30');
      await finish(tester);
    });
  });

  group('DSE and CSE', () {
    testWidgets('switching to CSE starts on its main index, without the '
        'DSE chart', (tester) async {
      final index = await start(tester, ExchangeMode.dseAndCse);
      await sends(tester, 'DSEX');
      index.selectSn('DS30');

      Get.find<ExchangeService>().select(StockExchange.cse);
      await tester.pump();

      expect(index.selectedSn, 'CASPI');
      expect(index.indexList, isEmpty);
      expect(index.indexCandleList, isEmpty);
      await finish(tester);
    });

    testWidgets('and back to DSE: DSEX again', (tester) async {
      final index = await start(tester, ExchangeMode.dseAndCse);
      final exchange = Get.find<ExchangeService>();

      exchange.select(StockExchange.cse);
      await tester.pump();
      exchange.select(StockExchange.dse);
      await tester.pump();

      expect(index.selectedSn, 'DSEX');
      await finish(tester);
    });
  });
}
