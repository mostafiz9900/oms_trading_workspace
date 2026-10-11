import '../../../core/utils/extensions/app_context.dart';
import '../../../core/utils/helpers/log_helper.dart';
import '../../../core/values/assets.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/dimens.dart';
import '../../../core/values/space.dart';
import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/custom_edit_text_form_field.dart';
import '../controllers/auth_controller.dart';
import 'login_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../onboarding/views/local_widgets/create_new_account.dart';

class SignupVerifyInputMedia extends GetView<AuthController> {
  const SignupVerifyInputMedia({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: AppSpace.pagePadding,
        child: Center(
          child: GetBuilder<AuthController>(
            builder: (authCon) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .center,
                  mainAxisAlignment: .center,
                  children: [
                    SvgPicture.asset(AssetsConstants.logoSvg),
                    AppSpace.spaceH30,
                    Text("Verify UserSelf", style: Get.textTheme.titleLarge),
                    AppSpace.spaceH30,
                    Column(
                      mainAxisAlignment: .start,
                      crossAxisAlignment: .start,
                      children: [
                        Align(
                          child: Text(
                            "Bio Id: ${authCon.verifyBoid?.boId}",
                            style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        AppSpace.spaceH10,
                        Text(
                          "Select Media",
                          style: Get.textTheme.titleMedium?.copyWith(
                            color: ColorConstants.gray,
                            fontSize: AppDimens.space17,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            authCon.setSelectMedia(authCon.media["email"]);
                          },
                          child: Row(
                            mainAxisAlignment: .start,
                            children: [
                              Radio(
                                value: authCon.media["email"],
                                groupValue: authCon.selectedMedia,
                                activeColor: context.buttonColor,
                                onChanged: (value) {
                                  printLog(value);
                                  authCon.setSelectMedia(value);
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              Text(
                                'Email',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontSize: AppDimens.space14,
                                  fontWeight: FontWeight.w400,
                                  color: ColorConstants.gray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            authCon.setSelectMedia(authCon.media["mobile"]);
                          },
                          child: Row(
                            mainAxisAlignment: .start,
                            children: [
                              Radio(
                                value: authCon.media["mobile"],
                                groupValue: authCon.selectedMedia,
                                activeColor: context.buttonColor,
                                onChanged: (value) {
                                  authCon.setSelectMedia(value);
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              Text(
                                'Mobile',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontSize: AppDimens.space14,
                                  fontWeight: FontWeight.w400,
                                  color: ColorConstants.gray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpace.spaceH10,
                        authCon.selectedMedia == null
                            ? Container()
                            : Row(
                                mainAxisAlignment: .start,
                                crossAxisAlignment: .start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      mainAxisAlignment: .start,
                                      crossAxisAlignment: .start,
                                      children: [
                                        Text(
                                          "Available ${authCon.selectedMedia}",
                                          style: Get.textTheme.titleMedium?.copyWith(
                                            color: ColorConstants.gray,
                                            fontSize: AppDimens.space17,
                                          ),
                                        ),
                                        authCon.selectMediaLoading == true || authCon.selectMediaInfo == null
                                            ? Container()
                                            : Column(
                                                children: List.generate(authCon.selectMediaInfo!.mediaData!.length, (
                                                  index,
                                                ) {
                                                  String? model = authCon.selectMediaInfo!.mediaData!.elementAt(index);
                                                  return InkWell(
                                                    onTap: () {
                                                      authCon.setSelectedAvailableEmail(model);
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment: .start,
                                                      children: [
                                                        Radio(
                                                          value: model,
                                                          groupValue: authCon.selectedAvailablePhoneOrEmail,
                                                          activeColor: context.buttonColor,
                                                          onChanged: (value) {
                                                            authCon.setSelectedAvailableEmail(value);
                                                          },
                                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                        ),
                                                        Text(
                                                          model,
                                                          maxLines: 1,
                                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                            fontSize: AppDimens.space14,
                                                            fontWeight: FontWeight.w400,
                                                            color: ColorConstants.gray,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      mainAxisAlignment: .start,
                                      crossAxisAlignment: .start,
                                      children: [
                                        Text(
                                          "Add New ${authCon.selectedMedia}",
                                          style: Get.textTheme.titleMedium?.copyWith(
                                            color: ColorConstants.gray,
                                            fontSize: AppDimens.space17,
                                          ),
                                        ),
                                        AppSpace.spaceH10,
                                        CustomEditTextFormField(
                                          hintText: 'Enter ${authCon.selectedMedia}',
                                          onChanged: (value) {
                                            authCon.setClearSelectedAvailableEmail();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                    AppSpace.spaceH10,
                    CustomButton(
                      isLoading: authCon.verifyMediaLoading,
                      onPressed: () {
                        authCon.verifyMedia();
                      },
                      title: "Submit",
                    ),
                    AppSpace.spaceH20,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
