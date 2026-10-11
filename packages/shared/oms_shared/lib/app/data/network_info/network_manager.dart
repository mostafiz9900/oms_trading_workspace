import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NetworkManager extends GetxController {
  // ইন্টারনেট আছে কি নেই তা ট্র্যাক করবে
  var isConnected = true;

  @override
  void onInit() {
    super.onInit();
    // ইন্টারনেট চেক করা শুরু করুন
    Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> connectivityResult) async {
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Only on the online -> offline change; repeated "none" events used to
      // queue several day-long bars behind each other.
      if (!isConnected) return;
      isConnected = false;
      // ইন্টারনেট চলে গেলে মেসেজ
      Get.rawSnackbar(
        message: "No internet connection. Please check your network.",
        backgroundColor: Colors.red,
        duration: const Duration(days: 1), // যতক্ষণ না ইন্টারনেট আসে ততক্ষণ দেখাবে
        isDismissible: false,
      );
    } else {
      if (isConnected == false) {
        // ইন্টারনেট আসার সাথে সাথে আগের রেড স্নাকবারটি সরিয়ে দিন
        // Close it together with every alert queued behind it while offline,
        // so they don't replay one by one now that we are back online.
        Get.closeAllSnackbars();
        for (var i = 0; i < 40 && Get.isSnackbarOpen; i++) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
        // ইন্টারনেট ফিরে আসার মেসেজ
        Get.rawSnackbar(message: "Back online!", backgroundColor: Colors.green, duration: const Duration(seconds: 3));
      }
      isConnected = true;
    }
    update(); // UI আপডেট করার জন্য
  }
}
