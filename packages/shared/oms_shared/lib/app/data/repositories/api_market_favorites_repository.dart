import '../models/request/add_fav_item_request.dart' show AddFavItemRequest;
import '../models/response/fav_market_response.dart' show FavMarketResponse, favMarketResponseFromMap;
import 'market_favorites_repository.dart' show MarketFavoritesRepository;

import '../../core/utils/helpers/log_helper.dart';
import '../../core/values/api_url.dart';
import '../../core/values/constants.dart';
import '../api/api_response.dart';
import '../models/response/favourite_model.dart';
import '../providers/home_provider.dart';

/// API-backed adapter for the shared market watchlist contract.
class ApiMarketFavoritesRepository implements MarketFavoritesRepository {
  ApiMarketFavoritesRepository({required this.homeProvider});

  final HomeProvider homeProvider;

  @override
  Future<ApiResponse<String>?> createFavCategory(String name) async {
    final response = await homeProvider.createFavCategory(
      ApiUrl.createFavoriteTable,
      name,
    );
    try {
      if (response.statusCode == 200) {
        final result = response.body;
        printLog('data processed :: ${result['name']}');
        return ApiResponse.success('${result['name']}');
      }
      printLog(
        'data processed error create fav table :: ${response.body[AppConstants.message]}',
      );
      return ApiResponse.error('${response.body[AppConstants.message]}');
    } catch (error) {
      printLog('create Fav Category:: $error');
      return ApiResponse.error('${response.body[AppConstants.message]}');
    }
  }

  @override
  Future<ApiResponse<String>?> updateFavTableName(int id, String name) async {
    final response = await homeProvider.updateFavTableName(
      ApiUrl.updateFavTableName(id),
      name,
    );
    try {
      if (response.statusCode == 200) {
        final result = response.body;
        printLog('data processed :: ${result['name']}');
        return ApiResponse.success('${result[AppConstants.message]}');
      }
      printLog(
        'data processed error create fav table :: ${response.body[AppConstants.message]}',
      );
      return ApiResponse.error('${response.body[AppConstants.message]}');
    } catch (error) {
      printLog('create Fav Category:: $error');
      return ApiResponse.error('${response.body[AppConstants.message]}');
    }
  }

  @override
  Future<ApiResponse<String>?> deleteFavTable(int id) async {
    final response = await homeProvider.deleteFavTable(
      ApiUrl.deleteFavTable(id),
    );
    try {
      if (response.statusCode == 200) {
        final result = response.body;
        printLog('data processed :: ${result[AppConstants.message]}');
        return ApiResponse.success('${result[AppConstants.message]}');
      }
      printLog(
        'data processed error create fav table :: ${response.body[AppConstants.message]}',
      );
      return ApiResponse.error('${response.body[AppConstants.message]}');
    } catch (error) {
      printLog('create Fav Category:: $error');
      return ApiResponse.error('${response.body[AppConstants.message]}');
    }
  }

  @override
  Future<ApiResponse<String>?> addMarketDataToFav(
    AddFavItemRequest request,
  ) async {
    final response = await homeProvider.addMarketDataToFav(
      ApiUrl.addMarketDataToFav,
      request,
    );
    try {
      if (response.statusCode == 201) {
        final result = response.body;
        printLog('result add market data :: $result');
        final resultModel = FavMarketResponse.fromMap(result);
        printLog('resultModel :: ${resultModel.toMap()}');
        return ApiResponse.success('${result[AppConstants.message]}');
      }
      return ApiResponse.error('${response.body['message']}');
    } catch (error) {
      printLog('create Fav Category:: $error');
      return ApiResponse.error('errorMessage');
    }
  }

  @override
  Future<ApiResponse<List<FavMarketResponse>>?> favMarketData(
    int tableId,
  ) async {
    final response = await homeProvider.favMarketData(
      ApiUrl.favoriteMarketData(id: tableId),
    );
    try {
      if (response.statusCode == 200) {
        final result = response.body;
        printLog('get fav :: $result');
        return ApiResponse.success(
          favMarketResponseFromMap(result[AppConstants.data]),
        );
      }
      return ApiResponse.error('${response.body['message']}');
    } catch (error) {
      printLog('create Fav makret list:: $error');
      return ApiResponse.error('');
    }
  }

  @override
  Future<ApiResponse<List<FavMarketResponse>>?> favoriteAllMarketData() async {
    final response = await homeProvider.favoriteAllMarketData(
      ApiUrl.favoriteAllMarketData,
    );
    try {
      if (response.statusCode == 200) {
        final result = response.body;
        printLog('favoriteAllMarketData:: $result');
        return ApiResponse.success(
          favMarketResponseFromMap(result[AppConstants.data]),
        );
      }
      return ApiResponse.error('${response.body['message']}');
    } catch (error) {
      printLog('favoriteAllMarketData list:: $error');
      return ApiResponse.error('');
    }
  }

  @override
  Future<ApiResponse<dynamic>?> unfavoriteMarketData(int orderBookId) async {
    final response = await homeProvider.unfavoriteMarketData(
      ApiUrl.unfavoriteMarketData(orderBookId),
    );
    try {
      if (response.statusCode == 200) {
        final result = response.body;
        printLog('unfavoriteMarketData fav :: $result');
        return ApiResponse.success(result[AppConstants.message]);
      }
      return ApiResponse.error('${response.body['message']}');
    } catch (error) {
      printLog('create Fav makret list:: $error');
      return ApiResponse.error('');
    }
  }

  @override
  Future<ApiResponse<List<FavouriteModel>>?> getFavTables() async {
    final response = await homeProvider.getFavTables(
      ApiUrl.getFavoriteTablesUrl,
    );
    printLog('res get fav cat list;:: ${response.body}');
    try {
      if (response.statusCode == 200) {
        final categories = favouriteModelFromJson(response.body['data']);
        printLog('getFavoriteCategoryName :: $categories');
        return ApiResponse.success(categories);
      }
      return ApiResponse.error('');
    } catch (error) {
      printLog('get Fav Category:: $error');
      return ApiResponse.error('errorMessage');
    }
  }
}
