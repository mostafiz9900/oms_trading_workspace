// To parse this JSON data, do
//
//     final verifySelectedMedia = verifySelectedMediaFromMap(jsonString);

import 'dart:convert';

VerifySelectedMedia verifySelectedMediaFromMap(dynamic str) =>
    VerifySelectedMedia.fromMap((str as dynamic));

String verifySelectedMediaToMap(VerifySelectedMedia data) =>
    json.encode(data.toMap());

class VerifySelectedMedia {
  DateTime? valid;
  int? remainingTime;
  String? mediaType;
  String? mediaData;
  String? boId;

  VerifySelectedMedia({
    this.valid,
    this.remainingTime,
    this.mediaType,
    this.mediaData,
    this.boId,
  });

  factory VerifySelectedMedia.fromMap(Map<String, dynamic> json) =>
      VerifySelectedMedia(
        valid: json["valid"] == null ? null : DateTime.parse(json["valid"]),
        remainingTime: json["remaining_time"],
        mediaType: json["media_type"],
        mediaData: json["media_data"],
        boId: json["bo_id"],
      );

  Map<String, dynamic> toMap() => {
    "valid": valid?.toIso8601String(),
    "remaining_time": remainingTime,
    "media_type": mediaType,
    "media_data": mediaData,
    "bo_id": boId,
  };
}
