import 'package:get/get.dart';

import '../../../core/utils/extensions/market_model_extensions.dart';
import '../../../data/models/response/market_model.dart';
import '../../../data/models/response/share_situation.dart';
import '../../../data/services/market_socket_service.dart';

// আপনার MarketModelExtensions ইম্পোর্ট করে নিবেন

class TopShareController extends GetxController {
  final MarketSocketService marketService = Get.find<MarketSocketService>();

  final _shareSituationList = <ShareSituation>[].obs;
  List<ShareSituation> get shareSituationList => _shareSituationList;

  bool pageLoad = true;
  List<MarketModel> get marketFeedList => marketService.marketFeedList;

  Worker? _debounceWorker;

  // Active Filter States
  String activeTopMenuTopShare = "Gainer";
  String activeDurationFilter = "Daily";
  String activeSector = "All";
  String activeSortByCompany = "Sort By";
  String activeSortByAscDesc = "Desc";

  List<String> sortByCompanyTypeMenuList = ["All"];
  List<String> sortByMenuList = [
    "A-Z",
    "Change(%)",
    "Value",
    "Volume",
    "Trade",
  ];
  List<String> sortByAscDescMenuList = ["Asc", "Desc"];

  List<MarketModel> marketFeedSortList = <MarketModel>[];

  @override
  void onInit() {
    super.onInit();
    pageLoad = true;

    if (Get.arguments != null && Get.arguments.toString().isNotEmpty) {
      activeTopMenuTopShare = Get.arguments.toString();
    }

    _updateShareSituationState();

    // _debounceWorker = debounce(marketService.marketFeedList, (
    //   List<MarketModel> marketList,
    // ) {
    //   if (marketList.isNotEmpty) {
    //     if (sortByCompanyTypeMenuList.length <= 1) {
    //       setCompanySectorList();
    //     }
    //     applyAllFiltersAndSort();
    //   }
    // }, time: const Duration(milliseconds: 500));

    if (marketFeedList.isNotEmpty) {
      setCompanySectorList();
      applyAllFiltersAndSort();
    }

    pageLoad = false;
    update();
  }

  @override
  void onClose() {
    _debounceWorker?.dispose();
    super.onClose();
  }

  String mapDurationToExtensionFormat(String duration) {
    switch (duration) {
      case "Weekly":
        return "1W";
      case "15 Day":
        return "2W";
      case "Monthly":
        return "1M";
      case "6 Month":
        return "6M";
      case "Yearly":
        return "1Y";
      case "Daily":
      default:
        return "1D";
    }
  }

  // double _getChangeValue(MarketModel m, String duration) {
  //   // ekhane public function call hobe
  //   return m.getChangeByDuration(mapDurationToExtensionFormat(duration));
  // }

  void updateSingleRowFromService(MarketModel updatedModel) {
    int sortIndex = marketFeedSortList.indexWhere(
      (e) => e.orderBook == updatedModel.orderBook,
    );
    if (sortIndex != -1) {
      marketFeedSortList[sortIndex] = updatedModel;
      update(['${updatedModel.orderBook}']);
    }
  }

