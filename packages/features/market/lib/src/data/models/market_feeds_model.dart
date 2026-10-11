// To parse this JSON data, do
//
//     final marketFeed = marketFeedFromJson(jsonString);

import 'dart:convert';

MarketFeed marketFeedFromJson(String str) =>
    MarketFeed.fromJson(json.decode(str));

String marketFeedToJson(MarketFeed data) => json.encode(data.toJson());

class MarketFeed {
  int? id;
  String? session;
  String? shortName;
  String? fullName;
  String? filterName;
  String? firmId;
  String? tradingState;
  String? shareType;
  String? marketType;
  int? orderbook;
  DateTime? date;
  int? lq;
  int? bq;
  int? aq;
  dynamic dl;
  dynamic dh;
  dynamic bid;
  dynamic ask;
  dynamic open;
  double? reference;
  dynamic last;
  dynamic volume;
  dynamic high;
  dynamic low;
  dynamic close;
  double? d;
  double? chg;
  double? settle1;
  dynamic settle;
  dynamic status;
  dynamic val;
  dynamic vwap;
  dynamic sellPending;
  dynamic buyPending;
  String? board;
  String? group;
  String? instrumentType;
  String? ticker;
  String? sector;
  String? isinCode;
  dynamic trades;
  dynamic lastTradeTime;
  dynamic the52WkLow;
  dynamic the52WkHigh;
  dynamic the1MonthLow;
  dynamic the1MonthHigh;
  double? the1WkAvgVol;
  List<Order>? orders;
  List<ExecutedOrder>? executedOrders;
  String? streamId;

  MarketFeed({
    this.id,
    this.session,
    this.shortName,
    this.fullName,
    this.filterName,
    this.firmId,
    this.tradingState,
    this.shareType,
    this.marketType,
    this.orderbook,
    this.date,
    this.lq,
    this.bq,
    this.aq,
    this.dl,
    this.dh,
    this.bid,
    this.ask,
    this.open,
    this.reference,
    this.last,
    this.volume,
    this.high,
    this.low,
    this.close,
    this.d,
    this.chg,
    this.settle1,
    this.settle,
    this.status,
    this.val,
    this.vwap,
    this.sellPending,
    this.buyPending,
    this.board,
    this.group,
    this.instrumentType,
    this.ticker,
    this.sector,
    this.isinCode,
    this.trades,
    this.lastTradeTime,
    this.the52WkLow,
    this.the52WkHigh,
    this.the1MonthLow,
    this.the1MonthHigh,
    this.the1WkAvgVol,
    this.orders,
    this.executedOrders,
    this.streamId,
  });

