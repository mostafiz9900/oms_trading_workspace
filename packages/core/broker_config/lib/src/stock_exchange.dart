/// A Bangladesh stock exchange.
enum StockExchange {
  /// Dhaka Stock Exchange.
  dse,

  /// Chittagong Stock Exchange.
  cse,
}

/// Which exchanges a broker house trades on (`HouseProfile.exchangeMode`).
/// Every house is [dseOnly] unless its `house_profile.dart` says otherwise.
/// UI that differs per exchange reads `AppConfig.hasDse` / `hasCse` /
/// `hasBothExchanges`; it never checks the house id.
enum ExchangeMode {
  dseOnly({StockExchange.dse}),
  cseOnly({StockExchange.cse}),
  dseAndCse({StockExchange.dse, StockExchange.cse});

  const ExchangeMode(this.exchanges);

  /// Exchanges of this mode, never empty.
  final Set<StockExchange> exchanges;

  bool get hasDse => exchanges.contains(StockExchange.dse);
  bool get hasCse => exchanges.contains(StockExchange.cse);
  bool get hasBoth => hasDse && hasCse;

  /// Exchange the UI starts on: DSE when the house has it, else CSE.
  StockExchange get defaultExchange =>
      hasDse ? StockExchange.dse : StockExchange.cse;
}
