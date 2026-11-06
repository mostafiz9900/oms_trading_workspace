import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/models/response/position_response.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/services/cse_market_service.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/modules/home/controllers/home_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/companies_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/market_index_controller.dart';
import 'package:oms_shared/app/modules/portfolio/controllers/position_controller.dart';

import '../../helpers/fake_socket.dart';
import '../../helpers/fake_storage.dart';
import '../../helpers/test_env.dart';

class _FakeHomeRepository implements HomeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MarketModel _quote(String isin, double last) =>
    MarketModel(isinCode: isin, last: last, group: 'PUBLIC');

/// Benemoy Position tab, 2026-11-01: 4 holdings, row 2 sold 20,000 today
/// (initial_quantity stays 68,620; total_qty and total_cost drop to 48,620).
final _positions = [
  PositionModel(
    isin: 'A',
    initialQuantity: 160000,
    totalQty: 160000,
    avgPrice: 19.9948,
    totalCost: 3199168.00,
  ),
  PositionModel(
    isin: 'B',
    initialQuantity: 68620,
    totalQty: 48620,
    intradaySellQuantity: 20000,
    avgPrice: 53.306,
    totalCost: 2591737.72,
  ),
  PositionModel(
    isin: 'C',
    initialQuantity: 50000,
    totalQty: 50000,
    avgPrice: 26.4043,
    totalCost: 1320215.00,
  ),
  PositionModel(
    isin: 'D',
    initialQuantity: 9005,
    totalQty: 9005,
    avgPrice: 3494593.76 / 9005,
    totalCost: 3494593.76,
  ),
];

void main() {
  late HomeController home;

  setUpAll(initTestStorage);
  setUp(clearTestStorage);
  tearDown(Get.reset);

  Future<PositionController> start(WidgetTester tester) async {
    initTestAppConfig();
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    final repo = _FakeHomeRepository();
    Get.put<HomeRepository>(repo);
    Get.put(ExchangeService());
    Get.put(MarketSocketService());
    Get.put(CompaniesController());
    Get.put(MarketIndexController(repo));
    Get.put(
      WebSocketService(
        connector: FakeChannel.new,
        onlineChanges: const Stream.empty(),
      ),
    );
    Get.put<CseMarketService>(CseMarketService());
    home = Get.put<HomeController>(HomeController(homeRepository: repo));
    await tester.pump();
    home.marketList.assignAll([
      _quote('A', 19.60),
      _quote('B', 53.10),
      _quote('C', 23.10),
      _quote('D', 410.90),
    ]);
    final positions = Get.put<PositionController>(_PositionsWithoutLoad());
    positions.positions = PositionResponse(data: _positions);
    return positions;
  }

  Future<void> finish(WidgetTester tester) async {
    await Get.delete<WebSocketService>(force: true);
    await tester.pump(const Duration(seconds: 6));
  }

  // Formulas since 2026-11-02 (f9c833e): market value = Σ total_qty × last;
  // top-summary cost = Σ total_cost (same as Account Summary).

  testWidgets('market value: total_qty × last (after the intraday sell)', (
    tester,
  ) async {
    final positions = await start(tester);

    // 160,000×19.60 + 48,620×53.10 + 50,000×23.10 + 9,005×410.90
    expect(positions.currentPortfolioValue, closeTo(10572876.50, 0.01));
    await finish(tester);
  });

  testWidgets('top summary: cost = Σ total_cost, gain = market value − cost', (
    tester,
  ) async {
    final positions = await start(tester);

    expect(positions.summaryCost, closeTo(10605714.48, 0.01));
    expect(positions.summaryGain, closeTo(-32837.98, 0.01));
    expect(positions.summaryGainPercentage, closeTo(-0.3096, 0.0001));
    await finish(tester);
  });

  testWidgets('Account Summary: Σ total_cost, same gain as the top summary', (
    tester,
  ) async {
    final positions = await start(tester);

    expect(positions.totalInvestment, closeTo(10605714.48, 0.01));
    expect(positions.totalUnrealizedPnL, closeTo(-32837.98, 0.01));
    expect(positions.totalUnrealizedPnL, closeTo(positions.summaryGain, 1e-6));
    await finish(tester);
  });

  testWidgets('intraday buy: counted through total_qty and total_cost', (
    tester,
  ) async {
    final positions = await start(tester);
    positions.positions = PositionResponse(
      data: [
        PositionModel(
          isin: 'A',
          initialQuantity: 1000,
          intradayBuyQuantity: 500,
          totalQty: 1500,
          avgPrice: 20,
          intradayBuyPriceAvg: 18,
          totalCost: 1000 * 20 + 500 * 18,
        ),
      ],
    );

    expect(positions.currentPortfolioValue, closeTo(1500 * 19.60, 0.001));
    expect(positions.summaryCost, closeTo(29000, 0.001));
    expect(positions.summaryGain, closeTo(29400 - 29000, 0.001));
    await finish(tester);
  });
}

class _PositionsWithoutLoad extends PositionController {
  @override
  // ignore: must_call_super
  void onInit() {}
}
