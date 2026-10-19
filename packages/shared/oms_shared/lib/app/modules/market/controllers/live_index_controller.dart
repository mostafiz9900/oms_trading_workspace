import '../../../data/models/response/index_candle_model.dart'
    show IndexCandleModel, indexCandleModelFromJson;

import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';

import '../../../core/utils/helpers/log_helper.dart';
import '../../../core/utils/helpers/update_throttle.dart';
import '../../../core/values/app_config.dart';
import '../../../data/models/response/index_model.dart';
import '../../../data/services/exchange_service.dart';
import '../../../data/services/socket_db_service.dart';

class LiveIndexController extends GetxController {
  final WebSocketService _webSocketService = WebSocketService.instance;
  final _connection = GetConnect();

  // ================= State Variables =================
  List<IndexModel> indexList = <IndexModel>[];
  List<IndexCandleModel> indexCandleList = <IndexCandleModel>[];
  String selectedSn = 'DSEX';
  String selectedChartParam = "1D";
  IndexModel? newArr = IndexModel(sn: "DSEX");

  DateTime? lastIndexUpdateTime;
  DateTime _lastIndexUIUpdateTime = DateTime.now();
  Timer? _indexUpdateTimer;
  final _chartThrottle = UpdateThrottle();

  // Exact param list from UI
  final List<String> chartParamList = ["1D", "1W", "1M", "1Y"];

  bool isChartLoading = false;

  // ================= Getters =================
  List<IndexModel> get visibleIndexList {
    return indexList
        .where(
          (m) =>
              m.sn != null &&
              m.sn != 'DSE SME Index' &&
              m.sn != 'CDSET' &&
              m.sn!.isNotEmpty,
        )
        .toList();
  }

  IndexModel? get selectedIndexData {
    try {
      return indexList.firstWhere((element) => element.sn == selectedSn);
    } catch (e) {
      return null;
    }
  }

  List<String> get availableSns {
    return indexList
        .map((e) => e.sn)
        .where((sn) => sn != null && sn.isNotEmpty)
        .cast<String>()
        .toList();
  }

  int get up => newArr?.u ?? 0;
  int get down => newArr?.d ?? 0;
  int get unchanged => newArr?.uc ?? 0;

  // ================= API Endpoint Logic (FIXED) =================
  static String getCandleEndpoint(
    String symbol,
    String param, {
    int? fromTime,
    int? toTime,
  }) {
    String resolution;
    DateTime now = DateTime.now();
    DateTime dynamicFromDate;

    switch (param) {
      case "1D":
        resolution = "1";
        dynamicFromDate = DateTime(now.year, now.month, now.day);
        break;
      case "1W":
        resolution = "1";
        dynamicFromDate = now.subtract(const Duration(days: 7));
        break;
      case "1M":
        resolution = "1D";
        dynamicFromDate = DateTime(
          now.year,
          now.month - 1,
          now.day,
          now.hour,
          now.minute,
        );
        break;
      case "1Y":
        resolution = "1D";
        dynamicFromDate = DateTime(
          now.year - 1,
          now.month,
          now.day,
          now.hour,
          now.minute,
        );
        break;
      default:
        resolution = "1";
        dynamicFromDate = DateTime(now.year, now.month, now.day);
        break;
    }

    int to = toTime ?? (now.millisecondsSinceEpoch ~/ 1000);
    int from = fromTime ?? (dynamicFromDate.millisecondsSinceEpoch ~/ 1000);

    return "${AppConfig.baseURLItch}api/candles?symbol=$symbol&resolution=$resolution&from=$from&to=$to";
  }

  // ================= Lifecycle Methods =================
  @override
  void onInit() {
    super.onInit();
    _initializeIndexWebSocket();
    fetchIndexCandleData(selectedSn, selectedChartParam);
    // DSE/CSE switch: reload the indices of the chosen exchange.
    if (Get.isRegistered<ExchangeService>()) {
      _exchangeWorker = ever(
        Get.find<ExchangeService>().selected,
        (_) => reloadIndexForExchange(),
      );
    }
  }

  Worker? _exchangeWorker;

  /// Drops the old exchange's index values and connects to the new feed.
  void reloadIndexForExchange() {
    indexList.clear();
    newArr = IndexModel(sn: selectedSn);
    update();
    _initializeIndexWebSocket();
    fetchIndexCandleData(selectedSn, selectedChartParam);
  }

  @override
  void onClose() {
    _exchangeWorker?.dispose();
    _indexUpdateTimer?.cancel();
    _chartThrottle.cancel();
    _webSocketService.disconnect(AppConfig.indexSocketId);
    super.onClose();
  }

  // ================= API Fetch Data =================
  Future<void> fetchIndexCandleData(String symbol, String param) async {
    isChartLoading = true;
    update(['index_chart']);
    await Future.delayed(const Duration(milliseconds: 10));

    try {
      final String url = getCandleEndpoint(symbol, param);
      // printLog('Fetching Index Chart Data: $url');

      final response = await _connection.get(url);
      printLog(response.body);
      if (response.isOk) {
        final data = response.body;
        List<IndexCandleModel> tempList = [];

        if (data != null && data is List) {
          tempList = indexCandleModelFromJson(data);
        } else if (data != null && data is String) {
          List<dynamic> parsedData = jsonDecode(data);
          tempList = indexCandleModelFromJson(parsedData);
        }

        if (tempList.isNotEmpty) {
          tempList.sort(
            (a, b) => (a.timestamp ?? 0).compareTo(b.timestamp ?? 0),
          );

          indexCandleList.clear();
          indexCandleList.addAll(tempList);
        }
      }
    } catch (e) {
      printLog('❌ Exception: $e');
    } finally {
      isChartLoading = false;
      update(['index_chart']);
    }
  }

