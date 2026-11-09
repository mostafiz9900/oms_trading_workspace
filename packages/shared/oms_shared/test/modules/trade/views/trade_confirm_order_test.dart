import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/core/utils/helpers/hex_color.dart';
import 'package:oms_shared/app/data/enums/app_enum.dart';
import 'package:oms_shared/app/data/models/order_confirm_holder.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/modules/home/controllers/home_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/companies_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/market_index_controller.dart';
import 'package:oms_shared/app/modules/trade/views/local_widgets/trade_confirm_order.dart';

import '../../../helpers/fake_socket.dart';
import '../../../helpers/fake_storage.dart';
import '../../../helpers/test_env.dart';

class _FakeHomeRepository implements HomeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// HomeController without onInit / onReady (they open sockets, start timers).
class _QuietHomeController extends HomeController {
  _QuietHomeController(HomeRepository repo) : super(homeRepository: repo);

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  // ignore: must_call_super
  Future<void> onReady() async {}
}

void main() {
  setUpAll(initTestStorage);

  setUp(() async {
    await clearTestStorage();
  });

  tearDown(() {
    Get.reset();
    initTestAppConfig();
  });

  Future<void> show(
    WidgetTester tester,
    SideType2 side, {
    ExchangeMode mode = ExchangeMode.dseOnly,
    StockExchange? exchange,
  }) async {
    initTestAppConfig(exchangeMode: mode);
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
    final service = Get.put(ExchangeService());
    if (exchange != null) service.select(exchange);
    Get.put<HomeController>(_QuietHomeController(repo));
    await tester.pumpWidget(
      GetMaterialApp(
        home: TradeConfirmOrders(
          orderConfirm: OrderConfirmHolder(
            marketData: const MarketModel(shortName: 'GP', fullName: 'GP Ltd'),
            price: 300,
            qty: '10',
            orderType: 'Limit',
            validity: 'Day',
            sideType: side,
          ),
        ),
      ),
    );
  }

  /// Colour of the BUY / SELL badge.
  Color? badgeColor(WidgetTester tester, String side) {
    final box = tester
        .widgetList<Container>(
          find.ancestor(of: find.text(side), matching: find.byType(Container)),
        )
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .first;
    return box.color;
  }

  testWidgets('SELL badge is red, BUY badge is green (as the Trade buttons)', (
    tester,
  ) async {
    await show(tester, SideType2.SELL);
    expect(badgeColor(tester, 'SELL'), HexColor('#F70042'));

    await show(tester, SideType2.BUY);
    expect(badgeColor(tester, 'BUY'), HexColor('#22C665'));
  });

  testWidgets('DSE-only house: no Exchange row (page as before)', (
    tester,
  ) async {
    await show(tester, SideType2.BUY);
    expect(find.text('Exchange'), findsNothing);
  });

  testWidgets('DSE + CSE house: shows the exchange the order goes to', (
    tester,
  ) async {
    await show(
      tester,
      SideType2.BUY,
      mode: ExchangeMode.dseAndCse,
      exchange: StockExchange.cse,
    );
    expect(find.text('Exchange'), findsOneWidget);
    expect(find.text('CSE'), findsOneWidget);
  });
}
