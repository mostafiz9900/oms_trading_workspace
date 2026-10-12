// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

List<NotificationModel> notificationModelFromJson(String str) =>
    List<NotificationModel>.from(
      json.decode(str).map((x) => NotificationModel.fromJson(x)),
    );

String notificationModelToJson(List<NotificationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NotificationModel {
  final DateTime? date;
  final DateTime? time;
  final int? orderBook;
  final int? newsId;
  final String? firmId;
  final String? title;
  final String? reference;
  final String? newsText;

  NotificationModel({
    this.date,
    this.time,
    this.orderBook,
    this.newsId,
    this.firmId,
    this.title,
    this.reference,
    this.newsText,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
        orderBook: json["orderBook"],
        newsId: json["newsId"],
        firmId: json["firmId"],
        title: json["title"],
        reference: json["reference"],
        newsText: json["newsText"],
      );

  Map<String, dynamic> toJson() => {
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "time": time?.toIso8601String(),
    "orderBook": orderBook,
    "newsId": newsId,
    "firmId": firmId,
    "title": title,
    "reference": reference,
    "newsText": newsText,
  };
}
