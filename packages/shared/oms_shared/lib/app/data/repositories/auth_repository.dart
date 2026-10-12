import '../../core/utils/helpers/app_helper.dart';
import '../../core/utils/helpers/log_helper.dart';
import '../../core/values/api_url.dart';
import '../../core/values/constants.dart';
import '../api/api_response.dart';
import '../api/base_response.dart';
import '../models/request/login_request.dart';
import '../models/response/user_profile.dart';
import '../providers/auth_provider.dart';

import 'authentication_repository.dart' show AuthenticationRepository;

import '../models/response/register_model.dart';
import '../models/response/select_media.dart';
import '../models/response/verify_boid.dart';
import '../models/response/verify_otp.dart';
import '../models/response/verify_selected_media.dart';

class AuthRepository implements AuthenticationRepository {
  AuthRepository({required this.authProvider});

  final AuthProvider authProvider;

  @override
  Future<ApiResponse<UserProfile>> login(LoginRequest data) async {
    var url = ApiUrl.login;
    final res = await authProvider.login(url, data);
    printLog('${res.body}');
    printLog('repo response body in login');
    if (res.body != null && res.statusCode == AppConstants.successStatus) {
      return ApiResponse.success(
        UserProfile.fromJson(res.body[AppConstants.data]),
      );
    } else {
      //??
      return res.body == null
          ? ApiResponse.error('Server not response')
          : ApiResponse.error('${res.body[AppConstants.message]}');
    }
  }

  @override
  Future<ApiResponse<UserProfile>> loginBiometric(String bioToken) async {
    var url = ApiUrl.login;
    final res = await authProvider.loginBiometric(url, bioToken);
    printLog('${res.body}');
    printLog('repo response body in login');
    if (res.body != null && res.statusCode == AppConstants.successStatus) {
      return ApiResponse.success(
        UserProfile.fromJson(res.body[AppConstants.data]),
      );
    } else {
      //??
      return res.body == null
          ? ApiResponse.error('Server not response')
          : ApiResponse.error('${res.body[AppConstants.message]}');
    }
  }

  Future<dynamic> register(String? boId) async {
    var url = ApiUrl.register;
    var boid = {"bo_id": boId};
    final res = await authProvider.register(url, boid);
    if (res.statusCode == 200) {
      Helpers.snackBarForSuccess2(bodyText: '${res.body["message"]}');
      return registerModelFromMap(res.body["data"]);
    } else {
      Helpers.snackbarForErorr2(bodyText: '${res.body["message"]}');
    }
  }

  Future<dynamic> verifyBoiId({
    String? biId,
    String? investorName,
    String? fatherName,
  }) async {
    var verifyData = {
      "bo_id": biId,
      "investor_name": investorName,
      "fathers_name": fatherName,
    };

    var url = ApiUrl.verifyBoid;
    final res = await authProvider.verifyBoiId(url, verifyData);
    if (res.statusCode == 200) {
      Helpers.snackBarForSuccess2(bodyText: '${res.body["message"]}');
      return verifyBoidFromMap(res.body["data"]);
    } else {
      Helpers.snackbarForErorr2(bodyText: '${res.body["message"]}');
    }
  }

  Future<dynamic> selectMedia({String? boId, String? mediaType}) async {
    var selectMediaData = {"bo_id": boId, "media_type": mediaType};
    var url = ApiUrl.selectMedia;
    final res = await authProvider.selectMedia(url, selectMediaData);
    if (res.statusCode == 200) {
      return selectMediaFromMap(res.body["data"]);
    } else {
      Helpers.snackbarForErorr2(bodyText: '${res.body["message"]}');
    }
  }

  Future<dynamic> verifyMedia({
    String? boId,
    String? mediaType,
    String? email,
  }) async {
    var verifyMediaData = {
      "bo_id": boId,
      "media_type": mediaType,
      "email": email,
    };
    var url = ApiUrl.verifyMedia;
    final res = await authProvider.verifyMedia(url, verifyMediaData);
    if (res.statusCode == 200) {
      Helpers.snackBarForSuccess2(bodyText: '${res.body["message"]}');
      return verifySelectedMediaFromMap(res.body["data"]);
    } else {
      Helpers.snackbarForErorr2(bodyText: '${res.body["message"]}');
    }
  }

  Future<dynamic> verifyOtp({
    String? boId,
    String? mediaType,
    String? email,
    String? otp,
  }) async {
    var varifyOtpData = {
      "bo_id": boId,
      "otp": otp,
      "email": email,
      "media_type": mediaType,
    };
    var url = ApiUrl.verifyOtp;
    final res = await authProvider.verifyOtp(url, varifyOtpData);
    if (res.statusCode == 200) {
      Helpers.snackBarForSuccess2(bodyText: '${res.body["message"]}');
      return verifyOtpFromMap(res.body["data"]);
    } else {
      Helpers.snackbarForErorr2(bodyText: '${res.body["message"]}');
    }
  }

  Future<dynamic> verifyOtpForgot({String? email, String? otp}) async {
    var varifyOtpData = {"email": email, "otp": otp};
    var url = ApiUrl.verifyOtpForgot;
    final res = await authProvider.verifyOtpForgot(url, varifyOtpData);
    if (res.statusCode == 200) {
      Helpers.snackBarForSuccess2(bodyText: '${res.body["message"]}');
      return true;
    } else {
      Helpers.snackbarForErorr2(bodyText: '${res.body["message"]}');
    }
  }

  Future<bool> resetPassword({String? email, String? password}) async {
    var resetPasswordData = {
      "email": email,
      "new_password": password,
      "confirm_new_password": password,
    };
    printLog('resetPassword Request :: $resetPasswordData');
    var url = ApiUrl.forgotPasswordUrl;

    try {
      // 🚀 ফিক্স: এখানে authProvider হবে, authRepository নয়!
      final res = await authProvider.resetPassword(url, resetPasswordData);

      if (res.statusCode == 200 || res.statusCode == 201) {
        Helpers.snackBarForSuccess2(
          bodyText:
              res.body["message"]?.toString() ?? "Password reset successfully!",
        );
        return true; // সাকসেস হলে true রিটার্ন করবে
      } else {
        // 🚀 ফেইল হলে সার্ভারের মেসেজ দেখাবে এবং false রিটার্ন করবে
        String errorMessage =
            res.body["message"]?.toString() ??
            "Verification failed. Please try again.";
        Helpers.snackbarForErorr2(bodyText: errorMessage);
        return false;
      }
    } catch (e) {
      printLog('resetPassword Repository Error :: $e');
      Helpers.snackbarForErorr2(
        bodyText: 'Failed to reset password. Please try again.',
      );
      return false;
    }
  }

  // ======================= forgot password ===========================

  Future<dynamic> forgotPassword({String? email}) async {
    var forgotData = {"email": email};
    var url = ApiUrl.forgotPassword;
    final res = await authProvider.forgotPassword(url, forgotData);
    if (res.statusCode == 200) {
      Helpers.snackBarForSuccess2(bodyText: '${res.body["message"]}');
      return verifyOtpFromMap(res.body);
    } else {
      Helpers.snackbarForErorr2(bodyText: '${res.body["message"]}');
    }
  }

  Future<dynamic> getUsers() async {
    final res = await authProvider.getUsers('/api/users?page=1&per_page=12');
    if (BaseResponse.handleApiResponse(res)) {
      return null;
    }
  }
}
