import 'dart:async';

import 'package:get/get.dart';

import '../../app_pkg.dart';
import '../../modules/top_share/controllers/top_share_controller.dart';

/// Market feed for the Top Stocks page.
///
/// It used to open its own connection to [AppConfig.marketUrl], so every
/// tick of the same feed was received and decoded twice and startup waited
/// for that socket. It now receives the ticks HomeController already decoded
/// (see [onMarketPayload]); the processing below is unchanged.
class MarketSocketService extends GetxService {
  final RxList<MarketModel> marketFeedList = <MarketModel>[].obs;
  final RxBool loadingMarketFeed = false.obs;
  final Map<int, MarketModel> _marketMap = {};

  Timer? _listUpdateTimer;

  /// One decoded market message (same JSON object the socket delivered).
  void onMarketPayload(Map<String, dynamic> jsonResponse) {
    if (jsonResponse['ob'] != null) {
      final incoming = MarketModel.fromJson(jsonResponse);

      final updatedModel = _marketMap.update(
        incoming.orderBook!,
        (existing) => existing.mergePartialUpdate(jsonResponse),
        ifAbsent: () => incoming,
      );

      if (Get.isRegistered<TopShareController>()) {
        Get.find<TopShareController>().updateSingleRowFromService(updatedModel);
      }

      // লিস্ট ফিল্টার করার ভারী কাজটা প্রতি সেকেন্ডে মাত্র ১ বার হবে।
      if (_listUpdateTimer == null || !_listUpdateTimer!.isActive) {
        _listUpdateTimer = Timer(const Duration(milliseconds: 1000), () {
          final filtered = _marketMap.values
            ..where((m) => m.group == "PUBLIC" && m.board == "Main Board" || m.board == "Small Cap Board").toList();

          marketFeedList.assignAll(filtered);
        });
      }
    }
  }

  // 🛡️ মেমোরি লিক ঠেকানোর জন্য GetxService এর ডিফল্ট onClose ব্যবহার করা হলো
  @override
  void onClose() {
    _listUpdateTimer?.cancel();
    super.onClose();
  }
}
