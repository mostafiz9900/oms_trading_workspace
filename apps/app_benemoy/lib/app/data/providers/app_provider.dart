import 'dart:convert';

import 'package:get/get_connect/http/src/response/response.dart';

import '../../app_pkg.dart';

class AppProvider extends BaseProvider {
  Future<Response> createFavCategory(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> getFavCategoryName(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> addMarketDataToFavorite(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> getFavoriteMarketData(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> deleteFavoriteCategoryName(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> updateFavoriteCategoryName(String path, data) {
    return post(path, jsonEncode(data));
  }
}
