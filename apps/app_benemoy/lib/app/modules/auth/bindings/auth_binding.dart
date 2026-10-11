import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/token_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(authRepository: Get.find()));
  }
}
