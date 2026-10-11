import 'package:market/market.dart'
    show HistoricalVolume, MarketChartRepository;
// lib/controllers/historical_volume_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app_pkg.dart';

class HistoricalVolumeController extends GetxController {
  // Repository instance
  final MarketChartRepository repository;

  // Constructor with dependency injection
  HistoricalVolumeController({required this.repository});
  var currentView = 'table';

  // States
  bool isLoading = false;
  String errorMessage = '';
  String tickerName = '';
  int orderbook = 0;

  // Data
  List<HistoricalVolume> allData = [];
  List<HistoricalVolume> filteredData = [];

  // Filter states
  String selectedFilter = 'All Time';
  String searchQuery = '';
  String sortBy = 'Date';
  bool sortAscending = false;
  RangeValues priceRange = const RangeValues(0, 100);
  double minPrice = 0.0;
  double maxPriceVar = 100.0;

  // Days filter
  int selectedDays = 10;
  final ValueNotifier<int?> daysNotifier = ValueNotifier<int?>(10);
  final List<int> daysOptions = [
    5,
    7,
    10,
    20,
    30,
    40,
    50,
    60,
    90,
    120,
    180,
    300,
  ];

  final homeController = Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    printLog(
      'init history volume controller:::::${homeController.marketData.shortName}',
    );
    loadData(
      homeController.marketData.shortName ?? '',
      homeController.marketData.orderBook ?? 0,
    );
  }

  void updateUI() {
    update();
  }

  void toggleView(String view) {
    currentView = view;
    update();
  }

  Future<void> loadData(String ticket, int orderbookId) async {
    try {
      isLoading = true;
      errorMessage = '';
      updateUI();

      final response = await repository.getHistoricalVolume(
        ticket,
        orderbookId,
      );

      if (response != null) {
        allData = response.data?.data ?? [];

        // Apply days filter initially
        _applyDaysFilter();

        tickerName = response.data?.tickerName ?? '';
        orderbook = response.data?.orderbook ?? 0;

        if (response.data!.data.isNotEmpty) {
          final prices = response.data!.data.map((d) => d.close).toList();
          if (prices.isNotEmpty) {
            minPrice = prices.reduce((a, b) => a < b ? a : b);
            maxPriceVar = prices.reduce((a, b) => a > b ? a : b);
            priceRange = RangeValues(minPrice, maxPriceVar);
          }
        }

        isLoading = false;
        updateUI();
      } else {
        errorMessage = 'Failed to load data';
        isLoading = false;
        updateUI();
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      isLoading = false;
      updateUI();
    }
  }

  void _applyDaysFilter() {
    if (allData.isEmpty) return;

    // Sort by date first (newest first)
    final sortedData = List<HistoricalVolume>.from(allData);
    sortedData.sort((a, b) => b.date.compareTo(a.date));

    // Take only selected days
    filteredData = sortedData.take(selectedDays).toList();
    applySorting();
  }

  void setDaysFilter(int days) {
    selectedDays = days;
    daysNotifier.value = days;
    _applyDaysFilter();
    updateUI();
  }

  void applyFilters() {
    if (allData.isEmpty) return;

    final sortedData = List<HistoricalVolume>.from(allData);
    sortedData.sort((a, b) => b.date.compareTo(a.date));
    var tempData = sortedData.take(selectedDays).toList();

    final filtered = tempData.where((item) {
      bool matchesTime = true;
      final now = DateTime.now();

      try {
        final dataDate = DateTime.parse(item.date);
        switch (selectedFilter) {
          case 'Last 30 Days':
            matchesTime = dataDate.isAfter(
              now.subtract(const Duration(days: 30)),
            );
            break;
          case 'Last 90 Days':
            matchesTime = dataDate.isAfter(
              now.subtract(const Duration(days: 90)),
            );
            break;
          default:
            matchesTime = true;
        }
      } catch (_) {}

      bool matchesVolume = true;
      if (selectedFilter == 'High Volume (>1M)') {
        matchesVolume = item.volume > 1000000;
      }

      bool matchesPriceChange = true;
      if (selectedFilter == 'Price Increase') {
        matchesPriceChange = item.isPositive;
      } else if (selectedFilter == 'Price Decrease') {
        matchesPriceChange = !item.isPositive;
      }

      bool matchesPriceRange =
          item.close >= priceRange.start && item.close <= priceRange.end;

      bool matchesSearch =
          searchQuery.isEmpty ||
          item.date.contains(searchQuery) ||
          item.close.toString().contains(searchQuery) ||
          item.volume.toString().contains(searchQuery);

      return matchesTime &&
          matchesVolume &&
          matchesPriceChange &&
          matchesPriceRange &&
          matchesSearch;
    }).toList();

    filteredData = filtered;
    applySorting();
    updateUI();
  }

  void applySorting() {
    final sorted = List<HistoricalVolume>.from(filteredData);

    switch (sortBy) {
      case 'Date':
        sorted.sort(
          (a, b) => sortAscending
              ? a.date.compareTo(b.date)
              : b.date.compareTo(a.date),
        );
        break;
      case 'Open':
        sorted.sort(
          (a, b) => sortAscending
              ? a.open.compareTo(b.open)
              : b.open.compareTo(a.open),
        );
        break;
      case 'High':
        sorted.sort(
          (a, b) => sortAscending
              ? a.high.compareTo(b.high)
              : b.high.compareTo(a.high),
        );
        break;
      case 'Low':
        sorted.sort(
          (a, b) =>
              sortAscending ? a.low.compareTo(b.low) : b.low.compareTo(a.low),
        );
        break;
      case 'Close':
        sorted.sort(
          (a, b) => sortAscending
              ? a.close.compareTo(b.close)
              : b.close.compareTo(a.close),
        );
        break;
      case 'Volume':
        sorted.sort(
          (a, b) => sortAscending
              ? a.volume.compareTo(b.volume)
              : b.volume.compareTo(a.volume),
        );
        break;
      case 'Change':
        sorted.sort(
          (a, b) => sortAscending
              ? a.priceChange.compareTo(b.priceChange)
              : b.priceChange.compareTo(a.priceChange),
        );
        break;
      case 'Ch(%)':
        sorted.sort(
          (a, b) => sortAscending
              ? a.priceChangePercent.compareTo(b.priceChangePercent)
              : b.priceChangePercent.compareTo(a.priceChangePercent),
        );
        break;
    }

    filteredData = sorted;
    updateUI();
  }

  void setSelectedFilter(String filter) {
    selectedFilter = filter;
    applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    applyFilters();
  }

  void setSortBy(String sort) {
    if (sortBy == sort) {
      sortAscending = !sortAscending;
    } else {
      sortBy = sort;
      sortAscending = false;
    }
    applySorting();
  }

  void setPriceRange(RangeValues values) {
    priceRange = values;
    applyFilters();
  }

  void refreshData() {
    loadData(
      homeController.marketData.shortName ?? '',
      homeController.marketData.orderBook ?? 0,
    );
  }

  // ==========================================
  // FIXED STATISTICS & CALCULATIONS
  // ==========================================

  int get totalVolume {
    if (filteredData.isEmpty) return 0;
    return filteredData.fold<int>(0, (sum, item) => sum + item.volume);
  }

  // ঠিক করা হলো: সরাসরি filteredData চেক করা হয়েছে
  double get avgPrice {
    if (filteredData.isEmpty) return 0.0;
    final total = filteredData.fold<double>(
      0.0,
      (sum, item) => sum + item.close,
    );
    return total / filteredData.length;
  }

  // ঠিক করা হলো: সঠিক হাই (High) প্রাইস থেকে ম্যাক্স বের করা
  double get maxPrice {
    if (filteredData.isEmpty) return 0.0;
    return filteredData.map((e) => e.high).reduce((a, b) => a > b ? a : b);
  }

  // ঠিক করা হলো: সঠিক লো (Low) প্রাইস থেকে মিনিমাম বের করা
  double get minPriceValue {
    if (filteredData.isEmpty) return 0.0;
    return filteredData.map((e) => e.low).reduce((a, b) => a < b ? a : b);
  }

  int get avgVolume {
    return filteredData.isNotEmpty ? totalVolume ~/ filteredData.length : 0;
  }

  int get maxVolume {
    if (filteredData.isEmpty) return 0;
    return filteredData.map((e) => e.volume).reduce((a, b) => a > b ? a : b);
  }

  int get minVolume {
    if (filteredData.isEmpty) return 0;
    return filteredData.map((e) => e.volume).reduce((a, b) => a < b ? a : b);
  }

  List<HistoricalVolume> get _sortedFilteredData {
    final list = List<HistoricalVolume>.from(filteredData);
    list.sort((a, b) => b.date.compareTo(a.date)); // Newest first
    return list;
  }

  double get priceChange {
    final data = _sortedFilteredData;
    if (data.isEmpty) return 0.0;
    final latest = data.first.close;
    final earliest = data.last.close;
    return latest - earliest;
  }

  double get priceChangePercent {
    final data = _sortedFilteredData;
    if (data.isEmpty || data.last.close == 0) return 0.0;
    return (priceChange / data.last.close) * 100;
  }

  bool get isPricePositive => priceChange >= 0;

  // ==========================================
  // UTILITY & FORMATTERS
  // ==========================================

  String formatDate(String date) {
    try {
      final DateFormat inputFormat = DateFormat("yyyy-MM-dd");
      final DateFormat outputFormat = DateFormat("dd-MMM-yy");
      final DateTime dateTime = inputFormat.parse(date);
      return outputFormat.format(dateTime);
    } catch (e) {
      return date;
    }
  }

  String getDayOfWeek(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  // চার্টে দেখানোর জন্য ডাটা প্রিপারেশন
  List<CandleData> get chartData {
    return allData.reversed.map((item) {
      return CandleData(
        x: DateTime.parse(item.date),
        open: item.open,
        high: item.high,
        low: item.low,
        close: item.close,
        volume: item.volume.toDouble(),
      );
    }).toList();
  }

  double getMovingAverage(int index, List<CandleData> data) {
    int period = 5;
    if (index < period) return data[index].volume;
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += data[index - i].volume;
    }
    return sum / period;
  }

  double getTableHeightFactor(int days) {
    if (days <= 10) return 0.40;
    if (days <= 40) return 0.60;
    if (days <= 90) return 0.80;
    if (days <= 180) return 0.90;
    return 0.95;
  }
}

// চার্টের জন্য মডেল ক্লাস
class CandleData {
  final DateTime x;
  final double open, high, low, close, volume;
  CandleData({
    required this.x,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
}
