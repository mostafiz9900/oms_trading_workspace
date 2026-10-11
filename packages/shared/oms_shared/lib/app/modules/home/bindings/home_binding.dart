import 'package:get/get.dart';

import '../../../app_pkg.dart';
import '../controllers/companies_controller.dart';
import '../controllers/historical_volume_controller.dart';
import '../controllers/index_chart_controller.dart';
import '../controllers/live_index_controller.dart';
import '../controllers/market_index_controller.dart';
import '../controllers/password_reset_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(homeRepository: Get.find()),
      fenix: true,
    );
    //লাইভ ইনডেক্স কন্ট্রোলারকে permanent করে দেওয়া হলো, যেন ট্যাব পাল্টালে ডিসপোজ না হয়
    Get.put<LiveIndexController>(LiveIndexController(), permanent: true);
    Get.lazyPut<HomeController>(
      () => HomeController(homeRepository: Get.find()),
      tag: 'orderModifiy',
    );
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
    Get.lazyPut<IndexChartController>(
      () => IndexChartController(Get.find<HomeRepository>()),
    );
    Get.lazyPut<OrderSummaryController>(() => OrderSummaryController());
  }
}
