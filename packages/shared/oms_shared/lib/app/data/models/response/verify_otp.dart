// To parse this JSON data, do
//
//     final verifyOtp = verifyOtpFromMap(jsonString);

import 'dart:convert';

VerifyOtp verifyOtpFromMap(dynamic str) => VerifyOtp.fromMap((str as dynamic));

String verifyOtpToMap(VerifyOtp data) => json.encode(data.toMap());

class VerifyOtp {
  String? boId;
  String? mediaType;
  String? mediaData;

  VerifyOtp({this.boId, this.mediaType, this.mediaData});

  factory VerifyOtp.fromMap(Map<String, dynamic> json) => VerifyOtp(
    boId: json["bo_id"],
    mediaType: json["media_type"],
    mediaData: json["media_data"],
  );

  Map<String, dynamic> toMap() => {
    "bo_id": boId,
    "media_type": mediaType,
    "media_data": mediaData,
  };
}
