import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class AppNetworkController extends GetxController {
  final _connectivityResult = ConnectivityResult.none.obs;

  ConnectivityResult get connectivityResult => _connectivityResult.value;

  void updateConnectivityResult(ConnectivityResult result) {
    _connectivityResult.value = result;
    showConnectivitySnackBar(result);
  }

  void showConnectivitySnackBar(ConnectivityResult result) {
    String message = result != ConnectivityResult.none ? 'Connected to the internet' : 'No internet connection';

    Get.snackbar(
      'Connection Status',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
