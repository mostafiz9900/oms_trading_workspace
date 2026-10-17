import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/core/utils/helpers/jwt_helper.dart';

/// Builds an unsigned JWT; the app only decodes tokens, it never verifies them.
String jwt(Map<String, dynamic> payload) {
  String part(Object o) => base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.${part(payload)}.signature';
}

int epoch(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;

void main() {
  final now = DateTime.now();

  test('a token that expires in the future is valid', () {
    final token = jwt({'exp': epoch(now.add(const Duration(hours: 1)))});
    expect(JWTHelper.isTokenExpired(token), isFalse);
  });

  test('a token past its expiry is expired', () {
    final token = jwt({'exp': epoch(now.subtract(const Duration(seconds: 1)))});
    expect(JWTHelper.isTokenExpired(token), isTrue);
  });

  test('expiry date is read from the exp claim', () {
    final exp = DateTime.fromMillisecondsSinceEpoch(epoch(now) * 1000 + 3600 * 1000);
    final token = jwt({'exp': epoch(exp)});
    expect(JWTHelper.getTokenExpiryDate(token), exp);
  });

  test('the payload is decoded', () {
    final token = jwt({'user_id': 42, 'exp': epoch(now)});
    expect(JWTHelper.decodeToken(token)?['user_id'], 42);
  });

  test('a malformed token decodes to null instead of throwing', () {
    expect(JWTHelper.decodeToken('not-a-jwt'), isNull);
    expect(JWTHelper.getTokenExpiryDate('not-a-jwt'), isNull);
  });

  test('isTokenExpired throws on a malformed token (callers must catch)', () {
    expect(() => JWTHelper.isTokenExpired('not-a-jwt'), throwsFormatException);
  });
}
