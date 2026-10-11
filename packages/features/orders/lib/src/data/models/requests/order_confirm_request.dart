// To parse this JSON data, do
//
//     final orderConfirmRequest = orderConfirmRequestFromJson(jsonString);

import 'dart:convert';

OrderConfirmRequest orderConfirmRequestFromJson(String str) =>
    OrderConfirmRequest.fromJson(json.decode(str));

String orderConfirmRequestToJson(OrderConfirmRequest data) =>
    json.encode(data.toJson());

class OrderConfirmRequest {
  String? action;
  int? traderPk;
  String? traderId;
  String? boId;
  String? clientCode;
  String? clientOrderId;
  String? orderId;
  int? branchId;
  int? userId;
  String? orderType;
  int? qty;
  double? price;
  String? symbol;
  String? side;
  String? isin;
  String? assetClass;
  String? securityCode;
  int? orderBookId;
  String? board;
  String? session;
  String? category;
  String? marketType;
  String? group;
  String? timeInForce;
  int? displayQty;
  String? execInst;
  int? minQty;

  OrderConfirmRequest({
    this.action,
    this.traderPk,
    this.traderId,
    this.boId,
    this.clientCode,
    this.clientOrderId,
    this.orderId,
    this.branchId,
    this.userId,
    this.orderType,
    this.qty,
    this.price,
    this.symbol,
    this.side,
    this.isin,
    this.assetClass,
    this.securityCode,
    this.orderBookId,
    this.board,
    this.session,
    this.category,
    this.marketType,
    this.group,
    this.timeInForce,
    this.displayQty,
    this.execInst,
    this.minQty,
  });
  factory OrderConfirmRequest.fromJson(Map<String, dynamic> json) {
    return OrderConfirmRequest(
      action: json['action'],
      traderPk: json['trader_pk'],
      traderId: json['trader_id'],
      boId: json['bo_id'],
      clientCode: json['client_code'],
      clientOrderId: json['orig_client_order_id'],
      orderId: json['order_id'],
      branchId: json['branch_id'],
      userId: json['user_id'],
      orderType: json['order_type'],
      qty: json['qty'],
      price: (json['price'] as num?)?.toDouble(),
      symbol: json['symbol'],
      side: json['side'],
      isin: json['isin'],
      assetClass: json['asset_class'],
      securityCode: json['security_code'],
      orderBookId: json['order_book_id'],
      board: json['board'],
      session: json['session'],
      category: json['category'],
      marketType: json['market_type'],
      group: json['group'],
      timeInForce: json['timeInForce'],
      displayQty: json['displayQty'],
      execInst: json['execInst'],
      minQty: json['minQty'],
    );
  }

  Map<String, dynamic> toJson() => {
    'action': action,
    'trader_pk': traderPk,
    'trader_id': traderId,
    'bo_id': boId,
    'client_code': clientCode,
    'branch_id': branchId,
    'user_id': userId,
    'order_type': orderType,
    'qty': qty,
    'price': price,
    'symbol': symbol,
    'side': side,
    'isin': isin,
    'asset_class': assetClass,
    'security_code': securityCode,
    'order_book_id': orderBookId,
    'board': board,
    'session': session,
    'category': category,
    'market_type': marketType,
    'group': group,
    'timeInForce': timeInForce,
    'displayQty': displayQty,
    'execInst': execInst,
    'minQty': minQty,
  };
  Map<String, dynamic> toJsonReplaceOrder() => {
    'action': action,
    'trader_pk': traderPk,
    'trader_id': traderId,
    'bo_id': boId,
    'client_code': clientCode,
    'orig_client_order_id': clientOrderId,
    'order_id': orderId,
    'branch_id': branchId,
    'user_id': userId,
    'order_type': orderType,
    'qty': qty,
    'price': price,
    'symbol': symbol,
    'side': side,
    'isin': isin,
    'asset_class': assetClass,
    'security_code': securityCode,
    'order_book_id': orderBookId,
    'board': board,
    'session': session,
    'category': category,
    'market_type': marketType,
    'group': group,
    'timeInForce': timeInForce,
    'displayQty': displayQty,
    'execInst': execInst,
    'minQty': minQty,
  };
}
