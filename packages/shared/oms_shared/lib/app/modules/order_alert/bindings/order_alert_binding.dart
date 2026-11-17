import 'package:getxify/getxify.dart';

import '../controllers/order_alert_controller.dart';

class OrderAlertBinding extends Binding {
  @override
  void dependencies() {
    Get.lazyPut<OrderAlertController>(() => OrderAlertController());
  }
}
