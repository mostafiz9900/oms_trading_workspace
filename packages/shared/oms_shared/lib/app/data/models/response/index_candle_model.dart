import 'dart:convert';

// 🚀 Helper functions for fast JSON parsing
List<IndexCandleModel> indexCandleModelFromJson(dynamic str) =>
    List<IndexCandleModel>.from(
      (str as List<dynamic>).map((x) => IndexCandleModel.fromJson(x)),
    );

String indexCandleModelToJson(List<IndexCandleModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class IndexCandleModel {
  final double? close;
  final double? high;
  final double? low;
  final double? open;
  final int? timestamp;
  final double? volume;

  IndexCandleModel({
    this.close,
    this.high,
    this.low,
    this.open,
    this.timestamp,
    this.volume,
  });

  // =======================================================
  // 🟢 Live Data Update এর জন্য CopyWith Method
  // =======================================================
  IndexCandleModel copyWith({
    double? close,
    double? high,
    double? low,
    double? open,
    int? timestamp,
    double? volume,
  }) {
    return IndexCandleModel(
      close: close ?? this.close,
      high: high ?? this.high,
      low: low ?? this.low,
      open: open ?? this.open,
      timestamp: timestamp ?? this.timestamp,
      volume: volume ?? this.volume,
    );
  }

  // =======================================================
  // 🟢 JSON Serialization (Safe Parsing)
  // =======================================================
  factory IndexCandleModel.fromJson(Map<String, dynamic> json) =>
      IndexCandleModel(
        close: (json["close"] as num?)?.toDouble(),
        high: (json["high"] as num?)?.toDouble(),
        low: (json["low"] as num?)?.toDouble(),
        open: (json["open"] as num?)?.toDouble(),
        timestamp: (json["timestamp"] as num?)?.toInt(),
        volume: (json["volume"] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
    "close": close,
    "high": high,
    "low": low,
    "open": open,
    "timestamp": timestamp,
    "volume": volume,
  };

  // =======================================================
  // 🟢 Helper Properties for UI & Charts
  // =======================================================

  // 🚀 Chart এ Date/Time দেখানোর জন্য Unix Timestamp কে DateTime এ কনভার্ট করা
  DateTime? get time {
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
  }
}
