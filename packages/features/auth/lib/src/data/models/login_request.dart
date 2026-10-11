import 'dart:convert';

/// Login request DTO shared by OMS authentication adapters.
class LoginRequest {
  const LoginRequest({required this.userName, required this.password});

  final String userName;
  final String password;

  factory LoginRequest.fromRawJson(String source) =>
      LoginRequest.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    userName: json['username'] as String,
    password: json['password'] as String,
  );

  Map<String, dynamic> toJson() => {'username': userName, 'password': password};
}
