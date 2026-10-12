import 'dart:convert';

PositionResponse positionResponseFromJson(String str) =>
    PositionResponse.fromJson(json.decode(str));

String positionResponseToJson(PositionResponse data) =>
    json.encode(data.toJson());

class PositionResponse {
  final bool? success;
  final String? message;
  final String? messageType;
  final List<PositionModel>? data;

  PositionResponse({this.success, this.message, this.messageType, this.data});

  PositionResponse copyWith({
    bool? success,
    String? message,
    String? messageType,
    List<PositionModel>? data,
  }) => PositionResponse(
    success: success ?? this.success,
    message: message ?? this.message,
    messageType: messageType ?? this.messageType,
    data: data ?? this.data,
  );

  factory PositionResponse.fromJson(Map<String, dynamic> json) {
    var rawData = json["data"];
    List<PositionModel> parsedData = [];

    if (rawData is List) {
      parsedData = rawData.map((x) => PositionModel.fromJson(x)).toList();
    } else if (rawData is Map<String, dynamic>) {
      parsedData = [PositionModel.fromJson(rawData)];
    }

    return PositionResponse(
      success: json["success"],
      message: json["message"],
      messageType: json["message_type"],
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "message_type": messageType,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class PositionModel {
  final int? id;
  final String? investorName;
  final String? clientCode;
  final String? securityCode;
  final String? isin;
  final int? initialQuantity;
  final int? quantity;
  final double? totalCost;
  final double? avgPrice;
  final int? sellablePosition;
  final int? intradayBuyQuantity;
  final double? intradayBuyPriceAvg;
  final int? intradaySellQuantity;
  final double? intradaySellPriceAvg;
  final double? realizedPnl;
  final int? totalQty;

  PositionModel({
    this.id,
    this.investorName,
    this.clientCode,
    this.securityCode,
    this.isin,
    this.initialQuantity,
    this.quantity,
    this.totalCost,
    this.avgPrice,
    this.sellablePosition,
    this.intradayBuyQuantity,
    this.intradayBuyPriceAvg,
    this.intradaySellQuantity,
    this.intradaySellPriceAvg,
    this.realizedPnl,
    this.totalQty,
  });

  PositionModel copyWith({
    int? id,
    String? investorName,
    String? clientCode,
    String? securityCode,
    String? isin,
    int? initialQuantity,
    int? quantity,
    double? totalCost,
    double? avgPrice,
    int? sellablePosition,
    int? intradayBuyQuantity,
    double? intradayBuyPriceAvg,
    int? intradaySellQuantity,
    double? intradaySellPriceAvg,
    double? realizedPnl,
    int? totalQty,
  }) => PositionModel(
    id: id ?? this.id,
    investorName: investorName ?? this.investorName,
    clientCode: clientCode ?? this.clientCode,
    securityCode: securityCode ?? this.securityCode,
    isin: isin ?? this.isin,
    initialQuantity: initialQuantity ?? this.initialQuantity,
    quantity: quantity ?? this.quantity,
    totalCost: totalCost ?? this.totalCost,
    avgPrice: avgPrice ?? this.avgPrice,
    sellablePosition: sellablePosition ?? this.sellablePosition,
    intradayBuyQuantity: intradayBuyQuantity ?? this.intradayBuyQuantity,
    intradayBuyPriceAvg: intradayBuyPriceAvg ?? this.intradayBuyPriceAvg,
    intradaySellQuantity: intradaySellQuantity ?? this.intradaySellQuantity,
    intradaySellPriceAvg: intradaySellPriceAvg ?? this.intradaySellPriceAvg,
    realizedPnl: realizedPnl ?? this.realizedPnl,
    totalQty: totalQty ?? this.totalQty,
  );

  factory PositionModel.fromJson(Map<String, dynamic> json) => PositionModel(
    id: json["id"],
    investorName: json["investor_name"],
    clientCode: json["client_code"],
    securityCode: json["security_code"],
    isin: json["isin"],
    initialQuantity: json["initial_quantity"],
    quantity: json["quantity"],
    totalCost: json["total_cost"]?.toDouble(),
    avgPrice: json["avg_price"]?.toDouble(),
    sellablePosition: json["sellable_position"],
    intradayBuyQuantity: json["intraday_buy_quantity"],
    intradayBuyPriceAvg: json["intraday_buy_price_avg"]?.toDouble(),
    intradaySellQuantity: json["intraday_sell_quantity"],
    intradaySellPriceAvg: json["intraday_sell_price_avg"]?.toDouble(),
    realizedPnl: json["realized_pnl"]?.toDouble(), // Fixed: added ?.toDouble()
    totalQty: json["total_qty"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "investor_name": investorName,
    "client_code": clientCode,
    "security_code": securityCode,
    "isin": isin,
    "initial_quantity": initialQuantity,
    "quantity": quantity,
    "total_cost": totalCost,
    "avg_price": avgPrice,
    "sellable_position": sellablePosition,
    "intraday_buy_quantity": intradayBuyQuantity,
    "intraday_buy_price_avg": intradayBuyPriceAvg,
    "intraday_sell_quantity": intradaySellQuantity,
    "intraday_sell_price_avg": intradaySellPriceAvg,
    "realized_pnl": realizedPnl,
    "total_qty": totalQty,
  };
}
