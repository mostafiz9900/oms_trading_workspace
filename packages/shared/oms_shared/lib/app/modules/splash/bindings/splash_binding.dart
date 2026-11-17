import 'package:getxify/getxify.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Binding {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
