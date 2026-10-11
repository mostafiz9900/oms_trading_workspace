import 'package:oms_shared/app/app_pkg.dart';
import 'package:oms_shared/app/modules/onboarding/views/local_widget/create_new_account.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SignupVerifyOtp extends GetView<AuthController> {
  const SignupVerifyOtp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authCon) {
        return Scaffold(
          body: Padding(
            padding: AppSpace.pagePadding,
            child: Center(
              child: Column(
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                children: [
                  SvgPicture.asset(AssetsConstants.logoSvg),
                  AppSpace.spaceH60,
                  Text("Verify Otp", style: Get.textTheme.titleLarge),
                  AppSpace.spaceH30,
                  CustomEditTextFormField(
                    controller: authCon.otpVerifyEditController,
                    hintText: 'Enter your otp',
                    onChanged: (value) {},
                  ),
                  AppSpace.spaceH10,
                  CustomButton(
                    isLoading: authCon.verifyOtpLoading,
                    onPressed: () {
                      if (!authCon.verifyOtpLoading) {
                        authCon.verifyOtp();
                      }
                    },
                    title: "Submit",
                  ),
                  AppSpace.spaceH20,
                  CreateNewAccount(
                    alignment: Alignment.center,
                    titleOne: "Already Registered ",
                    titleTwo: 'Sign-in?',
                    color: ColorConstants.blueColor,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        printLog('data');
                        Get.to(() => const LoginView());
                      },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
