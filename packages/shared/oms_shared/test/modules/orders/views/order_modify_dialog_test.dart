import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/models/response/user_order.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/modules/home/controllers/home_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/companies_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/market_index_controller.dart';
import 'package:oms_shared/app/modules/orders/views/local_widgets/order_form_dialog.dart';

import '../../../helpers/fake_socket.dart';
import '../../../helpers/fake_storage.dart';
import '../../../helpers/test_env.dart';

class _FakeHomeRepository implements HomeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _QuietHomeController extends HomeController {
  _QuietHomeController(HomeRepository repo) : super(homeRepository: repo);

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  // ignore: must_call_super
  void onClose() {}
}

void main() {
  late HomeController home;

  setUpAll(initTestStorage);

  setUp(() async {
    await clearTestStorage();
    initTestAppConfig(exchangeMode: ExchangeMode.dseAndCse);
    final repo = _FakeHomeRepository();
    Get.put<HomeRepository>(repo);
    Get.put(MarketSocketService());
    Get.put(CompaniesController());
    Get.put(MarketIndexController(repo));
    Get.put(
      WebSocketService(
        connector: FakeChannel.new,
        onlineChanges: const Stream.empty(),
      ),
    );
    Get.put(ExchangeService()).select(StockExchange.cse);

    home = Get.put<HomeController>(_QuietHomeController(repo));
    home
      ..disclosedQtyTextEditField = TextEditingController()
      ..qtyTextEditField = TextEditingController()
      ..minQtyTextEditField = TextEditingController()
      ..tradPriceTextEditField = TextEditingController();
  });

  tearDown(() {
    home.disclosedQtyTextEditField.dispose();
    home.qtyTextEditField.dispose();
    home.minQtyTextEditField.dispose();
    home.tradPriceTextEditField.dispose();
    Get.reset();
    initTestAppConfig();
  });

  testWidgets(
    'CSE modify price edits and closes without reusing trade field controller',
    (tester) async {
      expect(ExchangeService.current, StockExchange.cse);

      // Keep the main trade price field mounted behind the dialog, as it is in
      // the live app's kept-alive navigation tree.
      await tester.pumpWidget(
        ProviderScope(
          child: GetMaterialApp(
            home: Scaffold(
              body: TextFormField(controller: home.tradPriceTextEditField),
            ),
          ),
        ),
      );

      showOrderFormDialog(
        UserOrder(
          exchange: 'CSE',
          side: 'BUY',
          ordType: 'LIMIT',
          timeInForce: 'DAY',
          sentQty: 10,
          leavesQty: 10,
          limit: 250.50,
        ),
      );
      await tester.pumpAndSettle();

      final priceField = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .firstWhere(
            (field) => field.controller != home.tradPriceTextEditField,
          );
      expect(priceField.controller, isNotNull);
      expect(priceField.controller, isNot(same(home.tradPriceTextEditField)));

      await tester.enterText(find.byWidget(priceField), '251.25');
      await tester.pump();
      expect(tester.takeException(), isNull);

      Get.back();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: GetMaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextFormField(controller: home.qtyTextEditField),
                TextFormField(controller: home.minQtyTextEditField),
                TextFormField(controller: home.disclosedQtyTextEditField),
              ],
            ),
          ),
        ),
      ),
    );
    home.qtyTextEditField.text = '7';
    showOrderFormDialog(
      UserOrder(
        side: 'BUY',
        ordType: 'LIMIT',
        timeInForce: 'DAY',
        sentQty: 10,
        leavesQty: 10,
        minQty: 2,
        displayQty: 3,
        limit: 250.50,
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder dialogField(String hint) => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.ancestor(
      of: find.text(hint),
      matching: find.byType(TextFormField),
    ),
  );

  testWidgets('modify qty fields are the dialog\'s own, prefilled from the '
      'order; typing does not change the Trade page fields', (tester) async {
    await openDialog(tester);

    for (final hint in ['Qty.', 'Min Qty.', 'Disclosed Qty.']) {
      final c = tester.widget<TextFormField>(dialogField(hint)).controller;
      expect(c, isNot(same(home.qtyTextEditField)), reason: hint);
      expect(c, isNot(same(home.minQtyTextEditField)), reason: hint);
      expect(c, isNot(same(home.disclosedQtyTextEditField)), reason: hint);
    }
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.text('10')), findsOneWidget);
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.text('2')), findsOneWidget);
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.text('3')), findsOneWidget);

    await tester.enterText(dialogField('Qty.'), '25');
    await tester.pump();
    expect(home.qtyTextEditField.text, '7');
    expect(tester.takeException(), isNull);

    Get.back();
    await tester.pumpAndSettle();
  });

  testWidgets('Submit hands the dialog values to HomeController', (
    tester,
  ) async {
    setTestNetwork('none'); // stops the request right after the copy
    await openDialog(tester);

    await tester.enterText(dialogField('Qty.'), '25');
    await tester.enterText(dialogField('Min Qty.'), '5');
    await tester.enterText(dialogField('Disclosed Qty.'), '4');
    await tester.tap(find.text('Submit'));
    // Copied before the network check (which awaits).
    expect(home.qtyTextEditField.text, '25');
    expect(home.minQtyTextEditField.text, '5');
    expect(home.disclosedQtyTextEditField.text, '4');
    expect(home.tradPriceTextEditField.text, '250.5');
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  testWidgets('Cancel still clears the Trade page fields', (tester) async {
    await openDialog(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(home.qtyTextEditField.text, '');
    expect(home.minQtyTextEditField.text, '');
    expect(home.disclosedQtyTextEditField.text, '');
  });
}
