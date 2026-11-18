import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/services/market_listing_matcher.dart';

void main() {
  const source = MarketModel(
    shortName: 'SURV23',
    orderBook: 'CSE_101001462',
    isinCode: 'BD000SURV234',
    board: 'Main Board',
  );

  test('matches the stored listing by normalized ISIN code and board', () {
    const sameListing = MarketModel(
      shortName: 'SURV23',
      orderBook: 254555,
      isinCode: ' bd000-surv234 ',
      board: ' main-board ',
    );
    const wrongIsin = MarketModel(
      isinCode: 'BD000OTHER234',
      board: 'Main Board',
    );
    const wrongBoard = MarketModel(
      isinCode: 'BD000SURV234',
      board: 'SME Board',
    );

    expect(MarketListingMatcher.isSameListing(source, sameListing), isTrue);
    expect(MarketListingMatcher.isSameListing(source, wrongIsin), isFalse);
    expect(MarketListingMatcher.isSameListing(source, wrongBoard), isFalse);
    expect(
      MarketListingMatcher.findSameListing(source, [wrongIsin, sameListing]),
      sameListing,
    );
    expect(
      MarketListingMatcher.findSameListing(source, [wrongIsin, wrongBoard]),
      isNull,
    );
  });

  test('missing ISIN or board never counts as a match', () {
    expect(
      MarketListingMatcher.isSameListing(
        source,
        const MarketModel(isinCode: 'BD000SURV234'),
      ),
      isFalse,
    );
    expect(
      MarketListingMatcher.isSameListing(
        const MarketModel(board: 'Main Board'),
        source,
      ),
      isFalse,
    );
  });
}
