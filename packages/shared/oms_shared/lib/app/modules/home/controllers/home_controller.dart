import 'dart:async';
import 'dart:convert';

import '../../../data/models/response/order_alert_model.dart';
import '/app/modules/quote/controllers/historical_volume_controller.dart';

import '/app/modules/portfolio/controllers/position_controller.dart';

import 'package:broker_config/broker_config.dart' show StockExchange;
import 'package:flutter/material.dart' hide Actions;
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../data/models/request/add_fav_item_request.dart' show AddFavItemRequest;
import '../../../data/models/response/fav_market_response.dart' show FavMarketResponse;
import '../../../data/models/response/market_depth_model.dart' show MarketDepthData, MarketDepthModel;
import '../../../data/services/market_statistics_aggregator.dart' show MarketStatisticsAggregator;
import '../../../data/repositories/market_favorites_repository.dart' show MarketFavoritesRepository;
import '../../../data/services/market_sector_filter_store.dart' show MarketSectorFilterStore;
import '../../../data/services/market_sector_summary_aggregator.dart' show MarketSectorSummaryAggregator;
import '../../../data/services/market_snapshot_analytics.dart' show MarketSnapshotAnalytics;
import '../../../data/models/response/sector_data_model.dart' show SectorDataModel;
import '../../../data/models/response/market_tick_message.dart' show MarketTickKind, MarketTickMessage;
import '../../../data/services/market_tick_store.dart' show MarketTickStore;
import 'package:syncfusion_flutter_charts/charts.dart';

import '/app/data/models/request/update_order_holder.dart';
import '../../../core/utils/extensions/market_model_extensions.dart';
import '../../../core/utils/functions/network_util.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/utils/helpers/hex_color.dart';
import '../../../core/utils/helpers/log_helper.dart';
import '../../../core/utils/helpers/update_throttle.dart';
import '../../../core/values/app_config.dart';
import '../../../data/services/exchange_service.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/constants.dart';
import '../../../core/values/space.dart';
import '../../../core/values/storage.dart';
import '../../../data/enums/app_enum.dart';
import '../../../data/models/request/order_confirm_request.dart';
import '../../../data/models/response/favourite_model.dart';
import '../../../data/models/response/index_model.dart';
import '../../../data/models/response/market_model.dart';
import '../../../data/models/response/news_model.dart';
import '../../../data/models/response/time_sales_model.dart';
import '../../../data/models/response/user_order.dart';
import '../../../data/models/response/user_profile.dart';
import '../../../data/repositories/home_repository.dart';
import '../../../data/services/socket_db_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../global_provider.dart';
import '../../global_search/controllers/global_search_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/marquee_holder.dart';

import '../../../data/models/response/companies_model.dart';
import '../../../data/models/response/dividend_model.dart';
import '../../../data/models/response/eps_model.dart';
import '../../../data/models/response/order_status_details_model.dart';
import '../../../data/models/response/user_balance.dart';
import '../../../data/services/market_socket_service.dart';
import '../../auth/controllers/biometric_controller.dart';
import '../../auth/controllers/token_controller.dart';
import '../../orders/views/order_status_details_view.dart';
import '../../market/controllers/companies_controller.dart';
import '../../market/controllers/market_index_controller.dart';
import '../../watchlist/controllers/watchlist_controller.dart';

part 'home/home_state.dart';
part 'home/socket_mixin.dart';
part 'home/market_feed_mixin.dart';
part 'home/index_mixin.dart';
part 'home/time_sales_mixin.dart';
part 'home/market_depth_mixin.dart';
part 'home/watch_list_mixin.dart';
part 'home/fav_market_mixin.dart';
part 'home/trade_mixin.dart';
part 'home/order_list_mixin.dart';
part 'home/portfolio_mixin.dart';
part 'home/quote_mixin.dart';
part 'home/navigation_mixin.dart';
part 'home/account_mixin.dart';

