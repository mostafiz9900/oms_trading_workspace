// To parse this JSON data, do
//
//     final userBalance = userBalanceFromJson(jsonString);

import 'dart:convert';

List<UserBalance> userBalanceFromJson(dynamic str) => List<UserBalance>.from(
  (str as List<dynamic>).map((x) => UserBalance.fromJson(x)),
);

String userBalanceToJson(List<UserBalance> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserBalance {
  final int? id;
  final String? clientCode;
  final dynamic initialAmount;
  final dynamic amount;
  final dynamic percentage;
  final dynamic intradayAmount;

  UserBalance({
    this.id,
    this.clientCode,
    this.initialAmount,
    this.amount,
    this.percentage,
    this.intradayAmount,
  });

  factory UserBalance.fromJson(Map<String, dynamic> json) => UserBalance(
    id: json["id"],
    clientCode: json["client_code"],
    initialAmount: json["initial_amount"],
    amount: json["amount"],
    percentage: json["percentage"],
    intradayAmount: json["intraday_amount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "client_code": clientCode,
    "initial_amount": initialAmount,
    "amount": amount,
    "percentage": percentage,
    "intraday_amount": intradayAmount,
  };
}
