import 'package:oms_shared/oms_shared.dart';

/// Company details shown in the app: contact page, share text, store links.
/// Server URLs, app name and colors live in `env/uat.json` / `env/prod.json`.
const houseProfile = HouseProfile(
  houseId: 'cssl',
  legalName: 'Columbia Shares & Securities Limited (CSSL)',
  companyName: '',
  contact: HouseContact(
    phone: '+8801676429565',
    whatsApp: '+8801676429565',
    email: 'info@csslbd.com',
    websiteUrl: 'https://csslbd.net/',
    officeAddressShort: 'H#45, R#27, B#A, Banani, Dhaka',
    officeAddressFull: 'Elite House, Motijheel C/A',
    tradingHours: 'Sunday - Thursday (10:00 AM - 2:00 PM)',
  ),
  store: HouseStoreListing(
    androidPackageId: 'com.csslbd.oms.app',
    iosBundleId: 'com.csslbd.oms.app',
    appStoreId: 'TODO',
    playStoreShareUrl:
        'https://play.google.com/store/apps/details?id=com.csslbd.oms.app',
    appStoreShareUrl: 'TODO',
  ),
  // dseOnly (default) | cseOnly | dseAndCse
  exchangeMode: ExchangeMode.dseOnly,
);
