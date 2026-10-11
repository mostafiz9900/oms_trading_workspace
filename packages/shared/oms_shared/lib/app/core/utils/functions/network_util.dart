import 'dart:io';

import '../helpers/app_helper.dart';
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

  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  static void networkErrorMessage() {
    if (!Get.isSnackbarOpen) {
      Helpers.snackbarForErorr(bodyText: 'Sorry, there is no internet connection. Please connect and try again');
    }
  }
}
