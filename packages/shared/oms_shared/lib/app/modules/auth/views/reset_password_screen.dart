import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/utils/extensions/app_context.dart';
import '../../../core/values/assets.dart';
import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/custom_edit_text_form_field.dart';
import '../controllers/auth_controller.dart';

// ================== Password Visibility Providers ==================
final passwordVisibilityProvider = NotifierProvider<PasswordVisibilityNotifier, bool>(() {
  return PasswordVisibilityNotifier();
});

final confirmPasswordVisibilityProvider = NotifierProvider<ConfirmPasswordVisibilityNotifier, bool>(() {
  return ConfirmPasswordVisibilityNotifier();
});

class PasswordVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

class ConfirmPasswordVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

// ------------------ UI ------------------

class ResetPasswordPage extends HookConsumerWidget {
  const ResetPasswordPage({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showPassword = ref.watch(passwordVisibilityProvider);
    final showConfirm = ref.watch(confirmPasswordVisibilityProvider);

    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    var inputHintStyle = Get.textTheme.bodyMedium?.copyWith(
      color: Colors.grey.shade400,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(), // ওভার-স্ক্রল বা বাউন্স বন্ধ করবে
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                //  필্ডগুলোকে ফুল-উইডথ করার জন্য stretch ব্যবহার করা হলো
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: SvgPicture.asset(context.bannerLogo, width: 80, height: 80)),
                  const SizedBox(height: 10),

                  const SizedBox(height: 8),
                  Text('Please enter your new password', textAlign: TextAlign.center, style: inputHintStyle),
                  const SizedBox(height: 32),

                  //  New Password Field
                  CustomEditTextFormField(
                    controller: newPasswordController,
                    hintText: 'New Password',
                    passwordVisible: !showPassword,
                    keyboardType: TextInputType.visiblePassword,
                    prefixIcon: AssetsConstants.passwordIconSvg,
                    suffixIcon: showPassword
                        ? AssetsConstants.passwordVisibleSvg
                        : AssetsConstants.passwordInvisibelSvg,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    suffixOnTap: () {
                      ref.read(passwordVisibilityProvider.notifier).toggle();
                    },
                    onChanged: (String value) {},
                  ),
                  const SizedBox(height: 16),

                  //  Confirm Password Field
                  CustomEditTextFormField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    passwordVisible: !showConfirm,
                    keyboardType: TextInputType.visiblePassword,
                    prefixIcon: AssetsConstants.passwordIconSvg,
                    suffixIcon: showConfirm ? AssetsConstants.passwordVisibleSvg : AssetsConstants.passwordInvisibelSvg,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    suffixOnTap: () {
                      ref.read(confirmPasswordVisibilityProvider.notifier).toggle();
                    },
                    onChanged: (String value) {},
                  ),
                  const SizedBox(height: 32),

                  //  Reset Button
                  GetBuilder<AuthController>(
                    builder: (authCon) {
                      return CustomButton(
                        isLoading: authCon.verifyOtpLoading,
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            FocusScope.of(context).unfocus();
                            authCon.resetPassword(email: email, password: newPasswordController.text.trim());
                          }
                        },
                        title: "Reset Password",
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
