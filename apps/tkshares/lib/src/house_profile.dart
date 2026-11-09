import 'package:oms_shared/oms_shared.dart';

/// Company details shown in the app: contact page, share text, store links.
/// Server URLs, app name and colors live in `env/uat.json` / `env/prod.json`.
const houseProfile = HouseProfile(
  houseId: 'tkshares',
  legalName: 'T.K. Shares & Securities Ltd',
  companyName: 'T.K. Shares & Securities Ltd',
  contact: HouseContact(
    phone: '01701211124',
    whatsApp: '01701211124',
    email: 'info@tksslbd.com',
    websiteUrl: 'https://tksslbd.com',
    officeAddressShort: 'Chattogram, Bangladesh',
    officeAddressFull: '83, Khatungonj, Chattogram, Bangladesh',
    tradingHours: 'Sunday - Thursday (10:00 AM - 2:00 PM)',
  ),
  store: HouseStoreListing(
    androidPackageId: 'com.tksslbd.oms.app',
    iosBundleId: 'com.tksslbd.oms.app',
    appStoreId: '',
    playStoreShareUrl:
        'https://play.google.com/store/apps/details?id=com.tksslbd.oms.app',
    appStoreShareUrl: '',
  ),
  // dseOnly (default) | cseOnly | dseAndCse
  exchangeMode: ExchangeMode.dseAndCse,
);
