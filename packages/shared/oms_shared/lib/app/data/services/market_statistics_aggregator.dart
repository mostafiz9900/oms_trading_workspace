/// Aggregates market ticks into the chart data used by sector screens.
///
/// This class contains no Flutter or socket dependencies so broker apps can
/// share the same market statistics behavior.
class MarketStatisticsAggregator {
  final Map<String, Map<String, int>> sectorSummary = {};
  final Map<String, Map<String, int>> sectorShareTypeSummary = {};
  final Map<String, String> lastShareType = {};

  List<Map<String, dynamic>> chartData = [];
  List<Map<String, dynamic>> chartDataShareType = [];

  bool processGainerTick(Map<String, dynamic> tick) {
    if (tick['sn'] == null || tick['sc'] == null) return false;
    if (tick['sc'] == 'TBond') return false;

    var sector = tick['sc'].toString();
    final state = (tick['s'] ?? '').toString();
    if (tick['b'] == 'Small Cap Board') sector = 'SME';
    if (!const ['u', 'd', 'uc'].contains(state)) return false;

    sectorSummary.putIfAbsent(sector, () => {'u': 0, 'd': 0, 'uc': 0});
    sectorSummary[sector]![state] = (sectorSummary[sector]![state] ?? 0) + 1;
    chartData = _buildGainerChart();
    return true;
  }

  bool processShareTypeTick(Map<String, dynamic> tick) {
    if (tick['sc'] == 'TBond') return false;

    final shareType = tick['st']?.toString();
    final sector = tick['sc']?.toString();
    final orderBookId = tick['ob']?.toString();
    if (sector == null || orderBookId == null) return false;
    if (!const ['A', 'B', 'N', 'Z'].contains(shareType)) return false;

    sectorShareTypeSummary.putIfAbsent(
      sector,
      () => {'A': 0, 'B': 0, 'N': 0, 'Z': 0},
    );
    if (lastShareType[orderBookId] == shareType) return false;

    if (lastShareType.containsKey(orderBookId)) {
      final previous = lastShareType[orderBookId]!;
      if (sectorShareTypeSummary[sector]![previous]! > 0) {
        sectorShareTypeSummary[sector]![previous] =
            sectorShareTypeSummary[sector]![previous]! - 1;
      }
    }

    sectorShareTypeSummary[sector]![shareType!] =
        (sectorShareTypeSummary[sector]![shareType] ?? 0) + 1;
    lastShareType[orderBookId] = shareType;
    chartDataShareType = _buildShareTypeChart();
    return true;
  }

  List<Map<String, dynamic>> getGainerChartData() => _buildGainerChart();

  List<Map<String, dynamic>> getGainerCountsChartData() =>
      sectorSummary.entries.map((entry) {
        final value = entry.value;
        return {
          'sector': entry.key,
          'up': (value['u'] ?? 0).toDouble(),
          'down': (value['d'] ?? 0).toDouble(),
          'equal': (value['uc'] ?? 0).toDouble(),
        };
      }).toList();

  List<Map<String, dynamic>> getShareTypeChartData() => _buildShareTypeChart();

  List<Map<String, dynamic>> _buildGainerChart() {
    final data = sectorSummary.entries.map((entry) {
      final value = entry.value;
      final up = value['u'] ?? 0;
      final down = value['d'] ?? 0;
      final equal = value['uc'] ?? 0;
      return {
        'sector': entry.key,
        'up': up.toDouble(),
        'down': down.toDouble(),
        'equal': equal.toDouble(),
        'total': (up + down + equal).toDouble(),
      };
    }).toList();
    data.sort((a, b) => (b['total'] as double).compareTo(a['total'] as double));
    return data;
  }

  List<Map<String, dynamic>> _buildShareTypeChart() =>
      sectorShareTypeSummary.entries.map((entry) {
        final value = entry.value;
        final a = value['A'] ?? 0;
        final b = value['B'] ?? 0;
        final n = value['N'] ?? 0;
        final z = value['Z'] ?? 0;
        return {
          'sector': entry.key,
          'A': a.toDouble(),
          'B': b.toDouble(),
          'N': n.toDouble(),
          'Z': z.toDouble(),
          'total': (a + b + n + z).toDouble(),
        };
      }).toList();
}
