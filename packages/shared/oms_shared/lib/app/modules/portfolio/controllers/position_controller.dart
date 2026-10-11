import 'dart:convert';
import '../../../core/utils/extensions/market_model_extensions.dart';
import '../../../core/values/app_config.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/response/market_model.dart';
import '../../../data/models/response/user_profile.dart';
import '../../../data/services/socket_db_service.dart';
import '../../../data/services/storage_service.dart';
import '../../home/controllers/home_controller.dart';
import 'package:oms_shared/app/data/models/response/position_response.dart';
import 'package:get/get.dart';

class PositionController extends GetxController {
  final homeCont = Get.find<HomeController>();
  final webSocketService = Get.find<WebSocketService>();
  final RxInt selectedViewMode = 1.obs;
  var positions = PositionResponse();
  var isLoading = false;
  var isInitialized = false;
  final String socketId = 'position_socket';

  String searchQuery = '';
  bool sortByProfit = false;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () {
      if (!isInitialized) {
        initializePosition();
      }
    });
  }

  void updateSearchQuery(String query) {
    searchQuery = query.toLowerCase();
    update();
  }

  void toggleSort() {
    sortByProfit = !sortByProfit;
    update();
  }

  List<PositionModel> get filteredPositions {
    if (positions.data == null) return [];
    List<PositionModel> list = positions.data!.where((item) {
      return item.securityCode?.toLowerCase().contains(searchQuery) ?? false;
    }).toList();

    if (sortByProfit) {
      list.sort((a, b) {
        var marketA = getMarketData(a.isin);
        var marketB = getMarketData(b.isin);
        var pnlA = calculationMarketValuePercentage(last: marketA.activePrice, reference: a.avgPrice);
        var pnlB = calculationMarketValuePercentage(last: marketB.activePrice, reference: b.avgPrice);
        return pnlB.compareTo(pnlA);
      });
    }
    return list;
  }

  // =======================================================
  // 🟢 CORE CALCULATIONS
  // =======================================================

  int getTotalQuantity(PositionModel item) {
    int matureQty = item.quantity ?? 0;
    int intradayBuy = item.intradayBuyQuantity ?? 0;
    return matureQty + intradayBuy;
  }

  double get totalInvestment {
    return positions.data?.fold(0.0, (sum, item) {
          int remQty = item.quantity ?? 0;
          double avgPrice = item.avgPrice ?? 0.0;
          int intBuyQty = item.intradayBuyQuantity ?? 0;
          double intBuyAvgPrice = item.intradayBuyPriceAvg ?? 0.0;

          double cost = (remQty * avgPrice) + (intBuyQty * intBuyAvgPrice);
          return sum! + cost;
        }) ??
        0.0;
  }

  double get currentPortfolioValue {
    return positions.data?.fold(0.0, (sum, item) {
          var marketData = getMarketData(item.isin);
          double closeOrSettle = marketData.activeLast;
          double marketValue = (item.quantity ?? 0).toDouble() * closeOrSettle;
          return sum! + marketValue;
        }) ??
        0.0;
  }

  double get totalUnrealizedPnL {
    return positions.data?.fold(0.0, (sum, item) {
          var marketData = getMarketData(item.isin);
          double closeOrSettle = marketData.activeLast;

          int remQty = item.quantity ?? 0;
          double avgPrice = item.avgPrice ?? 0.0;
          int intBuyQty = item.intradayBuyQuantity ?? 0;
          double intBuyAvgPrice = item.intradayBuyPriceAvg ?? 0.0;

          double unPnl = ((remQty + intBuyQty) * closeOrSettle) - ((remQty * avgPrice) + (intBuyQty * intBuyAvgPrice));
          return sum! + unPnl;
        }) ??
        0.0;
  }

  double get totalUnrealizedPnLPercentage {
    if (totalInvestment <= 0) return 0.0;
    return (totalUnrealizedPnL / totalInvestment) * 100;
  }

  double getItemUnrealizedPnL(PositionModel item) {
    var marketData = getMarketData(item.isin);
    double activeLast = (marketData.activePrice > 0) ? marketData.activePrice : (marketData.reference ?? 0.0);
    double marketValue = getTotalQuantity(item).toDouble() * activeLast;
    return marketValue - (item.totalCost ?? 0.0);
  }

  double getItemRealizedPnL(PositionModel item) {
    double sellQty = (item.intradaySellQuantity ?? 0).toDouble();
    double sellAvgPrice = item.intradaySellPriceAvg ?? 0.0;
    double buyAvgPrice = item.avgPrice ?? 0.0;

    if (sellQty > 0 && sellAvgPrice > 0 && buyAvgPrice > 0) {
      return sellQty * (sellAvgPrice - buyAvgPrice);
    }
    return 0.0;
  }

  // =======================================================
  // 🟢 WEBSOCKET & CORE LOGIC
  // =======================================================

  void initializePosition() async {
    try {
      if (!homeCont.isUserInfoLoaded) {
        homeCont.getUserInfo();
        await Future.delayed(const Duration(milliseconds: 500));
      }
      var boId = homeCont.userInfo.userDetail?.boId ?? await _getBoIdFromStorage();
      var token = await StorageService.read(StorageConstants.token);

      if (boId == null || token == null) {
        isLoading = false;
        isInitialized = false;
        update();
        return;
      }
      if (!webSocketService.isConnected(socketId)) {
        isLoading = true;
        isInitialized = true;
        update();
        connectWebSocket(boId, token);
      } else {
        isLoading = false;
        update();
      }
    } catch (e) {
      isLoading = false;
      isInitialized = false;
      update();
    }
  }

  Future<String?> _getBoIdFromStorage() async {
    try {
      var userInfoMap = StorageService.getMap(StorageConstants.userInfo);
      if (userInfoMap != null) {
        var userProfile = UserProfile.fromJson(userInfoMap);
        return userProfile.userDetail?.boId;
      }
    } catch (e) {}
    return null;
  }

  void connectWebSocket(String boId, String token) async {
    try {
      isLoading = true;
      update();
      final url = '${AppConfig.socketBaseUrl}position/$boId/?token=$token';
      webSocketService.connect(
        socketId: socketId,
        url: url,
        onMessage: handleSocketResponse,
        onConnected: _onSocketConnected,
        onDisconnected: _onSocketDisconnected,
        onError: _onSocketError,
      );
    } catch (e) {
      isLoading = false;
      update();
    }
  }

  void _onSocketConnected() {
    isLoading = false;
    update();
  }

  void _onSocketDisconnected() {
    isLoading = false;
    update();
  }

  void _onSocketError(dynamic error) {
    isLoading = false;
    update();
  }

  void handleSocketResponse(String event) {
    try {
      final jsonMap = json.decode(event);
      final messageType = jsonMap["message_type"];
      if (messageType == 'position') {
        positions = PositionResponse.fromMap(jsonMap);
        update();
      } else if (messageType == 'position_update') {
        _updatePositions(PositionResponse.fromMap(jsonMap));
      }
    } catch (e) {}
  }

  void _updatePositions(PositionResponse updateData) {
    if (updateData.data == null) return;
    List<PositionModel> updatedList = List.from(positions.data ?? []);
    for (var updatedItem in updateData.data!) {
      final index = updatedList.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        updatedList[index] = updatedItem;
      } else {
        updatedList.add(updatedItem);
      }
    }
    positions = positions.copyWith(data: updatedList);
    update();
  }

  MarketModel getMarketData(String? isin) {
    if (isin == null) return MarketModel();
    try {
      return homeCont.marketList.firstWhere(
        (market) => market.isinCode?.trim() == isin.trim() && market.group == 'PUBLIC',
        orElse: () => MarketModel(),
      );
    } catch (e) {
      return MarketModel();
    }
  }

  double calculationMarketValuePercentage({required double last, required double? reference}) {
    if (reference == null || reference == 0.0 || last <= 0.0) return 0.0;
    return ((last - reference) / reference) * 100;
  }

  void closeWebSocket() {
    webSocketService.disconnect(socketId);
    isInitialized = false;
  }

  @override
  void onClose() {
    closeWebSocket();
    super.onClose();
  }
}
