// To parse this JSON data, do
//
//     final withdrawModel = withdrawModelFromJson(jsonString);

import 'dart:convert';

List<WithdrawModel> withdrawModelFromJson(dynamic str) =>
    List<WithdrawModel>.from(
      (str as List<dynamic>).map((x) => WithdrawModel.fromJson(x)),
    );

String withdrawModelToJson(List<WithdrawModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WithdrawModel {
  final int? id;
  final String? transactionId;
  final String? investorCode;
  final String? investorName;
  final String? withdrawRequest;
  final String? status;
  final String? requestedBy;
  final DateTime? createdAt;

  WithdrawModel({
    this.id,
    this.transactionId,
    this.investorCode,
    this.investorName,
    this.withdrawRequest,
    this.status,
    this.requestedBy,
    this.createdAt,
  });

  WithdrawModel copyWith({
    int? id,
    String? transactionId,
    String? investorCode,
    String? investorName,
    String? withdrawRequest,
    String? status,
    String? requestedBy,
    DateTime? createdAt,
  }) => WithdrawModel(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    investorCode: investorCode ?? this.investorCode,
    investorName: investorName ?? this.investorName,
    withdrawRequest: withdrawRequest ?? this.withdrawRequest,
    status: status ?? this.status,
    requestedBy: requestedBy ?? this.requestedBy,
    createdAt: createdAt ?? this.createdAt,
  );

  factory WithdrawModel.fromJson(Map<String, dynamic> json) => WithdrawModel(
    id: json["id"],
    transactionId: json["transaction_id"],
    investorCode: json["investor_code"],
    investorName: json["investor_name"],
    withdrawRequest: json["withdraw_request"],
    status: json["status"],
    requestedBy: json["requested_by"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "transaction_id": transactionId,
    "investor_code": investorCode,
    "investor_name": investorName,
    "withdraw_request": withdrawRequest,
    "status": status,
    "requested_by": requestedBy,
    "created_at": createdAt?.toIso8601String(),
  };
}
