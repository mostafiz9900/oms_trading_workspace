import 'package:get/get.dart';

import 'app_pkg.dart';
import 'data/services/market_socket.service.dart';
import 'modules/auth/controllers/token_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    Get.lazyPut(() => StorageService());
    Get.put<ThemeServices>(ThemeServices(), permanent: true);
    Get.lazyPut(() => WebSocketService());
    // Get.lazyPut(() => SSEService());
    Get.lazyPut<TokenController>(() => TokenController(), fenix: true);
    await Get.putAsync(() => MarketSocketService().init());
    // Get.lazyPut<MarketWebSocketService>(() => MarketWebSocketService(), fenix: true);
  }
}
