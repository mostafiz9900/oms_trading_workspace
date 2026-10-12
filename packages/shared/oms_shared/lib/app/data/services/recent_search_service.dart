import 'package:get/get.dart';

import 'storage_service.dart';
// import 'package:your_app/services/storage_service.dart'; // আপনার StorageService ফাইলের পাথ দিন

class RecentSearchService extends GetxService {
  static RecentSearchService get to => Get.find();

  List<int> recentOrderBookIds = [];
  final String _storageKey = 'recent_search_ids';

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final savedData = await StorageService.read(_storageKey);

    if (savedData != null) {
      recentOrderBookIds = List<int>.from(savedData);
    }
  }

  void addToRecentSearch(int orderBook) {
    recentOrderBookIds.removeWhere((id) => id == orderBook);
    recentOrderBookIds.insert(0, orderBook);

    if (recentOrderBookIds.length > 10) {
      recentOrderBookIds.removeLast();
    }

    StorageService.save(_storageKey, recentOrderBookIds);
  }

  void clearRecentSearches() {
    recentOrderBookIds.clear();
    StorageService.remove(_storageKey);
  }
}
