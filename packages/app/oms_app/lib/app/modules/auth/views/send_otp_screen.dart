import 'package:oms_app/app/app_pkg.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SendOTPScreen extends GetView<AuthController> {
  SendOTPScreen({super.key});

  //  Form Validation এর জন্য গ্লোবাল-কি (Global Key)
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(), //  সহজে আগের পেজে ব্যাক করার জন্য
        ),
      ),
      body: SafeArea(
        child: GetBuilder<AuthController>(
          builder: (authCon) {
            return Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(), // কীবোর্ড ওপেন হলে স্মুথ স্ক্রল হবে
                padding: AppSpace.pagePadding, // আপনার আগের ডিফল্ট প্যাডিং
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch, //  ফিল্ড এবং বাটন ফুল-উইডথ করার জন্য
                    children: [
                      //  Logo (সেন্টারে এবং পারফেক্ট সাইজে রাখা হলো)
                      Center(
                        child: SvgPicture.asset(
                          context.bannerLogo,
                          height: 80, //  চ্যাপ্টা যেন না লাগে তাই নির্দিষ্ট সাইজ
                          width: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // AppSpace.spaceH20,

                      // //  Title
                      // Text(
                      //   "Forgot Password",
                      //   textAlign: TextAlign.center,
                      //   style: Get.textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                      // ),
                      AppSpace.spaceH10,

                      //  Subtitle
                      Text(
                        "Enter your email to reset your password.",
                        textAlign: TextAlign.center,
                        style: Get.textTheme.titleSmall?.copyWith(
                          fontSize: 14,
                          color: Colors.grey.shade400, //  দেখতে সুন্দর লাগার জন্য
                        ),
                      ),
                      AppSpace.spaceH30,

                      //  Email Input Field (With Validation)
                      CustomEditTextFormField(
                        controller: authCon.forgotPassEditController,
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!GetUtils.isEmail(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        onChanged: (value) {},
                      ),
                      AppSpace.spaceH20,

                      //  Action Button (With Validation Trigger)
                      CustomButton(
                        isLoading: authCon.loadingForgotPass,
                        onPressed: () {
                          //  শুধু ভ্যালিড ইমেইল দিলেই রিকোয়েস্ট যাবে
                          if (_formKey.currentState?.validate() ?? false) {
                            FocusScope.of(context).unfocus(); // কীবোর্ড নামিয়ে দিবে
                            authCon.sentOtpForForgotPassword(authCon.forgotPassEditController.text.trim());
                          }
                        },
                        title: "Forgot Password",
                      ),
                      AppSpace.spaceH20,

                      //  "Already Registered?" অপশনটি ফিক্স করে চালু করা হলো
                      //   CreateNewAccount(
                      //     alignment: Alignment.center,
                      //     titleOne: "Already Registered? ",
                      //     titleTwo: 'Sign-in',
                      //     color: ColorConstants.blueColor,
                      //     recognizer: TapGestureRecognizer()
                      //       ..onTap = () {
                      //         printLog('Navigating back to Login');
                      //         Get.offAll(() => const LoginView()); //  লগিন পেজে নিয়ে যাবে
                      //       },
                      //   ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
