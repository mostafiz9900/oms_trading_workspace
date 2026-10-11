/// Immutable quote values and calculations shared between broker apps.
class MarketQuote {
  const MarketQuote({
    this.close,
    this.last,
    this.reference,
    this.settle1,
    this.change,
    this.vwap,
    this.value,
    this.volume,
    this.ask,
    this.bid,
    this.buyQuantity,
    this.sellQuantity,
    this.high,
    this.low,
    this.week52High,
    this.change1w,
    this.change2w,
    this.change1m,
    this.change6m,
    this.change1y,
    this.week1AverageVolume,
    this.month1AverageVolume,
    this.ticker,
    this.shortName,
    this.fullName,
    this.trades,
    this.orderBook,
  });

  final double? close, last, reference, settle1, change, vwap, value;
  final int? volume, buyQuantity, sellQuantity, trades, orderBook;
  final double? ask, bid, high, low, week52High;
  final double? change1w, change2w, change1m, change6m, change1y;
  final double? week1AverageVolume, month1AverageVolume;
  final String? ticker, shortName, fullName;

  double get activePrice =>
      close != null && close! > 0 ? close! : last ?? reference ?? 0.0;
  double get activeLast => last != null && last! > 0 ? last! : settle1 ?? 0.0;
  double get closeOrSettle =>
      close != null && close! > 0 ? close! : settle1 ?? 0.0;
  double get previousClose => reference ?? 0.0;

  double get absoluteChange =>
      previousClose <= 0 ? change ?? 0.0 : activePrice - previousClose;
  double get percentageChange {
    if (previousClose <= 0 || activePrice <= 0) return 0.0;
    return ((activePrice - previousClose) / previousClose) * 100;
  }

  bool get isGainer => absoluteChange > 0;
  bool get isLoser => absoluteChange < 0;
  bool get isUnchanged => absoluteChange == 0;

  double get averageTradedPrice {
    if (vwap != null && vwap! > 0) return vwap!;
    final totalVolume = volume ?? 0;
    return totalVolume <= 0 ? 0.0 : (value ?? 0.0) / totalVolume;
  }

  double get bidAskSpread {
    final currentAsk = ask ?? 0.0, currentBid = bid ?? 0.0;
    return currentAsk <= 0 || currentBid <= 0 ? 0.0 : currentAsk - currentBid;
  }

  double get spreadPercentage {
    final currentAsk = ask ?? 0.0, spread = bidAskSpread;
    return currentAsk <= 0 || spread <= 0 ? 0.0 : spread / currentAsk * 100;
  }

  double get buyingPressure {
    final buyQty = buyQuantity ?? 0, totalQty = buyQty + (sellQuantity ?? 0);
    return totalQty <= 0 ? 50.0 : buyQty / totalQty * 100;
  }

  double get sellingPressure => 100.0 - buyingPressure;

  double get dayRangePosition {
    final dayHigh = high ?? 0.0, dayLow = low ?? 0.0;
    if (dayHigh <= 0 || dayLow <= 0 || dayHigh == dayLow) return 0.0;
    return (activePrice - dayLow) / (dayHigh - dayLow) * 100;
  }

  double get distanceTo52WeekHigh {
    final high52 = week52High ?? 0.0;
    return high52 <= 0 ? 0.0 : (activePrice - high52) / high52 * 100;
  }

  double getChangeByDuration(String duration) =>
      switch (duration.toUpperCase()) {
        '1W' => change1w ?? 0.0,
        '2W' => change2w ?? 0.0,
        '1M' => change1m ?? 0.0,
        '6M' => change6m ?? 0.0,
        '1Y' => change1y ?? 0.0,
        _ => percentageChange,
      };

  String get displayName => ticker ?? shortName ?? fullName ?? 'N/A';
  double calculatePercentageChange() {
    final refPrice = reference ?? 0.0;
    if (refPrice <= 0) return 0.0;
    final currentPrice = close != null && close! > 0 ? close! : last ?? 0.0;
    return currentPrice <= 0 ? 0.0 : (currentPrice - refPrice) / refPrice * 100;
  }

  double getVolumeByDuration(String duration) =>
      switch (duration.toLowerCase().trim()) {
        'weekly' => (week1AverageVolume ?? volume ?? 0).toDouble(),
        'monthly' => (month1AverageVolume ?? volume ?? 0).toDouble(),
        _ => (volume ?? 0).toDouble(),
      };
  bool get hasTradingActivity => (trades ?? 0) > 0 || (volume ?? 0) > 0;
  bool get isValidShare => orderBook != null && orderBook != 0;
}
