import 'package:getxify/getxify.dart';

import '../controllers/app_network_controller.dart';

class AppNetworkBinding extends Binding {
  @override
  void dependencies() {
    Get.lazyPut<AppNetworkController>(() => AppNetworkController());
  }
}
