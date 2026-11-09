import 'dart:convert';

import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/core/values/storage.dart';
import 'package:oms_shared/app/data/enums/app_enum.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/models/response/user_order.dart';
import 'package:oms_shared/app/data/models/response/user_profile.dart';
import 'package:oms_shared/app/data/repositories/home_repository.dart';
import 'package:oms_shared/app/data/services/cse_market_service.dart';
import 'package:oms_shared/app/data/services/exchange_service.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/data/services/socket_db_service.dart';
import 'package:oms_shared/app/data/services/storage_service.dart';
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

void main() {
  late List<FakeChannel> sockets;
  late HomeController home;

  setUpAll(() async {
    await initTestStorage();
    initTestAppConfig();
  });

  setUp(() async {
    await clearTestStorage();
    await StorageService.save(StorageConstants.token, 'access-token');
    setTestNetwork('wifi');
    sockets = [];
  });

  tearDown(Get.reset);

  /// Builds HomeController the way HomeBinding does, without onInit (which
  /// would open every market socket), plus a signed-in user and a stock.
  Future<void> startApp(WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    final repo = _FakeHomeRepository();
    Get.put<HomeRepository>(repo);
    Get.put(MarketSocketService());
    Get.put(CompaniesController());
    Get.put(MarketIndexController(repo));
    Get.put(
      WebSocketService(
        connector: (uri) => (sockets..add(FakeChannel(uri))).last,
        onlineChanges: const Stream.empty(),
      ),
    );
    home = HomeController(homeRepository: repo)
      ..userInfo = UserProfile(
        id: 42,
        userDetail: UserDetail(
          boId: '1201234567890123',
          investorCode: 'C-100',
          traderId: 7,
          traderCode: 'TR01',
          branchId: 3,
        ),
      )
      ..marketData = const MarketModel(
        shortName: 'GP',
        ticker: 'GP',
        orderBook: 101,
        reference: 300,
        isinCode: 'BD0001GP0001',
        instrumentType: 'EQUITY',
        board: 'PUBLIC',
        shareType: 'a',
        marketType: 'MAIN',
        group: 'public',
      )
      ..selectOrderType = 'Limit';
    // The order-form fields and their total listeners, as onInit/onReady
    // create them.
    home
      ..disclosedQtyTextEditField = TextEditingController()
      ..qtyTextEditField = TextEditingController()
      ..minQtyTextEditField = TextEditingController()
      ..tradPriceTextEditField = TextEditingController();
    home.qtyTextEditField.addListener(home.calculateTotal);
    home.tradPriceTextEditField.addListener(home.calculateTotal);
    home.currentSession.value = 'CONTINUOUS';
    home.qtyTextEditField.text = '500';
    home.tradPriceTextEditField.text = '301.50';
  }

  /// Lets the order socket connect, then returns it.
  Future<FakeChannel> openOrderSocket(WidgetTester tester) async {
    await tester.pump();
    final socket = sockets.single;
    socket.open();
    await tester.pump(const Duration(milliseconds: 200));
    return socket;
  }

  Map<String, dynamic> sentOrder(FakeChannel socket) =>
      jsonDecode(socket.sent.single as String) as Map<String, dynamic>;

  /// Advances fake time in frame-sized steps so snackbar animations run
  /// exactly as on a device.
  Future<void> pumpFor(WidgetTester tester, Duration total) async {
    const step = Duration(milliseconds: 100);
    for (var t = Duration.zero; t < total; t += step) {
      await tester.pump(step);
    }
  }

  /// Ends the test cleanly: socket closed, order timeout elapsed, snackbars
  /// dismissed (GetX keeps them in a global queue across tests).
  Future<void> finish(WidgetTester tester) async {
    await Get.delete<WebSocketService>(force: true);
    await pumpFor(tester, const Duration(seconds: 16));
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  }

  group('placing a new order', () {
    testWidgets('a limit BUY sends one exact order to the gateway', (tester) async {
      await startApp(tester);

      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      expect(home.isOrderConfirmLoading, isTrue, reason: 'button locks at once');
      final socket = await openOrderSocket(tester);

      expect(socket.uri.toString(), startsWith('${testSocketBaseUrl}order/1201234567890123/?token=access-token'));
      final order = sentOrder(socket);
      expect(order, containsPair('action', 'NEW_ORDER_SINGLE_REQUEST'));
      expect(order, containsPair('side', 'BUY'));
      expect(order, containsPair('order_type', 'LIMIT'));
      expect(order, containsPair('qty', 500));
      expect(order, containsPair('price', 301.5));
      expect(order, containsPair('symbol', 'GP'));
      expect(order, containsPair('order_book_id', 101));
      expect(order, containsPair('bo_id', '1201234567890123'));
      expect(order, containsPair('client_code', 'C-100'));
      expect(order, containsPair('trader_pk', 7));
      expect(order, containsPair('trader_id', 'TR01'));
      expect(order, containsPair('branch_id', 3));
      expect(order, containsPair('user_id', 42));
      expect(order, containsPair('session', 'CONTINUOUS'));
      expect(order, containsPair('exchange', 'DSE'));
      expect(order, containsPair('cse_trader_code', null));
      expect(order, containsPair('category', 'A'));
      expect(order, containsPair('group', 'PUBLIC'));
      expect(order, containsPair('timeInForce', '0'));
      expect(order['displayQty'], isNull);
      expect(order['minQty'], isNull);
      expect(home.isOrderConfirmLoading, isTrue, reason: 'waits for the server');

      await finish(tester);
    });

    testWidgets('a SELL is sent as SELL', (tester) async {
      await startApp(tester);
      home.orderConfirmSubmitted(SideType2.SELL, ActionsType.ORDER);
      final socket = await openOrderSocket(tester);
      expect(sentOrder(socket)['side'], 'SELL');
      await finish(tester);
    });

    testWidgets('disclosed and minimum quantities are sent when set', (tester) async {
      await startApp(tester);
      home.disclosedQtyTextEditField.text = '100';
      home.minQtyTextEditField.text = '50';
      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      final socket = await openOrderSocket(tester);
      expect(sentOrder(socket)['displayQty'], 100);
      expect(sentOrder(socket)['minQty'], 50);
      await finish(tester);
    });

    testWidgets('waits up to 3 s for a slow order socket, then sends', (tester) async {
      await startApp(tester);
      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      await tester.pump();
      await pumpFor(tester, const Duration(seconds: 2));
      sockets.single.open();
      await pumpFor(tester, const Duration(milliseconds: 300));

      expect(sockets.single.sent, hasLength(1));
      await finish(tester);
    });

    testWidgets('a double tap sends only one order', (tester) async {
      await startApp(tester);
      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      final socket = await openOrderSocket(tester);
      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      await tester.pump(const Duration(milliseconds: 200));

      expect(sockets, hasLength(1));
      expect(socket.sent, hasLength(1));
      await finish(tester);
    });

    // Current behaviour, reported for review: sendPrice (the market price for
    // a non-LIMIT BUY) is computed but the request uses the typed price.
    testWidgets('a market BUY currently sends the typed price', (tester) async {
      await startApp(tester);
      home.selectOrderType = 'Market';
      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      final socket = await openOrderSocket(tester);
      expect(sentOrder(socket)['order_type'], 'MARKET');
      expect(sentOrder(socket)['price'], 301.5);
      await finish(tester);
    });
  });

  group('server answer', () {
    testWidgets('order_submitted unlocks the button, clears the form, opens Orders', (tester) async {
      await startApp(tester);
      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      final socket = await openOrderSocket(tester);

      socket.serverSends(jsonEncode({'message_type': 'order_submitted', 'message': 'Order placed'}));
      await pumpFor(tester, const Duration(seconds: 1));

      expect(home.isOrderConfirmLoading, isFalse);
      expect(home.qtyTextEditField.text, isEmpty);
      expect(home.tradPriceTextEditField.text, isEmpty);
      expect(home.currentIndex, 4);
      expect(home.currentTabIndexPortfolio, 1);
      expect(find.text('Order placed'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('order_error unlocks the button and keeps the form', (tester) async {
      await startApp(tester);
      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      final socket = await openOrderSocket(tester);

      socket.serverSends(jsonEncode({'message_type': 'order_error', 'message': ['Insufficient balance']}));
      await pumpFor(tester, const Duration(seconds: 1));

      expect(home.isOrderConfirmLoading, isFalse);
      expect(home.qtyTextEditField.text, '500', reason: 'user can fix and retry');
      expect(find.text('Insufficient balance'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('connection and alert messages do not unlock the button', (tester) async {
      await startApp(tester);
      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      final socket = await openOrderSocket(tester);

      socket.serverSends(jsonEncode({'message_type': 'connection', 'message': 'ok'}));
      socket.serverSends(jsonEncode({'message_type': 'alert', 'data': {'status': 'x'}}));
      await pumpFor(tester, const Duration(seconds: 1));

      expect(home.isOrderConfirmLoading, isTrue);
      await finish(tester);
    });

    testWidgets('no answer in 15 s: unlock, warn, and never re-send', (tester) async {
      await startApp(tester);
      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      final socket = await openOrderSocket(tester);

      await pumpFor(tester, const Duration(seconds: 14));
      expect(home.isOrderConfirmLoading, isTrue);
      await pumpFor(tester, const Duration(seconds: 2));

      expect(home.isOrderConfirmLoading, isFalse);
      expect(find.text('No Response'), findsOneWidget);
      expect(socket.sent, hasLength(1));
      await finish(tester);
    });
  });

  group('nothing is sent when', () {
    testWidgets('there is no internet', (tester) async {
      setTestNetwork('none');
      await startApp(tester);

      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      await pumpFor(tester, const Duration(seconds: 1));

      expect(sockets, isEmpty);
      expect(home.isOrderConfirmLoading, isFalse);
      expect(find.text('No Internet'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('the order socket does not connect within 3 s', (tester) async {
      await startApp(tester);

      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      await pumpFor(tester, const Duration(seconds: 4));

      expect(sockets.single.sent, isEmpty);
      expect(home.isOrderConfirmLoading, isFalse);
      expect(find.text('Connection Failed'), findsOneWidget);
      await finish(tester);
    });

    // Current behaviour, reported for review: the parse error is swallowed,
    // so the user sees the button unlock with no message.
    testWidgets('the quantity is empty (silently)', (tester) async {
      await startApp(tester);
      home.qtyTextEditField.clear();

      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      final socket = await openOrderSocket(tester);

      expect(socket.sent, isEmpty);
      expect(home.isOrderConfirmLoading, isFalse);
      await finish(tester);
    });
  });

  group('order form helpers', () {
    testWidgets('price +/- moves in 0.10 steps and never below 0', (tester) async {
      await startApp(tester);
      home.setInitialPrice(300.25);
      expect(home.tradPriceTextEditField.text, '300.25');

      home.incrementTradValue();
      expect(home.tradPriceTextEditField.text, '300.35');

      home.tradPriceTextEditField.text = '0.05';
      home.decrementTradValue();
      expect(home.tradPriceTextEditField.text, '0.00');
      await finish(tester);
    });

    testWidgets('quick-add quantity buttons add to the typed quantity', (tester) async {
      await startApp(tester);
      home.qtyTextEditField.text = '250';
      home.updateQuantity('1K');
      expect(home.qtyTextEditField.text, '1250');
      home.updateQuantity('100');
      expect(home.qtyTextEditField.text, '1350');
      await finish(tester);
    });

    testWidgets('total = quantity x price', (tester) async {
      await startApp(tester);
      home.qtyTextEditField.text = '200';
      home.tradPriceTextEditField.text = '12.50';
      home.calculateTotal();
      expect(home.totalAmount, 2500);
      await finish(tester);
    });
  });

  group('DSE/CSE house', () {
    // One order socket trades both; each order request says which exchange.
    Future<void> onExchange(WidgetTester tester, StockExchange exchange) async {
      initTestAppConfig(exchangeMode: ExchangeMode.dseAndCse);
      addTearDown(initTestAppConfig);
      await startApp(tester);
      Get.put(ExchangeService()).select(exchange);
    }

    testWidgets('CSE selected: the order is sent to CSE with the CSE '
        'trader code', (tester) async {
      await onExchange(tester, StockExchange.cse);
      home.userInfo.userDetail!.cseTraderCode = 'CSE-TR9';

      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      final socket = await openOrderSocket(tester);

      final order = sentOrder(socket);
      expect(order, containsPair('action', 'NEW_ORDER_SINGLE_REQUEST'));
      expect(order, containsPair('exchange', 'CSE'));
      expect(order, containsPair('cse_trader_code', 'CSE-TR9'));
      await finish(tester);
    });

    testWidgets('CSE selected, no CSE trader code: nothing is sent', (
      tester,
    ) async {
      await onExchange(tester, StockExchange.cse);

      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      await pumpFor(tester, const Duration(seconds: 1));

      expect(sockets, isEmpty, reason: 'order socket not even opened');
      expect(home.isOrderConfirmLoading, isFalse);
      expect(find.text(HomeState.cseTraderCodeMissingMessage), findsOneWidget);
      await finish(tester);
    });

    final dseOrder = UserOrder(
      orderId: 'OID-1',
      clientOrderId: 'COID-1',
      orderBookId: 101,
      side: 'BUY',
      limit: 300,
      sentQty: 100,
    );

    final orderActions = <String, void Function()>{
      'modify': () => home.orderConfirmSubmittedReplaceOrder(
        SideType2.BUY,
        ActionsType.REPLACE_ORDER,
        order: dseOrder,
      ),
      'cancel': () => home.orderCancelSubmitted('ORDER_CANCEL_REQUEST', dseOrder),
      'duplicate': () =>
          home.orderDuplicateSubmitted(ActionsType.ORDER, order: dseOrder),
      'status': () => home.orderStatusChangeConfirmSubmitted(
        ActionsType.ORDER_STATUS,
        dseOrder,
      ),
    };

    for (final entry in orderActions.entries) {
      testWidgets('CSE selected: ${entry.key} of a DSE order sends nothing', (
        tester,
      ) async {
        await onExchange(tester, StockExchange.cse);
        home.userInfo.userDetail!.cseTraderCode = 'CSE-TR9';
        home.marketListAll.add(home.marketData);

        entry.value();
        await pumpFor(tester, const Duration(seconds: 2));

        expect(sockets, isEmpty, reason: 'order socket not even opened');
        expect(
          find.text(
            'This order is on DSE. Switch to DSE to modify, cancel or '
            'duplicate it.',
          ),
          findsOneWidget,
        );
        await finish(tester);
      });
    }

    final cseOrder = UserOrder(
      orderId: 'OID-9',
      clientOrderId: 'COID-9',
      orderBookId: 101,
      side: 'BUY',
      limit: 80,
      sentQty: 10,
      exchange: 'CSE',
    );
    final cseOrderActions = <String, void Function()>{
      'modify': () => home.orderConfirmSubmittedReplaceOrder(
        SideType2.BUY,
        ActionsType.REPLACE_ORDER,
        order: cseOrder,
      ),
      'cancel': () => home.orderCancelSubmitted('ORDER_CANCEL_REQUEST', cseOrder),
      'duplicate': () =>
          home.orderDuplicateSubmitted(ActionsType.ORDER, order: cseOrder),
      'status': () => home.orderStatusChangeConfirmSubmitted(
        ActionsType.ORDER_STATUS,
        cseOrder,
      ),
    };

    for (final entry in cseOrderActions.entries) {
      testWidgets('CSE selected: ${entry.key} of a CSE order uses the CSE '
          'stock (same order book id as a DSE one)', (tester) async {
        await onExchange(tester, StockExchange.cse);
        home.userInfo.userDetail!.cseTraderCode = 'CSE-TR9';
        home.marketListAll.add(home.marketData); // DSE GP, order book 101
        final cse = Get.put<CseMarketService>(CseMarketService());
        cse.quotes.add(
          const MarketModel(
            shortName: 'BEXIMCO',
            ticker: 'BEXIMCO',
            orderBook: 101,
            reference: 80,
            isinCode: 'BD0613BXLTD6',
            instrumentType: 'EQ',
            board: 'Main Board',
            shareType: 'A',
            marketType: 'Public',
            group: 'PUBLIC',
          ),
        );
        cse.session.value = 'continuous';
        await tester.pump();

        entry.value();
        await tester.pump();
        final socket = sockets.lastWhere(
          (s) => s.uri.toString().contains('/order/'),
        )..open();
        await pumpFor(tester, const Duration(seconds: 1));

        final sent = sentOrder(socket);
        expect(sent, containsPair('symbol', 'BEXIMCO'));
        expect(sent, containsPair('exchange', 'CSE'));
        expect(sent, containsPair('cse_trader_code', 'CSE-TR9'));
        await finish(tester);
      });
    }

    testWidgets('DSE selected: actions on a CSE order send nothing', (
      tester,
    ) async {
      await onExchange(tester, StockExchange.dse);
      home.marketListAll.add(home.marketData);

      home.orderCancelSubmitted('ORDER_CANCEL_REQUEST', cseOrder);
      await pumpFor(tester, const Duration(seconds: 2));

      expect(sockets, isEmpty);
      expect(
        find.text(
          'This order is on CSE. Switch to CSE to modify, cancel or '
          'duplicate it.',
        ),
        findsOneWidget,
      );
      await finish(tester);
    });

    testWidgets('DSE selected: cancel is sent as before', (tester) async {
      await onExchange(tester, StockExchange.dse);
      home.marketListAll.add(home.marketData);

      home.orderCancelSubmitted('ORDER_CANCEL_REQUEST', dseOrder);
      final socket = await openOrderSocket(tester);
      await pumpFor(tester, const Duration(seconds: 1));

      final sent = jsonDecode(socket.sent.single as String) as Map;
      expect(sent['action'], 'ORDER_CANCEL_REQUEST');
      expect(sent['symbol'], 'GP');
      expect(sent['exchange'], 'DSE');
      expect(sent.containsKey('cse_trader_code'), isTrue);
      expect(sent['cse_trader_code'], isNull);
      await finish(tester);
    });

    testWidgets('DSE selected: the order is sent as before', (tester) async {
      await onExchange(tester, StockExchange.dse);

      home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
      final socket = await openOrderSocket(tester);

      expect(sentOrder(socket), containsPair('symbol', 'GP'));
      await finish(tester);
    });
  });

  group('single-exchange houses trade as before', () {
    for (final mode in [ExchangeMode.dseOnly, ExchangeMode.cseOnly]) {
      testWidgets('${mode.name}: a new order is sent', (tester) async {
        initTestAppConfig(exchangeMode: mode);
        addTearDown(initTestAppConfig);
        await startApp(tester);
        home.userInfo.userDetail!.cseTraderCode = 'CSE-TR9';
        Get.put(ExchangeService());

        home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER);
        final socket = await openOrderSocket(tester);

        final order = sentOrder(socket);
        expect(order, containsPair('symbol', 'GP'));
        final cse = mode == ExchangeMode.cseOnly;
        expect(order, containsPair('exchange', cse ? 'CSE' : 'DSE'));
        expect(order, containsPair('cse_trader_code', cse ? 'CSE-TR9' : null));
        await finish(tester);
      });

      testWidgets('${mode.name}: cancel is sent', (tester) async {
        initTestAppConfig(exchangeMode: mode);
        addTearDown(initTestAppConfig);
        await startApp(tester);
        home.userInfo.userDetail!.cseTraderCode = 'CSE-TR9';
        Get.put(ExchangeService());
        home.marketListAll.add(home.marketData);

        home.orderCancelSubmitted(
          'ORDER_CANCEL_REQUEST',
          UserOrder(orderId: 'OID-1', clientOrderId: 'C-1', orderBookId: 101, side: 'BUY'),
        );
        final socket = await openOrderSocket(tester);
        await pumpFor(tester, const Duration(seconds: 1));

        final cancel = sentOrder(socket);
        expect(cancel, containsPair('action', 'ORDER_CANCEL_REQUEST'));
        final cse = mode == ExchangeMode.cseOnly;
        expect(cancel, containsPair('exchange', cse ? 'CSE' : 'DSE'));
        expect(cancel, containsPair('cse_trader_code', cse ? 'CSE-TR9' : null));
        await finish(tester);
      });
    }
  });

  group('exchange on every order request (one socket for DSE and CSE)', () {
    final order = UserOrder(
      orderId: 'OID-1',
      clientOrderId: 'COID-1',
      orderBookId: 101,
      side: 'BUY',
      limit: 300,
      sentQty: 100,
    );
    final actions = <String, void Function()>{
      'modify': () => home.orderConfirmSubmittedReplaceOrder(
        SideType2.BUY,
        ActionsType.REPLACE_ORDER,
        order: order,
      ),
      'duplicate': () =>
          home.orderDuplicateSubmitted(ActionsType.ORDER, order: order),
      'status': () => home.orderStatusChangeConfirmSubmitted(
        ActionsType.ORDER_STATUS,
        order,
      ),
    };

    for (final entry in actions.entries) {
      testWidgets('DSE: ${entry.key} sends exchange DSE, no CSE trader code', (
        tester,
      ) async {
        await startApp(tester);
        home.userInfo.userDetail!.cseTraderCode = 'CSE-TR9';
        home.marketListAll.add(home.marketData);

        entry.value();
        final socket = await openOrderSocket(tester);
        await pumpFor(tester, const Duration(seconds: 1));

        final sent = sentOrder(socket);
        expect(sent, containsPair('exchange', 'DSE'));
        expect(sent, containsPair('cse_trader_code', null));
        await finish(tester);
      });
    }

    final allActions = <String, void Function()>{
      'new order': () =>
          home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER),
      'cancel': () => home.orderCancelSubmitted('ORDER_CANCEL_REQUEST', order),
      ...actions,
    };
    for (final entry in allActions.entries) {
      testWidgets('CSE: ${entry.key} sends exchange CSE and the CSE trader '
          'code', (tester) async {
        initTestAppConfig(exchangeMode: ExchangeMode.cseOnly);
        addTearDown(initTestAppConfig);
        await startApp(tester);
        home.userInfo.userDetail!.cseTraderCode = 'CSE-TR9';
        home.marketListAll.add(home.marketData);

        entry.value();
        final socket = await openOrderSocket(tester);
        await pumpFor(tester, const Duration(seconds: 1));

        final sent = sentOrder(socket);
        expect(sent, containsPair('exchange', 'CSE'));
        expect(sent, containsPair('cse_trader_code', 'CSE-TR9'));
        await finish(tester);
      });
    }

    final cseOnlyActions = <String, void Function()>{
      'new order': () =>
          home.orderConfirmSubmitted(SideType2.BUY, ActionsType.ORDER),
      'cancel': () => home.orderCancelSubmitted('ORDER_CANCEL_REQUEST', order),
      ...actions,
    };
    for (final entry in cseOnlyActions.entries) {
      testWidgets('CSE without a CSE trader code: ${entry.key} sends nothing', (
        tester,
      ) async {
        initTestAppConfig(exchangeMode: ExchangeMode.cseOnly);
        addTearDown(initTestAppConfig);
        await startApp(tester);
        home.marketListAll.add(home.marketData);

        entry.value();
        await pumpFor(tester, const Duration(seconds: 2));

        expect(sockets, isEmpty, reason: 'order socket not even opened');
        expect(home.isOrderConfirmLoading, isFalse);
        expect(find.text(HomeState.cseTraderCodeMissingMessage), findsOneWidget);
        await finish(tester);
      });
    }
  });
}
