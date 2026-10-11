part of '../home_controller.dart';

/// Search, filter and sort for watch_list_widget and global_search_view.
mixin WatchListMixin on HomeState {
  void _onSearchChanged() {
    search(searchController.text);
  }

  void scrollToMatch() {
    final model = marketList.firstWhere(
      (market) => market.filterName == filterName,
      orElse: () => MarketModel(),
    );
    final index = marketList.indexOf(model);
    if (index == -1) return;
    const itemHeight = 90.0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        final topOffset = index * itemHeight;
        final safeOffset = topOffset.clamp(
          scrollController.position.minScrollExtent,
          scrollController.position.maxScrollExtent,
        );
        scrollController.animateTo(
          safeOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    });

    update();
  }

  // আপনার এই ফাংশনটি ঠিক রাখুন
  void search(String query) {
    currentSearchQuery = query; // নিশ্চিত করুন এই ভেরিয়েবলটি গ্লোবালি আছে
    applyFilters();
  }

  // আপনার এই ফাংশনটি ঠিক রাখুন
  void searchSector(String query) {
    selectSector = query; // আপনার বর্তমান ভেরিয়েবল নাম ব্যবহার করুন
    applyFilters();
  }

  void updateSortCategory(String category) {
    currentSortCategory = category;
    update(['sortCategoryDropdown']); // Category ড্রপডাউন আপডেট হবে
    applyFilters();
  }

  void updateSortOrder(String order) {
    currentSortOrder = order;
    update(['sortOrderDropdown']); // Order ড্রপডাউন আপডেট হবে
    applyFilters();
  }

  @override
  void applyFilters() {
    List<MarketModel> results = List.from(marketList);

    // ১. সার্চ ফিল্টার
    if (currentSearchQuery.isNotEmpty) {
      results = results
          .where(
            (item) => (item.filterName ?? "").toLowerCase().startsWith(
              currentSearchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    // ২. সেক্টর ফিল্টার
    if (selectSector != 'All' && selectSector.isNotEmpty) {
      results = results
          .where(
            (item) => (item.sector ?? "").toLowerCase().contains(
              selectSector.toLowerCase(),
            ),
          )
          .toList();
    }

    results.sort((a, b) {
      int comparison = 0;

      // ক্যাটাগরি অনুযায়ী ডাটা কম্পেয়ার করা
      switch (currentSortCategory) {
        case 'A-Z':
          comparison = (a.shortName ?? "").compareTo(b.shortName ?? "");
          break;
        case 'Change(%)':
          comparison = (a.chg ?? 0).compareTo(b.chg ?? 0);
          break;
        case 'Value':
          comparison = (a.val ?? 0).compareTo(b.val ?? 0);
          break;
        case 'Volume':
          comparison = (a.volume ?? 0).compareTo(b.volume ?? 0);
          break;
        case 'Trade':
          comparison = (a.trades ?? 0).compareTo(b.trades ?? 0);
          break;
        case 'Price':
          comparison = (a.last ?? 0).compareTo(b.last ?? 0);
          break;
        case 'Paidup':
          comparison = (a.sp ?? 0).compareTo(b.sp ?? 0);
          break;
        default:
          comparison = (a.shortName ?? "").compareTo(b.shortName ?? "");
      }

      // অর্ডার অনুযায়ী রেজাল্ট রিটার্ন করা
      return (currentSortOrder == 'ASC') ? comparison : -comparison;
    });

    filteredItems.assignAll(results);
    update(['marketList']);
  }

  void toggleListGrid() {
    isGridView = !isGridView;
    update(['marketList']); // update only widgets with id 'watchList'
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      marketListForDilog = marketListAll;
    } else {
      marketListForDilog = marketListAll
          .where(
            (item) => (item.shortName ?? "").toUpperCase().startsWith(
              query.toUpperCase(),
            ),
          )
          .toList();
    }
    update();
  }

}
