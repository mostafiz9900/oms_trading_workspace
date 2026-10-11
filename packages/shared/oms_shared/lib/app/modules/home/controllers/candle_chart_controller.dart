// lib/controllers/candle_chart_controller.dart
import 'dart:math';

import 'package:get/get.dart';
import 'package:market/market.dart' show MarketModel;

import 'historical_volume_controller.dart';

// import 'package:oms_shared/app/core/core.dart'; // MarketModelExtensions

enum ChartType { candle, line }

class CandleChartController extends GetxController {
  bool isLoading = true;
  List<CandleData> chartData = [];

  List<String> timeframes = ['1m', '5m', '15m', '30m', '1H', '1D', '1Y'];
  String selectedTimeframe = '1m';

  ChartType currentChartType = ChartType.candle;
  var activeIndicators = <String>{}.obs;

  double currentPrice = 0.0;
  double priceChange = 0.0;
  double priceChangePercent = 0.0;

  CandleData? get latestCandle => chartData.isNotEmpty ? chartData.last : null;

  double get maxPrice =>
      chartData.isEmpty ? 0 : chartData.map((e) => e.high).reduce(max);
  double get minPrice =>
      chartData.isEmpty ? 0 : chartData.map((e) => e.low).reduce(min);
  double get avgPrice => chartData.isEmpty
      ? 0
      : chartData.map((e) => e.close).reduce((a, b) => a + b) /
            chartData.length;
  double get totalVolume => chartData.isEmpty
      ? 0
      : chartData.map((e) => e.volume).reduce((a, b) => a + b);

  // 🚀 Volume Bar Scale (ভলিউম চার্টের নিচের ২৫% জায়গায় আটকে থাকবে)
  double get maxVolumeScale {
    if (chartData.isEmpty) return 100;
    double maxV = chartData.map((e) => e.volume).reduce(max);
    return maxV <= 0 ? 100 : maxV * 4;
  }

  // 🚀 Professional Zoom Logic (Binance Standard)
  // লেটেস্ট ৩০টি ক্যান্ডেল ফোকাস করে ডানপাশে জুম করে রাখবে
  double get initialZoomFactor {
    if (chartData.isEmpty || chartData.length <= 30) return 1.0;
    return 30 / chartData.length;
  }

  double get initialZoomPosition {
    if (chartData.isEmpty || chartData.length <= 30) return 0.0;
    return 1.0 - initialZoomFactor; // চার্টের একদম ডানপাশে পজিশন করবে
  }

  @override
  void onInit() {
    super.onInit();
    fetchHistoricalData();
  }

  void changeTimeframe(String tf) {
    if (selectedTimeframe == tf) return;
    selectedTimeframe = tf;
    isLoading = true;
    update(['main_view']);
    fetchHistoricalData();
  }

  void toggleChartType(ChartType type) {
    currentChartType = type;
    update(['chart_area']);
  }

  void toggleIndicator(String indicator) {
    if (activeIndicators.contains(indicator)) {
      activeIndicators.remove(indicator);
    } else {
      activeIndicators.add(indicator);
    }
    update(['chart_area']);
  }

  void fetchHistoricalData() {
    isLoading = true;
    update(['main_view']);

    if (Get.isRegistered<HistoricalVolumeController>()) {
      final historyCtrl = Get.find<HistoricalVolumeController>();
      if (!historyCtrl.isLoading && historyCtrl.allData.isNotEmpty) {
        // 🚀 1. Data Cleaning (০ ভ্যালু রিমুভ)
        List<CandleData> parsedData = historyCtrl.chartData
            .where((e) => e.close > 0 && e.high > 0)
            .toList();

        // 🚀 2. Strict Sorting (Oldest to Newest) - চার্ট পারফেক্টলি রেন্ডার হওয়ার শর্ত
        parsedData.sort((a, b) => a.x.compareTo(b.x));
        chartData = parsedData;

        if (chartData.isNotEmpty) {
          currentPrice = chartData.last.close;
          double openPrice = chartData.first.open;
          priceChange = currentPrice - openPrice;
          priceChangePercent = openPrice != 0
              ? (priceChange / openPrice) * 100
              : 0;
        }
      }
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      isLoading = false;
      update(['main_view', 'chart_area', 'stats_card']);
    });
  }

  void updateLiveMarketData(MarketModel liveData) {
    if (chartData.isEmpty) return;

    final currentCandle = chartData.last;
    final now = DateTime.now();

    // এক্সটেনশন ব্যবহার করে একুরেট ডেটা
    currentPrice = (liveData.close != null && liveData.close! > 0)
        ? liveData.close!
        : (liveData.last ?? currentPrice);
    priceChange = liveData.chg ?? priceChange;
    priceChangePercent = liveData.d ?? priceChangePercent;

    bool isSameMinute =
        currentCandle.x.year == now.year &&
        currentCandle.x.month == now.month &&
        currentCandle.x.day == now.day &&
        currentCandle.x.hour == now.hour &&
        currentCandle.x.minute == now.minute;

    double newVolume = (liveData.volume ?? 0).toDouble();

    if (isSameMinute) {
      chartData[chartData.length - 1] = CandleData(
        x: currentCandle.x,
        open: currentCandle.open,
        high: max(currentPrice, currentCandle.high),
        low: min(currentPrice, currentCandle.low),
        close: currentPrice,
        volume: currentCandle.volume + newVolume,
      );
    } else {
      chartData.add(
        CandleData(
          x: DateTime(now.year, now.month, now.day, now.hour, now.minute),
          open: currentPrice,
          high: currentPrice,
          low: currentPrice,
          close: currentPrice,
          volume: newVolume,
        ),
      );
    }

    update(['chart_area', 'stats_card']);
  }
}
