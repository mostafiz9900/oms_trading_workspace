import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/models/response/market_depth_model.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/models/response/user_order.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/modules/home/controllers/home_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/companies_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/market_index_controller.dart';
import 'package:oms_shared/app/modules/orders/views/local_widgets/order_form_dialog.dart';
import 'package:oms_shared/app/modules/trade/views/trade_widget.dart';

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
  Future<void> onReady() async {}

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
    Get.put(ExchangeService());
    home = Get.put<HomeController>(_QuietHomeController(repo));
    home
      ..disclosedQtyTextEditField = TextEditingController()
      ..qtyTextEditField = TextEditingController()
      ..minQtyTextEditField = TextEditingController()
      ..tradPriceTextEditField = TextEditingController()
      ..tradePriceFocusNode = FocusNode()
      ..marketData = const MarketModel(shortName: 'GP', fullName: 'GP Ltd');
    home.qtyTextEditField.addListener(home.calculateTotal);
    home.tradPriceTextEditField.addListener(home.calculateTotal);
  });

  tearDown(() {
    Get.reset();
    initTestAppConfig();
  });

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: GetMaterialApp(
          home: GetBuilder<HomeController>(
            builder: (c) => Scaffold(
              body: IndexedStack(
                index: 1,
                children: const [SizedBox(), TradeWidget()],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  void keyboard(WidgetTester tester, bool open) {
    tester.view.viewInsets = open
        ? const FakeViewPadding(bottom: 900)
        : FakeViewPadding.zero;
  }

  void depth(int rows) {
    home
      ..buys = [
        for (var i = 0; i < rows; i++)
          MarketDepthModel(q: 10 + i, p: 100.0 - i, o: 1),
      ]
      ..sells = [
        for (var i = 0; i < rows + 1; i++)
          MarketDepthModel(q: 5 + i, p: 101.0 + i, o: 1),
      ];
    home.update(['market_depth']);
  }

  Finder field(String hint) =>
      find.ancestor(of: find.text(hint), matching: find.byType(TextFormField));

  testWidgets('Trade page: buttons + keyboard + live rebuilds', (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(tester.view.resetViewInsets);
    await pumpHome(tester);

    for (var round = 0; round < 12; round++) {
      depth(round % 7);
      await tester.pump();
      if (round.isOdd && find.text('Show More').evaluate().isNotEmpty) {
        await tester.tap(find.text('Show More'), warnIfMissed: false);
      }
      final price = find.byType(TextFormField).at(3);
      await tester.drag(
        find.byType(CustomScrollView),
        Offset(0, round.isEven ? -200 : 120),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.tap(price, warnIfMissed: false);
      await tester.showKeyboard(price);
      keyboard(tester, true);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('100'), warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add), warnIfMissed: false);
      home.update();
      await tester.pump();
      await tester.enterText(price, '12.3');
      home.update(['market_depth', 'trade_ticker_data', 'trade_root']);
      await tester.pump(const Duration(milliseconds: 16));
      depth((round + 3) % 9);
      await tester.tap(find.text('1K'), warnIfMissed: false);
      await tester.tap(price, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.tap(find.byIcon(Icons.minimize), warnIfMissed: false);
      keyboard(tester, false);
      home.update();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull, reason: 'round $round');
    }
    semantics.dispose();
  });

  testWidgets('Modify dialog over Trade: buttons + keyboard', (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(tester.view.resetViewInsets);
    await pumpHome(tester);

    showOrderFormDialog(
      UserOrder(
        side: 'BUY',
        ordType: 'LIMIT',
        timeInForce: 'DAY',
        sentQty: 10,
        leavesQty: 10,
        limit: 250.5,
      ),
    );
    await tester.pumpAndSettle();
    final dialog = find.byType(AlertDialog);
    final qty = find.descendant(of: dialog, matching: field('Qty.'));
    final price = find
        .descendant(of: dialog, matching: find.byType(TextFormField))
        .last;

    for (var round = 0; round < 6; round++) {
      await tester.tap(qty, warnIfMissed: false);
      await tester.showKeyboard(qty);
      keyboard(tester, true);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(qty, '${round + 5}');
      home.update();
      await tester.pump();
      await tester.tap(price, warnIfMissed: false);
      await tester.showKeyboard(price);
      await tester.tap(
        find.descendant(of: dialog, matching: find.byIcon(Icons.add)),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.tap(
        find.descendant(of: dialog, matching: find.byIcon(Icons.remove)),
        warnIfMissed: false,
      );
      await tester.enterText(price, '251.2');
      home.update(['order_modify_dialog']);
      keyboard(tester, false);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull, reason: 'round $round');
    }
    semantics.dispose();
  });
}
