import '../../../data/models/response/index_chart_model.dart' show IndexChartModel;
import '../../../data/repositories/market_chart_repository.dart' show MarketChartRepository;

import 'dart:math';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/utils/extensions/app_context.dart';



class MarketIndexController extends GetxController {
  final MarketChartRepository repository;
  MarketIndexController(this.repository);

  List<IndexChartModel> allData = [];
  String indexName = "DSEX";

  bool isLoading = false;
  String? errorMessage;

  // Timeframe Filter States
  String selectedTimeframe = '1D';
  final List<String> timeframes = ['1D', '1W', '1M', '1Y', 'ALL'];

  // Interactive Hover/Touch Model
  IndexChartModel? hoveredItem;

  // Dynamic X-Axis Properties
  DateTimeIntervalType xAxisIntervalType = DateTimeIntervalType.minutes;
  double xAxisInterval = 30;
  DateFormat xAxisDateFormat = DateFormat('HH:mm');

  void changeTimeframe(String tf) {
    if (selectedTimeframe == tf && allData.isNotEmpty) return;
    selectedTimeframe = tf;

    DateTime now = DateTime.now();
    DateTime fromDate;

    switch (tf) {
      case '1D':
        fromDate = now;
        xAxisIntervalType = DateTimeIntervalType.minutes;
        xAxisInterval = 30;
        xAxisDateFormat = DateFormat('HH:mm');
        break;
      case '1W':
        fromDate = now.subtract(const Duration(days: 7));
        xAxisIntervalType = DateTimeIntervalType.days;
        xAxisInterval = 1;
        xAxisDateFormat = DateFormat('E d');
        break;
      case '1M':
        fromDate = DateTime(now.year, now.month - 1, now.day);
        xAxisIntervalType = DateTimeIntervalType.days;
        xAxisInterval = 5;
        xAxisDateFormat = DateFormat('dd MMM');
        break;
      case '1Y':
        fromDate = DateTime(now.year - 1, now.month, now.day);
        xAxisIntervalType = DateTimeIntervalType.months;
        xAxisInterval = 2;
        xAxisDateFormat = DateFormat('MMM yy');
        break;
      case 'ALL':
        fromDate = DateTime(2015, 1, 1);
        xAxisIntervalType = DateTimeIntervalType.years;
        xAxisInterval = 1;
        xAxisDateFormat = DateFormat('yyyy');
        break;
      default:
        fromDate = now;
        xAxisIntervalType = DateTimeIntervalType.minutes;
        xAxisInterval = 30;
        xAxisDateFormat = DateFormat('HH:mm');
    }

    String formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate);
    String formattedToDate = DateFormat('yyyy-MM-dd')
        .format(now.add(const Duration(days: 1)));

