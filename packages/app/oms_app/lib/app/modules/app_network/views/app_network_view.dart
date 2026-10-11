import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/app_network_controller.dart';

class AppNetworkView extends GetView<AppNetworkController> {
  const AppNetworkView({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: <Widget>[
          Obx(
            () => Text(
              controller.connectivityResult != ConnectivityResult.none
                  ? 'Connected to the internet'
                  : 'No internet connection',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Simulate connectivity change (for demonstration purposes)
              var result = controller.connectivityResult == ConnectivityResult.none
                  ? ConnectivityResult.wifi
                  : ConnectivityResult.none;
              controller.updateConnectivityResult(result);
            },
            child: const Text('Toggle Connectivity'),
          ),
        ],
      ),
    );
  }
}