  // ================= User Actions =================
  void selectSn(String sn) {
    selectedSn = sn;
    newArr = selectedIndexData ?? IndexModel(sn: sn);
    indexCandleList.clear();
    update(['index_list', 'index_chart']);
    fetchIndexCandleData(selectedSn, selectedChartParam);
  }

  void changeChartParam(String param) {
    if (selectedChartParam == param) return;
    selectedChartParam = param;
    indexCandleList.clear();
    update(['index_chart']);
    fetchIndexCandleData(selectedSn, selectedChartParam);
  }

  void getSumOfAllIndex(IndexModel? newIndexData) {
    if (newIndexData == null || newIndexData.sn == null) return;

    newArr = newIndexData;
    if (selectedSn != newIndexData.sn) {
      selectedSn = newIndexData.sn!;
      newArr = selectedIndexData ?? newIndexData;
      fetchIndexCandleData(selectedSn, selectedChartParam);
    }
    update(['index_list', 'index_chart']);
  }

  // ================= Live Line Chart Sync Logic (ONLY FOR 1D) =================
  void _updateLiveChartData(double currentPrice, IndexModel indexData) {
    final now = DateTime.now();
    final currentMinuteTimestamp = (now.millisecondsSinceEpoch ~/ 60000) * 60;

    if (indexCandleList.isEmpty) {
      indexCandleList.add(
        IndexCandleModel(
          close: currentPrice,
          open: currentPrice,
          high: currentPrice,
          low: currentPrice,
          volume: 0,
          timestamp: currentMinuteTimestamp,
        ),
      );
      update(['index_chart']);
      return;
    }

    final lastDataPoint = indexCandleList.last;
    final lastDataTimestamp =
        lastDataPoint.timestamp ?? (now.millisecondsSinceEpoch ~/ 1000);

    // 🚀 Update running minute candle if it's the same minute
    if (lastDataTimestamp >= currentMinuteTimestamp) {
      indexCandleList[indexCandleList.length - 1] = lastDataPoint.copyWith(
        close: currentPrice,
      );
    } else {
      // 🚀 Always enforce exactly 60s increment to maintain sequential chart
      final nextTimestamp = lastDataTimestamp + 60;

      indexCandleList.add(
        IndexCandleModel(
          close: currentPrice,
          open: lastDataPoint.close ?? currentPrice,
          high: currentPrice,
          low: currentPrice,
          volume: 0,
          timestamp: nextTimestamp,
        ),
      );
    }
    // Live ticks for the selected index arrive many times a second; redraw
    // the chart at most every 500 ms, like the index list.
    _chartThrottle.run(() {
      if (!isClosed) update(['index_chart']);
    });
  }

  // ================= Socket Connection & Handler =================
  void _initializeIndexWebSocket() {
    final url = AppConfig.indexUrlFor(ExchangeService.current);
    if (url.isEmpty || url == 'null') return;

    _webSocketService.connect(
      socketId: AppConfig.indexSocketId,
      url: url,
      onMessage: _handleIndexMessage,
      onConnected: () => printLog('✅ Index Socket Connected'),
      onDisconnected: () => printLog('📡 Index Socket Disconnected'),
      onError: (error) => printLog('⚠️ Index Socket Error: $error'),
    );
  }

  void _handleIndexMessage(String message) {
    try {
      final jsonResponse = jsonDecode(message);
      final messageType = jsonResponse['message_type'];

      if (messageType == 'connection' || messageType == 'itch_heartbeat') {
        return;
      }

      if (messageType == null) {
        const baseIndices = ['DSEX', 'DSES', 'DS30', 'DSMEX'];
        var index = IndexModel.fromJson(jsonResponse);

        if (baseIndices.contains(index.sn)) {
          final indexPos = baseIndices.indexOf(index.sn!);
          final existingIndex = indexList.indexWhere((r) => r.sn == index.sn);
          if (existingIndex != -1) {
            indexList[existingIndex] = index;
          } else {
            while (indexList.length <= indexPos) {
              indexList.add(IndexModel.empty());
            }
            indexList[indexPos] = index;
          }
        } else {
          final existingIndex = indexList.indexWhere((r) => r.sn == index.sn);
          if (existingIndex != -1) {
            indexList[existingIndex] = index;
          } else {
            indexList.add(index);
          }
        }

        if (newArr?.sn == index.sn) {
          newArr = index;
        }

        if (selectedChartParam == "1D" &&
            selectedSn == index.sn &&
            index.civ != null) {
          _updateLiveChartData(index.civ!, index);
        }

        lastIndexUpdateTime = DateTime.now();
        final now = DateTime.now();

        if (now.difference(_lastIndexUIUpdateTime).inMilliseconds > 500) {
          _indexUpdateTimer?.cancel();
          update(['index_list']);
          _lastIndexUIUpdateTime = now;
        } else {
          _indexUpdateTimer?.cancel();
          _indexUpdateTimer = Timer(const Duration(milliseconds: 500), () {
            if (!isClosed) update(['index_list']);
          });
        }
      }
    } catch (e) {
      printLog('❌ Error parsing index data: $e');
    }
  }
}
