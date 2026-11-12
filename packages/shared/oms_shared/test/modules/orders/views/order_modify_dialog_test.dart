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
}
