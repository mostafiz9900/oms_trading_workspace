// To parse this JSON data, do
//
//     final orderStatusDetailsModel = orderStatusDetailsModelFromJson(jsonString);

import 'dart:convert';

OrderStatusDetailsModel orderStatusDetailsModelFromJson(String str) =>
    OrderStatusDetailsModel.fromJson(json.decode(str));

String orderStatusDetailsModelToJson(OrderStatusDetailsModel data) =>
    json.encode(data.toJson());

class OrderStatusDetailsModel {
  final String? action;
  final String? traderId;
  final String? boId;
  final String? clientCode;
  final String? name;
  final String? side;
  final int? cumQty;
  final int? leavesQty;
  final dynamic avgPx;
  final dynamic lastPx;
  final dynamic limit;
  final String? orderId;
  final int? sentQty;
  final String? ordType;
  final String? date;
  final String? transactTime;
  final String? clientOrderId;
  final dynamic origClOrdId;
  final String? orderStatus;
  final String? status;
  final String? execution;
  final dynamic rejectionReason;
  final String? msgType;
  final int? displayQty;
  final dynamic execInst;
  final int? minQty;
  final dynamic trdMatchId;
  final String? securitySubType;
  final dynamic grossTradeAmt;
  final String? execType;
  final dynamic tradeDate;
  final dynamic settlDate;
  final String? timeInForce;
  final int? lastQty;
  final String? execId;
  final String? sendingTime;
  final dynamic remainingQty;
  final dynamic aggressorIndicator;

  OrderStatusDetailsModel({
    this.action,
    this.traderId,
    this.boId,
    this.clientCode,
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
    this.origClOrdId,
    this.orderStatus,
    this.status,
    this.execution,
    this.rejectionReason,
    this.msgType,
    this.displayQty,
    this.execInst,
    this.minQty,
    this.trdMatchId,
    this.securitySubType,
    this.grossTradeAmt,
    this.execType,
    this.tradeDate,
    this.settlDate,
    this.timeInForce,
    this.lastQty,
    this.execId,
    this.sendingTime,
    this.remainingQty,
    this.aggressorIndicator,
  });

  factory OrderStatusDetailsModel.fromJson(Map<String, dynamic> json) =>
      OrderStatusDetailsModel(
        action: json["action"],
        traderId: json["trader_id"],
        boId: json["bo_id"],
        clientCode: json["client_code"],
        name: json["name"],
        side: json["side"],
        cumQty: json["cumQty"],
        leavesQty: json["leavesQty"],
        avgPx: json["avgPx"],
        lastPx: json["lastPx"],
        limit: json["limit"],
        orderId: json["orderId"],
        sentQty: json["sentQty"],
        ordType: json["ordType"],
        date: json["date"],
        transactTime: json["transactTime"],
        clientOrderId: json["clientOrderId"],
        origClOrdId: json["origClOrdID"],
        orderStatus: json["orderStatus"],
        status: json["status"],
        execution: json["execution"],
        rejectionReason: json["rejectionReason"],
        msgType: json["msgType"],
        displayQty: json["displayQty"],
        execInst: json["execInst"],
        minQty: json["minQty"],
        trdMatchId: json["trdMatchID"],
        securitySubType: json["securitySubType"],
        grossTradeAmt: json["grossTradeAmt"],
        execType: json["execType"],
        tradeDate: json["tradeDate"],
        settlDate: json["settlDate"],
        timeInForce: json["timeInForce"],
        lastQty: json["lastQty"],
        execId: json["execID"],
        sendingTime: json["sendingTime"],
        remainingQty: json["remainingQty"],
        aggressorIndicator: json["aggressorIndicator"],
      );

  Map<String, dynamic> toJson() => {
    "action": action,
    "trader_id": traderId,
    "bo_id": boId,
    "client_code": clientCode,
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
    "origClOrdID": origClOrdId,
    "orderStatus": orderStatus,
    "status": status,
    "execution": execution,
    "rejectionReason": rejectionReason,
    "msgType": msgType,
    "displayQty": displayQty,
    "execInst": execInst,
    "minQty": minQty,
    "trdMatchID": trdMatchId,
    "securitySubType": securitySubType,
    "grossTradeAmt": grossTradeAmt,
    "execType": execType,
    "tradeDate": tradeDate,
    "settlDate": settlDate,
    "timeInForce": timeInForce,
    "lastQty": lastQty,
    "execID": execId,
    "sendingTime": sendingTime,
    "remainingQty": remainingQty,
    "aggressorIndicator": aggressorIndicator,
  };
}
