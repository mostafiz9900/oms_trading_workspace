import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/data/models/market_identifier.dart';

void main() {
  group('market order book IDs', () {
    test('keeps DSE numeric IDs as integers', () {
      expect(marketIdentifierFromJson(254555), 254555);
      expect(marketIdentifierFromJson(254555), isA<int>());
    });

    test('keeps CSE alphanumeric IDs as strings', () {
      expect(marketIdentifierFromJson('CSE_101001288'), 'CSE_101001288');
      expect(marketIdentifierFromJson('CSE_101001288'), isA<String>());
    });

    test('normalizes legacy numeric strings to DSE integers', () {
      expect(marketIdentifierFromJson('254555'), 254555);
    });
  });
}
