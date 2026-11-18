import '../models/response/market_model.dart';

/// Matches one exchange's listing to the same listing on another exchange.
/// Order book IDs and ticker symbols can differ between exchanges, so the
/// stable identity is the ISIN code together with the board.
class MarketListingMatcher {
  const MarketListingMatcher._();

  static String _normalize(String? value) =>
      (value ?? '').trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  static bool isSameListing(MarketModel source, MarketModel candidate) {
    final sourceIsin = _normalize(source.isinCode);
    final sourceBoard = _normalize(source.board);
    final candidateIsin = _normalize(candidate.isinCode);
    final candidateBoard = _normalize(candidate.board);

    return sourceIsin.isNotEmpty &&
        sourceBoard.isNotEmpty &&
        candidateIsin.isNotEmpty &&
        candidateBoard.isNotEmpty &&
        sourceIsin == candidateIsin &&
        sourceBoard == candidateBoard;
  }

  static MarketModel? findSameListing(
    MarketModel source,
    Iterable<MarketModel> candidates,
  ) {
    for (final candidate in candidates) {
      if (isSameListing(source, candidate)) return candidate;
    }
    return null;
  }
}