    loadData(indexName, fromDate: formattedFromDate, toDate: formattedToDate);
  }

  Future<void> loadData(String name, {String? fromDate, String? toDate}) async {
    indexName = name;
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(const Duration(days: 1));

    String formattedFromDate = fromDate ?? DateFormat('yyyy-MM-dd').format(now);
    String formattedToDate =
        toDate ?? DateFormat('yyyy-MM-dd').format(tomorrow);

    if (!await checkInternet()) {
      errorMessage = "No internet connection";
      update();
      return;
    }

    isLoading = true;
    errorMessage = null;
    hoveredItem = null;
    update();

    try {
      var response = await repository.getIndexChart(
        name,
        formattedFromDate,
        formattedToDate,
      );

      if (response.data != null && response.data is List) {
        allData = response.data!;

        // Chronological order sorting
        allData.sort((a, b) {
          DateTime timeA = a.lmDateTime ?? DateTime.now();
          DateTime timeB = b.lmDateTime ?? DateTime.now();
          return timeA.compareTo(timeB);
        });
      } else {
        allData = [];
      }
    } catch (e) {
      errorMessage = "Failed to load chart: ${e.toString()}";
    } finally {
      isLoading = false;
      update();
    }
  }

  void setHoveredItem(IndexChartModel? item) {
    hoveredItem = item;
    update();
  }

  void resetHoveredItem() {
    hoveredItem = null;
    update();
  }

  // ===========================================================================
  // COMPUTED PROPERTIES USING IndexChartModel FIELDS
  // ===========================================================================

  int get activeIndex {
    if (hoveredItem != null) {
      final index = allData.indexOf(hoveredItem!);
      return index != -1
          ? index
          : (allData.isNotEmpty ? allData.length - 1 : 0);
    }
    return allData.isNotEmpty ? allData.length - 1 : 0;
  }

  IndexChartModel? get activeItem =>
      allData.isNotEmpty ? allData[activeIndex] : null;

  // Previous Close Calculation using LTP - changeNew
  double get basePrevClose {
    if (allData.isEmpty) return 0.0;
    final first = allData.first;
    if (first.changeNew != null && first.ltp != null) {
      return first.ltp! - first.changeNew!;
    }
    return first.ltp ?? 0.0;
  }

  double get currentValue => activeItem?.ltp ?? basePrevClose;

  // Change and % Change
  double get change => activeItem?.changeNew ?? (currentValue - basePrevClose);
  double get changePercent =>
      basePrevClose != 0 ? (change / basePrevClose) * 100 : 0.0;
  bool get isBullish => change >= 0;

  // Dynamically calculated OHLC for TradingView/BullBD HUD
  double get displayOpen =>
      allData.isNotEmpty ? (allData.first.ltp ?? 0.0) : 0.0;

  double get displayHigh {
    if (allData.isEmpty) return 0.0;
    final activeRange = allData.take(activeIndex + 1);
    return activeRange.map((e) => e.ltp ?? 0.0).reduce(max);
  }

  double get displayLow {
    if (allData.isEmpty) return 0.0;
    final activeRange = allData.take(activeIndex + 1);
    return activeRange.map((e) => e.ltp ?? 0.0).reduce(min);
  }

  double get displayClose => activeItem?.ltp ?? currentValue;

  double get displayVolume =>
      (activeItem?.volumeNew ?? activeItem?.totalVolume ?? 0).toDouble();

  // Overall Min/Max for Axis Bounds
  double get rawMin {
    if (allData.isEmpty) return 0.0;
    return allData.map((e) => e.ltp ?? basePrevClose).reduce(min);
  }

  double get rawMax {
    if (allData.isEmpty) return 0.0;
    return allData.map((e) => e.ltp ?? basePrevClose).reduce(max);
  }

  // Symmetric Range Around Prev Close (BullBD Style Centered Baseline)
  double get yMin {
    if (allData.isEmpty) return 0.0;
    final double maxDiff = max(
      (rawMax - basePrevClose).abs(),
      (basePrevClose - rawMin).abs(),
    );
    final double padding = maxDiff == 0
        ? (basePrevClose * 0.01)
        : maxDiff * 1.25;
    return max(0.0, basePrevClose - padding);
  }

  double get yMax {
    if (allData.isEmpty) return 100.0;
    final double maxDiff = max(
      (rawMax - basePrevClose).abs(),
      (basePrevClose - rawMin).abs(),
    );
    final double padding = maxDiff == 0
        ? (basePrevClose * 0.01)
        : maxDiff * 1.25;
    return basePrevClose + padding;
  }

  // DSE Trading Hours Fixed Bounds (10:00 AM to 02:30 PM) for 1D
  DateTime? get minX {
    if (selectedTimeframe == '1D' && allData.isNotEmpty) {
      final DateTime firstTime = allData.first.lmDateTime ?? DateTime.now();
      return DateTime(firstTime.year, firstTime.month, firstTime.day, 10, 0);
    }
    return null;
  }

  DateTime? get maxX {
    if (selectedTimeframe == '1D' && allData.isNotEmpty) {
      final DateTime firstTime = allData.first.lmDateTime ?? DateTime.now();
      return DateTime(firstTime.year, firstTime.month, firstTime.day, 14, 30);
    }
    return null;
  }

  double get maxVolume {
    if (allData.isEmpty) return 100.0;
    return allData
        .map((e) => (e.volumeNew ?? e.totalVolume ?? 0).toDouble())
        .reduce(max);
  }
}
