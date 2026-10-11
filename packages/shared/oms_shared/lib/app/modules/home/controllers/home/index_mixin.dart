part of '../home_controller.dart';

/// Index feed for market_index_list_widget and index charts.
mixin MarketIndexMixin on HomeState {
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

  @override
  void _handleIndexMessage(String message) {
    try {
      final jsonResponse = jsonDecode(message); //  একবারই পার্স হবে
      final messageType = jsonResponse['message_type'];

      if (messageType == 'connection' || messageType == 'itch_heartbeat') {
        return; // অপ্রয়োজনীয় ডেটা সরাসরি রিটার্ন
      }

      if (messageType == null) {
        const baseIndices = ['DSEX', 'DSES', 'DS30', 'DSMEX'];
        var index = IndexModel.fromJson(
          jsonResponse,
        ); //  ডাবল jsonDecode বন্ধ করা হলো

        // Existing list logic
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
          selectedSn = index.sn ?? "${newArr?.sn}";
        }

        lastIndexUpdateTime = DateTime.now();

        //  ২. Throttling: ইনডেক্স দ্রুত পরিবর্তন হলেও UI আপডেট হবে প্রতি ৫০০ms এ
        final now = DateTime.now();
        if (now.difference(_lastIndexUIUpdateTime).inMilliseconds > 500) {
          _indexUpdateTimer?.cancel();
          update(['indexList']);
          _lastIndexUIUpdateTime = now;
        } else {
          _indexUpdateTimer?.cancel();
          _indexUpdateTimer = Timer(const Duration(milliseconds: 500), () {
            if (!isClosed) update(['indexList']);
          });
        }
      }
    } catch (e) {
      printLog('❌ Error parsing index data: $e');
    }
  }

  void selectSn(String sn) {
    selectedSn = sn;
    update(['indexList', AppConfig.indexSocketId, 'indexChartTap']);
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
        .map((e) => e.sn) // Get the sn value (could be null)
        .where((sn) => sn != null && sn.isNotEmpty) // Filter out null and empty
        .cast<String>() // Cast to non-nullable String
        .toList();
  }

  int get up => newArr?.u ?? 0;

  int get down => newArr?.d ?? 0;

  int get unchanged => newArr?.uc ?? 0;

  void getSumOfAllIndex(IndexModel? newIndexData) {
    newArr = newIndexData;
    selectedSn = newIndexData!.sn!;
    printLog('getSumOfAllIndex called -> ${newArr?.toJson()}');
    update(['indexList']);
  }

}
