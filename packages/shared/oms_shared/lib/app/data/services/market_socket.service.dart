import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../app_pkg.dart';
import '../../modules/top_share/controllers/top_share_controller.dart';

class MarketSocketService extends GetxService {
  WebSocketChannel? _channel;
  final RxList<MarketModel> marketFeedList = <MarketModel>[].obs;
  final RxBool loadingMarketFeed = false.obs;
  final Map<int, MarketModel> _marketMap = {};

  bool _isReconnecting = false;
  Timer? _listUpdateTimer;

  Future<MarketSocketService> init() async {
    await _connect();
    return this;
  }

  // 🚀 কানেকশন এবং অটো-রিকানেক্ট লজিক
  Future<void> _connect() async {
    try {
      final wsUrl = Uri.parse(AppConfig.marketUrl);
      _channel = WebSocketChannel.connect(wsUrl);
      await _channel!.ready;
      _isReconnecting = false;
      print("WebSocket Connected Successfully!");

      _channel!.stream.listen(
        _onMessage,
        onError: (e) {
          print("WebSocket Error: $e");
          _reconnect(); // 🛡️ এরর হলে রিকানেক্ট করবে
        },
        onDone: () {
          print("WebSocket closed by server.");
          _reconnect(); // 🛡️ কানেকশন ড্রপ হলে রিকানেক্ট করবে
        },
      );
    } catch (e) {
      print("WebSocket Connection Exception: $e");
      _reconnect();
    }
  }

  void _reconnect() {
    if (_isReconnecting) return;
    _isReconnecting = true;
    print("Reconnecting Socket in 3 seconds...");

    Future.delayed(const Duration(seconds: 3), () {
      _connect();
    });
  }

  void _onMessage(event) {
    if (event != null) {
      final jsonResponse = jsonDecode(event);
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
    } else {
      print('⚠️ Null message received from socket');
    }
  }

  // 🛡️ মেমোরি লিক ঠেকানোর জন্য GetxService এর ডিফল্ট onClose ব্যবহার করা হলো
  @override
  void onClose() {
    _listUpdateTimer?.cancel();
    _channel?.sink.close();
    super.onClose();
  }

  // যদি আপনি ম্যানুয়ালি close কল করেন, তার জন্য সেফটি
  void close() {
    _listUpdateTimer?.cancel();
    _channel?.sink.close();
  }
}
