import 'package:broker_config/broker_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/core/values/app_config.dart';

import '../../helpers/test_env.dart';

HouseProfile _profile(ExchangeMode exchangeMode) => HouseProfile(
  houseId: 'testhouse',
  legalName: 'Test House Ltd',
  companyName: 'Test House',
  contact: const HouseContact(
    phone: '0',
    whatsApp: '0',
    email: 'support@house.test',
    websiteUrl: 'https://house.test',
    officeAddressShort: 'Dhaka',
    officeAddressFull: 'Dhaka',
    tradingHours: '10-2',
  ),
  store: const HouseStoreListing(
    androidPackageId: 'test.house',
    iosBundleId: 'test.house',
    appStoreId: '0',
    playStoreShareUrl: 'https://play.test',
    appStoreShareUrl: 'https://apps.test',
  ),
  exchangeMode: exchangeMode,
);

void main() {
  late BrokerHouseConfig house;

  setUp(() {
    initTestAppConfig();
    house = AppConfig.house;
  });

  test('a default house is DSE only', () {
    expect(AppConfig.exchangeMode, ExchangeMode.dseOnly);
    expect(AppConfig.exchanges, {StockExchange.dse});
    expect(AppConfig.hasDse, isTrue);
    expect(AppConfig.hasCse, isFalse);
    expect(AppConfig.hasBothExchanges, isFalse);
    expect(AppConfig.defaultExchange, StockExchange.dse);
  });

  test('a house can be on CSE only', () {
    AppConfig.initializeForTesting(house, _profile(ExchangeMode.cseOnly));
    expect(AppConfig.exchanges, {StockExchange.cse});
    expect(AppConfig.hasDse, isFalse);
    expect(AppConfig.hasCse, isTrue);
    expect(AppConfig.hasBothExchanges, isFalse);
    expect(AppConfig.defaultExchange, StockExchange.cse);
  });

  test('a house can be on DSE and CSE', () {
    AppConfig.initializeForTesting(house, _profile(ExchangeMode.dseAndCse));
    expect(AppConfig.exchanges, {StockExchange.dse, StockExchange.cse});
    expect(AppConfig.hasDse, isTrue);
    expect(AppConfig.hasCse, isTrue);
    expect(AppConfig.hasBothExchanges, isTrue);
    expect(AppConfig.defaultExchange, StockExchange.dse);
  });
}
