import 'package:get/get.dart';
import 'package:market/market.dart' show AddFavItemRequest;

import '../../app_pkg.dart';
import '../models/request/withdraw_request.dart';

class HomeProvider extends BaseProvider {
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
    var isToken = await StorageService.read(StorageConstants.token);
    var refreshToken = await StorageService.read(StorageConstants.refreshToken);
    return post(path, {"refresh_token": refreshToken});
  }

  Future<Response> changePassword(
    String path, {
    required String oldPassword,
    required String newPassword,
  }) async {
    var isToken = await StorageService.read(StorageConstants.token);
    var refreshToken = await StorageService.read(StorageConstants.refreshToken);
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
    return GetConnect().post(path, {
      "ticker_name": tickerName,
      "order_book": orderBook,
    });
  }

  Future<Response> getIndexChart(String path) {
    return GetConnect().get(path);
  }

  Future<Response> fetchIndexChartData({
    required String fsym,
    required int resolution,
    required int fromTs,
    required int toTs,
  }) {
    return GetConnect().get(
      'https://uat-itchservice.skytrade.us/api/get_index_chart_data',
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
