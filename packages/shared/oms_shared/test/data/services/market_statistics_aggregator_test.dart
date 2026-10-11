import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/data/services/market_statistics_aggregator.dart';

void main() {
  late MarketStatisticsAggregator aggregator;
  setUp(() => aggregator = MarketStatisticsAggregator());

  group('gainer / loser counts per sector', () {
    test('counts up, down and unchanged ticks', () {
      aggregator.processGainerTick({'sn': 'GP', 'sc': 'Telecom', 's': 'u'});
      aggregator.processGainerTick({'sn': 'RB', 'sc': 'Telecom', 's': 'd'});
      aggregator.processGainerTick({'sn': 'BT', 'sc': 'Telecom', 's': 'uc'});

      expect(aggregator.chartData, [
        {'sector': 'Telecom', 'up': 1.0, 'down': 1.0, 'equal': 1.0, 'total': 3.0},
      ]);
    });

    test('Small Cap Board stocks are grouped as SME', () {
      aggregator.processGainerTick({
        'sn': 'X',
        'sc': 'Bank',
        's': 'u',
        'b': 'Small Cap Board',
      });
      expect(aggregator.sectorSummary.keys, ['SME']);
    });

    test('ignores treasury bonds, unknown states and incomplete ticks', () {
      expect(aggregator.processGainerTick({'sn': 'T', 'sc': 'TBond', 's': 'u'}), isFalse);
      expect(aggregator.processGainerTick({'sn': 'A', 'sc': 'Bank', 's': 'x'}), isFalse);
      expect(aggregator.processGainerTick({'sc': 'Bank', 's': 'u'}), isFalse);
      expect(aggregator.processGainerTick({'sn': 'A', 's': 'u'}), isFalse);
      expect(aggregator.sectorSummary, isEmpty);
    });

    test('sectors are sorted by total, largest first', () {
      aggregator.processGainerTick({'sn': 'A', 'sc': 'Bank', 's': 'u'});
      for (final s in ['u', 'd', 'uc']) {
        aggregator.processGainerTick({'sn': 'B', 'sc': 'Pharma', 's': s});
      }
      expect(aggregator.getGainerChartData().map((e) => e['sector']), ['Pharma', 'Bank']);
    });

    // Current behaviour: there is no per-stock de-duplication, so repeated
    // ticks for the same stock raise the count again. See the PR notes.
    test('counts every tick, including repeats for the same stock', () {
      aggregator.processGainerTick({'sn': 'GP', 'sc': 'Telecom', 's': 'u'});
      aggregator.processGainerTick({'sn': 'GP', 'sc': 'Telecom', 's': 'u'});
      expect(aggregator.sectorSummary['Telecom']!['u'], 2);
    });
  });

  group('share-type (A/B/N/Z) counts per sector', () {
    test('counts each order book once', () {
      aggregator.processShareTypeTick({'ob': 1, 'sc': 'Bank', 'st': 'A'});
      expect(aggregator.processShareTypeTick({'ob': 1, 'sc': 'Bank', 'st': 'A'}), isFalse);
      aggregator.processShareTypeTick({'ob': 2, 'sc': 'Bank', 'st': 'Z'});

      expect(aggregator.chartDataShareType, [
        {'sector': 'Bank', 'A': 1.0, 'B': 0.0, 'N': 0.0, 'Z': 1.0, 'total': 2.0},
      ]);
    });

    test('a category change moves the stock, it is not counted twice', () {
      aggregator.processShareTypeTick({'ob': 1, 'sc': 'Bank', 'st': 'A'});
      aggregator.processShareTypeTick({'ob': 1, 'sc': 'Bank', 'st': 'Z'});
      expect(aggregator.sectorShareTypeSummary['Bank'], {'A': 0, 'B': 0, 'N': 0, 'Z': 1});
    });

    test('ignores bonds, unknown categories and ticks without ids', () {
      expect(aggregator.processShareTypeTick({'ob': 1, 'sc': 'TBond', 'st': 'A'}), isFalse);
      expect(aggregator.processShareTypeTick({'ob': 1, 'sc': 'Bank', 'st': 'Q'}), isFalse);
      expect(aggregator.processShareTypeTick({'sc': 'Bank', 'st': 'A'}), isFalse);
      expect(aggregator.processShareTypeTick({'ob': 1, 'st': 'A'}), isFalse);
      expect(aggregator.chartDataShareType, isEmpty);
    });
  });
}
