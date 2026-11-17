import 'package:getxify/getxify.dart';

import '../controllers/auth_controller.dart';

class AuthBinding extends Binding {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(authRepository: Get.find()),
    );
  }
}