  void setCompanySectorList() {
    final sectors = marketFeedList
        .map((e) => e.sector?.toString().trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    sectors.sort((a, b) => a.compareTo(b));
    sortByCompanyTypeMenuList = ["All", ...sectors];
    update();
  }

  // ========================================================
  // STATE UPDATES
  // ========================================================
  void setActiveTopMenuTopShare(String? value) {
    if (value == null || value == activeTopMenuTopShare) return;
    activeTopMenuTopShare = value;
    activeSortByCompany = "Sort By";
    activeSortByAscDesc = "Desc";

    _updateShareSituationState();
    applyAllFiltersAndSort();
  }

  void setActiveSector(String value) {
    activeSector = value;
    applyAllFiltersAndSort();
  }

  void setActiveSortByCompany(String value) {
    activeSortByCompany = value;
    applyAllFiltersAndSort();
  }

  void setActiveSortByAscDesc(String value) {
    activeSortByAscDesc = value;
    applyAllFiltersAndSort();
  }

  void setActiveDurationFilter(String value) {
    activeDurationFilter = value;
    applyAllFiltersAndSort();
  }

  // ========================================================
  // FILTER & SORT PIPELINE
  // ========================================================
  void applyAllFiltersAndSort() {
    List<MarketModel> filteredList = List<MarketModel>.from(marketFeedList);

    // 1. Sector Filter
    if (activeSector.toLowerCase() != "all" && activeSector.isNotEmpty) {
      filteredList = filteredList
          .where(
            (e) =>
                (e.sector?.trim().toUpperCase() ?? '') ==
                activeSector.trim().toUpperCase(),
          )
          .toList();
    }

    // 2. Base Filters based on Top Menu (DSE rules: exclude 0 volume/value)
    switch (activeTopMenuTopShare) {
      case "Gainer":
        filteredList = filteredList
            .where(
              (e) =>
                  _getChangeValue(e, activeDurationFilter) > 0 &&
                  (e.volume ?? 0) > 0,
            )
            .toList();
        break;
      case "Loser":
        filteredList = filteredList
            .where(
              (e) =>
                  _getChangeValue(e, activeDurationFilter) < 0 &&
                  (e.volume ?? 0) > 0,
            )
            .toList();
        break;
      case "Unchanged":
        filteredList = filteredList
            .where(
              (e) =>
                  _getChangeValue(e, activeDurationFilter) == 0 &&
                  (e.volume ?? 0) > 0,
            )
            .toList();
        break;
      case "Value":
        filteredList = filteredList.where((e) => (e.val ?? 0) > 0).toList();
        break;
      case "Volume":
        filteredList = filteredList.where((e) => (e.volume ?? 0) > 0).toList();
        break;
      case "Trade":
        filteredList = filteredList.where((e) => (e.trades ?? 0) > 0).toList();
        break;
    }

    // 3. Determine Sort Type
    String currentSort = activeSortByCompany;
    if (currentSort == "Sort By") {
      switch (activeTopMenuTopShare) {
        case "Value":
          currentSort = "Value";
          break;
        case "Volume":
          currentSort = "Volume";
          break;
        case "Trade":
          currentSort = "Trade";
          break;
        case "A-Z":
          currentSort = "A-Z";
          break;
        case "Gainer":
        case "Loser":
        case "Unchanged":
        default:
          currentSort = "Change(%)";
          break;
      }
    }

    // 4. Execute Sorting
    filteredList.sort((a, b) {
      int sortResult = 0;
      switch (currentSort) {
        case "A-Z":
          sortResult = a.displayName.compareTo(b.displayName);
          break;
        case "Value":
          sortResult = (a.val ?? 0.0).compareTo(b.val ?? 0.0);
          break;
        case "Volume":
          sortResult = _getVolumeValue(
            a,
            activeDurationFilter,
          ).compareTo(_getVolumeValue(b, activeDurationFilter));
          break;
        case "Trade":
          sortResult = (a.trades ?? 0).compareTo(b.trades ?? 0);
          break;
        case "Change(%)":
        default:
          sortResult = _getChangeValue(
            a,
            activeDurationFilter,
          ).compareTo(_getChangeValue(b, activeDurationFilter));
          break;
      }

      // 🚀 DSE Logic for Losers: Losers should show the most negative value at the top (Ascending mathematical order)
      if (activeTopMenuTopShare == "Loser" && currentSort == "Change(%)") {
        return activeSortByAscDesc == "Desc" ? sortResult : -sortResult;
      }

      // For others, Descending means Largest to Smallest
      return activeSortByAscDesc == "Desc" ? -sortResult : sortResult;
    });

    marketFeedSortList.assignAll(filteredList);
    update();
  }

  // ========================================================
  // ========================================================

  String _mapDurationToExtensionFormat(String duration) {
    switch (duration) {
      case "Weekly":
        return "1W";
      case "15 Day":
        return "2W";
      case "Monthly":
        return "1M";
      case "6 Month":
        return "6M";
      case "Yearly":
        return "1Y";
      case "Daily":
      default:
        return "1D";
    }
  }

  double _getChangeValue(MarketModel m, String duration) {
    return m.getChangeByDuration(_mapDurationToExtensionFormat(duration));
  }

  double _getVolumeValue(MarketModel m, String duration) {
    String extDur = duration == "Weekly"
        ? "weekly"
        : duration == "Monthly"
        ? "monthly"
        : "daily";
    return m.getVolumeByDuration(extDur);
  }

  void _updateShareSituationState() {
    final list = getShareSituationList();
    for (var item in list) {
      item.isActive = (item.name == activeTopMenuTopShare);
    }
    _shareSituationList.assignAll(list);
  }

  List<ShareSituation> getShareSituationList() => [
    ShareSituation(id: 1, name: 'Gainer', isActive: false),
    ShareSituation(id: 2, name: 'Loser', isActive: false),
    ShareSituation(id: 3, name: 'Value', isActive: false),
    ShareSituation(id: 4, name: 'Volume', isActive: false),
    ShareSituation(id: 5, name: 'Trade', isActive: false),
    ShareSituation(id: 6, name: 'Unchanged', isActive: false),
  ];
  String currentViewMode = 'Default';
  final List<String> viewModes = ['Default', 'Small', 'Classic'];

  void updateViewMode(String mode) {
    currentViewMode = mode;
    update(); // পুরো পেজ রিবিল্ড করার জন্য
  }
}
