import 'dart:async';
import 'dart:convert';
import 'package:app_benemoy/app/app_pkg.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/marquee_holder.dart';

import 'index_and_sector_service.dart';

class MarketDataService extends GetxService {
  static MarketDataService get to => Get.find();
  final WebSocketService _wsService = WebSocketService.instance;

  final Map<int, MarketModel> marketMap = {};
  List<MarketModel> marketList = [];
  List<MarketModel> marketListAll = [];
  List<MarketModel> marketFeedList = [];

  String currentSession = "";
  List<MarqueeHolder> marqueeList = [];
  bool isMarketLoading = true;
  bool _firstDataLoaded = false;

  final List<Map<String, dynamic>> _tickBuffer = [];
  Timer? _bufferTimer;
  final Set<String> _pendingUiUpdates = {};

  @override
  void onInit() {
    super.onInit();
    resumeTimer();
  }

  @override
  void onClose() {
    pauseTimer();
    super.onClose();
  }

  void pauseTimer() => _bufferTimer?.cancel();

  void resumeTimer() {
    _bufferTimer?.cancel();
    _bufferTimer = Timer.periodic(const Duration(milliseconds: 500), (_) => _flushBuffer());
  }

  void initMarketSocket() {
    _wsService.connect(socketId: AppConfig.marketSocketId, url: AppConfig.marketUrl, onMessage: _queueMarketMessage);
  }

  void _queueMarketMessage(String message) {
    try {
      final jsonResponse = jsonDecode(message);
      if (jsonResponse['message_type'] == 'itch_heartbeat') return;

      if (jsonResponse['cs'] != null) {
        currentSession = jsonResponse['cs'];
        _updateUI(['marketSession']);
        return;
      }

      if (jsonResponse['ob'] != null) {
        _tickBuffer.add(jsonResponse);

        // 🚀 Forward raw tick to IndexService for Chart Calculations
        if (Get.isRegistered<IndexAndSectorService>()) {
          Get.find<IndexAndSectorService>().processTick2(message);
          Get.find<IndexAndSectorService>().processShareTypeTick(message);
        }

        final incoming = MarketModel.fromJson(jsonResponse);
        _updateUI(['ITEM_${incoming.orderBook}']);
      }
    } catch (e) {
      debugPrint('Error parsing market message: $e');
    }
  }

  void _flushBuffer() {
    if (_tickBuffer.isEmpty) return;
    final ticks = List<Map<String, dynamic>>.from(_tickBuffer);
    _tickBuffer.clear();

    bool needListUpdate = false;
    for (var json in ticks) {
      final incoming = MarketModel.fromJson(json);
      if (incoming.orderBook == null) continue;

      marketMap.update(incoming.orderBook!, (existing) => existing.mergePartialUpdate(json), ifAbsent: () => incoming);
      _pendingUiUpdates.add('ITEM_${incoming.orderBook}');
      needListUpdate = true;
      _updateMarquee(incoming);
    }

    if (needListUpdate) {
      marketListAll = marketMap.values.toList();
      marketFeedList = List.from(marketListAll);

      if (!_firstDataLoaded && marketListAll.isNotEmpty) {
        _firstDataLoaded = true;
        isMarketLoading = false;
      }

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().applyFilters();
      }
    }
    _pendingUiUpdates.clear();
  }

  void _updateMarquee(MarketModel incoming) {
    if (incoming.group != "PUBLIC") return;
    final holder = MarqueeHolder(
      status: incoming.status,
      shortName: incoming.shortName,
      chg: incoming.chg,
      last: incoming.last,
      d: incoming.d,
    );
    final idx = marqueeList.indexWhere((m) => m.shortName == holder.shortName);
    if (idx >= 0)
      marqueeList[idx] = holder;
    else
      marqueeList.add(holder);
  }

  void _updateUI(List<String> ids) {
    if (Get.isRegistered<HomeController>()) {
      final homeCon = Get.find<HomeController>();
      if (homeCon.currentIndex == 0 || homeCon.currentIndex == 1 || homeCon.currentIndex == 2) {
        homeCon.update(ids);
      }
    }
  }
}
