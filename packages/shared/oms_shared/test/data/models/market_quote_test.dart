import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/data/models/market_quote.dart';

void main() {
  group('price used for change', () {
    test('close wins when the market has closed', () {
      const q = MarketQuote(close: 105, last: 104, reference: 100);
      expect(q.activePrice, 105);
    });

    test('last is used during trading (no close yet)', () {
      const q = MarketQuote(close: 0, last: 104, reference: 100);
      expect(q.activePrice, 104);
    });

    test('falls back to reference, then 0', () {
      expect(const MarketQuote(reference: 100).activePrice, 100);
      expect(const MarketQuote().activePrice, 0);
    });
  });

  group('change', () {
    test('absolute and percentage change against yesterday close', () {
      const q = MarketQuote(last: 110, reference: 100);
      expect(q.absoluteChange, 10);
      expect(q.percentageChange, closeTo(10, 1e-9));
      expect(q.isGainer, isTrue);
      expect(q.isLoser, isFalse);
    });

    test('a falling stock is a loser', () {
      const q = MarketQuote(last: 95, reference: 100);
      expect(q.absoluteChange, -5);
      expect(q.percentageChange, closeTo(-5, 1e-9));
      expect(q.isLoser, isTrue);
    });

    test('without a reference price the server change is used', () {
      const q = MarketQuote(last: 50, change: 2.5);
      expect(q.absoluteChange, 2.5);
      expect(q.percentageChange, 0, reason: 'no base to divide by');
    });

    test('unchanged stock', () {
      const q = MarketQuote(last: 100, reference: 100);
      expect(q.isUnchanged, isTrue);
      expect(q.percentageChange, 0);
    });

    test('change by duration uses the server values, default is today', () {
      const q = MarketQuote(
        last: 110,
        reference: 100,
        change1w: 1,
        change2w: 2,
        change1m: 3,
        change6m: 6,
        change1y: 12,
      );
      expect(q.getChangeByDuration('1w'), 1);
      expect(q.getChangeByDuration('2W'), 2);
      expect(q.getChangeByDuration('1M'), 3);
      expect(q.getChangeByDuration('6M'), 6);
      expect(q.getChangeByDuration('1Y'), 12);
      expect(q.getChangeByDuration('today'), closeTo(10, 1e-9));
    });
  });

  group('order book', () {
    test('spread and spread %', () {
      const q = MarketQuote(ask: 101, bid: 100);
      expect(q.bidAskSpread, 1);
      expect(q.spreadPercentage, closeTo(100 / 101, 1e-9));
    });

    test('no spread when a side is empty', () {
      expect(const MarketQuote(ask: 101).bidAskSpread, 0);
      expect(const MarketQuote(bid: 100).spreadPercentage, 0);
    });

    test('buying and selling pressure add up to 100', () {
      const q = MarketQuote(buyQuantity: 300, sellQuantity: 100);
      expect(q.buyingPressure, 75);
      expect(q.sellingPressure, 25);
    });

    test('pressure is 50/50 with no quantities', () {
      expect(const MarketQuote().buyingPressure, 50);
      expect(const MarketQuote().sellingPressure, 50);
    });
  });

  group('averages and ranges', () {
    test('average traded price prefers VWAP, else value / volume', () {
      expect(const MarketQuote(vwap: 99.5).averageTradedPrice, 99.5);
      expect(
        const MarketQuote(value: 10000, volume: 100).averageTradedPrice,
        100,
      );
      expect(const MarketQuote(value: 10000).averageTradedPrice, 0);
    });

    test('position inside the day range', () {
      const q = MarketQuote(last: 105, low: 100, high: 110);
      expect(q.dayRangePosition, 50);
      expect(const MarketQuote(last: 1, low: 5, high: 5).dayRangePosition, 0);
    });

    test('distance to the 52-week high', () {
      const q = MarketQuote(last: 90, week52High: 100);
      expect(q.distanceTo52WeekHigh, closeTo(-10, 1e-9));
    });

    test('volume by duration falls back to today', () {
      const q = MarketQuote(
        volume: 10,
        week1AverageVolume: 20,
        month1AverageVolume: 30,
      );
      expect(q.getVolumeByDuration('weekly'), 20);
      expect(q.getVolumeByDuration(' Monthly '), 30);
      expect(q.getVolumeByDuration('daily'), 10);
      expect(const MarketQuote(volume: 10).getVolumeByDuration('weekly'), 10);
    });
  });

  group('identity', () {
    test('display name prefers ticker, then short and full name', () {
      expect(const MarketQuote(ticker: 'GP', shortName: 'G').displayName, 'GP');
      expect(const MarketQuote(shortName: 'G').displayName, 'G');
      expect(const MarketQuote(fullName: 'Grameen').displayName, 'Grameen');
      expect(const MarketQuote().displayName, 'N/A');
    });

    test('a share is valid only with an order book id', () {
      expect(const MarketQuote(orderBook: 101).isValidShare, isTrue);
      expect(const MarketQuote(orderBook: 0).isValidShare, isFalse);
      expect(const MarketQuote().isValidShare, isFalse);
    });

    test('trading activity means trades or volume', () {
      expect(const MarketQuote(trades: 1).hasTradingActivity, isTrue);
      expect(const MarketQuote(volume: 1).hasTradingActivity, isTrue);
      expect(const MarketQuote().hasTradingActivity, isFalse);
    });
  });
}
