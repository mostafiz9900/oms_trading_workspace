import '/app/app_pkg.dart';
import '/app/modules/onboarding/views/local_widget/create_new_account.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../generated/assets.dart';
import 'otp_verify_screen.dart';
import 'send_otp_screen.dart';
import 'signup_verify_otp.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AuthController>(
        builder: (authCon) {
          return Padding(
            padding: AppSpace.pagePadding,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //  App Logo Banner
                    SvgPicture.asset(
                      context.bannerLogo,
                      width: Get.width * 0.8,
                      height: Get.width * 0.20,
                      fit: BoxFit.contain,
                    ),
                    AppSpace.spaceH60,
                    Text(AppTranslations.signIn.tr, style: Get.textTheme.titleLarge),
                    AppSpace.spaceH10,
                    Text(
                      AppTranslations.yourAssetsAtAGlanceKeepUp.tr,
                      textAlign: TextAlign.center,
                      style: Get.textTheme.titleSmall!.copyWith(fontSize: 14),
                    ),
                    AppSpace.spaceH30,

                    //  Investor ID / Gmail Field
                    CustomEditTextFormField(
                      controller: authCon.loginUserNameController,
                      hintText: 'Investor ID or Gmail',
                      onChanged: (value) {},
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: AssetsConstants.userIconSvg,
                    ),
                    AppSpace.spaceH10,
                    CustomEditTextFormField(
                      controller: authCon.loginPasswordController,
                      hintText: 'Password',
                      onChanged: (value) {},
                      passwordVisible: !authCon.passwordVisible,
                      keyboardType: TextInputType.text,
                      prefixIcon: AssetsConstants.passwordIconSvg,
                      enableInteractiveSelection: authCon.passwordVisible,
                      suffixIcon: authCon.passwordVisible
                          ? AssetsConstants.passwordInvisibelSvg
                          : AssetsConstants.passwordVisibleSvg,
                      suffixOnTap: () {
                        authCon.passwordVisible = !authCon.passwordVisible;
                        authCon.update();
                      },
                    ),
                    AppSpace.spaceH30,

                    //  Login Button
                    CustomButton(
                      isLoading: authCon.isLoading,
                      onPressed: () {
                        if (authCon.loginUserNameController.text.isEmpty) {
                          Helpers.snackbarForErorr2(bodyText: 'Please enter investor ID Or Gmail');
                        } else if (authCon.loginPasswordController.text.isEmpty) {
                          Helpers.snackbarForErorr2(bodyText: 'Please enter password');
                        } else {
                          authCon.login();
                        }
                      },
                      title: AppTranslations.login.tr,
                    ),
                    AppSpace.spaceH20,

                    //  Remember Me & Forgot Password Row (Fixed Alignment)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              activeColor: ColorConstants.buttonColorDark,
                              checkColor: ColorConstants.white,
                              value: authCon.rememberMe,
                              onChanged: authCon.toggleRememberMe,
                            ),
                            Text(
                              "Remember Me",
                              style: Get.textTheme.titleSmall!.copyWith(
                                color: context.textColor,
                                fontSize: AppDimens.fontSizeMedium,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        CreateNewAccount(
                          alignment: Alignment.centerRight,
                          titleTwo: 'Forgot Password?',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(() => SendOTPScreen());
                              // Get.to(() => const OtpVerifyScreen(email: ''));
                            },
                        ),
                      ],
                    ),
                    AppSpace.spaceH20,

                    //  Fingerprint / Biometric Login Button
                    FingerprintButton(
                      onPressed: () async {
                        final success = await authCon.loginWithBiometric();
                        printLog('success:: $success');

                        if (!success) {
                          Helpers.snackbarForErorr2(bodyText: "Biometric login failed");
                        }
                      },
                    ),
                    AppSpace.spaceH30,

                    //  Added Skip Option (Go directly to Home Page without login)
                    TextButton(
                      onPressed: () async {
                        // ১. গেস্ট মোডে যাওয়ার আগে স্টোরেজ থেকে সমস্ত টোকেন ক্লিয়ার করুন
                        // await StorageService.remove(StorageConstants.token);
                        // await StorageService.remove(StorageConstants.refreshToken);
                        // await StorageService.remove(StorageConstants.userInfo);

                        // ২. মেমোরিতে যদি পুরানো HomeController অ্যাক্টিভ থাকে, তবে তা জোরপূর্বক ডিলিট করে দিন
                        if (Get.isRegistered<HomeController>()) {
                          Get.delete<HomeController>(force: true);
                        }

                        // ৩. এরপর ফ্রেশভাবে হোম পেজে চলে যান
                        Get.offAllNamed(Routes.HOME);
                      },
                      child: Text(
                        "Skip & Continue",
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: context.buttonColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------------------
//  Fingerprint Button Widget
// ----------------------------------------------------------------------
class FingerprintButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FingerprintButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: context.tapBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Center(
          child: SvgPicture.asset(
            GetPlatform.isIOS ? Assets.svgImageFaceId : Assets.svgImageFingerScan,
            width: 60,
            height: 60,
            colorFilter: ColorFilter.mode(ColorConstants.secondaryColorLight, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
