import 'package:get/get.dart';

import '../models/marquee_holder.dart';
import '../models/response/market_model.dart';
import '../models/response/sector_data_model.dart';

/// What the market screens show of one exchange's feed: the DSE feed
/// (HomeController) or the CSE feed (CseMarketService). Screens read the one
/// of the selected exchange through `HomeController.shownMarket`.
abstract interface class MarketFeedView {
  /// Latest quote of every order book.
  List<MarketModel> get quotes;

  /// PUBLIC stocks for the marquee, sorted by short name.
  List<MarqueeHolder> get marqueeList;

  /// Sector gainers (Up / Down / Equal) and share-type charts.
  List<Map<String, dynamic>> get chartData;
  List<Map<String, dynamic>> get chartDataShareType;

  List<SectorDataModel> get sectorSummaryList;

  /// Price-movement distribution (buckets of % change).
  List<int> get distributionCounts;
  int get distributionTotal;
  int get distributionMaxCount;

  /// Market session as the feed sends it (`cs`), e.g. `CONTINUOUS`.
  RxString get session;
}
