// To parse this JSON data, do
//
//     final indexChartModel = indexChartModelFromJson(jsonString);

import 'dart:convert';

List<IndexChartModel> indexChartModelFromJson(dynamic str) =>
    List<IndexChartModel>.from(
      (str as List<dynamic>).map((x) => IndexChartModel.fromJson(x)),
    );

String indexChartModelToJson(List<IndexChartModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class IndexChartModel {
  final double? changeNew;
  final DateTime? lmDateTime;
  final double? ltp;
  final int? totalVolume;
  final int? volumeNew;

  IndexChartModel({
    this.changeNew,
    this.lmDateTime,
    this.ltp,
    this.totalVolume,
    this.volumeNew,
  });

  IndexChartModel copyWith({
    double? changeNew,
    DateTime? lmDateTime,
    double? ltp,
    int? totalVolume,
    int? volumeNew,
  }) => IndexChartModel(
    changeNew: changeNew ?? this.changeNew,
    lmDateTime: lmDateTime ?? this.lmDateTime,
    ltp: ltp ?? this.ltp,
    totalVolume: totalVolume ?? this.totalVolume,
    volumeNew: volumeNew ?? this.volumeNew,
  );

  factory IndexChartModel.fromJson(Map<String, dynamic> json) =>
      IndexChartModel(
        changeNew: json["change_new"]?.toDouble(),
        lmDateTime: json["lm_date_time"] == null
            ? null
            : DateTime.parse(json["lm_date_time"]),
        ltp: json["ltp"]?.toDouble(),
        totalVolume: json["total_volume"],
        volumeNew: json["volume_new"],
      );

  Map<String, dynamic> toJson() => {
    "change_new": changeNew,
    "lm_date_time": lmDateTime?.toIso8601String(),
    "ltp": ltp,
    "total_volume": totalVolume,
    "volume_new": volumeNew,
  };
}
