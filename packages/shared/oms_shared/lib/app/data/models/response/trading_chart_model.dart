import 'dart:convert';

class TradingChartModel {
  List<int>? t; // time (Unix timestamp)
  List<double>? o; // open
  List<double>? h; // high
  List<double>? l; // low
  List<double>? c; // close
  List<int>? v; // volume
  String? s; // status

  TradingChartModel({this.t, this.o, this.h, this.l, this.c, this.v, this.s});

  factory TradingChartModel.fromJson(Map<String, dynamic> json) {
    return TradingChartModel(
      t: json['t'] != null ? List<int>.from(json['t']) : null,
      o: json['o'] != null
          ? List<double>.from(
              json['o'].map((x) => double.tryParse(x.toString()) ?? 0.0),
            )
          : null,
      h: json['h'] != null
          ? List<double>.from(
              json['h'].map((x) => double.tryParse(x.toString()) ?? 0.0),
            )
          : null,
      l: json['l'] != null
          ? List<double>.from(
              json['l'].map((x) => double.tryParse(x.toString()) ?? 0.0),
            )
          : null,
      c: json['c'] != null
          ? List<double>.from(
              json['c'].map((x) => double.tryParse(x.toString()) ?? 0.0),
            )
          : null,
      v: json['v'] != null
          ? List<int>.from(
              json['v'].map((x) => int.tryParse(x.toString()) ?? 0),
            )
          : null,
      s: json['s'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"t": t, "o": o, "h": h, "l": l, "c": c, "v": v, "s": s};
  }

  TradingChartModel copyWith({
    List<int>? t,
    List<double>? o,
    List<double>? h,
    List<double>? l,
    List<double>? c,
    List<int>? v,
    String? s,
  }) {
    return TradingChartModel(
      t: t ?? this.t,
      o: o ?? this.o,
      h: h ?? this.h,
      l: l ?? this.l,
      c: c ?? this.c,
      v: v ?? this.v,
      s: s ?? this.s,
    );
  }

  static TradingChartModel fromJsonString(String str) =>
      TradingChartModel.fromJson(json.decode(str));

  String toJsonString() => json.encode(toJson());
}

//
// class CandleData {
//   final DateTime? time;
//   final double? open;
//   final double? high;
//   final double? low;
//   final double? close;
//   final int? volume;
//
//   CandleData({
//      this.time,
//      this.open,
//      this.high,
//      this.low,
//      this.close,
//      this.volume,
//   });
//
//   CandleData copyWith({
//     DateTime? time,
//     double? open,
//     double? high,
//     double? low,
//     double? close,
//     int? volume,
//   }) {
//     return CandleData(
//       time: time ?? this.time,
//       open: open ?? this.open,
//       high: high ?? this.high,
//       low: low ?? this.low,
//       close: close ?? this.close,
//       volume: volume ?? this.volume,
//     );
//   }
//   List<CandleData> parseCandleData(Map<String, dynamic> json) {
//     final times = List<int>.from(json['t']);
//     final opens = json['o'].map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
//     final highs = json['h'].map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
//     final lows = json['l'].map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
//     final closes = json['c'].map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
//     final volumes = List<int>.from(json['v']);
//
//     return List.generate(times.length, (i) {
//       return CandleData(
//         time: DateTime.fromMillisecondsSinceEpoch(times[i] * 1000, isUtc: true),
//         open: opens[i],
//         high: highs[i],
//         low: lows[i],
//         close: closes[i],
//         volume: volumes[i],
//       );
//     });
//   }
//
//   @override
//   String toString() {
//     return 'CandleData(time: $time, O: $open, H: $high, L: $low, C: $close, V: $volume)';
//   }
// }
