class UpdateOrderHolder {
  final String action;
  final String? traderId;
  final String boId;
  final String clientCode;
  final int? userId;
  final String clientOrderId;
  final String origClientOrderId;
  final String orderId;
  final String symbol;
  final String side;
  final String session;

  /// `DSE` / `CSE` and the CSE trader code (null on DSE), as on new orders.
  final String exchange;
  final String? cseTraderCode;

  UpdateOrderHolder({
    required this.action,
    required this.traderId,
    required this.boId,
    required this.clientCode,
    required this.userId,
    this.clientOrderId = '',
    required this.origClientOrderId,
    required this.orderId,
    required this.symbol,
    required this.side,
    required this.session,
    required this.exchange,
    required this.cseTraderCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'trader_id': traderId,
      'bo_id': boId,
      'client_code': clientCode,
      'user_id': userId,
      'client_order_id': clientOrderId,
      'orig_client_order_id': origClientOrderId,
      'order_id': orderId,
      'symbol': symbol,
      'side': side,
      'session': session,
      'exchange': exchange,
      'cse_trader_code': cseTraderCode,
    };
  }
}
