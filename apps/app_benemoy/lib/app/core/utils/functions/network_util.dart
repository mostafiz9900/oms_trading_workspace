import 'dart:io';

import 'package:app_benemoy/app/app_pkg.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as connectivity;
import 'package:get/get.dart';

class NetworkUtil {
  static Future<bool> checkNetworkConnectivity2() async {
    var connectivityResult = await (connectivity.Connectivity().checkConnectivity());
    return connectivityResult.contains(connectivity.ConnectivityResult.none);
  }

  static Future<bool> isConnected() async {
    final List<connectivity.ConnectivityResult> connectivityResult = await (connectivity.Connectivity()
        .checkConnectivity());
    return !connectivityResult.contains(connectivity.ConnectivityResult.none);
  }

  // static Future<bool> checkInternetConnection() async {
  //   final connectivityResult = await connectivity.Connectivity().checkConnectivity();
  //
  //   return connectivityResult.contains(connectivity.ConnectivityResult.none);
  // }
  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  // static Future<bool> checkInternetConnection() async {
  //   try {
  //     final response = await GetConnect().get('https://google.com').timeout(Duration(seconds: 3));
  //     return response.statusCode == 200;
  //   } catch (_) {
  //     return false;
  //   }
  // }

  static void networkErrorMessage() {
    if (!Get.isSnackbarOpen) {
      Helpers.snackbarForErorr(bodyText: 'Sorry, there is no internet connection. Please connect and try again');
    }
  }
}
