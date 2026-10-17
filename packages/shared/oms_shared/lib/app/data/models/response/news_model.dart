// To parse this JSON data, do
//
//     final newsModel = newsModelFromJson(jsonString);

import 'dart:convert';

List<NewsModel> newsModelFromMap(dynamic str) => List<NewsModel>.from(
  (str as List<dynamic>).map((x) => NewsModel.fromMap(x)),
);

String newsModelToJson(NewsModel data) => json.encode(data.toMap());

class NewsModel {
  final DateTime? dt;
  final String? t;
  final int? ob;
  final int? nid;
  final String? fid;
  final String? tl;
  final String? rf;
  final String? nt;

  NewsModel({
    this.dt,
    this.t,
    this.ob,
    this.nid,
    this.fid,
    this.tl,
    this.rf,
    this.nt,
  });

  NewsModel copyWith({
    DateTime? dt,
    String? t,
    int? ob,
    int? nid,
    String? fid,
    String? tl,
    String? rf,
    String? nt,
  }) => NewsModel(
    dt: dt ?? this.dt,
    t: t ?? this.t,
    ob: ob ?? this.ob,
    nid: nid ?? this.nid,
    fid: fid ?? this.fid,
    tl: tl ?? this.tl,
    rf: rf ?? this.rf,
    nt: nt ?? this.nt,
  );

  factory NewsModel.fromMap(Map<String, dynamic> json) => NewsModel(
    dt: json["dt"] == null ? null : DateTime.parse(json["dt"]),
    t: json["t"],
    ob: json["ob"],
    nid: json["nid"],
    fid: json["fid"],
    tl: json["tl"],
    rf: json["rf"],
    nt: json["nt"],
  );

  Map<String, dynamic> toMap() => {
    "dt":
        "${dt!.year.toString().padLeft(4, '0')}-${dt!.month.toString().padLeft(2, '0')}-${dt!.day.toString().padLeft(2, '0')}",
    "t": t,
    "ob": ob,
    "nid": nid,
    "fid": fid,
    "tl": tl,
    "rf": rf,
    "nt": nt,
  };
}
