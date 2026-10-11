import '../models/market_model.dart';

/// Keeps the latest market tick for each order book.
///
/// Partial updates merge into existing quotes so omitted fields retain their
/// previous values.
class MarketTickStore {
  final Map<int, MarketModel> _quotesByOrderBook = {};

  Iterable<MarketModel> get quotes => _quotesByOrderBook.values;

  MarketModel? apply(Map<String, dynamic> tick) {
    final incoming = MarketModel.fromJson(tick);
    final orderBook = incoming.orderBook;
    if (orderBook == null) return null;

    _quotesByOrderBook.update(
      orderBook,
      (existing) => existing.mergePartialUpdate(tick),
      ifAbsent: () => incoming,
    );
    return incoming;
  }

  void clear() => _quotesByOrderBook.clear();
}
