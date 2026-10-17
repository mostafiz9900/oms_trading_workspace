// To parse this JSON data, do
//
//     final orderModel = orderModelFromJson(jsonString);

import 'dart:convert';

List<OrderModel> orderModelFromJson(String str) =>
    List<OrderModel>.from(json.decode(str).map((x) => OrderModel.fromJson(x)));

String orderModelToJson(List<OrderModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderModel {
  final String? side;
  final int? qty;
  final double? price;
  final double? orderNumber;
  final int? executedQty;
  // final int? cQty;
  final bool? executed;
  final String? status;

  OrderModel({
    this.side,
    this.qty,
    this.price,
    this.orderNumber,
    this.executedQty,
    this.executed,
    this.status,
  });

  OrderModel copyWith({
    String? side,
    int? qty,
    double? price,
    double? orderNumber,
    int? executedQty,
    bool? executed,
    String? status,
  }) => OrderModel(
    side: side ?? this.side,
    qty: qty ?? this.qty,
    price: price ?? this.price,
    orderNumber: orderNumber ?? this.orderNumber,
    executedQty: executedQty ?? this.executedQty,
    executed: executed ?? this.executed,
    status: status ?? this.status,
  );

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    side: json["side"],
    qty: json["qty"],
    price: json["price"]?.toDouble(),
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
