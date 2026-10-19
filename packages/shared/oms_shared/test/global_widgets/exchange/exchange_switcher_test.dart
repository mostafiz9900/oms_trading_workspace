import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/global_widgets/exchange/exchange_switcher.dart';

import '../../helpers/fake_storage.dart';
import '../../helpers/test_env.dart';

void main() {
  setUpAll(initTestStorage);
  setUp(clearTestStorage);
  tearDown(Get.reset);

  Future<ExchangeService> pump(WidgetTester tester, ExchangeMode mode) async {
    initTestAppConfig(exchangeMode: mode);
    final service = Get.put(ExchangeService());
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(appBar: AppBar(actions: const [ExchangeSwitcher()])),
      ),
    );
    return service;
  }

  /// Horizontal centre of the sliding highlight (the AnimatedAlign child).
  double highlightX(WidgetTester tester) => tester
      .getCenter(
        find.descendant(
          of: find.byType(AnimatedAlign),
          matching: find.byType(Container),
        ),
      )
      .dx;

  testWidgets('DSE-only house: no switch, app bar unchanged', (tester) async {
    await pump(tester, ExchangeMode.dseOnly);
    expect(find.byKey(const ValueKey('exchange_switcher')), findsNothing);
    expect(find.text('DSE'), findsNothing);
  });

  testWidgets('hidden switch takes no space, even with padding', (tester) async {
    initTestAppConfig();
    Get.put(ExchangeService());
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [ExchangeSwitcher(padding: EdgeInsets.only(right: 8))],
        ),
      ),
    );
    expect(tester.getSize(find.byType(ExchangeSwitcher)).width, 0);
  });

  testWidgets('CSE-only house: no switch', (tester) async {
    await pump(tester, ExchangeMode.cseOnly);
    expect(find.byKey(const ValueKey('exchange_switcher')), findsNothing);
  });

  testWidgets('DSE + CSE house: both sides shown, DSE highlighted', (
    tester,
  ) async {
    await pump(tester, ExchangeMode.dseAndCse);
    expect(find.text('DSE'), findsOneWidget);
    expect(find.text('CSE'), findsOneWidget);
    expect(
      highlightX(tester),
      tester.getCenter(find.byKey(const ValueKey('exchange_dse'))).dx,
    );
    expect(
      find.byType(PopupMenuButton<StockExchange>),
      findsNothing,
      reason: 'a switch, not a dropdown',
    );
  });

  testWidgets('tapping CSE selects it and slides the highlight', (
    tester,
  ) async {
    final service = await pump(tester, ExchangeMode.dseAndCse);

    await tester.tap(find.byKey(const ValueKey('exchange_cse')));
    await tester.pumpAndSettle();

    expect(service.selected.value, StockExchange.cse);
    expect(
      highlightX(tester),
      tester.getCenter(find.byKey(const ValueKey('exchange_cse'))).dx,
    );

    await tester.tap(find.byKey(const ValueKey('exchange_dse')));
    await tester.pumpAndSettle();
    expect(service.selected.value, StockExchange.dse);
  });

  testWidgets('tapping the selected side changes nothing', (tester) async {
    final service = await pump(tester, ExchangeMode.dseAndCse);
    var changes = 0;
    final worker = ever(service.selected, (_) => changes++);

    await tester.tap(find.byKey(const ValueKey('exchange_dse')));
    await tester.pumpAndSettle();

    expect(changes, 0, reason: 'no needless socket reload');
    worker.dispose();
  });
}
