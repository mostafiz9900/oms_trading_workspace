import 'package:getxify/getxify.dart';

import '../controllers/search_watch_list_controller.dart';

class SearchWatchListBinding extends Binding {
  @override
  void dependencies() {
    Get.lazyPut<SearchWatchListController>(() => SearchWatchListController());
  }
}
