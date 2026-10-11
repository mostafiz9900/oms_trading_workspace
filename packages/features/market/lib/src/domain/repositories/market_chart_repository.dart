import 'package:trading_core/trading_core.dart';

import '../../data/models/historical_volume.dart';
import '../../data/models/index_chart_model.dart';
import '../../data/models/index_chart_model2.dart';

/// Contract for historical price and index chart data sources.
abstract interface class MarketChartRepository {
  Future<ApiResponse<PriceTableResponse>?> getHistoricalVolume(
    String tickerName,
    int orderBook,
  );

  Future<ApiResponse<List<IndexChartModel>>> getIndexChart(
    String name,
    String fromDate,
    String toDate,
  );

  Future<ApiResponse<List<IndexChartModel2>>> fetchIndexChartData({
    required String fsym,
    required int resolution,
    required int fromTs,
    required int toTs,
  });
}
