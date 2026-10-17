import 'dart:convert';

UserBalance userBalanceFromJson(String str) =>
    UserBalance.fromJson(json.decode(str));

String userBalanceToJson(UserBalance data) => json.encode(data.toJson());

class UserBalance {
  final int? id;
  final String? clientCode;
  final double? amount;
  final double? intradayAmount; // Fixed: Changed from int? to double?
  final bool? canUsedIntradayAmount;

  UserBalance({
    this.id,
    this.clientCode,
    this.amount,
    this.intradayAmount,
    this.canUsedIntradayAmount,
  });

  UserBalance copyWith({
    int? id,
    String? clientCode,
    double? amount,
    double? intradayAmount, // Fixed: Changed from int? to double?
    bool? canUsedIntradayAmount,
  }) => UserBalance(
    id: id ?? this.id,
    clientCode: clientCode ?? this.clientCode,
    amount: amount ?? this.amount,
    intradayAmount: intradayAmount ?? this.intradayAmount,
    canUsedIntradayAmount: canUsedIntradayAmount ?? this.canUsedIntradayAmount,
  );

  factory UserBalance.fromJson(Map<String, dynamic> json) => UserBalance(
    id: json["id"],
    clientCode: json["client_code"],
    amount: json["amount"]?.toDouble(),
    intradayAmount: json["intraday_amount"]
        ?.toDouble(), // Fixed: Added ?.toDouble()
    canUsedIntradayAmount: json["can_used_intraday_amount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "client_code": clientCode,
    "amount": amount,
    "intraday_amount": intradayAmount,
    "can_used_intraday_amount": canUsedIntradayAmount,
  };
}
