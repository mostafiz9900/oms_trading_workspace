import '../models/response/index_chart_model.dart'
    show IndexChartModel, indexChartModelFromJson;
import '../models/response/index_chart_model2.dart'
    show IndexChartModel2, indexChartModel2FromJson;
import 'market_chart_repository.dart' show MarketChartRepository;
import '../models/response/historical_volume.dart' show PriceTableResponse;

import '../../core/utils/helpers/log_helper.dart';
import '../../core/values/api_url.dart';
import '../api/api_response.dart';
import '../providers/home_provider.dart';

/// API-backed adapter for market chart and historical data.
class ApiMarketChartRepository implements MarketChartRepository {
  ApiMarketChartRepository({required this.homeProvider});

  final HomeProvider homeProvider;

  @override
  Future<ApiResponse<PriceTableResponse>?> getHistoricalVolume(
    String tickerName,
    int orderBook,
  ) async {
    final response = await homeProvider.getHistoricalVolume(
      ApiUrl.getHistoricalVolumeData,
      tickerName,
      orderBook,
    );
    // printLog(
    //   'getHistoricalVolume response;:: ${ApiUrl.getHistoricalVolumeData}',
    // );
    // printLog('getHistoricalVolume    $tickerName response;:: ${orderBook}');
    printLog('getHistoricalVolume response;:: ${response.body}');
    try {
      if (response.statusCode == 200) {
        final result = PriceTableResponse.fromJson(response.body);
        printLog(
          'getHistoricalVolume response success resutl :: ${result.tickerName}',
        );
        return ApiResponse.success(result);
      }
      return ApiResponse.error('');
    } on Exception catch (error) {
      printLog('getHistoricalVolume error:: $error');
      return ApiResponse.error('error');
    }
  }

  @override
  Future<ApiResponse<List<IndexChartModel>>> getIndexChart(
    String name,
    String fromDate,
    String toDate,
  ) async {
    final response = await homeProvider.getIndexChart(
      ApiUrl.getIndexChart(name, fromDate, toDate),
    );
    try {
      if (response.statusCode == 200) {
        final result = indexChartModelFromJson(response.body);
        printLog('getIndexChart response success resutl :: $result');
        return ApiResponse.success(result);
      }
      return ApiResponse.error('');
    } on Exception catch (error) {
      printLog('getHistoricalVolume error:: $error');
      return ApiResponse.error('error');
    }
  }

  @override
  Future<ApiResponse<List<IndexChartModel2>>> fetchIndexChartData({
    required String fsym,
    required int resolution,
    required int fromTs,
    required int toTs,
  }) async {
    final response = await homeProvider.fetchIndexChartData(
      fsym: fsym,
      resolution: resolution,
      fromTs: fromTs,
      toTs: toTs,
    );
    printLog('getIndexChart response;$fromTs: $toTs: ${response.body.length}');
    try {
      if (response.statusCode == 200) {
        final result = indexChartModel2FromJson(response.body);
        printLog('getIndexChart response success resutl :: $result');
        return ApiResponse.success(result);
      }
      return ApiResponse.error('');
    } on Exception catch (error) {
      printLog('getHistoricalVolume error:: $error');
      return ApiResponse.error('error');
    }
  }
}
