// To parse this JSON data, do
//
//     final favouriteModel = favouriteModelFromJson(jsonString);

import 'dart:convert';

List<FavouriteModel> favouriteModelFromJson(dynamic str) =>
    List<FavouriteModel>.from(
      (str as List<dynamic>).map((x) => FavouriteModel.fromJson(x)),
    );

String favouriteModelToJson(List<FavouriteModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FavouriteModel {
  final int? id;
  final String? name;
  FavouriteModel({this.id, this.name});
  FavouriteModel copyWith({
    int? id,
    int? user,
    String? name,
    List<String>? items,
  }) => FavouriteModel(id: id ?? this.id, name: name ?? this.name);

  factory FavouriteModel.fromJson(Map<String, dynamic> json) =>
      FavouriteModel(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
