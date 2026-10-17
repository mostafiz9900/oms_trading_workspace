import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/data/enums/app_enum.dart';
import 'package:oms_shared/app/data/models/request/order_confirm_request.dart';

/// The JSON built here is what the order socket sends to the exchange
/// gateway. A renamed or missing key means a rejected (or wrong) order.
void main() {
  OrderConfirmRequest buyLimit() => OrderConfirmRequest(
    action: actionValues[ActionsType.ORDER],
    traderPk: 7,
    traderId: 'TR01',
    boId: '1201234567890123',
    clientCode: 'C-100',
    branchId: 3,
    userId: 42,
    orderType: 'LIMIT',
    qty: 500,
    price: 101.5,
    symbol: 'GP',
    side: sideTypeEnumMap[SideType2.BUY],
    isin: 'BD0001GP0001',
    assetClass: 'EQUITY',
    securityCode: 'GP',
    orderBookId: 101,
    board: 'PUBLIC',
    session: 'CONTINUOUS',
    category: 'A',
    marketType: 'MAIN',
    group: 'PUBLIC',
    timeInForce: '0',
  );

  group('new order (toJson)', () {
    test('sends exactly the gateway keys, in snake_case', () {
      expect(buyLimit().toJson().keys.toList(), [
        'action',
        'trader_pk',
        'trader_id',
        'bo_id',
        'client_code',
        'branch_id',
        'user_id',
        'order_type',
        'qty',
        'price',
        'symbol',
        'side',
        'isin',
        'asset_class',
        'security_code',
        'order_book_id',
        'board',
        'session',
        'category',
        'market_type',
        'group',
        'timeInForce',
        'displayQty',
        'execInst',
        'minQty',
      ]);
    });

    test('carries the order values unchanged', () {
      final json = buyLimit().toJson();
      expect(json['action'], 'NEW_ORDER_SINGLE_REQUEST');
      expect(json['side'], 'BUY');
      expect(json['order_type'], 'LIMIT');
      expect(json['qty'], 500);
      expect(json['price'], 101.5);
      expect(json['order_book_id'], 101);
      expect(json['bo_id'], '1201234567890123');
      expect(json['timeInForce'], '0');
    });

    test('never sends the replace-only ids', () {
      final json = (buyLimit()
            ..clientOrderId = 'CL-1'
            ..orderId = 'OR-1')
          .toJson();
      expect(json.containsKey('orig_client_order_id'), isFalse);
      expect(json.containsKey('order_id'), isFalse);
    });

    test('optional quantities go out as null, not 0', () {
      final json = buyLimit().toJson();
      expect(json['displayQty'], isNull);
      expect(json['minQty'], isNull);
      expect(jsonEncode(json), contains('"displayQty":null'));
    });
  });

  group('replace order (toJsonReplaceOrder)', () {
    test('adds the original client order id and order id', () {
      final request = buyLimit()
        ..action = actionValues[ActionsType.REPLACE_ORDER]
        ..clientOrderId = 'CL-1'
        ..orderId = 'OR-1';
      final json = request.toJsonReplaceOrder();
      expect(json['action'], 'ORDER_CANCEL_REPLACE_REQUEST');
      expect(json['orig_client_order_id'], 'CL-1');
      expect(json['order_id'], 'OR-1');
    });

    test('is the new-order payload plus exactly those two keys', () {
      final request = buyLimit()
        ..clientOrderId = 'CL-1'
        ..orderId = 'OR-1';
      final replace = request.toJsonReplaceOrder();
      final order = request.toJson();
      expect(
        replace.keys.toSet().difference(order.keys.toSet()),
        {'orig_client_order_id', 'order_id'},
      );
      for (final key in order.keys) {
        expect(replace[key], order[key], reason: key);
      }
    });
  });

  group('fromJson', () {
    test('round-trips a replace payload', () {
      final original = buyLimit()
        ..clientOrderId = 'CL-1'
        ..orderId = 'OR-1'
        ..displayQty = 100
        ..minQty = 50;
      final parsed = OrderConfirmRequest.fromJson(
        jsonDecode(jsonEncode(original.toJsonReplaceOrder())),
      );
      expect(parsed.toJsonReplaceOrder(), original.toJsonReplaceOrder());
    });

    test('accepts an integer price from the server', () {
      final parsed = OrderConfirmRequest.fromJson({'price': 100});
      expect(parsed.price, 100.0);
      expect(parsed.price, isA<double>());
    });
  });
}
