import 'package:get/get.dart';

import '../controllers/app_network_controller.dart';

class AppNetworkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppNetworkController>(() => AppNetworkController());
  }
}
