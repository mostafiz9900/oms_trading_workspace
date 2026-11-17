import 'package:getxify/getxify.dart';

import '../controllers/limit_request_controller.dart';

class LimitRequestBinding extends Binding {
  @override
  void dependencies() {
    Get.lazyPut<LimitRequestController>(() => LimitRequestController());
  }
}
