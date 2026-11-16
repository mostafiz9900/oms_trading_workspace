import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/data/models/response/user_order.dart';

void main() {
  test('reads the exchange of an order; none (older orders) stays null', () {
    expect(UserOrder.fromJson({'exchange': 'CSE'}).exchange, 'CSE');
    expect(UserOrder.fromJson({'orderId': 'O-1'}).exchange, isNull);
    expect(UserOrder.fromJson({'exchange': 'CSE'}).toJson()['exchange'], 'CSE');
  });

  test('parses DSE integer and CSE string order book IDs in one list', () {
    final model = UserOrderModel.fromJson({
      'message_type': 'connection',
      'data': [
        {'order_book_id': 254555, 'exchange': 'DSE'},
        {'order_book_id': 'CSE_101001288', 'exchange': 'CSE'},
      ],
    });

    expect(model.data, hasLength(2));
    expect(model.data![0].orderBookId, 254555);
    expect(model.data![0].orderBookId, isA<int>());
    expect(model.data![1].orderBookId, 'CSE_101001288');
    expect(model.data![1].orderBookId, isA<String>());
  });
}
