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
    };
  }
}
