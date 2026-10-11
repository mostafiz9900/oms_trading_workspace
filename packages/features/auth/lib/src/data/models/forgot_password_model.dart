// To parse this JSON data, do
//
//     final forgotPassword = forgotPasswordFromMap(jsonString);

import 'dart:convert';

ForgotPassword forgotPasswordFromMap(dynamic str) =>
    ForgotPassword.fromMap((str as dynamic));

String forgotPasswordToMap(ForgotPassword data) => json.encode(data.toMap());

class ForgotPassword {
  bool? success;
  String? message;

  ForgotPassword({this.success, this.message});

  factory ForgotPassword.fromMap(Map<String, dynamic> json) =>
      ForgotPassword(success: json["success"], message: json["message"]);

  Map<String, dynamic> toMap() => {"success": success, "message": message};
}
