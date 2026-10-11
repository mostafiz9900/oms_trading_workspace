import 'package:get/get.dart';

import '../controllers/limit_request_controller.dart';

class LimitRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LimitRequestController>(
      () => LimitRequestController(),
    );
  }
}
