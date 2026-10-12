import 'package:trading_core/trading_core.dart';

import '../../../data/services/storage_service.dart';
import '../../values/storage.dart';

class JWTHelper {
  /// Check if a token has expired
  static Future<bool> hasTokenExpired({String? token}) async {
    var data = token ?? await StorageService.read(StorageConstants.token);
    if (data == null) return true;
    return JwtToken.isExpired(data);
  }

  /// Get the expiration date of a token
  static DateTime? getTokenExpiryDate(String token) {
    return JwtToken.expirationDate(token);
  }

  /// Decode a token to retrieve its payload
  static Map<String, dynamic>? decodeToken(String token) {
    return JwtToken.decode(token);
  }

  /// Validate if a token is valid (not expired and decodable)
  static Future<bool> isValidToken(String? token) async {
    var data = await StorageService.read(StorageConstants.token);
    if (data == null) return false;
    var result = await hasTokenExpired(token: token ?? data);
    return !result;
  }

  static bool isTokenExpired(String token) {
    return JwtToken.isExpired(token);
  }
}
