import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app_pkg.dart';
import '/app/modules/auth/views/otp_verify_screen.dart';
import '/app/modules/auth/views/reset_password_sereen.dart';
import '/app/modules/auth/views/signup_verify.dart';
import '../../../data/models/response/forgot_password_model.dart';
import '../../../data/models/response/register_model.dart';
import '../../../data/models/response/select_media.dart';
import '../../../data/models/response/verify_boid.dart';
import '../../../data/models/response/verify_otp.dart';
import '../../../data/models/response/verify_selected_media.dart';
import '../views/signup_verify_otp.dart';
import '../views/signup_verify_userself_media.dart';
import 'biometric_controller.dart';
import 'token_controller.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;
  AuthController({required this.authRepository});

  // ============= login ================================
  var timerCont = Get.put<TokenController>(TokenController());
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final loginUserNameController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final bioCon = Get.put(BiometricController(), tag: 'biometric_Con');

  bool isLoading = false;
  bool passwordVisible = false;
  bool isEnabled = false;
  bool rememberMe = false;

  @override
  void onInit() {
    super.onInit();
    Helpers.isBiometricEnabled().then((value) {
      isEnabled = value;
      update();
    });
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    // Read saved data from StorageService
    final savedUser = await StorageService.read('saved_username');
    final remember = await StorageService.read('remember_me');
    if (remember == true && savedUser != null && savedUser.isNotEmpty) {
      loginUserNameController.text = savedUser;
      rememberMe = true;
    } else {
      rememberMe = false;
    }
  }

  void toggleRememberMe(bool? value) {
    rememberMe = value ?? false;
    update();
  }

  void _rememberedUserSave(String username) async {
    if (rememberMe) {
      await StorageService.save('saved_username', username);
      await StorageService.save('remember_me', true);
    } else {
      await StorageService.save('saved_username', '');
      await StorageService.save('remember_me', false);
    }
  }

  Future<dynamic> login() async {
    var loginInfo = LoginRequest(userName: loginUserNameController.text, password: loginPasswordController.text);

    if (await NetworkUtil.checkInternetConnection()) {
      try {
        isLoading = true;
        update();

        var res = await authRepository.login(loginInfo);
        printLog('response;: data ');
        printLog('${res.data}');

        if (res.data != null) {
          printLog(res.data);
          printLog("res.data here it is");

          _rememberedUserSave(loginUserNameController.text);

          // 1. Storage এ সিকিউরলি সেভ করুন
          await StorageService.save(StorageConstants.token, res.data!.token?.access);
          await StorageService.save(StorageConstants.refreshToken, res.data!.token?.refresh);
          await StorageService.saveMap(StorageConstants.userInfo, res.data!.toJson());

          // 2. টোকেন সেভ নিশ্চিত করার জন্য সামান্য মাইক্রোটাস্ক বা ডিলে দিতে পারেন (যদি প্রয়োজন হয়)
          await Future.delayed(const Duration(milliseconds: 100));

          isLoading = false; // 👈 এখানে অবশ্যই false করতে হবে, নাহলে লোডার আটকে থাকবে
          update();

          // 3. পুরানো HomeController মেমোরি থেকে সম্পূর্ণ মুছে ফেলুন
          if (Get.isRegistered<HomeController>()) {
            Get.delete<HomeController>(force: true);
          }

          // 4. হোম পেজে নেভিগেট করুন।
          // লক্ষ্য রাখবেন: Routes.HOME এর জন্য যেন নির্দিষ্ট Binding (যেমন HomeBinding) বাঁধানো থাকে,
          // যাতে HomeController স্বয়ংক্রিয়ভাবে আবার তৈরি হয়ে onInit() কল করতে পারে।
          Get.offAllNamed(
            Routes.HOME,
          ); // offNamed এর বদলে offAllNamed ব্যবহার করা বেশি সেফ, এতে প্রিভিয়াস রাউট স্ট্যাক ক্লিয়ার থাকে।
        } else {
          Helpers.snackbarForErorr2(bodyText: '${res.errorMessage}');
          isLoading = false;
          update();
        }
      } on Exception catch (e) {
        printLog('login error :: $e');
        isLoading = false;
        update();
      }
    } else {
      Helpers.snackbarForErorr2(bodyText: AppTranslations.noInternetConnection.tr);
    }
  }

  Future<dynamic> loginBiometric(String bioToken) async {
    if (await NetworkUtil.checkInternetConnection()) {
      try {
        isLoading = true;
        update();
        var res = await authRepository.loginBiometric(bioToken);
        printLog('response;: data ');
        printLog('${res.data}');
        if (res.data != null) {
          printLog(res.data);
          printLog("res.data here it is");
          // _rememberedUserSave(loginUserNameController.text);
          await StorageService.save(StorageConstants.token, res.data!.token?.access);
          await StorageService.save(StorageConstants.refreshToken, res.data!.token?.refresh);
          await StorageService.saveMap(StorageConstants.userInfo, res.data!.toJson());
          var token = await StorageService.read(StorageConstants.token);
          // timerCont.startTokenCountdown('$token');
          isLoading = true;
          update();
          Get.delete<HomeController>(force: true);
          // await Get.find<HomeController>().reloadHome();
          Get.offNamed(Routes.HOME, preventDuplicates: false);
        } else {
          Helpers.snackbarForErorr2(bodyText: '${res.errorMessage}');
          isLoading = false;
          update();
        }
      } on Exception catch (e) {
        printLog('login error :: $e');
        isLoading = false;
        update();
      }
    } else {
      Helpers.snackbarForErorr2(bodyText: AppTranslations.noInternetConnection.tr);
    }
  }

  Future<bool> loginWithBiometric2() async {
    final isEnable = await bioCon.isBiometricEnabled();
    if (!isEnable) return false;
    final authenticated = await bioCon.authenticate();
    printLog('authenticated::::::: $authenticated');
    if (!authenticated) return false;
    final decureDeviceId = await Helpers.getSecureDeviceIdLogin();
    printLog('decureDeviceId ::::::::: $decureDeviceId');
    await loginBiometric(decureDeviceId);
    // final res = await api.post('/biometric-login', {"device_id": deviceId});
    // if (res['success'] == true) {
    //   token.value = res['token'];
    //   userId.value = res['user']['id'];
    //   return true;
    // }
    return authenticated;
  }

  Future<bool> loginWithBiometric() async {
    final isEnable = await bioCon.isBiometricEnabled();
    if (!isEnable) {
      Helpers.snackbarForErorr2(bodyText: "Biometric is not enabled for this device.");
      return false;
    }

    // 1. Verify Fingerprint/Face
    final authenticated = await bioCon.authenticate();
    printLog('authenticated::::::: $authenticated');
    if (!authenticated) return false;

    // 2. Get Device ID
    final decureDeviceId = await Helpers.getSecureDeviceIdLogin();
    printLog('decureDeviceId ::::::::: $decureDeviceId');

    // ignore: dead_code
    if (decureDeviceId == null) {
      Helpers.snackbarForErorr2(bodyText: "Could not retrieve Device ID.");
      return false;
    }

    // 3. Authenticate with backend
    // Assuming loginBiometric returns a boolean indicating success!
    // If it doesn't return a bool, you need to adjust this to check the response.
    final apiSuccess = await loginBiometric(decureDeviceId);

    return apiSuccess;
  }

  /// BiometricController function to enable or disable based on current status
  Future<void> enableDisableBiometric() async {
    try {
      final isEnable = await bioCon.isBiometricEnabled(); // check current status
      if (isEnable) {
        // Currently enabled → disable?';
        await bioCon.disableBiometric();
        printLog('Biometric disabled locally');
        // Call API to disable
        // await apiCallDisable();
      } else {
        // Currently disabled → enable
        await bioCon.enableBiometric();
        printLog('Biometric enabled locally');
        // Call API to enable
        // await apiCallEnable();
      }
    } catch (e) {
      printLog('Error in enableDisableBiometric: $e');
    }
  }

  // ============= register ================================
  bool isLoadingRegister = false;
  bool isLoadingVerifyBoId = false;
  final registerBoIdController = TextEditingController();

  RegisterModel? registerInformation;

  String? chooseName;

  void setChooseName(name) {
    chooseName = name;
    update();
  }

  String? chooseFatherName;

  void setChooseFatherName(name) {
    chooseFatherName = name;
    update();
  }

  void register() async {
    if (await NetworkUtil.checkInternetConnection()) {
      if (registerBoIdController.text.isEmpty) {
        Helpers.toastError("Please enter bio");
      } else {
        try {
          isLoadingRegister = true;
          update();
          final res = await authRepository.register(registerBoIdController.text.toString());
          if (res != null) {
            printLog('user register information');
            registerInformation = res;
            update();
            isLoadingRegister = false;
            update();
            Get.off(() => const SignupVerify());
          } else {
            isLoadingRegister = false;
            update();
          }
        } on Exception catch (e) {
          printLog('register error :: $e');
          isLoadingRegister = false;
          update();
        }
      }
    } else {
      Helpers.snackbarForErorr2(bodyText: AppTranslations.noInternetConnection.tr);
    }
  }

  VerifyBoid? verifyBoid;

  void verifyBoiId() async {
    if (await NetworkUtil.checkInternetConnection()) {
      if (chooseName == null || chooseFatherName == null) {
        Helpers.toastError("Please Choose name & Father name");
      } else {
        try {
          isLoadingVerifyBoId = true;
          update();
          final res = await authRepository.verifyBoiId(
            biId: registerInformation?.boId,
            investorName: chooseName,
            fatherName: chooseFatherName,
          );
          if (res != null) {
            printLog('user verifyBoiId information');
            verifyBoid = res;
            isLoadingVerifyBoId = false;
            update();
            Get.off(() => const SignupVerifyInputMedia());
          } else {
            isLoadingVerifyBoId = false;
            update();
          }
        } on Exception catch (e) {
          printLog('verifyBoiId error :: $e');
          isLoadingVerifyBoId = false;
          update();
        }
      }
    } else {
      Helpers.snackbarForErorr2(bodyText: AppTranslations.noInternetConnection.tr);
    }
  }

  SelectMedia? selectMediaInfo;

  var media = {"email": "email", "mobile": "mobile"};

  String? selectedMedia;

  void setSelectMedia(value) {
    selectedMedia = value;
    update();
    selectMedia();
  }

  bool selectMediaLoading = false;

  void selectMedia() async {
    if (await NetworkUtil.checkInternetConnection()) {
      try {
        selectMediaLoading = true;
        update();
        final res = await authRepository.selectMedia(boId: verifyBoid?.boId, mediaType: selectedMedia);
        if (res != null) {
          selectMediaLoading = false;
          update();
          printLog('user selectMediaInfo information');
          selectMediaInfo = res;
          update();
          Get.off(() => const SignupVerifyInputMedia());
        } else {
          selectMediaLoading = false;
          update();
        }
      } on Exception catch (e) {
        selectMediaLoading = false;
        update();
        printLog('selectMediaInfo error :: $e');
      }
    } else {
      Helpers.snackbarForErorr2(bodyText: AppTranslations.noInternetConnection.tr);
    }
  }

  VerifySelectedMedia? verifySelectedMedia;
  bool? verifyMediaLoading = false;

  String? selectedAvailablePhoneOrEmail;

  void setSelectedAvailableEmail(value) {
    selectedAvailablePhoneOrEmail = value;
    update();
    inputMediaEmailOrPhone.clear();
    update();
  }

  void setClearSelectedAvailableEmail() {
    selectedAvailablePhoneOrEmail = null;
    update();
  }

  final inputMediaEmailOrPhone = TextEditingController();
  void verifyMedia() async {
    if (await NetworkUtil.checkInternetConnection()) {
      try {
        if (selectedMedia == null) {
          Helpers.snackbarForErorr2(bodyText: "Please select media");
        } else if (selectedAvailablePhoneOrEmail == null && inputMediaEmailOrPhone.text.isEmpty) {
          Helpers.snackbarForErorr2(bodyText: "Please Enter available email or mobile number");
        } else {
          verifyMediaLoading = true;
          update();
          final res = await authRepository.verifyMedia(
            boId: selectMediaInfo?.boId,
            mediaType: selectedMedia,
            email: selectedAvailablePhoneOrEmail ?? inputMediaEmailOrPhone.text,
          );
          if (res != null) {
            verifyMediaLoading = false;
            update();
            printLog('user verifyMedia information');
            verifySelectedMedia = res;
            update();
            Get.off(() => const SignupVerifyOtp());
          } else {
            verifyMediaLoading = false;
            update();
          }
        }
      } on Exception catch (e) {
        verifyMediaLoading = false;
        update();
        printLog('verifyMedia error :: $e');
      }
    } else {
      Helpers.snackbarForErorr2(bodyText: AppTranslations.noInternetConnection.tr);
    }
  }

  bool verifyOtpLoading = false;
  final otpVerifyEditController = TextEditingController();
  VerifyOtp? verifyOtpInfo;

  void verifyOtp() async {
    if (await NetworkUtil.checkInternetConnection()) {
      try {
        if (otpVerifyEditController.text.isEmpty) {
          Helpers.snackbarForErorr2(bodyText: "Please enter valid otp");
        } else {
          verifyOtpLoading = true;
          update();
          final res = await authRepository.verifyOtp(
            boId: verifySelectedMedia?.boId,
            mediaType: verifySelectedMedia?.mediaType,
            email: verifySelectedMedia?.mediaData,
            otp: otpVerifyEditController.text,
          );
          if (res != null) {
            verifyOtpLoading = false;
            update();
            printLog('user verifyOtp information');
            verifyOtpInfo = res;
            update();
            Get.off(() => const LoginView());
          } else {
            verifyOtpLoading = false;
            update();
          }
        }
      } on Exception catch (e) {
        verifyOtpLoading = false;
        update();
        printLog('verifyOtp error :: $e');
      }
    } else {
      Helpers.snackbarForErorr2(bodyText: AppTranslations.noInternetConnection.tr);
    }
  }

  // ======================= forgot password ===========================
  bool loadingForgotPass = false;
  final forgotPassEditController = TextEditingController();
  ForgotPassword? forgotPasswordInfo;

  void sentOtpForForgotPassword(String email, {bool isReset = false}) async {
    if (await NetworkUtil.checkInternetConnection()) {
      try {
        final emailAddress = email.trim().isNotEmpty ? email.trim() : forgotPassEditController.text.trim();
        final bool isValid = EmailValidator.validate(emailAddress);
        if (emailAddress.isEmpty) {
          Helpers.snackbarForErorr2(bodyText: "Enter email address");
        } else if (!isValid) {
          Helpers.snackbarForErorr2(bodyText: "Invalid email address");
        } else {
          loadingForgotPass = true;
          update();
          final res = await authRepository.forgotPassword(email: emailAddress);
          if (res != null) {
            loadingForgotPass = false;
            update();
            printLog('user forgotPassword information');
            if (isReset) {
              Get.off(() => ResetPasswordPage(email: emailAddress));
            } else {
              Get.to(() => OtpVerifyScreen(email: emailAddress));
            }
          } else {
            loadingForgotPass = false;
            update();
          }
        }
      } on Exception catch (e) {
        loadingForgotPass = false;
        update();
        printLog('forgotPassword error :: $e');
      }
    } else {
      Helpers.snackbarForErorr2(bodyText: AppTranslations.noInternetConnection.tr);
    }
  }

  void verifyOtpForgot(String email, otp) async {
    if (await NetworkUtil.checkInternetConnection()) {
      try {
        verifyOtpLoading = true;
        update();
        final res = await authRepository.verifyOtpForgot(email: email, otp: otp);
        if (res != null) {
          verifyOtpLoading = false;
          update();
          printLog('user verifyOtp information');
          Get.off(() => ResetPasswordPage(email: email));
        } else {
          verifyOtpLoading = false;
          update();
        }
      } on Exception catch (e) {
        verifyOtpLoading = false;
        update();
        printLog('verifyOtp error :: $e');
      }
    } else {
      Helpers.snackbarForErorr2(bodyText: AppTranslations.noInternetConnection.tr);
    }
  }

  void resetPassword({required String email, required String password}) async {
    if (await NetworkUtil.checkInternetConnection()) {
      try {
        verifyOtpLoading = true;
        update();

        // 🚀 Repository থেকে true/false রিসিভ করছে
        final bool isSuccess = await authRepository.resetPassword(email: email, password: password);

        if (isSuccess) {
          verifyOtpLoading = false;
          update();

          // 🚀 ফিক্স ১: গ্লোবালি ফোকাস এবং কীবোর্ড হাইড করা হলো
          FocusManager.instance.primaryFocus?.unfocus();

          // 🚀 ফিক্স ২: ফোকাস রিলিজ হওয়ার জন্য ২০০ মিলি-সেকেন্ড অপেক্ষা করে তারপর নেভিগেট করা হলো
          Future.delayed(const Duration(milliseconds: 200), () {
            // Get.offAllNamed(Routes.LOGIN);
            Get.off(() => const LoginView());
          });
        } else {
          verifyOtpLoading = false;
          update();
        }
      } on Exception catch (e) {
        verifyOtpLoading = false;
        update();
        printLog('resetPassword error :: $e');
      }
    } else {
      Helpers.snackbarForErorr2(bodyText: AppTranslations.noInternetConnection.tr);
    }
  }

  @override
  void onClose() {
    super.onClose();
    closeController();
  }

  void closeController() {
    registerBoIdController.dispose();
    loginUserNameController.dispose();
    loginPasswordController.dispose();
  }
}

