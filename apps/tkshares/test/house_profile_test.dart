import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/oms_shared.dart';
import 'package:tkshares/src/house_profile.dart';

void main() {
  test('TK trades on DSE and CSE (DSE | CSE switcher)', () {
    expect(houseProfile.exchangeMode, ExchangeMode.dseAndCse);
  });
}
