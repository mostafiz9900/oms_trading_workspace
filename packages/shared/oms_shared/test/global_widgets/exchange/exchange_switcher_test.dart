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
        home: Scaffold(
          appBar: AppBar(actions: const [ExchangeSwitcher()]),
        ),
      ),
    );
    return service;
  }

  testWidgets('DSE-only house: no switcher, app bar unchanged', (tester) async {
    await pump(tester, ExchangeMode.dseOnly);
    expect(find.byKey(const ValueKey('exchange_switcher')), findsNothing);
    expect(find.text('DSE'), findsNothing);
  });

  testWidgets('CSE-only house: no switcher', (tester) async {
    await pump(tester, ExchangeMode.cseOnly);
    expect(find.byKey(const ValueKey('exchange_switcher')), findsNothing);
  });

  testWidgets('DSE + CSE house: shows DSE and switches to CSE', (tester) async {
    final service = await pump(tester, ExchangeMode.dseAndCse);
    expect(find.text('DSE'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('exchange_switcher')));
    await tester.pumpAndSettle();
    expect(find.text('CSE'), findsOneWidget, reason: 'menu lists CSE');

    await tester.tap(find.text('CSE'));
    await tester.pumpAndSettle();

    expect(service.selected.value, StockExchange.cse);
    expect(find.text('CSE'), findsOneWidget, reason: 'chip now shows CSE');
    expect(find.text('DSE'), findsNothing);
  });
}
