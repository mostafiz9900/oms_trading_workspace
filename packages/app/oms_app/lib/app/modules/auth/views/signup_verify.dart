import 'package:oms_app/app/app_pkg.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../data/models/response/register_model.dart';
import '../../onboarding/views/local_widget/create_new_account.dart';

class SignupVerify extends GetView<AuthController> {
  const SignupVerify({super.key});
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
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .center,
                  children: [
                    AppSpace.spaceH30,
                    Align(child: SvgPicture.asset(AssetsConstants.logoSvg)),
                    AppSpace.spaceH30,
                    Align(child: Text("Verify UserSelf", style: Get.textTheme.titleLarge)),
                    AppSpace.spaceH30,
                    Align(
                      child: Text(
                        "Bio Id: ${authCon.registerInformation?.boId}",
                        style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    AppSpace.spaceH10,
                    Text(
                      "Choose Name",
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: ColorConstants.gray,
                        fontSize: AppDimens.space17,
                      ),
                    ),
                    Column(
                      children: List.generate(authCon.registerInformation!.nameList!.length, (index) {
                        NameList model = authCon.registerInformation!.nameList!.elementAt(index);
                        return InkWell(
                          onTap: () {
                            authCon.setChooseName(model.name);
                          },
                          child: Row(
                            mainAxisAlignment: .start,
                            children: [
                              Radio(
                                value: model.name,
                                groupValue: authCon.chooseName,
                                activeColor: context.buttonColor,
                                onChanged: (value) {
                                  printLog(value);
                                  authCon.setChooseName(value);
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              Text(
                                '${model.name}',
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
                    AppSpace.spaceH10,
                    Text(
                      "Father Name",
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: ColorConstants.gray,
                        fontSize: AppDimens.space17,
                      ),
                    ),
                    Column(
                      children: List.generate(authCon.registerInformation!.nameList!.length, (index) {
                        NameList model = authCon.registerInformation!.nameList!.elementAt(index);
                        return InkWell(
                          onTap: () {
                            authCon.setChooseFatherName(model.fathersName);
                          },
                          child: Row(
                            mainAxisAlignment: .start,
                            children: [
                              Radio(
                                value: model.fathersName,
                                groupValue: authCon.chooseFatherName,
                                activeColor: context.buttonColor,
                                onChanged: (value) {
                                  authCon.setChooseFatherName(value);
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              Text(
                                '${model.fathersName}',
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
                    AppSpace.spaceH10,
                    CustomButton(
                      isLoading: authCon.isLoadingVerifyBoId,
                      onPressed: () {
                        authCon.verifyBoiId();
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
          ),
        );
      },
    );
  }
}
