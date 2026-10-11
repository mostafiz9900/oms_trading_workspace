// To parse this JSON data, do
//
//     final withdrawRequest = withdrawRequestFromJson(jsonString);

import 'dart:convert';

WithdrawRequest withdrawRequestFromJson(String str) =>
    WithdrawRequest.fromJson(json.decode(str));

String withdrawRequestToJson(WithdrawRequest data) =>
    json.encode(data.toJson());

class WithdrawRequest {
  final String? investorCode;
  final String? withdrawRequest;
  final String? narration;

  WithdrawRequest({this.investorCode, this.withdrawRequest, this.narration});

  WithdrawRequest copyWith({
    String? investorCode,
    String? withdrawRequest,
    String? narration,
  }) => WithdrawRequest(
    investorCode: investorCode ?? this.investorCode,
    withdrawRequest: withdrawRequest ?? this.withdrawRequest,
    narration: narration ?? this.narration,
  );

  factory WithdrawRequest.fromJson(Map<String, dynamic> json) =>
      WithdrawRequest(
        investorCode: json["investor_code"],
        withdrawRequest: json["withdraw_request"],
        narration: json["narration"],
      );

  Map<String, dynamic> toJson() => {
    "investor_code": investorCode,
    "withdraw_request": withdrawRequest,
    "narration": narration,
  };
}
