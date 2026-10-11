// To parse this JSON data, do
//
//     final userProfile = userProfileFromJson(jsonString);

import 'dart:convert';

UserProfile userProfileFromJson(String str) =>
    UserProfile.fromJson(json.decode(str));

String userProfileToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
  int? id;
  String? email;
  String? username;
  String? mobile;
  bool? isVerified;
  bool? isActive;
  Token? token;
  UserDetail? userDetail;
  bool? firstLogin;
  String? usersStatus;
  bool? b;

  UserProfile({
    this.id,
    this.email,
    this.username,
    this.mobile,
    this.isVerified,
    this.isActive,
    this.token,
    this.userDetail,
    this.firstLogin,
    this.usersStatus,
    this.b,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json["id"],
    email: json["email"],
    username: json["username"],
    mobile: json["mobile"],
    isVerified: json["is_verified"],
    isActive: json["is_active"],
    token: json["token"] == null ? null : Token.fromJson(json["token"]),
    userDetail: json["user_detail"] == null
        ? null
        : UserDetail.fromJson(json["user_detail"]),
    firstLogin: json["first_login"],
    usersStatus: json["users_status"],
    b: json["b"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "username": username,
    "mobile": mobile,
    "is_verified": isVerified,
    "is_active": isActive,
    "token": token?.toJson(),
    "user_detail": userDetail?.toJson(),
    "first_login": firstLogin,
    "users_status": usersStatus,
    "b": b,
  };
}

class Token {
  String? access;
  String? refresh;

  Token({this.access, this.refresh});

  factory Token.fromJson(Map<String, dynamic> json) =>
      Token(access: json["access"], refresh: json["refresh"]);

  Map<String, dynamic> toJson() => {"access": access, "refresh": refresh};
}

class UserDetail {
  int? investorId;
  String? investorName;
  String? investorCode;
  String? boId;
  int? traderId;
  String? traderCode;
  int? branchId;

  UserDetail({
    this.investorId,
    this.investorName,
    this.investorCode,
    this.boId,
    this.traderId,
    this.traderCode,
    this.branchId,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
    investorId: json["investor_id"],
    investorName: json["investor_name"],
    investorCode: json["investor_code"],
    boId: json["bo_id"],
    traderId: json["trader_id"],
    traderCode: json["trader_code"],
    branchId: json["branch_id"],
  );

  Map<String, dynamic> toJson() => {
    "investor_id": investorId,
    "investor_name": investorName,
    "investor_code": investorCode,
    "bo_id": boId,
    "trader_id": traderId,
    "trader_code": traderCode,
    "branch_id": branchId,
  };
}
