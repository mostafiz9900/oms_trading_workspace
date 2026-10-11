import 'package:get/get.dart';

import '../controllers/search_watch_list_controller.dart';

class SearchWatchListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchWatchListController>(() => SearchWatchListController());
  }
}
