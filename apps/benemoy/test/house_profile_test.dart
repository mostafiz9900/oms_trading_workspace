import 'package:benemoy/src/house_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/oms_shared.dart';

void main() {
  test('Benemoy trades on DSE only', () {
    expect(houseProfile.exchangeMode, ExchangeMode.dseOnly);
  });
}
