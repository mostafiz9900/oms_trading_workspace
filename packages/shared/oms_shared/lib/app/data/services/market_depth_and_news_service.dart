import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:market/market.dart' show MarketDepthData, MarketDepthModel;

import '../../app_pkg.dart';

class MarketDepthAndNewsService extends GetxService {
  static MarketDepthAndNewsService get to => Get.find();
  final WebSocketService _wsService = WebSocketService.instance;

  List<MarketDepthModel> buys = [];
  List<MarketDepthModel> sells = [];
  List<TimeAndSalesModel> timeAndSales = [];
  List<TimeAndSalesModel> timeAndSalesHistory = [];
  List<NewsModel> news = [];
  List<NewsModel> newsSingleItem = [];

  void initMarketDepthSocket() {
    _wsService.connect(
      socketId: AppConfig.marketDepthSocketId,
      url: AppConfig.marketDepthUrl,
      onMessage: _handleMarketDepthMessage,
    );
    _wsService.connect(
      socketId: AppConfig.newsTimeSalesSocketId,
      url: AppConfig.newsAndTimeAndSalesUrl,
      onMessage: _handleNewsTimeSalesMessage,
    );
  }

  void subscribeMarketDepth(int orderbookId) {
    final payload = {"type": AppConstants.subscribe, "ob": orderbookId};
    _wsService.sendMessage(AppConfig.marketDepthSocketId, jsonEncode(payload));
  }

  void subscribeTimeAndSales(String tp, String tid, String ob) {
    final payload = {
      "ac": "subscribe",
      "tp": tp,
      "tid": int.parse(tid),
      "ob": int.parse(ob),
    };
    _wsService.sendMessage(
      AppConfig.newsTimeSalesSocketId,
      jsonEncode(payload),
    );
  }

  void _handleMarketDepthMessage(String message) {
    try {
      final jsonResponse = jsonDecode(message);
      if (jsonResponse['type'] == 'heartbeat' ||
          jsonResponse.containsKey('message'))
        return;

      (jsonResponse as Map<String, dynamic>).forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final depth = MarketDepthData.fromJson(value);
          buys = depth.buy;
          sells = depth.sell;
        }
      });
      _updateUI(["market_depth"]);
    } catch (e) {
      debugPrint('Error market depth: $e');
    }
  }

  void _handleNewsTimeSalesMessage(String message) {
    try {
      final jsonResponse = jsonDecode(message);
      final messageType = jsonResponse['tp'];
      final data = jsonResponse['d'];

      if (messageType == 'tsm') {
        if (data is List) {
          timeAndSales.clear();
          timeAndSales.addAll(timeAndSalesModelFromMap(data));
        } else if (data is Map<String, dynamic>) {
          timeAndSales.insert(0, TimeAndSalesModel.fromMap(data));
        }
        _updateUI(['timeAndSales']);
      } else if (messageType == 'tsb') {
        if (data is List) {
          timeAndSalesHistory.clear();
          timeAndSalesHistory.addAll(
            data.map((e) => TimeAndSalesModel.fromMap(e)).toList(),
          );
        } else if (data is Map<String, dynamic>) {
          timeAndSalesHistory.insert(0, TimeAndSalesModel.fromMap(data));
        } else {
          timeAndSalesHistory.clear();
        }
        _updateUI(['timeAndSalesHistory']);
      } else if (messageType == 'news') {
        if (data is List) {
          news.clear();
          news.addAll(newsModelFromMap(data));
        } else if (data is Map<String, dynamic>) {
          news.insert(0, NewsModel.fromMap(data));
        } else {
          news.clear();
        }
        _updateUI(['news']);
      } else if (messageType == 'news_hist') {
        if (data is List) {
          newsSingleItem.clear();
          newsSingleItem.addAll(newsModelFromMap(data));
        } else if (data is Map<String, dynamic>) {
          newsSingleItem.insert(0, NewsModel.fromMap(data));
        } else {
          newsSingleItem.clear();
        }
        _updateUI(['newsSingleItem']);
      }
    } catch (e) {
      debugPrint('Error Time & Sales data: $e');
    }
  }

  void _updateUI(List<String> ids) {
    if (Get.isRegistered<HomeController>())
      Get.find<HomeController>().update(ids);
  }
}