  MarketFeed copyWith({
    int? id,
    String? session,
    String? shortName,
    String? fullName,
    String? filterName,
    String? firmId,
    String? tradingState,
    String? shareType,
    String? marketType,
    int? orderbook,
    DateTime? date,
    int? lq,
    int? bq,
    int? aq,
    dynamic dl,
    int? dh,
    int? bid,
    int? ask,
    int? open,
    double? reference,
    int? last,
    int? volume,
    int? high,
    int? low,
    int? close,
    double? d,
    double? chg,
    double? settle1,
    int? settle,
    String? status,
    int? val,
    int? vwap,
    int? sellPending,
    int? buyPending,
    String? board,
    String? group,
    String? instrumentType,
    String? ticker,
    String? sector,
    String? isinCode,
    int? trades,
    dynamic lastTradeTime,
    int? the52WkLow,
    int? the52WkHigh,
    int? the1MonthLow,
    int? the1MonthHigh,
    double? the1WkAvgVol,
    List<Order>? orders,
    List<ExecutedOrder>? executedOrders,
    String? streamId,
  }) => MarketFeed(
    id: id ?? this.id,
    session: session ?? this.session,
    shortName: shortName ?? this.shortName,
    fullName: fullName ?? this.fullName,
    filterName: filterName ?? this.filterName,
    firmId: firmId ?? this.firmId,
    tradingState: tradingState ?? this.tradingState,
    shareType: shareType ?? this.shareType,
    marketType: marketType ?? this.marketType,
    orderbook: orderbook ?? this.orderbook,
    date: date ?? this.date,
    lq: lq ?? this.lq,
    bq: bq ?? this.bq,
    aq: aq ?? this.aq,
    dl: dl ?? this.dl,
    dh: dh ?? this.dh,
    bid: bid ?? this.bid,
    ask: ask ?? this.ask,
    open: open ?? this.open,
    reference: reference ?? this.reference,
    last: last ?? this.last,
    volume: volume ?? this.volume,
    high: high ?? this.high,
    low: low ?? this.low,
    close: close ?? this.close,
    d: d ?? this.d,
    chg: chg ?? this.chg,
    settle1: settle1 ?? this.settle1,
    settle: settle ?? this.settle,
    status: status ?? this.status,
    val: val ?? this.val,
    vwap: vwap ?? this.vwap,
    sellPending: sellPending ?? this.sellPending,
    buyPending: buyPending ?? this.buyPending,
    board: board ?? this.board,
    group: group ?? this.group,
    instrumentType: instrumentType ?? this.instrumentType,
    ticker: ticker ?? this.ticker,
    sector: sector ?? this.sector,
    isinCode: isinCode ?? this.isinCode,
    trades: trades ?? this.trades,
    lastTradeTime: lastTradeTime ?? this.lastTradeTime,
    the52WkLow: the52WkLow ?? this.the52WkLow,
    the52WkHigh: the52WkHigh ?? this.the52WkHigh,
    the1MonthLow: the1MonthLow ?? this.the1MonthLow,
    the1MonthHigh: the1MonthHigh ?? this.the1MonthHigh,
    the1WkAvgVol: the1WkAvgVol ?? this.the1WkAvgVol,
    orders: orders ?? this.orders,
    executedOrders: executedOrders ?? this.executedOrders,
    streamId: streamId ?? this.streamId,
  );

