import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../core/values/app_config.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/response/order_summary_model.dart';
import '../../../data/services/socket_db_service.dart';
import '../../../data/services/storage_service.dart';
import '../../home/controllers/home_controller.dart';

class OrderSummaryController extends GetxController {
  final String _socketId = 'order_summary_socket';
  final homeController = Get.find<HomeController>();

  // 🚀 States for Clean UI Management
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  OrderSummaryData? orderSummaryData;

  @override
  void onInit() {
    super.onInit();
    _connectToOrderSummarySocket();
  }

  @override
  void onClose() {
    WebSocketService.instance.disconnect(_socketId);
    super.onClose();
  }

  Future<void> _connectToOrderSummarySocket() async {
    try {
      _setLoadingState();

      // 🚀 ডাইনামিক টোকেন এবং ইনভেস্টর কোড রিড করা
      String token = await StorageService.read(StorageConstants.token) ?? '';
      String investorCode =
          homeController.userInfo.userDetail?.investorCode ?? '';

      if (token.isEmpty || investorCode.isEmpty) {
        _setErrorState("Authentication failed. Please login again.");
        return;
      }

      // সকেট কনফ্লিক্ট এড়াতে ইউনিক ID
      String individualId = const Uuid().v4();
      String url =
          "${AppConfig.socketBaseUrl}order_summary/$investorCode/all/?token=$token&individual_id=$individualId";

      await WebSocketService.instance.connect(
        socketId: _socketId,
        url: url,
        onConnected: () => debugPrint("✅ Order Summary Socket Connected"),
        onDisconnected: () {
          debugPrint("❌ Order Summary Socket Disconnected");
          _setErrorState("Connection lost. Trying to reconnect...");
        },
        onError: (error) {
          debugPrint("🚨 Order Summary Error: $error");
          _setErrorState("Failed to connect to the live server.");
        },
        onMessage: _parseSocketData,
      );
    } catch (e) {
      _setErrorState("Something went wrong. Please try again.");
    }
  }

  void _parseSocketData(String message) {
    try {
      final model = orderSummaryModelFromJson(message);
      if (model.data != null) {
        orderSummaryData = model.data;
        hasError = false;
        errorMessage = '';
      }
      isLoading = false;
      update();
    } catch (e) {
      debugPrint("JSON Parsing Error: $e");
    }
  }

  void refreshData() {
    _setLoadingState();
    WebSocketService.instance.forceReconnect(_socketId);
  }

  // --- Helper Methods ---
  void _setLoadingState() {
    isLoading = true;
    hasError = false;
    update();
  }

  void _setErrorState(String msg) {
    isLoading = false;
    hasError = true;
    errorMessage = msg;
    update();
  }
}
