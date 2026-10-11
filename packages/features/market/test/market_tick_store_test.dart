import 'package:flutter_test/flutter_test.dart';
import 'package:market/market.dart';

void main() {
  test('a partial tick returns the merged quote, not zeros', () {
    final store = MarketTickStore();
    store.apply({'ob': 7, 'sn': 'GP', 'g': 'PUBLIC', 'lp': 300.5, 'cg': 1.5, 'd': 0.5});

    // Only volume changed: price/change fields are omitted from the tick.
    final merged = store.apply({'ob': 7, 'v': 1000});

    expect(merged!.shortName, 'GP');
    expect(merged.group, 'PUBLIC');
    expect(merged.last, 300.5);
    expect(merged.chg, 1.5);
    expect(merged.d, 0.5);
    expect(store.quotes.single.last, 300.5);
  });

  test('ticks without an order book are ignored', () {
    final store = MarketTickStore();
    expect(store.apply({'message_type': 'itch_heartbeat'}), isNull);
    expect(store.quotes, isEmpty);
  });
}
