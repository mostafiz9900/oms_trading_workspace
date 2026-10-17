// To parse this JSON data, do
//
//     final userOrder = userOrderFromJson(jsonString);

import 'dart:convert';

List<UserOrder> userOrderFromJson(dynamic str) => List<UserOrder>.from(
  (str as List<dynamic>).map((x) => UserOrder.fromJson(x)),
);

String userOrderToJson(List<UserOrder> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

UserOrderModel userOrderModelFromJson(String str) =>
    UserOrderModel.fromJson(json.decode(str));

String userOrderModelToJson(UserOrderModel data) => json.encode(data.toJson());

class UserOrderModel {
  String? messageType;
  String? message;
  List<UserOrder>? data;

  UserOrderModel({this.messageType, this.message, this.data});

  UserOrderModel copyWith({
    String? messageType,
    String? message,
    List<UserOrder>? data,
  }) => UserOrderModel(
    messageType: messageType ?? this.messageType,
    message: message ?? this.message,
    data: data ?? this.data,
  );

  factory UserOrderModel.fromJson(Map<String, dynamic> json) => UserOrderModel(
    messageType: json["message_type"],
    message: json["message"],
    data: json["data"] == null
        ? []
        : (json["data"] is List)
        ? List<UserOrder>.from(json["data"].map((x) => UserOrder.fromJson(x)))
        : [UserOrder.fromJson(json["data"])],
  );

  Map<String, dynamic> toJson() => {
    "message_type": messageType,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class UserOrder {
  final String? traderId;
  final String? boId;
  final int? orderBookId;
  final String? name;
  final String? side;
  final int? cumQty;
  final int? leavesQty;
  final double? avgPx;
  final double? lastPx;
  final double? limit;
  final String? orderId;
  final int? sentQty;
  final String? ordType;
  final String? date;
  final String? transactTime;
  final String? clientOrderId;
  final String? origClOrdID;
  final String? orderStatus;
  final String? status;
  final String? execution;
  final String? rejectionReason;
  final String? msgType;
  final int? displayQty;
  final String? execInst;
  final int? minQty;
  final String? trdMatchID;
  final String? securitySubType;
  final double? grossTradeAmt;
  final String? execType;
  final String? tradeDate;
  final String? settlDate;
  final String? timeInForce;
  final int? lastQty;
  final String? execID;
  final String? sendingTime;
  final dynamic remainingQty;
  final String? aggressorIndicator;
  final String? clientCode;

  UserOrder({
    this.traderId,
    this.boId,
    this.orderBookId,
    this.name,
    this.side,
    this.cumQty,
    this.leavesQty,
    this.avgPx,
    this.lastPx,
    this.limit,
    this.orderId,
    this.sentQty,
    this.ordType,
    this.date,
    this.transactTime,
    this.clientOrderId,
    this.origClOrdID,
    this.orderStatus,
    this.status,
    this.execution,
    this.rejectionReason,
    this.msgType,
    this.displayQty,
    this.execInst,
    this.minQty,
    this.trdMatchID,
    this.securitySubType,
    this.grossTradeAmt,
    this.execType,
    this.tradeDate,
    this.settlDate,
    this.timeInForce,
    this.lastQty,
    this.execID,
    this.sendingTime,
    this.remainingQty,
    this.aggressorIndicator,
    this.clientCode,
  });

  factory UserOrder.fromJson(Map<String, dynamic> json) => UserOrder(
    traderId: json["trader_id"] as String?,
    boId: json["bo_id"] as String?,
    orderBookId: json["order_book_id"] as int?,
    name: json["name"] as String?,
    side: json["side"] as String?,
    cumQty: json["cumQty"] as int?,
    leavesQty: json["leavesQty"] as int?,
    avgPx: (json["avgPx"] as num?)?.toDouble(),
    lastPx: (json["lastPx"] as num?)?.toDouble(),
    limit: (json["limit"] as num?)?.toDouble(),
    orderId: json["orderId"] as String?,
    sentQty: json["sentQty"] as int?,
    ordType: json["ordType"] as String?,
    date: json["date"] as String?,
    transactTime: json["transactTime"] as String?,
    clientOrderId: json["clientOrderId"] as String?,
    origClOrdID: json["origClOrdID"] as String?,
    orderStatus: json["orderStatus"] as String?,
    status: json["status"] as String?,
    execution: json["execution"] as String?,
    rejectionReason: json["rejectionReason"] as String?,
    msgType: json["msgType"] as String?,
    displayQty: json["displayQty"] as int?,
    execInst: json["execInst"] as String?,
    minQty: json["minQty"] as int?,
    trdMatchID: json["trdMatchID"] as String?,
    securitySubType: json["securitySubType"] as String?,
    grossTradeAmt: (json["grossTradeAmt"] is num)
        ? (json["grossTradeAmt"] as num).toDouble()
        : double.tryParse(json["grossTradeAmt"] ?? ''),
    // grossTradeAmt:Helpers.toDouble(json["grossTradeAmt"]),
    execType: json["execType"] as String?,
    tradeDate: json["tradeDate"] as String?,
    settlDate: json["settlDate"] as String?,
    timeInForce: json["timeInForce"] as String?,
    lastQty: json["lastQty"] as int?,
    execID: json["execID"] as String?,
    sendingTime: json["sendingTime"] as String?,
    remainingQty: json["remainingQty"],
    aggressorIndicator: json["aggressorIndicator"] as String?,
    clientCode: json["client_code"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "trader_id": traderId,
    "bo_id": boId,
    "order_book_id": orderBookId,
    "name": name,
    "side": side,
    "cumQty": cumQty,
    "leavesQty": leavesQty,
    "avgPx": avgPx,
    "lastPx": lastPx,
    "limit": limit,
    "orderId": orderId,
    "sentQty": sentQty,
    "ordType": ordType,
    "date": date,
    "transactTime": transactTime,
    "clientOrderId": clientOrderId,
    "origClOrdID": origClOrdID,
    "orderStatus": orderStatus,
    "status": status,
    "execution": execution,
    "rejectionReason": rejectionReason,
    "msgType": msgType,
    "displayQty": displayQty,
    "execInst": execInst,
    "minQty": minQty,
    "trdMatchID": trdMatchID,
    "securitySubType": securitySubType,
    "grossTradeAmt": grossTradeAmt,
    "execType": execType,
    "tradeDate": tradeDate,
    "settlDate": settlDate,
    "timeInForce": timeInForce,
    "lastQty": lastQty,
    "execID": execID,
    "sendingTime": sendingTime,
    "remainingQty": remainingQty,
    "aggressorIndicator": aggressorIndicator,
    "client_code": clientCode,
  };

  // --- copyWith function for UserOrder ---
  UserOrder copyWith({
    String? traderId,
    String? boId,
    int? orderBookId,
    String? name,
    String? side,
    int? cumQty,
    int? leavesQty,
    double? avgPx,
    double? lastPx,
    double? limit,
    String? orderId,
    int? sentQty,
    String? ordType,
    String? date,
    String? transactTime,
    String? clientOrderId,
    String? origClOrdID,
    String? orderStatus,
    String? status,
    String? execution,
    String? rejectionReason,
    String? msgType,
    int? displayQty,
    String? execInst,
    int? minQty,
    String? trdMatchID,
    String? securitySubType,
    double? grossTradeAmt,
    String? execType,
    String? tradeDate,
    String? settlDate,
    String? timeInForce,
    int? lastQty,
    String? execID,
    String? sendingTime,
    dynamic remainingQty,
    String? aggressorIndicator,
    String? clientCode,
  }) {
    return UserOrder(
      traderId: traderId ?? this.traderId,
      boId: boId ?? this.boId,
      orderBookId: orderBookId ?? this.orderBookId,
      name: name ?? this.name,
      side: side ?? this.side,
      cumQty: cumQty ?? this.cumQty,
      leavesQty: leavesQty ?? this.leavesQty,
      avgPx: avgPx ?? this.avgPx,
      lastPx: lastPx ?? this.lastPx,
      limit: limit ?? this.limit,
      orderId: orderId ?? this.orderId,
      sentQty: sentQty ?? this.sentQty,
      ordType: ordType ?? this.ordType,
      date: date ?? this.date,
      transactTime: transactTime ?? this.transactTime,
      clientOrderId: clientOrderId ?? this.clientOrderId,
      origClOrdID: origClOrdID ?? this.origClOrdID,
      orderStatus: orderStatus ?? this.orderStatus,
      status: status ?? this.status,
      execution: execution ?? this.execution,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      msgType: msgType ?? this.msgType,
      displayQty: displayQty ?? this.displayQty,
      execInst: execInst ?? this.execInst,
      minQty: minQty ?? this.minQty,
      trdMatchID: trdMatchID ?? this.trdMatchID,
      securitySubType: securitySubType ?? this.securitySubType,
      grossTradeAmt: grossTradeAmt ?? this.grossTradeAmt,
      execType: execType ?? this.execType,
      tradeDate: tradeDate ?? this.tradeDate,
      settlDate: settlDate ?? this.settlDate,
      timeInForce: timeInForce ?? this.timeInForce,
      lastQty: lastQty ?? this.lastQty,
      execID: execID ?? this.execID,
      sendingTime: sendingTime ?? this.sendingTime,
      remainingQty: remainingQty ?? this.remainingQty,
      aggressorIndicator: aggressorIndicator ?? this.aggressorIndicator,
      clientCode: clientCode ?? this.clientCode,
    );
  }

  // --- End copyWith function for UserOrder ---
}