final userInfoProvider = Provider<UserProfile>((ref) {
  printLog('user profile:: ');
  var res = StorageService.getMap(StorageConstants.userInfo);
  // Guest mode / after logout there is no stored profile; `res!` threw.
  UserProfile? user = res == null ? UserProfile() : UserProfile.fromJson(res);
  printLog(user.toJson());
  printLog('user profile:: ');
  return user;
});

final watchListOnProvider = NotifierProvider<WatchListOnNotifier, bool>(
  () => WatchListOnNotifier(),
);

class WatchListOnNotifier extends Notifier<bool> {
  @override
  bool build() {
    return true;
  }

  void changeValue(bool value) => state = value;
}

/// Home screen controller. State is in [HomeState]; each mixin holds the logic
/// for one view (see `home/`). This class only wires the lifecycle.
class HomeController extends HomeState
    with
        HomeSocketMixin,
        MarketFeedMixin,
        MarketIndexMixin,
        TimeSalesMixin,
        MarketDepthMixin,
        WatchListMixin,
        FavMarketMixin,
        TradeMixin,
        OrderListMixin,
        PortfolioMixin,
        QuoteMixin,
        HomeNavigationMixin,
        AccountMixin {
  HomeController({required super.homeRepository});

  @override
  void onInit() async {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    // DSE/CSE switch: reload the market feed of the chosen exchange.
    if (Get.isRegistered<ExchangeService>()) {
      _exchangeWorker = ever(
        Get.find<ExchangeService>().selected,
        (_) => reloadMarketForExchange(),
      );
    }
    printLog('home repository :: ${homeRepository.hashCode}');
    if (Get.arguments != null) {
      currentIndex = Get.arguments;
      update();
    }
    printLog('home controller initialized:: on init');
    _firstDataLoaded = false;
    initConnect();
    // যেকোনো ফিল্ডে চেঞ্জ আসলে ক্যালকুলেশন ট্রিগার হবে
    disclosedQtyTextEditField = TextEditingController();
    qtyTextEditField = TextEditingController();
    minQtyTextEditField = TextEditingController();
    tradPriceTextEditField = TextEditingController();
    tradePriceFocusNode = FocusNode();
    update();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    reloadHome();
    qtyTextEditField.addListener(calculateTotal);
    tradPriceTextEditField.addListener(calculateTotal);
    final container = ProviderContainer();
    var value = container.read(orderTypeProvider);
    selectOrderType = value.first;
    var types = container.read(typeProvider);
    selectType = types.first;
    var validity = container.read(validityProvider);
    selectValidity = validity.first;
    container.dispose();
    marketIndexController.loadData('${newArr?.sn}');
    update();
    update(['total_amount_update']);
    printLog("on ready home controller");
  }

  @override
  void onClose() {
    _exchangeWorker?.dispose();
    _marketUpdateTimer?.cancel();
    _indexUpdateTimer?.cancel();
    _orderResponseTimer?.cancel();
    _timeSalesThrottle.cancel();
    disconnect();
    Future.delayed(const Duration(milliseconds: 100), () {
      _disconnectAll();
      searchController.removeListener(_onSearchChanged);
      searchController.dispose();
      disclosedQtyTextEditField.dispose();
      qtyTextEditField.dispose(); // শুধুমাত্র একবার কল হবে ✅
      minQtyTextEditField.dispose();
      tradPriceTextEditField.dispose();
      tradePriceFocusNode.dispose();
      scrollController.dispose();
      searchTextEditCont.dispose();
      watchlistTextEditField.dispose();
    });

    super.onClose();
  }

  // Toggle sorting order

  @override
  void onResumed() {
    printLog("▶️ App resumed (GetX Lifecycle) → Reconnecting Sockets");
    initConnect();
    reloadHome();
  }

  @override
  void onPaused() {
    printLog(
      "⏸️ App paused (GetX Lifecycle) → Closing Sockets to save battery",
    );
    disconnect();
  }

  @override
  void onDetached() {
    printLog('⏹️ App detached ::::');
    disconnect();
  }

  @override
  void onHidden() {
    printLog('👁️‍🗨️ App hidden ::::');
  }

  @override
  void onInactive() {
    printLog('💤 App Inactive ::::');
  }

}
