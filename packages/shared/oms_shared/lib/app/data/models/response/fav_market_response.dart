// To parse this JSON data, do
//
//     final favMarketResponse = favMarketResponseFromMap(jsonString);

import 'dart:convert';

List<FavMarketResponse> favMarketResponseFromMap(dynamic str) =>
    List<FavMarketResponse>.from(
      (str as List<dynamic>).map((x) => FavMarketResponse.fromMap(x)),
    );

String favMarketResponseToMap(List<FavMarketResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class FavMarketResponse {
  final int? id;
  final String? ticker;
  final String? group;
  final String? oderBook;
  final dynamic order;
  final int? tableId;

  FavMarketResponse({
    this.id,
    this.ticker,
    this.group,
    this.oderBook,
    this.order,
    this.tableId,
  });

  FavMarketResponse copyWith({
    int? id,
    String? ticker,
    String? group,
    String? oderBook,
    dynamic order,
    int? tableId,
  }) => FavMarketResponse(
    id: id ?? this.id,
    ticker: ticker ?? this.ticker,
    group: group ?? this.group,
    oderBook: oderBook ?? this.oderBook,
    order: order ?? this.order,
    tableId: tableId ?? this.tableId,
  );

  factory FavMarketResponse.fromMap(Map<String, dynamic> json) =>
      FavMarketResponse(
        id: json["id"],
        ticker: json["ticker"],
        group: json["group"],
        oderBook: json["oder_book"],
        order: json["order"],
        tableId: json["table_id"],
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "ticker": ticker,
    "group": group,
    "oder_book": oderBook,
    "order": order,
    "table_id": tableId,
  };
}
