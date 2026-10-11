import 'package:get/get.dart';

import '../controllers/withdrawal_request_controller.dart';

class WithdrawalRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WithdrawalRequestController>(
      () => WithdrawalRequestController(),
    );
  }
}