  factory MarketFeed.fromJson(Map<String, dynamic> json) => MarketFeed(
    id: json["id"],
    session: json["session"],
    shortName: json["short_name"],
    fullName: json["full_name"],
    filterName: json["filter_name"],
    firmId: json["firm_id"],
    tradingState: json["trading_state"],
    shareType: json["share_type"],
    marketType: json["market_type"],
    orderbook: json["orderbook"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    lq: json["lq"],
    bq: json["bq"],
    aq: json["aq"],
    dl: json["dl"],
    dh: json["dh"],
    bid: json["bid"],
    ask: json["ask"],
    open: json["open"],
    reference: json["reference"]?.toDouble(),
    last: json["last"],
    volume: json["volume"],
    high: json["high"],
    low: json["low"],
    close: json["close"],
    d: json["d"]?.toDouble(),
    chg: json["chg"]?.toDouble(),
    settle1: json["settle_1"]?.toDouble(),
    settle: json["settle"],
    status: json["status"],
    val: json["val"],
    vwap: json["vwap"],
    sellPending: json["sell_pending"],
    buyPending: json["buy_pending"],
    board: json["board"],
    group: json["group"],
    instrumentType: json["instrument_type"],
    ticker: json["ticker"],
    sector: json["sector"],
    isinCode: json["isin_code"],
    trades: json["trades"],
    lastTradeTime: json["last_trade_time"],
    the52WkLow: json["52_wk_low"],
    the52WkHigh: json["52_wk_high"],
    the1MonthLow: json["1_month_low"],
    the1MonthHigh: json["1_month_high"],
    the1WkAvgVol: json["1_wk_avg_vol"]?.toDouble(),
    orders: json["orders"] == null
        ? []
        : List<Order>.from(json["orders"]!.map((x) => Order.fromJson(x))),
    executedOrders: json["executed_orders"] == null
        ? []
        : List<ExecutedOrder>.from(
            json["executed_orders"]!.map((x) => ExecutedOrder.fromJson(x)),
          ),
    streamId: json["stream_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "session": session,
    "short_name": shortName,
    "full_name": fullName,
    "filter_name": filterName,
    "firm_id": firmId,
    "trading_state": tradingState,
    "share_type": shareType,
    "market_type": marketType,
    "orderbook": orderbook,
    "date":
        "${date?.year.toString().padLeft(4, '0')}-${date?.month.toString().padLeft(2, '0')}-${date?.day.toString().padLeft(2, '0')}",
    "lq": lq,
    "bq": bq,
    "aq": aq,
    "dl": dl,
    "dh": dh,
    "bid": bid,
    "ask": ask,
    "open": open,
    "reference": reference,
    "last": last,
    "volume": volume,
    "high": high,
    "low": low,
    "close": close,
    "d": d,
    "chg": chg,
    "settle_1": settle1,
    "settle": settle,
    "status": status,
    "val": val,
    "vwap": vwap,
    "sell_pending": sellPending,
    "buy_pending": buyPending,
    "board": board,
    "group": group,
    "instrument_type": instrumentType,
    "ticker": ticker,
    "sector": sector,
    "isin_code": isinCode,
    "trades": trades,
    "last_trade_time": lastTradeTime,
    "52_wk_low": the52WkLow,
    "52_wk_high": the52WkHigh,
    "1_month_low": the1MonthLow,
    "1_month_high": the1MonthHigh,
    "1_wk_avg_vol": the1WkAvgVol,
    "orders": orders == null
        ? []
        : List<dynamic>.from(orders!.map((x) => x.toJson())),
    "executed_orders": executedOrders == null
        ? []
        : List<dynamic>.from(executedOrders!.map((x) => x.toJson())),
    "stream_id": streamId,
  };
}

class ExecutedOrder {
  String? side;
  int? executedQty;
  dynamic price;
  List<double>? orderNumbers;
  bool? executed;

  ExecutedOrder({
    this.side,
    this.executedQty,
    this.price,
    this.orderNumbers,
    this.executed,
  });

  ExecutedOrder copyWith({
    String? side,
    int? executedQty,
    dynamic price,
    List<double>? orderNumbers,
    bool? executed,
  }) => ExecutedOrder(
    side: side ?? this.side,
    executedQty: executedQty ?? this.executedQty,
    price: price ?? this.price,
    orderNumbers: orderNumbers ?? this.orderNumbers,
    executed: executed ?? this.executed,
  );

  factory ExecutedOrder.fromJson(Map<String, dynamic> json) => ExecutedOrder(
    side: json["side"],
    executedQty: json["executed_qty"],
    price: json["price"],
    orderNumbers: json["order_numbers"] == null
        ? []
        : List<double>.from(json["order_numbers"]!.map((x) => x?.toDouble())),
    executed: json["executed"],
  );

  Map<String, dynamic> toJson() => {
    "side": side,
    "executed_qty": executedQty,
    "price": price,
    "order_numbers": orderNumbers == null
        ? []
        : List<dynamic>.from(orderNumbers!.map((x) => x)),
    "executed": executed,
  };
}

class Order {
  String? side;
  int? qty;
  dynamic price;
  double? orderNumber;
  int? executedQty;
  bool? executed;
  String? status;

  Order({
    this.side,
    this.qty,
    this.price,
    this.orderNumber,
    this.executedQty,
    this.executed,
    this.status,
  });

  Order copyWith({
    String? side,
    int? qty,
    dynamic price,
    double? orderNumber,
    int? executedQty,
    bool? executed,
    String? status,
  }) => Order(
    side: side ?? this.side,
    qty: qty ?? this.qty,
    price: price ?? this.price,
    orderNumber: orderNumber ?? this.orderNumber,
    executedQty: executedQty ?? this.executedQty,
    executed: executed ?? this.executed,
    status: status ?? this.status,
  );

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    side: json["side"],
    qty: json["qty"],
    price: json["price"],
    orderNumber: json["order_number"]?.toDouble(),
    executedQty: json["executed_qty"],
    executed: json["executed"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "side": side,
    "qty": qty,
    "price": price,
    "order_number": orderNumber,
    "executed_qty": executedQty,
    "executed": executed,
    "status": status,
  };
}
