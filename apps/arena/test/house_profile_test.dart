import 'package:arena/src/house_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/oms_shared.dart';

void main() {
  test('Arena trades on DSE and CSE (DSE | CSE switcher)', () {
    expect(houseProfile.exchangeMode, ExchangeMode.dseOnly);
  });
}
