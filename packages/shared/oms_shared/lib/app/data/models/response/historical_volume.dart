// lib/models/historical_volume.dart
class HistoricalVolume {
  final String date;
  final double close;
  final int volume;
  final double high;
  final double low;
  final double open;

  HistoricalVolume({
    required this.date,
    required this.close,
    required this.volume,
    required this.high,
    required this.low,
    required this.open,
  });

  factory HistoricalVolume.fromJson(Map<String, dynamic> json) {
    return HistoricalVolume(
      date: json['date']?.toString() ?? '',
      close: (json['close'] ?? 0).toDouble(),
      volume: json['volume'] ?? 0,
      high: (json['high'] ?? 0).toDouble(),
      low: (json['low'] ?? 0).toDouble(),
      open: (json['open'] ?? 0).toDouble(),
    );
  }

  double get priceChange => close - open;
  double get priceChangePercent =>
      open != 0 ? ((close - open) / open) * 100 : 0;
  bool get isPositive => close >= open;
}

class PriceTableResponse {
  final List<HistoricalVolume> data;
  final int orderbook;
  final bool success;
  final String tickerName;

  PriceTableResponse({
    required this.data,
    required this.orderbook,
    required this.success,
    required this.tickerName,
  });

  factory PriceTableResponse.fromJson(Map<String, dynamic> json) {
    final List<HistoricalVolume> volumes = [];
    final dataList = json['data'] as List? ?? [];

    for (var weekData in dataList) {
      final dailyDetails = weekData['daily_details'] as List? ?? [];
      for (var day in dailyDetails) {
        volumes.add(HistoricalVolume.fromJson(day));
      }
    }

    // Sort by date (newest first)
    volumes.sort((a, b) => b.date.compareTo(a.date));

    return PriceTableResponse(
      data: volumes,
      orderbook: json['orderbook'] ?? 0,
      success: json['success'] ?? false,
      tickerName: json['ticker_name'] ?? 'Unknown',
    );
  }
}
