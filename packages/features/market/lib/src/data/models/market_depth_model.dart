// To parse this JSON data, do
//
//     final marketDepthModel = marketDepthModelFromJson(jsonString);

import 'dart:convert';

List<MarketDepthModel> marketDepthModelFromJson(String str) =>
    List<MarketDepthModel>.from(
      json.decode(str).map((x) => MarketDepthModel.fromJson(x)),
    );

String marketDepthModelToJson(List<MarketDepthModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MarketDepthModel {
  final int? q;
  final double? p;
  final int? o;
  final int? cq;

  MarketDepthModel({this.q, this.p, this.o, this.cq});

  MarketDepthModel copyWith({int? q, double? p, int? o, int? cq}) =>
      MarketDepthModel(
        q: q ?? this.q,
        p: p ?? this.p,
        o: o ?? this.o,
        cq: cq ?? this.cq,
      );

  factory MarketDepthModel.fromJson(Map<String, dynamic> json) =>
      MarketDepthModel(
        q: json["q"],
        p: json["p"]?.toDouble(),
        o: json["o"],
        cq: json["cq"],
      );

  Map<String, dynamic> toJson() => {"q": q, "p": p, "o": o, "cq": cq};
}

class MarketDepthData {
  final List<MarketDepthModel> buy;
  final List<MarketDepthModel> sell;

  MarketDepthData({required this.buy, required this.sell});

  factory MarketDepthData.fromJson(Map<String, dynamic> json) {
    List<MarketDepthModel> parseSide(dynamic data) {
      if (data is List) {
        return data.map((e) => MarketDepthModel.fromJson(e)).toList();
      }
      return []; // If it's {} or null, return empty list
    }

    return MarketDepthData(
      buy: parseSide(json['buy']),
      sell: parseSide(json['sell']),
    );
  }
}
