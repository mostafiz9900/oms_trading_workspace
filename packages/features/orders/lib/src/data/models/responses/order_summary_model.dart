// To parse this JSON data, do
//
//     final orderSummaryModel = orderSummaryModelFromJson(jsonString);

import 'dart:convert';

OrderSummaryModel orderSummaryModelFromJson(String str) =>
    OrderSummaryModel.fromJson(json.decode(str));

String orderSummaryModelToJson(OrderSummaryModel data) =>
    json.encode(data.toJson());

class OrderSummaryModel {
  final String? messageType;
  final String? message;
  final OrderSummaryData? data;
  final String? tableId;

  OrderSummaryModel({this.messageType, this.message, this.data, this.tableId});

  OrderSummaryModel copyWith({
    String? messageType,
    String? message,
    OrderSummaryData? data,
    String? tableId,
  }) => OrderSummaryModel(
    messageType: messageType ?? this.messageType,
    message: message ?? this.message,
    data: data ?? this.data,
    tableId: tableId ?? this.tableId,
  );

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) =>
      OrderSummaryModel(
        messageType: json["message_type"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : OrderSummaryData.fromJson(json["data"]),
        tableId: json["table_id"],
      );

  Map<String, dynamic> toJson() => {
    "message_type": messageType,
    "message": message,
    "data": data?.toJson(),
    "table_id": tableId,
  };
}

class OrderSummaryData {
  final List<ClientOrder>? clientOrders;
  final List<Summary>? summary;

  OrderSummaryData({this.clientOrders, this.summary});

  OrderSummaryData copyWith({
    List<ClientOrder>? clientOrders,
    List<Summary>? summary,
  }) => OrderSummaryData(
    clientOrders: clientOrders ?? this.clientOrders,
    summary: summary ?? this.summary,
  );

  factory OrderSummaryData.fromJson(Map<String, dynamic> json) =>
      OrderSummaryData(
        clientOrders: json["client_orders"] == null
            ? []
            : List<ClientOrder>.from(
                json["client_orders"]!.map((x) => ClientOrder.fromJson(x)),
              ),
        summary: json["summary"] == null
            ? []
            : List<Summary>.from(
                json["summary"]!.map((x) => Summary.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "client_orders": clientOrders == null
        ? []
        : List<dynamic>.from(clientOrders!.map((x) => x.toJson())),
    "summary": summary == null
        ? []
        : List<dynamic>.from(summary!.map((x) => x.toJson())),
  };
}

class ClientOrder {
  final String? clientCode;
  final String? symbol;
  final int? buyExecQty;
  final int? sellExecQty;
  final double? buyExecVal;
  final double? sellExecVal;
  final double? buyAvgPx;
  final double? sellAvgPx;
  final double? netExecVal;
  final String? uniqueKey;
  final String? uniqueName;

  ClientOrder({
    this.clientCode,
    this.symbol,
    this.buyExecQty,
    this.sellExecQty,
    this.buyExecVal,
    this.sellExecVal,
    this.buyAvgPx,
    this.sellAvgPx,
    this.netExecVal,
    this.uniqueKey,
    this.uniqueName,
  });

  ClientOrder copyWith({
    String? clientCode,
    String? symbol,
    int? buyExecQty,
    int? sellExecQty,
    double? buyExecVal,
    double? sellExecVal,
    double? buyAvgPx,
    double? sellAvgPx,
    double? netExecVal,
    String? uniqueKey,
    String? uniqueName,
  }) => ClientOrder(
    clientCode: clientCode ?? this.clientCode,
    symbol: symbol ?? this.symbol,
    buyExecQty: buyExecQty ?? this.buyExecQty,
    sellExecQty: sellExecQty ?? this.sellExecQty,
    buyExecVal: buyExecVal ?? this.buyExecVal,
    sellExecVal: sellExecVal ?? this.sellExecVal,
    buyAvgPx: buyAvgPx ?? this.buyAvgPx,
    sellAvgPx: sellAvgPx ?? this.sellAvgPx,
    netExecVal: netExecVal ?? this.netExecVal,
    uniqueKey: uniqueKey ?? this.uniqueKey,
    uniqueName: uniqueName ?? this.uniqueName,
  );

  factory ClientOrder.fromJson(Map<String, dynamic> json) => ClientOrder(
    clientCode: json["client_code"],
    symbol: json["symbol"],
    buyExecQty: json["buy_exec_qty"],
    sellExecQty: json["sell_exec_qty"],
    buyExecVal: json["buy_exec_val"]?.toDouble(),
    sellExecVal: json["sell_exec_val"]?.toDouble(),
    buyAvgPx: json["buy_avg_px"]?.toDouble(),
    sellAvgPx: json["sell_avg_px"]?.toDouble(),
    netExecVal: json["net_exec_val"]?.toDouble(),
    uniqueKey: json["unique_key"],
    uniqueName: json["unique_name"],
  );

  Map<String, dynamic> toJson() => {
    "client_code": clientCode,
    "symbol": symbol,
    "buy_exec_qty": buyExecQty,
    "sell_exec_qty": sellExecQty,
    "buy_exec_val": buyExecVal,
    "sell_exec_val": sellExecVal,
    "buy_avg_px": buyAvgPx,
    "sell_avg_px": sellAvgPx,
    "net_exec_val": netExecVal,
    "unique_key": uniqueKey,
    "unique_name": uniqueName,
  };
}

class Summary {
  final String? side;
  final int? orders;
  final int? quantity;
  final double? execVal;
  final double? filled;

  Summary({this.side, this.orders, this.quantity, this.execVal, this.filled});

  Summary copyWith({
    String? side,
    int? orders,
    int? quantity,
    double? execVal,
    double? filled,
  }) => Summary(
    side: side ?? this.side,
    orders: orders ?? this.orders,
    quantity: quantity ?? this.quantity,
    execVal: execVal ?? this.execVal,
    filled: filled ?? this.filled,
  );

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    side: json["side"],
    orders: json["orders"],
    quantity: json["quantity"],
    execVal: json["exec_val"]?.toDouble(),
    filled: json["filled"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "side": side,
    "orders": orders,
    "quantity": quantity,
    "exec_val": execVal,
    "filled": filled,
  };
}
