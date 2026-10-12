import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/services/market_sector_filter_store.dart';
import 'package:oms_shared/app/data/services/market_sector_summary_aggregator.dart';

MarketModel stock({
  String? sector = 'Bank',
  String group = 'PUBLIC',
  String board = 'Main Board',
  double val = 0,
  int volume = 0,
  double last = 0,
  double d = 0,
}) => MarketModel(
  sector: sector,
  group: group,
  board: board,
  val: val,
  volume: volume,
  last: last,
  d: d,
);

void main() {
  final aggregator = MarketSectorSummaryAggregator();

  test('totals and averages per sector', () {
    final result = aggregator.generate([
      stock(val: 100, volume: 10, last: 20, d: 2),
      stock(val: 300, volume: 30, last: 40, d: -1),
    ]);

    expect(result, hasLength(1));
    final bank = result.single;
    expect(bank.sectorName, 'Bank');
    expect(bank.stocks, hasLength(2));
    expect(bank.totalValue, 400);
    expect(bank.totalVolume, 40);
    expect(bank.avgLastPrice, 30);
    expect(bank.avgTodayChange, 0.5);
  });

  test('only public Main Board and Small Cap Board stocks count', () {
    final result = aggregator.generate([
      stock(val: 1),
      stock(val: 1, board: 'Small Cap Board'),
      stock(val: 1, board: 'Block Board'),
      stock(val: 1, group: 'DEBT'),
    ]);
    expect(result.single.stocks, hasLength(2));
  });

  test('stocks without a sector are grouped under their group', () {
    final result = aggregator.generate([stock(sector: null), stock(sector: '')]);
    expect(result.single.sectorName, 'PUBLIC');
  });

  test('sectors are sorted by traded value, largest first', () {
    final result = aggregator.generate([
      stock(sector: 'Bank', val: 10),
      stock(sector: 'Pharma', val: 50),
      stock(sector: 'Telecom', val: 30),
    ]);
    expect(result.map((s) => s.sectorName), ['Pharma', 'Telecom', 'Bank']);
  });

  test('no stocks, no sectors', () {
    expect(aggregator.generate([]), isEmpty);
  });

  group('sector filter options', () {
    test('adds each tradable sector once', () {
      final store = MarketSectorFilterStore(sectors: ['All']);
      expect(store.addSector('Bank'), isTrue);
      expect(store.addSector('Bank'), isFalse);
      expect(store.sectors, ['All', 'Bank']);
    });

    test('skips bonds and empty names', () {
      final store = MarketSectorFilterStore();
      for (final s in ['TBond', 'CorpBond', '', null]) {
        expect(store.addSector(s), isFalse);
      }
      expect(store.sectors, isEmpty);
    });

    test('reset leaves only All', () {
      final store = MarketSectorFilterStore(sectors: ['All', 'Bank']);
      store.reset();
      expect(store.sectors, ['All']);
    });
  });
}
