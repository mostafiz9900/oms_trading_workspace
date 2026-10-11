
// Order types

// Side types
enum SideType { buy, sell }

enum SideType2 { BUY, SELL }

final Map<SideType2, String> sideTypeEnumMap = {SideType2.BUY: "BUY", SideType2.SELL: 'SELL'};

enum OrderType { MARKET, MARKET_AT_BEST, LIMIT }

final Map<OrderType, String> orderTypeMap = {
  OrderType.MARKET: '1',
  OrderType.MARKET_AT_BEST: 'Z',
  OrderType.LIMIT: '2',
};

enum TimeInForce { DAY, SESSION, IMMEDIATE_OR_CANCEL, FILL_OR_KILL, GOOD_TILL_CANCEL, GOOD_TILL_DATE }

final Map<TimeInForce, String> timeInForceMap = {
  TimeInForce.DAY: '0',
  TimeInForce.SESSION: 'S',
  TimeInForce.IMMEDIATE_OR_CANCEL: '3',
  TimeInForce.FILL_OR_KILL: '4',
  TimeInForce.GOOD_TILL_CANCEL: '1',
  TimeInForce.GOOD_TILL_DATE: '6',
};

enum ExecInst { SUSPEND, RELEASE, WHOLE_OR_NONE, WHOLE_OR_NONE_AND_SUSPEND, WHOLE_OR_NONE_AND_RELEASE }

final Map<ExecInst, String> execInstMap = {
  ExecInst.SUSPEND: 'S',
  ExecInst.RELEASE: 'q',
  ExecInst.WHOLE_OR_NONE: 'w',
  ExecInst.WHOLE_OR_NONE_AND_SUSPEND: 'w S',
  ExecInst.WHOLE_OR_NONE_AND_RELEASE: 'w q',
};

enum ActionsType { ORDER, REPLACE_ORDER, CANCEL_ORDER, ORDER_STATUS }

const Map<ActionsType, String> actionValues = {
  ActionsType.ORDER: 'NEW_ORDER_SINGLE_REQUEST',
  ActionsType.REPLACE_ORDER: 'ORDER_CANCEL_REPLACE_REQUEST',
  ActionsType.CANCEL_ORDER: 'ORDER_CANCEL_REQUEST',
  ActionsType.ORDER_STATUS: 'ORDER_STATUS_REQUEST',
};
