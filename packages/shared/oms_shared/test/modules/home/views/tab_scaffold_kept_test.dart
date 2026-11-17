// ignore_for_file: deprecated_member_use

import 'package:broker_config/broker_config.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart' as legacy show Material, MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/modules/home/controllers/home_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/companies_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/market_index_controller.dart';
import 'package:oms_shared/app/modules/portfolio/views/portfolio_widget.dart';
import 'package:oms_shared/app/modules/quote/views/quote_widget.dart';
import 'package:oms_shared/app/modules/watchlist/views/fav_market_view.dart';

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

/// A home tab used to make a new `GlobalKey<ScaffoldState>` in build, so every
/// bare HomeController.update() (HomeView rebuilds all six tabs) threw the
/// tab's Scaffold away: drawer closed, inner tabs and scroll reset, and the
/// whole tab was built again from scratch.
void main() {
  late HomeController home;

  setUpAll(initTestStorage);

  setUp(() async {
    await clearTestStorage();
    initTestAppConfig(exchangeMode: ExchangeMode.dseOnly);
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
  });

  tearDown(() {
    Get.reset();
    initTestAppConfig();
  });

  final tabs = <String, Widget Function()>{
    'Quote': () => QuoteWidget(),
    'Favourites': () => FavMarketView(),
    'Portfolio': () => PortfolioWidget(),
  };

  for (final MapEntry(key: name, value: tab) in tabs.entries) {
    testWidgets('$name keeps its Scaffold when Home rebuilds', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: GetMaterialApp(
            // As HomeView: a bare GetBuilder making a new tab widget each time.
            home: GetBuilder<HomeController>(builder: (_) => tab()),
            builder: (context, child) => MaterialUiCompatibilityBridge(
              child: legacy.Material(
                type: legacy.MaterialType.transparency,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1));
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      });
      final before = tester.state<ScaffoldState>(find.byType(Scaffold).first);

      home.update();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        tester.state<ScaffoldState>(find.byType(Scaffold).first),
        same(before),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
