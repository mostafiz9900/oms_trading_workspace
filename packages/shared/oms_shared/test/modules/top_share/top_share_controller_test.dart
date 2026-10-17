import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/models/response/market_model.dart';
import 'package:oms_shared/app/data/services/market_socket_service.dart';
import 'package:oms_shared/app/modules/top_share/controllers/top_share_controller.dart';

void main() {
  late TopShareController controller;

  setUp(() {
    Get.put(MarketSocketService());
    controller = Get.put(TopShareController());
  });

  tearDown(Get.reset);

  test('resolves the latest model for a row using the orderBook, not the list index', () {
    final first = const MarketModel(orderBook: 101, shortName: 'GP');
    final second = const MarketModel(orderBook: 202, shortName: 'BATBC');

    controller.marketFeedSortList.assignAll([first, second]);
    controller.marketFeedSortList.assignAll([second, first]);

    final resolved = controller.resolveMarketModelForRow(first);

    expect(resolved.orderBook, 101);
    expect(resolved.shortName, 'GP');
  });
}
