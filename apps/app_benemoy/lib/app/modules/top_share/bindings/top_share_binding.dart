import 'package:get/get.dart';

import '../controllers/top_share_controller.dart';

class TopShareBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TopShareController>(() => TopShareController());
  }
}
