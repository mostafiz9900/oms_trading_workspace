// To parse this JSON data, do
//
//     final cashModel = cashModelFromJson(jsonString);

import 'dart:convert';

CashModel cashModelFromJson(String str) => CashModel.fromJson(json.decode(str));

String cashModelToJson(CashModel data) => json.encode(data.toJson());

class CashModel {
  final String? messageType;
  final String? message;
  final List<CashDataModel>? data;

  CashModel({this.messageType, this.message, this.data});

  factory CashModel.fromJson(Map<String, dynamic> json) => CashModel(
    messageType: json["message_type"],
    message: json["message"],
    data: json["data"] == null
        ? []
        : List<CashDataModel>.from(
            json["data"]!.map((x) => CashDataModel.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "message_type": messageType,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class CashDataModel {
  final int? id;
  final String? clientCode;
  final int? amount;
  final int? percentage;
  final int? intradayAmount;

  CashDataModel({
    this.id,
    this.clientCode,
    this.amount,
    this.percentage,
    this.intradayAmount,
  });

  factory CashDataModel.fromJson(Map<String, dynamic> json) => CashDataModel(
    id: json["id"],
    clientCode: json["client_code"],
    amount: json["amount"],
    percentage: json["percentage"],
    intradayAmount: json["intraday_amount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "client_code": clientCode,
    "amount": amount,
    "percentage": percentage,
    "intraday_amount": intradayAmount,
  };
}
