import 'package:getxify/getxify.dart';

import '../controllers/top_share_controller.dart';

class TopShareBinding extends Binding {
  @override
  void dependencies() {
    Get.lazyPut<TopShareController>(() => TopShareController());
  }
}
