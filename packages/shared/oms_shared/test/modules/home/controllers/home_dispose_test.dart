import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/modules/home/controllers/home_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/companies_controller.dart';
import 'package:oms_shared/app/modules/market/controllers/market_index_controller.dart';

import '../../../helpers/fake_socket.dart';
import '../../../helpers/fake_storage.dart';
import '../../../helpers/test_env.dart';

class _FakeHomeRepository implements HomeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// HomeController without onInit / onReady (sockets, timers); its order form
/// fields are created here as onInit creates them. onClose is the real one.
class _QuietHomeController extends HomeController {
  _QuietHomeController(HomeRepository repo) : super(homeRepository: repo) {
    disclosedQtyTextEditField = TextEditingController();
    qtyTextEditField = TextEditingController();
    minQtyTextEditField = TextEditingController();
    tradPriceTextEditField = TextEditingController();
    tradePriceFocusNode = FocusNode();
  }

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  // ignore: must_call_super
  Future<void> onReady() async {}
}

void main() {
  setUpAll(() async {
    await initTestStorage();
    initTestAppConfig();
  });

  tearDown(Get.reset);

  testWidgets('login: the old Home can use its fields during the route '
      'transition; they are disposed afterwards', (tester) async {
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
    final home = Get.put<HomeController>(_QuietHomeController(repo));
    final qty = home.qtyTextEditField;
    final price = home.tradPriceTextEditField;
    final focus = home.tradePriceFocusNode;

    // The old Home's Trade fields, redrawn every frame (route animation).
    final tick = ValueNotifier(0);
    final showOldHome = ValueNotifier(true);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: showOldHome,
            builder: (_, show, _) => !show
                ? const SizedBox()
                : ValueListenableBuilder<int>(
                    valueListenable: tick,
                    builder: (_, _, _) => Column(
                      children: [
                        TextField(controller: qty),
                        TextField(controller: price, focusNode: focus),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );

    // AuthController after a login: delete HomeController, then replace the
    // route; the old Home stays on screen for the transition (~500 ms here).
    Get.delete<HomeController>(force: true);
    for (var ms = 0; ms < 500; ms += 16) {
      tick.value++;
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(tester.takeException(), isNull);

    // Transition over: old Home gone; the fields are disposed in time.
    showOldHome.value = false;
    await tester.pump();
    await tester.pump(HomeController.fieldsDisposeDelay);
    expect(() => qty.addListener(() {}), throwsFlutterError);
    expect(() => focus.addListener(() {}), throwsFlutterError);
  });
}
