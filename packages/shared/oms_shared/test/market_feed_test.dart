import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/services/market_socket.service.dart';

void main() {
  late MarketSocketService service;

  setUp(() => service = Get.put(MarketSocketService()));
  tearDown(Get.reset);

  testWidgets('Top Stocks feed merges partial ticks and refreshes once a second',
      (tester) async {
    service.onMarketPayload({'ob': 101, 'sn': 'GP', 'l': 300.5});
    service.onMarketPayload({'ob': 202, 'sn': 'BATBC', 'l': 500.0});
    // A partial tick for GP: fields it omits keep their previous values.
    service.onMarketPayload({'ob': 101, 'l': 301.0});
    // Messages without an order book are ignored, as before.
    service.onMarketPayload({'message_type': 'itch_heartbeat'});

    expect(service.marketFeedList, isEmpty, reason: 'list refresh is throttled');
    await tester.pump(const Duration(seconds: 1));

    expect(service.marketFeedList.length, 2);
    final gp = service.marketFeedList.firstWhere((m) => m.orderBook == 101);
    expect(gp.shortName, 'GP', reason: 'kept from the first tick');
  });
}
