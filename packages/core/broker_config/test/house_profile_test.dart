import 'package:broker_config/broker_config.dart';
import 'package:test/test.dart';

const _contact = HouseContact(
  phone: '0',
  whatsApp: '0',
  email: 'e',
  websiteUrl: 'w',
  officeAddressShort: 's',
  officeAddressFull: 'f',
  tradingHours: 'h',
);

const _store = HouseStoreListing(
  androidPackageId: 'a',
  iosBundleId: 'i',
  appStoreId: '1',
  playStoreShareUrl: 'p',
  appStoreShareUrl: 'u',
);

void main() {
  test('a house trades on DSE only unless it says otherwise', () {
    const profile = HouseProfile(
      houseId: 'h',
      legalName: 'L',
      companyName: 'C',
      contact: _contact,
      store: _store,
    );
    expect(profile.exchangeMode, ExchangeMode.dseOnly);
  });

  test('DSE only', () {
    const mode = ExchangeMode.dseOnly;
    expect(mode.exchanges, {StockExchange.dse});
    expect((mode.hasDse, mode.hasCse, mode.hasBoth), (true, false, false));
    expect(mode.defaultExchange, StockExchange.dse);
  });

  test('CSE only', () {
    const mode = ExchangeMode.cseOnly;
    expect(mode.exchanges, {StockExchange.cse});
    expect((mode.hasDse, mode.hasCse, mode.hasBoth), (false, true, false));
    expect(mode.defaultExchange, StockExchange.cse);
  });

  test('DSE and CSE starts on DSE', () {
    const mode = ExchangeMode.dseAndCse;
    expect(mode.exchanges, {StockExchange.dse, StockExchange.cse});
    expect((mode.hasDse, mode.hasCse, mode.hasBoth), (true, true, true));
    expect(mode.defaultExchange, StockExchange.dse);
  });

  test('no mode is empty', () {
    for (final mode in ExchangeMode.values) {
      expect(mode.exchanges, isNotEmpty, reason: mode.name);
    }
  });
}
