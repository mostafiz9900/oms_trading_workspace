// lib/controllers/candle_chart_controller.dart
import 'dart:math';

import 'package:get/get.dart';
import 'package:market/market.dart' show MarketModel;

import 'historical_volume_controller.dart';

// import 'package:oms_shared/app/core/core.dart'; // আপনার MarketModel Extensions পাথ

enum ChartType { candle, line }

class CandleChartController extends GetxController {
  bool isLoading = true;
  bool isInitialLoad = true;

  List<CandleData> chartData = [];

  List<String> timeframes = ['1m', '5m', '15m', '30m', '1H', '1D', '1W', '1M'];
  String selectedTimeframe = '1D';

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

  // 🚀 ভলিউম বারগুলো প্রাইস ক্যান্ডেলের সাথে ওভারল্যাপ করবে না (নিচের ২০% অংশে থাকবে)
  double get maxVolumeScale {
    if (chartData.isEmpty) return 100;
    double maxV = chartData.map((e) => e.volume).reduce(max);
    return maxV <= 0 ? 100 : maxV * 5.0;
  }

  // ========================================================
  // 🚀 StockNow Style Zoom (Focusing exactly 30 Thick Candles)
  // ========================================================
  double? get initialZoomFactor {
    if (isInitialLoad) {
      if (chartData.isEmpty || chartData.length <= 30) {
        return 1.0;
      } else {
        return 30 /
            chartData
                .length; // 🚀 ৩০টি ক্যান্ডেল মানেই অনেক বড় ও স্পষ্ট ক্যান্ডেল
      }
    }
    return null; // লাইভ আপডেটে জুম লক করবে না
  }

  double? get initialZoomPosition {
    if (isInitialLoad) {
      if (chartData.isEmpty || chartData.length <= 30) {
        return 0.0;
      } else {
        return 1.0 - (30 / chartData.length);
      }
    }
    return null;
  }
  // ========================================================

  @override
  void onInit() {
    super.onInit();
    fetchHistoricalData();
  }

  void changeTimeframe(String tf) {
    if (selectedTimeframe == tf) return;
    selectedTimeframe = tf;
    isLoading = true;
    isInitialLoad = true;
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
        List<CandleData> parsedData = historyCtrl.chartData
            .where((e) => e.close > 0 && e.high > 0)
            .toList();
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

    Future.delayed(const Duration(milliseconds: 150), () {
      isLoading = false;
      update(['main_view', 'chart_area', 'stats_card']);

      Future.delayed(const Duration(milliseconds: 500), () {
        isInitialLoad = false;
      });
    });
  }

  DateTime _getBucketTime(DateTime now, String timeframe) {
    if (timeframe == '1D' || timeframe == '1W' || timeframe == '1M') {
      return DateTime(now.year, now.month, now.day);
    }
    if (timeframe == '1H')
      return DateTime(now.year, now.month, now.day, now.hour);
    if (timeframe == '1m')
      return DateTime(now.year, now.month, now.day, now.hour, now.minute);

    int min = now.minute;
    if (timeframe == '5m') min = (min ~/ 5) * 5;
    if (timeframe == '15m') min = (min ~/ 15) * 15;
    if (timeframe == '30m') min = (min ~/ 30) * 30;

    return DateTime(now.year, now.month, now.day, now.hour, min);
  }

  void updateLiveMarketData(MarketModel liveData) {
    if (chartData.isEmpty || isLoading) return;

    final now = DateTime.now();
    final bucketTime = _getBucketTime(now, selectedTimeframe);

    currentPrice = (liveData.close != null && liveData.close! > 0)
        ? liveData.close!
        : (liveData.last ?? currentPrice);
    priceChange = liveData.chg ?? priceChange;
    priceChangePercent = liveData.d ?? priceChangePercent;

    double newVolume = (liveData.volume ?? 0).toDouble();
    final lastCandle = chartData.last;

    bool isSameBucket =
        lastCandle.x.millisecondsSinceEpoch ==
        bucketTime.millisecondsSinceEpoch;

    if (isSameBucket) {
      chartData[chartData.length - 1] = CandleData(
        x: lastCandle.x,
        open: lastCandle.open,
        high: max(currentPrice, lastCandle.high),
        low: min(currentPrice, lastCandle.low),
        close: currentPrice,
        volume: lastCandle.volume + newVolume,
      );
    } else {
      chartData.add(
        CandleData(
          x: bucketTime,
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
