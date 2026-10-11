import 'package:jwt_decoder/jwt_decoder.dart';

/// Stateless JWT inspection that is independent of app storage and UI.
class JwtToken {
  const JwtToken._();

  static DateTime? expirationDate(String token) {
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? decode(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (_) {
      return null;
    }
  }

  static bool isExpired(String token) => JwtDecoder.isExpired(token);
}
