import 'package:app_benemoy/app/app_pkg.dart';
import 'package:app_benemoy/app/modules/onboarding/views/local_widget/create_new_account.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authCon) {
        return Scaffold(
          body: Padding(
            padding: AppSpace.pagePadding,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .center,
                  mainAxisAlignment: .center,
                  children: [
                    SvgPicture.asset(AssetsConstants.logoSvg),
                    AppSpace.spaceH60,
                    Text("Sign Up", style: Get.textTheme.titleLarge),
                    AppSpace.spaceH10,
                    Text(
                      "Your assets at a glance.keep up to date sWith your stocks portfolio",
                      textAlign: TextAlign.center,
                      style: Get.textTheme.titleSmall!.copyWith(fontSize: 14),
                    ),
                    AppSpace.spaceH30,
                    CustomEditTextFormField(
                      controller: authCon.registerBoIdController,
                      hintText: 'Bio',
                      onChanged: (value) {},
                      prefixIcon: AssetsConstants.userIconSvg,
                    ),
                    AppSpace.spaceH10,
                    CustomButton(
                      isLoading: authCon.isLoadingRegister,
                      onPressed: () {
                        if (!authCon.isLoadingRegister) {
                          authCon.register();
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
                          //     binding: AuthBinding());
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
