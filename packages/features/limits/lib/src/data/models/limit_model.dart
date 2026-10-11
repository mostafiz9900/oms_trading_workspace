// To parse this JSON data, do
//
//     final limitModel = limitModelFromJson(jsonString);

import 'dart:convert';

List<LimitModel> limitModelFromJson(String str) =>
    List<LimitModel>.from(json.decode(str).map((x) => LimitModel.fromJson(x)));

String limitModelToJson(List<LimitModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LimitModel {
  final int? id;
  final String? investorCode;
  final String? investorName;
  final String? requestedAmount;
  final String? market;
  final String? status;
  final String? receipt;
  final DateTime? createdAt;

  LimitModel({
    this.id,
    this.investorCode,
    this.investorName,
    this.requestedAmount,
    this.market,
    this.status,
    this.receipt,
    this.createdAt,
  });

  LimitModel copyWith({
    int? id,
    String? investorCode,
    String? investorName,
    String? requestedAmount,
    String? market,
    String? status,
    String? receipt,
    DateTime? createdAt,
  }) => LimitModel(
    id: id ?? this.id,
    investorCode: investorCode ?? this.investorCode,
    investorName: investorName ?? this.investorName,
    requestedAmount: requestedAmount ?? this.requestedAmount,
    market: market ?? this.market,
    status: status ?? this.status,
    receipt: receipt ?? this.receipt,
    createdAt: createdAt ?? this.createdAt,
  );

  factory LimitModel.fromJson(Map<String, dynamic> json) => LimitModel(
    id: json["id"],
    investorCode: json["investor_code"],
    investorName: json["investor_name"],
    requestedAmount: json["requested_amount"],
    market: json["market"],
    status: json["status"],
    receipt: json["receipt"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "investor_code": investorCode,
    "investor_name": investorName,
    "requested_amount": requestedAmount,
    "market": market,
    "status": status,
    "receipt": receipt,
    "created_at": createdAt?.toIso8601String(),
  };
}
