import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/data/models/response/user_profile.dart';

void main() {
  group('UserDetail', () {
    test('reads the CSE trader code (cse_trader_code) and keeps it', () {
      final detail = UserDetail.fromJson({
        'trader_code': 'TR01',
        'cse_trader_code': 'CSE-TR9',
      });

      expect(detail.traderCode, 'TR01');
      expect(detail.cseTraderCode, 'CSE-TR9');
      expect(detail.toJson()['cse_trader_code'], 'CSE-TR9');
    });

    test('no CSE trader code in the response: null', () {
      final detail = UserDetail.fromJson({'trader_code': 'TR01'});

      expect(detail.cseTraderCode, isNull);
    });
  });
}
