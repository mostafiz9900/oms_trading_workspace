import 'package:get/get.dart';

import 'data/providers/auth_provider.dart';
import 'data/providers/home_provider.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/home_repository.dart';
import 'data/network_info/network_manager.dart';
import 'data/services/recent_search_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() async {
    Get.put(NetworkManager(), permanent: true);
    //provider
    Get.put(AuthProvider(), permanent: true);
    Get.put(RecentSearchService(), permanent: true);
    Get.lazyPut<HomeProvider>(() => HomeProvider(), fenix: true);
    //Repository
    Get.put(AuthRepository(authProvider: Get.find()), permanent: true);
    Get.put(HomeRepository(homeProvider: Get.find()), permanent: true);
  }
}
