import 'package:get/get.dart';

import '../../../data/repositories/home_repository.dart';
import '../controllers/home_controller.dart';
import '../../orders/controllers/order_summary_controller.dart';
import '../../market/controllers/companies_controller.dart';
import '../../quote/controllers/historical_volume_controller.dart';
import '../../market/controllers/live_index_controller.dart';
import '../../market/controllers/market_index_controller.dart';
import '../../auth/controllers/password_reset_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(homeRepository: Get.find()),
      fenix: true,
    );
    //লাইভ ইনডেক্স কন্ট্রোলারকে permanent করে দেওয়া হলো, যেন ট্যাব পাল্টালে ডিসপোজ না হয়
    if (!Get.isRegistered<LiveIndexController>()) {
      Get.put<LiveIndexController>(LiveIndexController(), permanent: true);
    }
    Get.lazyPut<PasswordResetController>(
      () => PasswordResetController(Get.find()),
    );
    Get.lazyPut<CompaniesController>(() => CompaniesController());
    // Register HistoricalVolumeController with dependency injection
    Get.lazyPut<HistoricalVolumeController>(
      () => HistoricalVolumeController(repository: Get.find<HomeRepository>()),
    );
    Get.lazyPut<MarketIndexController>(
      () => MarketIndexController(Get.find<HomeRepository>()),
    );
    Get.lazyPut<OrderSummaryController>(() => OrderSummaryController());
  }
}
