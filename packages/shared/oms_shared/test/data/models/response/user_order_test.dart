import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/data/models/response/user_order.dart';

void main() {
  test('reads the exchange of an order; none (older orders) stays null', () {
    expect(UserOrder.fromJson({'exchange': 'CSE'}).exchange, 'CSE');
    expect(UserOrder.fromJson({'orderId': 'O-1'}).exchange, isNull);
    expect(UserOrder.fromJson({'exchange': 'CSE'}).toJson()['exchange'], 'CSE');
  });
}
