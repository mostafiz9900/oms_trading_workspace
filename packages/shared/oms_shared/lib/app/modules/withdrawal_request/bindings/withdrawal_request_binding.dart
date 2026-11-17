import 'package:getxify/getxify.dart';

import '../controllers/withdrawal_request_controller.dart';

class WithdrawalRequestBinding extends Binding {
  @override
  void dependencies() {
    Get.lazyPut<WithdrawalRequestController>(
      () => WithdrawalRequestController(),
    );
  }
}
