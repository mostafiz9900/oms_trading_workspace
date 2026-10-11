import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:market/market.dart' show MarketStatisticsAggregator;

import '../../app_pkg.dart';

class IndexAndSectorService extends GetxService {
  static IndexAndSectorService get to => Get.find();
  final WebSocketService _wsService = WebSocketService.instance;

  List<IndexModel> indexList = [];
  IndexModel? newArr = IndexModel(sn: "DSEX");
  String selectedSn = 'DSEX';

  final MarketStatisticsAggregator _marketStatistics =
      MarketStatisticsAggregator();

  Map<String, Map<String, int>> get sectorSummary =>
      _marketStatistics.sectorSummary;
  List<Map<String, dynamic>> get chartData => _marketStatistics.chartData;
  Map<String, Map<String, int>> get sectorShareTypeSummary =>
      _marketStatistics.sectorShareTypeSummary;
  Map<String, String> get lastShareType => _marketStatistics.lastShareType;
  List<Map<String, dynamic>> get chartDataShareType =>
      _marketStatistics.chartDataShareType;

  void initIndexSocket() {
    _wsService.connect(
      socketId: AppConfig.indexSocketId,
      url: AppConfig.indexUrl,
      onMessage: _handleIndexMessage,
    );
  }

  void _handleIndexMessage(String message) {
    try {
      final jsonResponse = jsonDecode(message);
      if (jsonResponse['message_type'] == 'itch_heartbeat' ||
          jsonResponse['message_type'] == 'connection')
        return;

      if (jsonResponse['message_type'] == null) {
        var index = IndexModel.fromJson(jsonResponse);
        const baseIndices = ['DSEX', 'DSES', 'DS30', 'DSMEX'];

        if (baseIndices.contains(index.sn)) {
          final indexPos = baseIndices.indexOf(index.sn!);
          while (indexList.length <= indexPos)
            indexList.add(IndexModel.empty());
          indexList[indexPos] = index;
        } else {
          final existing = indexList.indexWhere((r) => r.sn == index.sn);
          if (existing != -1)
            indexList[existing] = index;
          else
            indexList.add(index);
        }

        if (newArr?.sn == index.sn) newArr = index;
        _updateUI(['indexList']);
      }
    } catch (e) {
      debugPrint('Error parsing index data: $e');
    }
  }

  // 🚀 Sector Gainer/Loser Chart Logic
  void processTick2(String message) {
    try {
      final tick = Map<String, dynamic>.from(jsonDecode(message) as Map);
      if (_marketStatistics.processGainerTick(tick)) {
        _updateUI(['marketListByGainer']);
      }
    } catch (e) {
      debugPrint('Error processTick2: $e');
    }
  }

  // 🚀 Sector ShareType (A, B, N, Z) Chart Logic
  void processShareTypeTick(String message) {
    try {
      final tick = Map<String, dynamic>.from(jsonDecode(message) as Map);
      if (_marketStatistics.processShareTypeTick(tick)) {
        _updateUI(['marketListByShareType']);
      }
    } catch (e) {
      debugPrint('Error processShareTypeTick: $e');
    }
  }

  void _updateUI(List<String> ids) {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().update(ids);
    }
  }
}
