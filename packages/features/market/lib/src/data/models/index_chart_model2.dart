List<IndexChartModel2> indexChartModel2FromJson(dynamic str) =>
    List<IndexChartModel2>.from(
      (str as List<dynamic>).map((x) => IndexChartModel2.fromJson(x)),
    );

class IndexChartModel2 {
  final int timestamp;
  final double price; // Close price
  final double open;
  final double high;
  final double low;
  final double volume;

  IndexChartModel2({
    required this.timestamp,
    required this.price,
    this.open = 0.0,
    this.high = 0.0,
    this.low = 0.0,
    this.volume = 0.0,
  });

  /// Parse standard object list [ { "t": 1722000000, "c": 5874.31, "v": 1200 }, ... ]
  factory IndexChartModel2.fromJson(Map<String, dynamic> json) {
    return IndexChartModel2(
      timestamp: json['t'] ?? json['timestamp'] ?? 0,
      price: (json['c'] ?? json['price'] ?? json['close'] ?? 0.0).toDouble(),
      open: (json['o'] ?? json['open'] ?? 0.0).toDouble(),
      high: (json['h'] ?? json['high'] ?? 0.0).toDouble(),
      low: (json['l'] ?? json['low'] ?? 0.0).toDouble(),
      volume: (json['v'] ?? json['volume'] ?? 0.0).toDouble(),
    );
  }

  /// Parse UDF format { "t": [...], "c": [...], "v": [...] }
  static List<IndexChartModel2> fromUdfJson(Map<String, dynamic> json) {
    final List<IndexChartModel2> list = [];
    if (json['t'] != null && json['c'] != null) {
      final List timestamps = json['t'];
      final List prices = json['c'];
      final List volumes = json['v'] ?? [];

      for (int i = 0; i < timestamps.length; i++) {
        list.add(
          IndexChartModel2(
            timestamp: timestamps[i],
            price: (prices[i] as num).toDouble(),
            volume: volumes.length > i ? (volumes[i] as num).toDouble() : 0.0,
          ),
        );
      }
    }
    return list;
  }
}
