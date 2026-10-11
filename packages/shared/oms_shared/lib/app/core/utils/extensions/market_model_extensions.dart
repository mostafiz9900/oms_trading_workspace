import '../../../data/models/response/market_model.dart';
import '../../../data/models/market_quote.dart';

/// Preserves the existing app API and delegates calculations to the shared
/// market-domain package. Screens and their presentation remain unchanged.
extension MarketModelExtensions on MarketModel {
  MarketQuote get _quote => MarketQuote(
    close: close,
    last: last,
    reference: reference,
    settle1: settle1,
    change: chg,
    vwap: vwap,
    value: val,
    volume: volume,
    ask: ask,
    bid: bid,
    buyQuantity: bq,
    sellQuantity: aq,
    high: high,
    low: low,
    week52High: wk52High,
    change1w: chp1w,
    change2w: chp2w,
    change1m: chp1m,
    change6m: chp6m,
    change1y: chp1y,
    week1AverageVolume: wk1AvgVol,
    month1AverageVolume: month1AvgVol,
    ticker: ticker,
    shortName: shortName,
    fullName: fullName,
    trades: trades,
    orderBook: orderBook,
  );

  double get activePrice => _quote.activePrice;
  double get activeLast => _quote.activeLast;
  double get closeOrSettle => _quote.closeOrSettle;
  double get previousClose => _quote.previousClose;
  double get absoluteChange => _quote.absoluteChange;
  double get percentageChange => _quote.percentageChange;
  bool get isGainer => _quote.isGainer;
  bool get isLoser => _quote.isLoser;
  bool get isUnchanged => _quote.isUnchanged;
  double get averageTradedPrice => _quote.averageTradedPrice;
  double get bidAskSpread => _quote.bidAskSpread;
  double get spreadPercentage => _quote.spreadPercentage;
  double get buyingPressure => _quote.buyingPressure;
  double get sellingPressure => _quote.sellingPressure;
  double get dayRangePosition => _quote.dayRangePosition;
  double get distanceTo52WeekHigh => _quote.distanceTo52WeekHigh;
  double getChangeByDuration(String duration) =>
      _quote.getChangeByDuration(duration);
  String get displayName => _quote.displayName;
  double calculatePercentageChange() => _quote.calculatePercentageChange();
  double getVolumeByDuration(String duration) =>
      _quote.getVolumeByDuration(duration);
  bool get hasTradingActivity => _quote.hasTradingActivity;
  bool get isValidShare => _quote.isValidShare;
}
