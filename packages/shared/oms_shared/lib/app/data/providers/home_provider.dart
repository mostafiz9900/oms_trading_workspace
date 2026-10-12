import 'package:get/get.dart';
import '../models/request/add_fav_item_request.dart' show AddFavItemRequest;

import '../../core/values/app_config.dart';
import '../../core/values/storage.dart';
import '../api/base_provider.dart';
import '../services/storage_service.dart';
import '../models/request/withdraw_request.dart';

class HomeProvider extends BaseProvider {
  // Plain client (no base URL or interceptors), reused across calls.
  final GetConnect _plainClient = GetConnect();

  Future<Response> createFavCategory(String path, data) {
    var body = {"device_type": "mobile", "name": data};
    return post(path, body);
  }

  Future<Response> biometrictActive(
    String path,
    String? bioToken,
    bool isActive,
  ) {
    var body = {
      "key": bioToken,
      "is_active": isActive,
    };
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
    int orderBook,
  ) {
    return _plainClient.post(path, {
      "ticker_name": tickerName,
      "order_book": orderBook,
    });
  }

  Future<Response> getIndexChart(String path) {
    return _plainClient.get(path);
  }

  Future<Response> fetchIndexChartData({
    required String fsym,
    required int resolution,
    required int fromTs,
    required int toTs,
  }) {
    return _plainClient.get(
      '${AppConfig.baseURLItch}api/get_index_chart_data',
      query: {
        'fsym': fsym,
        'resolution': resolution.toString(),
        'fromTs': fromTs.toString(),
        'toTs': toTs.toString(),
      },
    );
  }

  Future<Response> withdrawCreate(String path, WithdrawRequest requestData) {
    return post(path, requestData.toJson());
  }

  Future<Response> withdrawGet(String path) {
    return get(path);
  }
}
