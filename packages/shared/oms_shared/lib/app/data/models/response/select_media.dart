// To parse this JSON data, do
//
//     final selectMedia = selectMediaFromMap(jsonString);

import 'dart:convert';

SelectMedia selectMediaFromMap(dynamic str) =>
    SelectMedia.fromMap((str as dynamic));

String selectMediaToMap(SelectMedia data) => json.encode(data.toMap());

class SelectMedia {
  String? boId;
  List<String>? mediaData;

  SelectMedia({this.boId, this.mediaData});

  factory SelectMedia.fromMap(Map<String, dynamic> json) => SelectMedia(
    boId: json["bo_id"],
    mediaData: json["media_data"] == null
        ? []
        : List<String>.from(json["media_data"]!.map((x) => x)),
  );

  Map<String, dynamic> toMap() => {
    "bo_id": boId,
    "media_data": mediaData == null
        ? []
        : List<dynamic>.from(mediaData!.map((x) => x)),
  };
}