final otpDurationProvider = FutureProvider<int>((ref) async {
  return 2; // default if API fails
});

/// Notifier that receives the `minutes` via constructor (family arg).
class CountDownNotifier extends Notifier<int> {
  final int minutes;
  Timer? _timer;
  late final int _initialSeconds;

  CountDownNotifier(this.minutes);

  @override
  int build() {
    _initialSeconds = minutes * 60;

    // Clean when provider is disposed
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });

    return _initialSeconds;
  }

  void start() {
    if (_timer != null) return; // prevent multiple timers

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 0) {
        state = state - 1;
      } else {
        timer.cancel();
        _timer = null;
      }
    });
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    state = _initialSeconds;
  }

  bool get isRunning => state > 0;
}

// Provider: family, pass minutes into constructor
final countDownProvider = NotifierProvider.family<CountDownNotifier, int, int>(
  (int minutes) => CountDownNotifier(minutes),
);
// Provider: family with explicit typed closure (Ref, int)

/*
class CountDownTime extends StateNotifier<int> {
  Timer? _timer;
  final int initialSeconds;
  bool _mounted = true;
  CountDownTime({required this.initialSeconds}) : super(initialSeconds);

  void start() {
    if (_timer != null) return; // prevent multiple timers
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_mounted) return;
      if (state > 0) {
        state = state - 1;
      } else {
        timer.cancel();
        _timer = null;
      }
    });
  }

  void reset() {
    if (!_mounted) return;
    _timer?.cancel();
    _timer = null;
    state = initialSeconds;
  }

  @override
  void dispose() {
    _mounted = false;
    _timer?.cancel();
    super.dispose();
  }

  bool get isRunning => state > 0;
}

// AutoDispose family to handle dynamic minutes and page lifecycle
final countDownProvider = StateNotifierProvider.autoDispose.family<CountDownTime, int, int>((ref, minutes) {
  final notifier = CountDownTime(initialSeconds: minutes * 60);

  // Optional: persist remaining seconds when disposed
  ref.onDispose(() {
    // You can store notifier.state somewhere (SharedPreferences, etc.)
    notifier.dispose();
  });

  return notifier;
});
*/
