import 'package:getxify/getxify.dart';

import '../controllers/contact_us_controller.dart';

class ContactUsBinding extends Binding {
  @override
  void dependencies() {
    Get.lazyPut<ContactUsController>(() => ContactUsController());
  }
}
