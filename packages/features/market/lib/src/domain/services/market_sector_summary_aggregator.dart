import '../../data/models/market_model.dart';
import '../../data/models/sector_data_model.dart';

/// Builds sector totals and average price-change values from market quotes.
class MarketSectorSummaryAggregator {
  List<SectorDataModel> generate(List<MarketModel> marketItems) {
    final sectorMap = <String, _SectorAccumulator>{};

    for (final item in marketItems) {
      if (item.group == 'PUBLIC' &&
          (item.board == 'Main Board' || item.board == 'Small Cap Board')) {
        final sector = (item.sector != null && item.sector != '')
            ? item.sector!
            : (item.group ?? 'Others');
        final accumulator = sectorMap.putIfAbsent(
          sector,
          () => _SectorAccumulator(sectorName: sector),
        );

        accumulator
          ..stocks.add(item)
          ..totalValue += item.val ?? 0.0
          ..totalVolume += item.volume ?? 0
          ..totalTrades += item.trades ?? 0
          ..totalOpen += item.open ?? 0.0
          ..totalHigh += item.high ?? 0.0
          ..totalLow += item.low ?? 0.0
          ..totalYcp += item.reference ?? 0.0
          ..totalBidQty += item.bq ?? 0
          ..totalAskQty += item.aq ?? 0
          ..totalChangeTk += item.chg ?? 0.0
          ..sumLast += item.last ?? 0.0
          ..sumVwap += item.vwap ?? 0.0
          ..sumToday += item.d ?? 0.0
          ..sum1Week += item.chp1w ?? 0.0
          ..sum1Month += item.chp1m ?? 0.0
          ..sum6Month += item.chp6m ?? 0.0
          ..sum1Year += item.chp1y ?? 0.0;
      }
    }

    final summaries = sectorMap.values.map((accumulator) {
      final count = accumulator.stocks.isNotEmpty
          ? accumulator.stocks.length
          : 1;
      return SectorDataModel(
        sectorName: accumulator.sectorName,
        stocks: accumulator.stocks,
        totalValue: accumulator.totalValue,
        totalVolume: accumulator.totalVolume,
        totalTrades: accumulator.totalTrades,
        totalOpen: accumulator.totalOpen,
        totalHigh: accumulator.totalHigh,
        totalLow: accumulator.totalLow,
        totalYcp: accumulator.totalYcp,
        totalBidQty: accumulator.totalBidQty,
        totalAskQty: accumulator.totalAskQty,
        totalChangeTk: accumulator.totalChangeTk,
        avgTodayChange: accumulator.sumToday / count,
        avg1WeekChange: accumulator.sum1Week / count,
        avg1MonthChange: accumulator.sum1Month / count,
        avg6MonthChange: accumulator.sum6Month / count,
        avg1YearChange: accumulator.sum1Year / count,
        avgLastPrice: accumulator.sumLast / count,
        avgVwap: accumulator.sumVwap / count,
      );
    }).toList();

    summaries.sort((a, b) => b.totalValue.compareTo(a.totalValue));
    return summaries;
  }
}

class _SectorAccumulator {
  _SectorAccumulator({required this.sectorName});

  final String sectorName;
  final List<MarketModel> stocks = [];
  double totalValue = 0,
      totalOpen = 0,
      totalHigh = 0,
      totalLow = 0,
      totalYcp = 0,
      totalChangeTk = 0;
  double sumToday = 0, sum1Week = 0, sum1Month = 0, sum6Month = 0, sum1Year = 0;
  double sumLast = 0, sumVwap = 0;
  int totalVolume = 0, totalTrades = 0, totalBidQty = 0, totalAskQty = 0;
}
