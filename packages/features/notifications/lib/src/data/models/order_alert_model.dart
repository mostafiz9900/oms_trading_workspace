class OrderAlertModel {
  final String? account;
  final String? clientId;
  final String? execType;
  final int? msgSequenceNumber;
  final int? qty;
  final String? side;
  final String? status;
  final String? symbol;
  final String? transactTime;

  OrderAlertModel({
    this.account,
    this.clientId,
    this.execType,
    this.msgSequenceNumber,
    this.qty,
    this.side,
    this.status,
    this.symbol,
    this.transactTime,
  });

  // JSON থেকে Model এ কনভার্ট করার জন্য
  factory OrderAlertModel.fromJson(Map<String, dynamic> json) {
    return OrderAlertModel(
      account: json['account']?.toString(),
      clientId: json['client_id']?.toString(),
      execType: json['exec_type']?.toString(),
      msgSequenceNumber: json['msg_sequence_number'] != null
          ? int.tryParse(json['msg_sequence_number'].toString())
          : null,
      qty: json['qty'] != null ? int.tryParse(json['qty'].toString()) : null,
      side: json['side']?.toString(),
      status: json['status']?.toString(),
      symbol: json['symbol']?.toString(),
      transactTime: json['transact_time']?.toString(),
    );
  }

  // Model থেকে JSON এ কনভার্ট করার জন্য
  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'client_id': clientId,
      'exec_type': execType,
      'msg_sequence_number': msgSequenceNumber,
      'qty': qty,
      'side': side,
      'status': status,
      'symbol': symbol,
      'transact_time': transactTime,
    };
  }

  // ডেটা আপডেট বা কপি করার জন্য (copyWith)
  OrderAlertModel copyWith({
    String? account,
    String? clientId,
    String? execType,
    int? msgSequenceNumber,
    int? qty,
    String? side,
    String? status,
    String? symbol,
    String? transactTime,
  }) {
    return OrderAlertModel(
      account: account ?? this.account,
      clientId: clientId ?? this.clientId,
      execType: execType ?? this.execType,
      msgSequenceNumber: msgSequenceNumber ?? this.msgSequenceNumber,
      qty: qty ?? this.qty,
      side: side ?? this.side,
      status: status ?? this.status,
      symbol: symbol ?? this.symbol,
      transactTime: transactTime ?? this.transactTime,
    );
  }
}
