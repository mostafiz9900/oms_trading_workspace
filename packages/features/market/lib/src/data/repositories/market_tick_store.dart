import '../models/market_model.dart';

/// Keeps the latest market tick for each order book.
///
/// Partial updates merge into existing quotes so omitted fields retain their
/// previous values.
class MarketTickStore {
  final Map<int, MarketModel> _quotesByOrderBook = {};

  Iterable<MarketModel> get quotes => _quotesByOrderBook.values;

  /// Stores [tick] and returns the merged quote for its order book.
  ///
  /// (It used to return the raw tick, whose omitted fields parse as 0, so
  /// the marquee briefly showed 0 for price and change on partial updates.)
  MarketModel? apply(Map<String, dynamic> tick) {
    final incoming = MarketModel.fromJson(tick);
    final orderBook = incoming.orderBook;
    if (orderBook == null) return null;

    return _quotesByOrderBook.update(
      orderBook,
      (existing) => existing.mergePartialUpdate(tick),
      ifAbsent: () => incoming,
    );
  }

  void clear() => _quotesByOrderBook.clear();
}
