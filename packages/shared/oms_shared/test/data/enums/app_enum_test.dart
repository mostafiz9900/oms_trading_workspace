import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/data/enums/app_enum.dart';

/// These strings are part of the exchange gateway protocol. Changing any of
/// them changes what is sent with every order.
void main() {
  test('order actions', () {
    expect(actionValues, {
      ActionsType.ORDER: 'NEW_ORDER_SINGLE_REQUEST',
      ActionsType.REPLACE_ORDER: 'ORDER_CANCEL_REPLACE_REQUEST',
      ActionsType.CANCEL_ORDER: 'ORDER_CANCEL_REQUEST',
      ActionsType.ORDER_STATUS: 'ORDER_STATUS_REQUEST',
    });
  });

  test('order sides', () {
    expect(sideTypeEnumMap, {SideType2.BUY: 'BUY', SideType2.SELL: 'SELL'});
  });

  test('order types (FIX OrdType)', () {
    expect(orderTypeMap, {
      OrderType.MARKET: '1',
      OrderType.MARKET_AT_BEST: 'Z',
      OrderType.LIMIT: '2',
    });
  });

  test('time in force (FIX TimeInForce)', () {
    expect(timeInForceMap, {
      TimeInForce.DAY: '0',
      TimeInForce.SESSION: 'S',
      TimeInForce.IMMEDIATE_OR_CANCEL: '3',
      TimeInForce.FILL_OR_KILL: '4',
      TimeInForce.GOOD_TILL_CANCEL: '1',
      TimeInForce.GOOD_TILL_DATE: '6',
    });
  });

  test('execution instructions (FIX ExecInst)', () {
    expect(execInstMap, {
      ExecInst.SUSPEND: 'S',
      ExecInst.RELEASE: 'q',
      ExecInst.WHOLE_OR_NONE: 'w',
      ExecInst.WHOLE_OR_NONE_AND_SUSPEND: 'w S',
      ExecInst.WHOLE_OR_NONE_AND_RELEASE: 'w q',
    });
  });

  test('every enum value has a wire string', () {
    expect(actionValues.keys, containsAll(ActionsType.values));
    expect(sideTypeEnumMap.keys, containsAll(SideType2.values));
    expect(orderTypeMap.keys, containsAll(OrderType.values));
    expect(timeInForceMap.keys, containsAll(TimeInForce.values));
    expect(execInstMap.keys, containsAll(ExecInst.values));
  });
}
