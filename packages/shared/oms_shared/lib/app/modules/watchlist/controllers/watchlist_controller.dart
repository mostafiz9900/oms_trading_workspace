import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/extensions/market_model_extensions.dart';
import '../../../data/models/response/market_model.dart';
import '../../home/controllers/home_controller.dart';

class WatchListController extends GetxController {
  final HomeController homeCon = Get.find<HomeController>();

  // --- UI State ---
  bool isGridView = false;
  String currentSearchQuery = '';
  String currentSortCategory = 'A-Z';
  String currentSortOrder = 'ASC';
  String selectSector = 'All';

  String selectedBoard = 'All';
  String selectedMarketType = 'All';
  String selectedShareType = 'All';
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final TextEditingController watchlistTextEditField = TextEditingController();

  List<MarketModel> filteredItems = [];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    _generateFilteredList();
  }

  @override
  void onReady() {
    super.onReady();
    applyFilters();
  }

  void onSocketMarketUpdate() {
    _generateFilteredList();
    update(['watchListUI', 'marketList']);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    scrollController.dispose();
    watchlistTextEditField.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    currentSearchQuery = searchController.text;
    applyFilters();
  }

  void toggleListGrid() {
    isGridView = !isGridView;
    update(['watchListUI']);
  }

  void updateSortCategory(String category) {
    currentSortCategory = category;
    applyFilters();
  }

  void updateSortOrder(String order) {
    currentSortOrder = order;
    applyFilters();
  }

  void searchSector(String query) {
    selectSector = query;
    applyFilters();
    update(['sectorSelection']);
  }

  void updateBoardFilter(String board) {
    selectedBoard = board;
    applyFilters();
  }

  void updateMarketTypeFilter(String type) {
    selectedMarketType = type;
    applyFilters();
  }

  void updateShareTypeFilter(String type) {
    selectedShareType = type;
    applyFilters();
  }

  void ensureDataLoaded() {
    _generateFilteredList();
  }

  void applyFilters() {
    _generateFilteredList();
    update([
      'watchListUI',
      'sortCategoryDropdown',
      'sortOrderDropdown',
      'marketList',
    ]);
  }

  // --- Pure Data Processing Logic ---
  void _generateFilteredList() {
    if (homeCon.marketList.isEmpty && homeCon.marketListAll.isEmpty) {
      isLoading = true;
      filteredItems = [];
      return;
    }
    isLoading = false;
    List<MarketModel> sourceList = homeCon.marketList.isNotEmpty
        ? homeCon.marketList
        : homeCon.marketListAll;

    // Main Board & PUBLIC Group Filter
    List<MarketModel> results = sourceList
        .where(
          (m) =>
              m.group == "PUBLIC" &&
              (m.board == "Main Board" || m.board == "Small Cap Board"),
        )
        .toList();

    if (selectedBoard != 'All') {
      if (selectedBoard == 'Main') {
        results = results.where((m) => m.board == "Main Board").toList();
      } else if (selectedBoard == 'SME') {
        results = results.where((m) => m.board == "Small Cap Board").toList();
      }
    }

    if (selectedMarketType != 'All') {
      results = results
          .where(
            (m) =>
                (m.marketType ?? "").toLowerCase() ==
                    selectedMarketType.toLowerCase() ||
                (m.group ?? "").toLowerCase() ==
                    selectedMarketType.toLowerCase(),
          )
          .toList();
    }

    if (selectedShareType != 'All') {
      results = results
          .where(
            (m) =>
                (m.shareType ?? "").toUpperCase() ==
                selectedShareType.toUpperCase(),
          )
          .toList();
    }

    if (currentSearchQuery.isNotEmpty) {
      results = results
          .where(
            (item) => item.displayName.toLowerCase().contains(
              currentSearchQuery.toLowerCase(),
            ),
          )
          .toList();
    }
    //A,B,N,P,S,Z

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
      switch (currentSortCategory) {
        case 'A-Z':
          comparison = a.displayName.compareTo(b.displayName);
          break;
        case 'Change(%)':
          comparison = a.percentageChange.compareTo(b.percentageChange);
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
          comparison = a.activePrice.compareTo(b.activePrice);
          break;
        case 'Paidup':
          comparison = (a.sp ?? 0).compareTo(b.sp ?? 0);
          break;
        default:
          comparison = a.displayName.compareTo(b.displayName);
      }
      return (currentSortOrder == 'ASC') ? comparison : -comparison;
    });

    filteredItems = results;
  }

  Future<void> refreshWatchList() async {
    await homeCon.refreshMarket();
    applyFilters();
  }

  // --- View Mode State ---
  String currentViewMode = 'Default';
  final List<String> viewModes = ['Default', 'Small', 'Classic'];

  void updateViewMode(String mode) {
    currentViewMode = mode;
    update(['watchListUI']);
  }

  void resetFilters() {
    selectedBoard = 'All';
    selectedMarketType = 'All';
    selectedShareType = 'All';
    currentSortCategory = 'A-Z';
    currentSortOrder = 'ASC';
    selectSector = 'All';

    // সার্চ বক্স ক্লিয়ার করা
    searchController.clear();
    currentSearchQuery = '';

    FocusManager.instance.primaryFocus?.unfocus();

    // ফিল্টার পুনরায় অ্যাপ্লাই করে UI আপডেট করা
    applyFilters();
    update(['sectorSelection']); // সেক্টর ট্যাবের UI আপডেটের জন্য
  }
}
