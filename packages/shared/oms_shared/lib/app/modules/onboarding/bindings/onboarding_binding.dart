import 'package:getxify/getxify.dart';

import '../controllers/onboarding_controller.dart';

class OnboardingBinding extends Binding {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
