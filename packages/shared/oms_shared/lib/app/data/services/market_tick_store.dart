import '../models/response/market_model.dart';

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
    // Same parse as MarketModel.fromJson; the full model is only built for a
    // new order book (it used to be built and dropped on every tick).
    final orderBook = int.tryParse(tick['ob']?.toString() ?? '');
    if (orderBook == null) return null;

    return _quotesByOrderBook.update(
      orderBook,
      (existing) => existing.mergePartialUpdate(tick),
      ifAbsent: () => MarketModel.fromJson(tick),
    );
  }

  void clear() => _quotesByOrderBook.clear();
}
