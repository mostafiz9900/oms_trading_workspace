import 'package:trading_core/trading_core.dart';

import '../models/request/login_request.dart';
import '../models/response/user_profile.dart';

/// Authentication operations required by broker-house application clients.
///
/// UI navigation, local token persistence, and HTTP concerns stay in each
/// application adapter.
abstract interface class AuthenticationRepository {
  Future<ApiResponse<UserProfile>> login(LoginRequest request);

  Future<ApiResponse<UserProfile>> loginBiometric(String biometricToken);
}
