import 'package:market/market.dart'
    show
        IndexChartModel,
        IndexChartModel2,
        MarketChartRepository,
        PriceTableResponse,
        indexChartModel2FromJson,
        indexChartModelFromJson;

import '../../app_pkg.dart';

/// Benemoy's API-backed adapter for market chart and historical data.
class BenemoyMarketChartRepository implements MarketChartRepository {
  BenemoyMarketChartRepository({required this.homeProvider});

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
