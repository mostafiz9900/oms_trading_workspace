// To parse this JSON data, do
//
//     final timeAndSalesModel = timeAndSalesModelFromMap(jsonString);

import 'dart:convert';

List<TimeAndSalesModel> timeAndSalesModelFromMap(dynamic str) =>
    List<TimeAndSalesModel>.from(
      (str as List<dynamic>).map((x) => TimeAndSalesModel.fromMap(x)),
    );

String timeAndSalesModelToMap(List<TimeAndSalesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class TimeAndSalesModel {
  final String? id;
  final double? p;
  final int? v;
  final String? tst;
  final double? vl;
  final String? tds;
  final String? s;
  final int? tsmId;

  TimeAndSalesModel({
    this.id,
    this.p,
    this.v,
    this.tst,
    this.vl,
    this.tds,
    this.s,
    this.tsmId,
  });

  TimeAndSalesModel copyWith({
    String? id,
    double? p,
    int? v,
    String? tst,
    double? vl,
    String? tds,
    String? s,
    int? tsmId,
  }) => TimeAndSalesModel(
    id: id ?? this.id,
    p: p ?? this.p,
    v: v ?? this.v,
    tst: tst ?? this.tst,
    vl: vl ?? this.vl,
    tds: tds ?? this.tds,
    s: s ?? this.s,
    tsmId: tsmId ?? this.tsmId,
  );

  factory TimeAndSalesModel.fromMap(Map<String, dynamic> json) =>
      TimeAndSalesModel(
        id: json["id"],
        p: json["p"]?.toDouble(),
        v: json["v"],
        tst: json["tst"],
        vl: json["vl"],
        tds: json["tds"].toString(),
        s: json["s"],
        tsmId: json["tsmId"],
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "p": p,
    "v": v,
    "tst": tst,
    "vl": vl,
    "tds": tds,
    "s": s,
    "tsmId": tsmId,
  };
}
