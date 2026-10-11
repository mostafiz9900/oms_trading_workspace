import 'market_model.dart';

class SectorDataModel {
  final String sectorName;
  final List<MarketModel> stocks;
  final double totalValue;
  final int totalVolume;
  final int totalTrades;
  final double totalOpen;
  final double totalHigh;
  final double totalLow;
  final double totalYcp;
  final int totalBidQty;
  final int totalAskQty;
  final double totalChangeTk;
  final double avgTodayChange;
  final double avg1WeekChange;
  final double avg1MonthChange;
  final double avg6MonthChange;
  final double avg1YearChange;
  final double avgLastPrice;
  final double avgVwap;

  SectorDataModel({
    required this.sectorName,
    required this.stocks,
    required this.totalValue,
    required this.totalVolume,
    required this.totalTrades,
    required this.totalOpen,
    required this.totalHigh,
    required this.totalLow,
    required this.totalYcp,
    required this.totalBidQty,
    required this.totalAskQty,
    required this.totalChangeTk,
    required this.avgTodayChange,
    required this.avg1WeekChange,
    required this.avg1MonthChange,
    required this.avg6MonthChange,
    required this.avg1YearChange,
    required this.avgLastPrice,
    required this.avgVwap,
  });

  SectorDataModel copyWith({
    String? sectorName,
    List<MarketModel>? stocks,
    double? totalValue,
    int? totalVolume,
    int? totalTrades,
    double? totalOpen,
    double? totalHigh,
    double? totalLow,
    double? totalYcp,
    int? totalBidQty,
    int? totalAskQty,
    double? totalChangeTk,
    double? avgTodayChange,
    double? avg1WeekChange,
    double? avg1MonthChange,
    double? avg6MonthChange,
    double? avg1YearChange,
    double? avgLastPrice,
    double? avgVwap,
  }) => SectorDataModel(
    sectorName: sectorName ?? this.sectorName,
    stocks: stocks ?? this.stocks,
    totalValue: totalValue ?? this.totalValue,
    totalVolume: totalVolume ?? this.totalVolume,
    totalTrades: totalTrades ?? this.totalTrades,
    totalOpen: totalOpen ?? this.totalOpen,
    totalHigh: totalHigh ?? this.totalHigh,
    totalLow: totalLow ?? this.totalLow,
    totalYcp: totalYcp ?? this.totalYcp,
    totalBidQty: totalBidQty ?? this.totalBidQty,
    totalAskQty: totalAskQty ?? this.totalAskQty,
    totalChangeTk: totalChangeTk ?? this.totalChangeTk,
    avgTodayChange: avgTodayChange ?? this.avgTodayChange,
    avg1WeekChange: avg1WeekChange ?? this.avg1WeekChange,
    avg1MonthChange: avg1MonthChange ?? this.avg1MonthChange,
    avg6MonthChange: avg6MonthChange ?? this.avg6MonthChange,
    avg1YearChange: avg1YearChange ?? this.avg1YearChange,
    avgLastPrice: avgLastPrice ?? this.avgLastPrice,
    avgVwap: avgVwap ?? this.avgVwap,
  );
}
