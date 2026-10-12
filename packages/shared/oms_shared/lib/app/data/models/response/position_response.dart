// To parse this JSON data, do
//
//     final positionResponse = positionResponseFromMap(jsonString);

import 'dart:convert';

import 'market_model.dart' show MarketModel;

PositionResponse positionResponseFromMap(String str) =>
    PositionResponse.fromMap(json.decode(str));

String positionResponseToMap(PositionResponse data) =>
    json.encode(data.toMap());

class PositionResponse {
  final String? messageType;
  final String? message;
  final List<PositionModel>? data;

  PositionResponse({this.messageType, this.message, this.data});

  factory PositionResponse.fromMap(Map<String, dynamic> json) =>
      PositionResponse(
        messageType: json["message_type"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<PositionModel>.from(
                json["data"]!.map((x) => PositionModel.fromMap(x)),
              ),
      );

  Map<String, dynamic> toMap() => {
    "message_type": messageType,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
  };
  // Add copyWith method
  PositionResponse copyWith({
    String? messageType,
    String? message,
    List<PositionModel>? data,
  }) {
    return PositionResponse(
      messageType: messageType ?? this.messageType,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

class PositionModel {
  final int? id;
  final String? clientCode;
  final String? isin;
  final String? securityCode;
  final int? quantity;
  final double? totalCost;
  final double? avgPrice;
  final int? intradayBuyQuantity;
  final double? intradayBuyPriceAvg;
  final int? intradaySellQuantity;
  final double? intradaySellPriceAvg;
  final double? lastPrice;
  final double? marketValue;
  final double? unrealizedValue;
  final double? realizedValue;
  final MarketModel? marketModel;
  final int? totalQty;

  PositionModel({
    this.id,
    this.clientCode,
    this.isin,
    this.securityCode,
    this.quantity,
    this.totalCost,
    this.avgPrice,
    this.intradayBuyQuantity,
    this.intradayBuyPriceAvg,
    this.intradaySellQuantity,
    this.intradaySellPriceAvg,
    this.lastPrice,
    this.marketValue,
    this.unrealizedValue,
    this.realizedValue,
    this.marketModel,
    this.totalQty,
  });

  factory PositionModel.fromMap(Map<String, dynamic> json) => PositionModel(
    id: json["id"],
    clientCode: json["client_code"],
    isin: json["isin"],
    securityCode: json["security_code"],
    quantity: json["quantity"],
    totalCost: (json["total_cost"] as num?)?.toDouble(),
    avgPrice: (json["avg_price"] as num?)?.toDouble(),
    intradayBuyQuantity: json["intraday_buy_quantity"],
    intradayBuyPriceAvg: (json["intraday_buy_price_avg"] as num?)?.toDouble(),
    intradaySellQuantity: json["intraday_sell_quantity"],
    intradaySellPriceAvg: (json["intraday_sell_price_avg"] as num?)?.toDouble(),
    totalQty: json["total_qty"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "client_code": clientCode,
    "isin": isin,
    "security_code": securityCode,
    "quantity": quantity,
    "total_cost": totalCost,
    "avg_price": avgPrice,
    "intraday_buy_quantity": intradayBuyQuantity,
    "intraday_buy_price_avg": intradayBuyPriceAvg,
    "intraday_sell_quantity": intradaySellQuantity,
    "intraday_sell_price_avg": intradaySellPriceAvg,
    "lastPrice": lastPrice,
    "marketValue": marketValue,
    "unrealizedValue": unrealizedValue,
    "realizedValue": realizedValue,
    "total_qty": totalQty,
  };

  PositionModel copyWith({
    int? id,
    String? clientCode,
    String? isin,
    String? securityCode,
    int? quantity,
    double? totalCost,
    double? avgPrice,
    int? intradayBuyQuantity,
    double? intradayBuyPriceAvg,
    int? intradaySellQuantity,
    double? intradaySellPriceAvg,
    double? lastPrice,
    double? marketValue,
    double? unrealizedValue,
    double? realizedValue,
    int? totalQty,
  }) {
    return PositionModel(
      id: id ?? this.id,
      clientCode: clientCode ?? this.clientCode,
      isin: isin ?? this.isin,
      securityCode: securityCode ?? this.securityCode,
      quantity: quantity ?? this.quantity,
      totalCost: totalCost ?? this.totalCost,
      avgPrice: avgPrice ?? this.avgPrice,
      intradayBuyQuantity: intradayBuyQuantity ?? this.intradayBuyQuantity,
      intradayBuyPriceAvg: intradayBuyPriceAvg ?? this.intradayBuyPriceAvg,
      intradaySellQuantity: intradaySellQuantity ?? this.intradaySellQuantity,
      intradaySellPriceAvg: intradaySellPriceAvg ?? this.intradaySellPriceAvg,
      lastPrice: lastPrice ?? this.lastPrice,
      marketValue: marketValue ?? this.marketValue,
      unrealizedValue: unrealizedValue ?? this.unrealizedValue,
      realizedValue: realizedValue ?? this.realizedValue,
      totalQty: totalQty ?? this.totalQty,
    );
  }
}
