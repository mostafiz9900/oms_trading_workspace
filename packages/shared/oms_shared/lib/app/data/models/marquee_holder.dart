// To parse this JSON data, do
//
//     final marqueeModel = marqueeModelFromJson(jsonString);

import 'dart:convert';

List<MarqueeHolder> marqueeModelFromJson(String str) =>
    List<MarqueeHolder>.from(
      json.decode(str).map((x) => MarqueeHolder.fromJson(x)),
    );

String marqueeModelToJson(List<MarqueeHolder> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MarqueeHolder {
  final dynamic status;
  final String? shortName;
  final double? chg;
  final double? last;
  final double? d;

  MarqueeHolder({this.status, this.shortName, this.chg, this.last, this.d});

  factory MarqueeHolder.fromJson(Map<String, dynamic> json) => MarqueeHolder(
    status: json["status"],
    shortName: json["short_name"],
    chg: json["chg"]?.toDouble(),
    last: json["last"]?.toDouble(),
    d: json["d"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "short_name": shortName,
    "chg": chg,
    "last": last,
    "d": d,
  };
}
