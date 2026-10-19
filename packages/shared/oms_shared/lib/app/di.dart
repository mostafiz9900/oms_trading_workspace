import 'package:get/get.dart';

import 'core/theme/theme_service.dart';
import 'data/services/exchange_service.dart';
import 'data/services/socket_db_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/market_socket_service.dart';
import 'modules/auth/controllers/token_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    Get.lazyPut(() => StorageService());
    Get.put<ThemeServices>(ThemeServices(), permanent: true);
    // Selected DSE/CSE exchange; read by the market and index sockets.
    Get.put(ExchangeService(), permanent: true);
    Get.lazyPut(() => WebSocketService());
    Get.lazyPut<TokenController>(() => TokenController(), fenix: true);
    // Fed by HomeController's market socket; no network wait at startup.
    Get.put(MarketSocketService());
  }
}
