import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:getxify/getxify.dart';

class AppNetworkController extends GetxController {
  final _connectivityResult = ConnectivityResult.none.obs;

  ConnectivityResult get connectivityResult => _connectivityResult.value;

  void updateConnectivityResult(ConnectivityResult result) {
    _connectivityResult.value = result;
    showConnectivitySnackBar(result);
  }

  void showConnectivitySnackBar(ConnectivityResult result) {
    String message = result != ConnectivityResult.none
        ? 'Connected to the internet'
        : 'No internet connection';

    Get.snackbar(
      'Connection Status',
      message,
      snackPosition: SnackPosition.bottom,
      duration: const Duration(seconds: 3),
    );
  }
}
