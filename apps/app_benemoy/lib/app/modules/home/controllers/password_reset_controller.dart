import 'package:app_benemoy/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordResetController extends GetxController {
  final HomeRepository homeRepository;
  PasswordResetController(this.homeRepository);

  // 🚀 emailController এর বদলে oldPasswordController দেওয়া হলো
  // কারণ API তে oldPassword এবং password পাঠাতে হবে
  final oldPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool oldPasswordVisible = false;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  final formKey = GlobalKey<FormState>();

  // 🟢 Eye Icon Toggles (UI আপডেট করার জন্য)
  void toggleOldPassword() {
    oldPasswordVisible = !oldPasswordVisible;
    update();
  }

  void togglePassword() {
    passwordVisible = !passwordVisible;
    update();
  }

  void toggleConfirmPassword() {
    confirmPasswordVisible = !confirmPasswordVisible;
    update();
  }

  Future<void> changePassword() async {
    isLoading = true;
    update();

    try {
      var response = await homeRepository.changePassword(oldPasswordController.text, passwordController.text);

      if (response.success) {
        isLoading = false; // 🚀 FIX: এখানে true ছিল, false করা হলো
        Helpers.snackBarForSuccess2(titleText: "Success", bodyText: "${response.data}");
        Get.offAllNamed(Routes.LOGIN);
      } else {
        isLoading = false; // 🚀 FIX: এখানেও false করা হলো
        Helpers.snackbarForErorr2(titleText: "Error", bodyText: "${response.errorMessage}");
      }
    } catch (e) {
      isLoading = false; // 🚀 FIX
      print('Change password error: $e');
      Helpers.snackbarForErorr2(titleText: "Exception", bodyText: "Something went wrong!");
    }
    update();
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
