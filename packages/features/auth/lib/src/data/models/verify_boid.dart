// To parse this JSON data, do
//
//     final verifyBoid = verifyBoidFromMap(jsonString);

import 'dart:convert';

VerifyBoid verifyBoidFromMap(dynamic str) =>
    VerifyBoid.fromMap((str as dynamic));

String verifyBoidToMap(VerifyBoid data) => json.encode(data.toMap());

class VerifyBoid {
  String? boId;

  VerifyBoid({this.boId});

  factory VerifyBoid.fromMap(Map<String, dynamic> json) =>
      VerifyBoid(boId: json["bo_id"]);

  Map<String, dynamic> toMap() => {"bo_id": boId};
}
