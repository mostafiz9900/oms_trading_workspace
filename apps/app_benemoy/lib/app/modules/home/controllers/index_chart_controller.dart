import 'package:market/market.dart'
    show IndexChartModel2, MarketChartRepository;
import 'package:get/get.dart';

import '../../../data/data.dart';

import 'home_controller.dart';

class IndexChartController extends GetxController {
  final MarketChartRepository repository;
  IndexChartController(this.repository);

  final homeController = Get.find<HomeController>();
  bool isLoading = true;
  String errorMessage = '';
  List<IndexChartModel2> chartData = [];

  String symbol = 'DSEX';
  double currentPrice = 0.0;
  double currentVolume = 0.0;

  @override
  void onInit() {
    super.onInit();
    fetchChartData(symbol);
    update();
  }

  Future<void> fetchChartData(String indexName) async {
    isLoading = true;
    errorMessage = '';
    symbol = indexName;
    update(); // Notify GetBuilder to show loading state

    try {
      final now = DateTime.now();
      final today10AM = DateTime(now.year, now.month, now.day, 10, 0, 0);

      final int fromTs = (today10AM.millisecondsSinceEpoch / 1000).round();
      final int toTs = (now.millisecondsSinceEpoch / 1000).round();

      final ApiResponse<List<IndexChartModel2>> response = await repository
          .fetchIndexChartData(
            fsym: symbol,
            resolution: 1,
            fromTs: fromTs,
            toTs: toTs,
          );

      if (response.success) {
        chartData = response.data ?? [];

        if (chartData.isNotEmpty) {
          currentPrice = chartData.last.price;
          currentVolume = chartData.last.volume;
        } else {
          errorMessage = 'No data available';
        }
      } else {
        errorMessage = response.errorMessage ?? 'Failed to load chart data';
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
    } finally {
      isLoading = false;
      update(); // Notify GetBuilder to rebuild UI
    }
  }

  String formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(2)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(2)}K';
    }
    return volume.toStringAsFixed(0);
  }
}
