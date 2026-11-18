import 'package:material_ui/material_ui.dart';
import 'package:getxify/getxify.dart';

import '../../../core/utils/extensions/market_model_extensions.dart';
import '../../../data/models/response/market_model.dart';
import '../views/global_search_view.dart';
import '../../home/controllers/home_controller.dart';
import '../../../data/services/recent_search_service.dart';
import '../../../data/services/cse_market_service.dart';
import '../../../data/services/exchange_service.dart';

class GlobalSearchController extends GetxController {
  List<MarketModel> filteredItems = [];

  String currentSearchQuery = '';

  // Sorting Variables
  String currentSortCategory = 'A-Z';
  String currentSortOrder = 'ASC';

  // View Mode Variables
  String currentViewMode = 'Default';
  final List<String> viewModes = ['Default', 'Small', 'Classic'];

  // 🚀 Service-কে কল করার শর্টকাট
  RecentSearchService get recentService => RecentSearchService.to;

  // মেইন লাইভ ডাটা (stocks of the shown exchange; on DSE: marketList)
  List<MarketModel> get _validHomeData {
    final rawList = Get.find<HomeController>().searchFeed.quotes
        .cast<MarketModel>();
    return rawList.where((m) => m.group == "PUBLIC").toList();
  }

  Worker? _exchangeWorker;
  Worker? _cseWorker;

  List<MarketModel> get recentSearches {
    List<MarketModel> liveRecentItems = [];
    for (final id in recentService.recentOrderBookIds) {
      final matches = _validHomeData.where((m) => m.orderBook == id);
      if (matches.isNotEmpty) {
        liveRecentItems.add(matches.first);
      }
    }
    return liveRecentItems;
  }

  @override
  void onInit() {
    super.onInit();
    syncLiveData();
    if (Get.isRegistered<ExchangeService>()) {
      _exchangeWorker = ever(
        Get.find<ExchangeService>().selection(ExchangeScope.search),
        (_) => syncLiveData(),
      );
    }
    if (Get.isRegistered<CseMarketService>()) {
      _cseWorker = ever<List<MarketModel>>(
        Get.find<CseMarketService>().quotes,
        (_) {
          if (CseMarketService.isShownFor(ExchangeScope.search)) {
            syncLiveData();
          }
        },
      );
    }
  }

  @override
  void onClose() {
    _exchangeWorker?.dispose();
    _cseWorker?.dispose();
    super.onClose();
  }

  void syncLiveData() {
    searchData(currentSearchQuery);
  }

  // Update Methods
  void updateSortCategory(String category) {
    currentSortCategory = category;
    searchData(currentSearchQuery);
  }

  void updateSortOrder(String order) {
    currentSortOrder = order;
    searchData(currentSearchQuery);
  }

  void updateViewMode(String mode) {
    currentViewMode = mode;
    update(['searchList', 'viewModeDropdown']);
  }

  void searchData(String query) {
    currentSearchQuery = query;

    filteredItems = _validHomeData.where((item) {
      bool matchesSearch =
          query.isEmpty ||
          item.displayName.toLowerCase().contains(query.toLowerCase());
      return matchesSearch;
    }).toList();

    filteredItems.sort((a, b) {
      int result = 0;
      switch (currentSortCategory) {
        case 'A-Z':
          result = a.displayName.compareTo(b.displayName);
          break;
        case 'Change(%)':
          result = a.percentageChange.compareTo(b.percentageChange);
          break;
        case 'Value':
          result = (a.val ?? 0.0).compareTo(b.val ?? 0.0);
          break;
        case 'Volume':
          result = (a.volume ?? 0).compareTo(b.volume ?? 0);
          break;
        case 'Trade':
          result = (a.trades ?? 0).compareTo(b.trades ?? 0);
          break;
        case 'Price':
          result = a.activePrice.compareTo(b.activePrice);
          break;
        case 'Paidup':
          result = (a.sp ?? 0).compareTo(b.sp ?? 0);
          break;
        default:
          result = a.displayName.compareTo(b.displayName);
      }
      return currentSortOrder == 'ASC' ? result : -result;
    });

    if (query.isNotEmpty && currentSortCategory == 'A-Z') {
      filteredItems.sort((a, b) {
        final String nameA = a.displayName.toLowerCase();
        final String nameB = b.displayName.toLowerCase();
        final String q = query.toLowerCase();

        if (nameA.startsWith(q) && !nameB.startsWith(q)) return -1;
        if (!nameA.startsWith(q) && nameB.startsWith(q)) return 1;
        return 0;
      });
    }

    update([
      'searchList',
      'sortCategoryDropdown',
      'sortOrderDropdown',
      'viewModeDropdown',
    ]);
  }

  void addToRecent(MarketModel item) {
    if (item.orderBook == null) return;
    recentService.addToRecentSearch(item.orderBook!);
  }

  void clearRecent() {
    recentService.clearRecentSearches();
    update(['searchList']);
  }
}

class SearchHelper {
  static Future<MarketModel?> open() async {
    final selectedItem = await Get.to(
      () => const GlobalSearchScreen(),
      transition: Transition.downToUp,
      curve: Curves.easeOutQuart,
      duration: const Duration(milliseconds: 250),
      bindings: [
        Binding.builder(() {
          Get.put(GlobalSearchController());
        }),
      ],
    );

    if (selectedItem is MarketModel && Get.isRegistered<ExchangeService>()) {
      final exchange = Get.find<ExchangeService>().exchangeFor(
        ExchangeScope.search,
      );
      Get.find<ExchangeService>().select(
        exchange,
        scope: ExchangeScope.quoteTrade,
      );
    }
    return selectedItem as MarketModel?;
  }
}
