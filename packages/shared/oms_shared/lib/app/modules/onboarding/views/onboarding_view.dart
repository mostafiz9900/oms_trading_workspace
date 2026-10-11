import '../../../core/utils/extensions/app_context.dart';
import '../../../core/values/app_config.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/space.dart';
import '../../../global_widgets/custom_button.dart';
import 'package:localization/localization.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';

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
                          //   //   context.isDart?HexColor('#1C2546'):HexColor('#EBF2FC'), // Color with opacity as the overlay
                          //   //   BlendMode.srcOver, // Blending mode for the overlay
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

                      },
                      title: AppTranslations.startHouse.tr.replaceAll(
                        'Benemoy',
                        AppConfig.house.displayName,
                      ),
                      isLoading: false,
                      radius: 16,
                    ),
                  ),
                ),
                AppSpace.spaceH30,
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

