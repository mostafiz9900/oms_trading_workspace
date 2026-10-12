// To parse this JSON data, do
//
//     final userModel = userModelFromMap(jsonString);

import 'dart:convert';

UserModel userModelFromMap(dynamic str) => UserModel.fromMap((str as dynamic));

String userModelToMap(UserModel data) => json.encode(data.toMap());

class UserModel {
  int? id;
  String? email;
  String? username;
  String? mobile;
  bool? isVerified;
  bool? isActive;
  String? firstName;
  String? lastName;
  String? profileImage;

  UserModel({
    this.id,
    this.email,
    this.username,
    this.mobile,
    this.isVerified,
    this.isActive,
    this.firstName,
    this.lastName,
    this.profileImage,
  });

  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    email: json["email"],
    username: json["username"],
    mobile: json["mobile"],
    isVerified: json["is_verified"],
    isActive: json["is_active"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    profileImage: json["profile_image"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "email": email,
    "username": username,
    "mobile": mobile,
    "is_verified": isVerified,
    "is_active": isActive,
    "first_name": firstName,
    "last_name": lastName,
    "profile_image": profileImage,
  };
}
