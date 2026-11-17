import 'package:dio/dio.dart' as dio;

import '../models/market_identifier.dart';
import '../models/request/add_fav_item_request.dart' show AddFavItemRequest;

import '../../core/values/app_config.dart';
import '../../core/values/storage.dart';
import '../api/base_provider.dart';
import '../api/http_response.dart';
import '../services/storage_service.dart';
import '../models/request/withdraw_request.dart';

class HomeProvider extends BaseProvider {
  // Public market history endpoints intentionally bypass OMS auth headers.
  final dio.Dio _publicClient = dio.Dio(
    dio.BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      responseType: dio.ResponseType.json,
      validateStatus: (status) => status != null,
    ),
  );

  Future<Response> createFavCategory(String path, data) {
    var body = {"device_type": "mobile", "name": data};
    return post(path, body);
  }

  Future<Response> biometrictActive(
    String path,
    String? bioToken,
    bool isActive,
  ) {
    var body = {"key": bioToken, "is_active": isActive};
    return post(path, body);
  }

  Future<Response> updateFavTableName(String path, data) {
    var body = {"name": data};
    return patch(path, body);
  }

  Future<Response> deleteFavTable(String path) {
    return delete(path);
  }

  Future<Response> addMarketDataToFav(
    String path,
    AddFavItemRequest requestData,
  ) {
    return post(path, requestData.toJson());
  }

  Future<Response> favMarketData(String path) {
    return get(path);
  }

  Future<Response> favoriteAllMarketData(String path) {
    return get(path);
  }

  Future<Response> unfavoriteMarketData(String path) {
    return delete(path);
  }

  Future<Response> getFavTables(String path) {
    return get(path);
  }

  Future<Response> logout(String path) async {
    var refreshToken = await StorageService.read(StorageConstants.refreshToken);
    return post(path, {"refresh_token": refreshToken});
  }

  Future<Response> changePassword(
    String path, {
    required String oldPassword,
    required String newPassword,
  }) async {
    var body = {
      "old_password": oldPassword,
      "new_password": newPassword,
      "confirm_new_password": newPassword,
    };
    return put(path, body);
  }

  Future<Response> refreshTokenIfNeeded(String path, String accessToken) {
    return post(path, {"refresh": accessToken});
  }

  Future<Response> getHistoricalVolume(
    String path,
    String tickerName,
    MarketIdentifier orderBook,
  ) {
    return _sendPublic(
      () => _publicClient.post<dynamic>(
        path,
        data: {"ticker_name": tickerName, "order_book": orderBook},
      ),
    );
  }

  Future<Response> getIndexChart(String path) {
    return _sendPublic(() => _publicClient.get<dynamic>(path));
  }

  Future<Response> fetchIndexChartData({
    required String fsym,
    required int resolution,
    required int fromTs,
    required int toTs,
  }) {
    return _sendPublic(
      () => _publicClient.get<dynamic>(
        '${AppConfig.baseURLItch}api/get_index_chart_data',
        queryParameters: {
          'fsym': fsym,
          'resolution': resolution.toString(),
          'fromTs': fromTs.toString(),
          'toTs': toTs.toString(),
        },
      ),
    );
  }

  Future<Response> withdrawCreate(String path, WithdrawRequest requestData) {
    return post(path, requestData.toJson());
  }

  Future<Response> withdrawGet(String path) {
    return get(path);
  }

  @override
  void onClose() {
    _publicClient.close(force: true);
    super.onClose();
  }

  Future<Response> _sendPublic(
    Future<dio.Response<dynamic>> Function() request,
  ) async {
    try {
      return Response<dynamic>.fromDio(await request());
    } on dio.DioException catch (error) {
      return Response<dynamic>.fromDioException(error);
    }
  }
}
