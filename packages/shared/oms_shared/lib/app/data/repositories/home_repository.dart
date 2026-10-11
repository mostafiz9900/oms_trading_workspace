import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/request/add_fav_item_request.dart' show AddFavItemRequest;
import '../models/response/fav_market_response.dart' show FavMarketResponse;
import '../models/response/index_chart_model.dart' show IndexChartModel;
import '../models/response/index_chart_model2.dart' show IndexChartModel2;
import 'market_chart_repository.dart' show MarketChartRepository;
import 'market_favorites_repository.dart' show MarketFavoritesRepository;
import '../models/response/historical_volume.dart' show PriceTableResponse;

import '../../core/utils/helpers/log_helper.dart';
import '../../core/values/api_url.dart';
import '../../core/values/constants.dart';
import '../api/api_response.dart';
import '../models/response/favourite_model.dart';
import '../providers/home_provider.dart';
import 'api_market_favorites_repository.dart';
import 'api_market_chart_repository.dart';
import '../models/request/withdraw_request.dart';
import '../models/response/withdraw_model.dart';

final homeProvider = Provider<HomeProvider>((ref) {
  return HomeProvider();
});
class HomeRepository
    implements MarketFavoritesRepository, MarketChartRepository {
  HomeRepository({required this.homeProvider})
    : _marketFavoritesRepository = ApiMarketFavoritesRepository(
        homeProvider: homeProvider,
      ),
      _marketChartRepository = ApiMarketChartRepository(
        homeProvider: homeProvider,
      );
  final HomeProvider homeProvider;
  final ApiMarketFavoritesRepository _marketFavoritesRepository;
  final ApiMarketChartRepository _marketChartRepository;

  @override
  Future<ApiResponse<String>?> createFavCategory(String data) async {
    return _marketFavoritesRepository.createFavCategory(data);
  }

  Future<ApiResponse<String>?> biometricActive(
    String? bioToken,
    bool isActive,
  ) async {
    var url = ApiUrl.biometricActiveDeactive;
    final res = await homeProvider.biometrictActive(url, bioToken, isActive);
    try {
      if (res.statusCode == 201) {
        var result = res.body;
        printLog('data processed :: ${result['name']}');
        return ApiResponse.success('Biometric successfully enabled');
      } else {
        printLog(
          'data processed error create fav table :: ${res.body[AppConstants.message]}',
        );
        return ApiResponse.error('${res.body[AppConstants.message]}');
      }
    } catch (error) {
      printLog("create Fav Category:: $error");
    }
    return ApiResponse.error('${res.body[AppConstants.message]}');
  }

  @override
  Future<ApiResponse<String>?> updateFavTableName(int id, String data) async {
    return _marketFavoritesRepository.updateFavTableName(id, data);
  }

  @override
  Future<ApiResponse<String>?> deleteFavTable(int id) async {
    return _marketFavoritesRepository.deleteFavTable(id);
  }

  @override
  Future<ApiResponse<String>?> addMarketDataToFav(
    AddFavItemRequest requestData,
  ) async {
    return _marketFavoritesRepository.addMarketDataToFav(requestData);
  }

  @override
  Future<ApiResponse<List<FavMarketResponse>>?> favMarketData(int id) async {
    return _marketFavoritesRepository.favMarketData(id);
  }

  @override
  Future<ApiResponse<List<FavMarketResponse>>?> favoriteAllMarketData() async {
    return _marketFavoritesRepository.favoriteAllMarketData();
  }

  @override
  Future<ApiResponse<dynamic>?> unfavoriteMarketData(int orderBookId) async {
    return _marketFavoritesRepository.unfavoriteMarketData(orderBookId);
  }

  @override
  Future<ApiResponse<List<FavouriteModel>>?> getFavTables() async {
    return _marketFavoritesRepository.getFavTables();
  }

  Future<ApiResponse<dynamic>?> refreshTokenIfNeeded(String accessToken) async {
    var url = ApiUrl.tokenRefresh;
    final res = await homeProvider.refreshTokenIfNeeded(url, accessToken);
    printLog('refreshTokenIfNeeded;:: ${res.body}');
    try {
      if (res.statusCode == 200) {
        var result = res.body;
        printLog('refreshTokenIfNeeded result :: ${res.body}');
        return ApiResponse.success(result);
      } else {
        return ApiResponse.error('${res.body['message']}');
      }
    } catch (error) {
      printLog("error refreshTokenIfNeeded:: $error");
      return ApiResponse.error('$error');
    }
  }

  Future<ApiResponse<dynamic>> logout() async {
    var url = ApiUrl.logoutUrl;
    final res = await homeProvider.logout(url);
    printLog('logout response;:: ${res.body}');
    try {
      if (res.statusCode == 200) {
        printLog('logout response success resutl :: ${res.body}');
        return ApiResponse.success(true);
      } else {
        return ApiResponse.error('');
      }
    } catch (error) {
      printLog("logout error:: $error");
    }
    return ApiResponse.error('errorMessage');
  }

  Future<ApiResponse<dynamic>> changePassword(
    String oldPassword,
    String password,
  ) async {
    var url = ApiUrl.changePasswordPutUrl;
    final res = await homeProvider.changePassword(
      url,
      oldPassword: oldPassword,
      newPassword: password,
    );
    printLog('change  response;:: ${res.body}');
    try {
      if (res.statusCode == 200) {
        printLog('change response success resutl :: ${res.body}');
        return ApiResponse.success("${res.body[AppConstants.message]}");
      } else {
        return ApiResponse.error("${res.body[AppConstants.message]}");
      }
    } catch (error) {
      printLog("change error:: $error");
    }
    return ApiResponse.error('errorMessage');
  }

  @override
  Future<ApiResponse<PriceTableResponse>?> getHistoricalVolume(
    String tickerName,
    int orderBook,
  ) async {
    return _marketChartRepository.getHistoricalVolume(tickerName, orderBook);
  }

  @override
  Future<ApiResponse<List<IndexChartModel>>> getIndexChart(
    String name,
    String fromDate,
    String toDate,
  ) async {
    return _marketChartRepository.getIndexChart(name, fromDate, toDate);
  }

  @override
  Future<ApiResponse<List<IndexChartModel2>>> fetchIndexChartData({
    required String fsym,
    required int resolution,
    required int fromTs,
    required int toTs,
  }) async {
    return _marketChartRepository.fetchIndexChartData(
      fsym: fsym,
      resolution: resolution,
      fromTs: fromTs,
      toTs: toTs,
    );
  }

  // ========================================================
  // ========================================================

  Future<ApiResponse<String>> createWithdraw(
    WithdrawRequest requestData,
  ) async {
    var url = ApiUrl.withdrawCreateUrl;
    final res = await homeProvider.withdrawCreate(url, requestData);

    try {
      if (res.statusCode == 200 || res.statusCode == 201) {
        var result = res.body;
        printLog('createWithdraw success :: $result');

        // 🚀 সার্ভার থেকে আসা সাকসেস মেসেজটি রিটার্ন করা হলো
        String successMsg =
            result[AppConstants.message] ??
            'Withdraw request submitted successfully';
        return ApiResponse.success(successMsg);
      } else {
        var errorMsg =
            res.body['message'] ?? 'Failed to submit withdraw request';
        printLog('createWithdraw error :: $errorMsg');
        return ApiResponse.error(errorMsg);
      }
    } catch (error) {
      printLog("createWithdraw exception :: $error");
      return ApiResponse.error(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<ApiResponse<List<WithdrawModel>>> getWithdrawList(
    String investorCode,
  ) async {
    var url = ApiUrl.withdrawGetUrl(investorCode);
    final res = await homeProvider.withdrawGet(url);

    try {
      if (res.statusCode == 200) {
        // 🚀 ১. GetConnect অটোমেটিক JSON কে Map এ কনভার্ট করে ফেলে
        var responseData = res.body['data'];
        printLog('getWithdrawList data :: $responseData');

        List<WithdrawModel> withdrawList = [];

        if (responseData != null && responseData is List) {
          // 🚀 ৩. যেহেতু এটি অলরেডি একটি List, তাই স্ট্রিং পার্সার (withdrawModelFromJson) এর বদলে সরাসরি ম্যাপ করা হলো
          withdrawList = List<WithdrawModel>.from(
            responseData.map((x) => WithdrawModel.fromJson(x)),
          );
        }

        return ApiResponse.success(withdrawList);
      } else {
        var errorMsg = res.body['message'] ?? 'Failed to fetch withdraw list';
        printLog('getWithdrawList error :: $errorMsg');
        return ApiResponse.error(errorMsg);
      }
    } catch (error) {
      printLog("getWithdrawList exception :: $error");
      return ApiResponse.error(
        'An unexpected error occurred. Please try again.',
      );
    }
  }
}
