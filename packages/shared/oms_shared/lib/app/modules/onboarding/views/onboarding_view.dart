import 'package:oms_shared/app/app_pkg.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';
import 'local_widget/create_new_account.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingController>(
      assignId: true,
      builder: (onboardingCont) {
        return Scaffold(
          body: Padding(
            padding: AppSpace.pagePadding,
            child: ListView(
              children: [
                SizedBox(
                  height: 440,
                  child: PageView.builder(
                    controller: onboardingCont.pageController,
                    itemCount: onboardingCont.demoData.length,
                    onPageChanged: (value) {
                      onboardingCont.selectedIndex = value;
                      onboardingCont.update();
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        crossAxisAlignment: .center,
                        mainAxisAlignment: .center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ColorFiltered(
                          //   // colorFilter: ColorFilter.mode(
                          //   //   context.isDart?HexColor('#1C2546'):HexColor('#EBF2FC'), // Color with opacity as the overlay
                          //   //   BlendMode.srcOver, // Blending mode for the overlay
                          //   // ),
                          //   child: Image.asset(onboardingCont.demoData[index]['illustration']),
                          // ),
                          Image.asset(
                            onboardingCont.demoData[index]['illustration'],
                          ),
                          AppSpace.spaceH50,
                          Center(
                            child: Text(
                              onboardingCont.demoData[index]['title'],
                              style: Get.textTheme.titleLarge?.copyWith(
                                color: context.textColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 19),
                          Text(
                            onboardingCont.demoData[index]['text'],
                            textAlign: TextAlign.center,
                            style: Get.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: context.textColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: .center,
                    children: List.generate(
                      onboardingCont.demoData.length,
                      (index) => Padding(
                        padding: const .only(right: 6),
                        child: AnimatedDot(
                          isActive: onboardingCont.selectedIndex == index,
                        ),
                      ),
                    ),
                  ),
                ),
                AppSpace.spaceH50,
                AppSpace.spaceH30,
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: Get.width * 0.60,
                    child: CustomButton(
                      onPressed: () {
                        onboardingCont.changeNextPage();

                        // Get.to(() => const RegistrationView(),
                        //     binding: AuthBinding());
                      },
                      title: AppTranslations.startBenemoy.tr.replaceAll(
                        'Benemoy',
                        AppConfig.house.displayName,
                      ),
                      isLoading: false,
                      radius: 16,
                    ),
                  ),
                ),
                AppSpace.spaceH30,
                // CreateNewAccount(
                //   alignment: Alignment.center,
                //   titleOne: 'Already have an account? ',
                //   titleTwo: 'Login',
                //   recognizer: TapGestureRecognizer()
                //     ..onTap = () {
                //       printLog('data');
                //       // Get.to(() => const RegistrationView(),
                //       //     binding: AuthBinding());
                //     },
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedDot extends StatelessWidget {
  const AnimatedDot({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 6,
      width: isActive ? 20 : 6,
      decoration: BoxDecoration(
        color: isActive
            ? ColorConstants.secondaryColorLight
            : const Color(0xFF868686).alphaSafe(0.25),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key,
    required this.illustration,
    required this.title,
    required this.text,
  });

  final String illustration, title, text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: SvgPicture.asset(illustration),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
