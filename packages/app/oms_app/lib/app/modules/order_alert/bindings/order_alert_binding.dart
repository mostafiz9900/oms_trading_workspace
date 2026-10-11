import 'package:get/get.dart';

import '../controllers/order_alert_controller.dart';

class OrderAlertBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderAlertController>(
      () => OrderAlertController(),
    );
  }
}
