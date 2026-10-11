import 'package:trading_core/trading_core.dart';

import '../../data/models/add_fav_item_request.dart';
import '../../data/models/fav_market_response.dart';
import '../../data/models/favourite_model.dart';

/// Broker-app contract for market watchlist operations.
///
/// Each broker app supplies its own endpoints and transport implementation.
abstract interface class MarketFavoritesRepository {
  Future<ApiResponse<String>?> createFavCategory(String name);

  Future<ApiResponse<String>?> updateFavTableName(int id, String name);

  Future<ApiResponse<String>?> deleteFavTable(int id);

  Future<ApiResponse<String>?> addMarketDataToFav(AddFavItemRequest request);

  Future<ApiResponse<List<FavMarketResponse>>?> favMarketData(int tableId);

  Future<ApiResponse<List<FavMarketResponse>>?> favoriteAllMarketData();

  Future<ApiResponse<dynamic>?> unfavoriteMarketData(int orderBookId);

  Future<ApiResponse<List<FavouriteModel>>?> getFavTables();
}
