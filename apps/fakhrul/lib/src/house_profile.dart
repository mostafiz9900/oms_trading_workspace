import 'package:oms_shared/oms_shared.dart';

/// Company details shown in the app: contact page, share text, store links.
/// Server URLs, app name and colors live in `env/uat.json` / `env/prod.json`.
const houseProfile = HouseProfile(
  houseId: 'fakhrul',
  legalName: 'Md. Fakhrul Islam Securities Limited',
  companyName: 'Md. Fakhrul Islam Securities Limited',
  contact: HouseContact(
    phone: '01713057701',
    whatsApp: '01713057701',
    email: 'fisbdltd@gmail.com',
    websiteUrl: 'http://www.fisbd.com/',
    officeAddressShort: 'PBL Tower, (7th&13th Floor),17 Gulshan North C/A',
    officeAddressFull: 'PBL Tower, (7th&13th Floor),17 Gulshan North C/A,Circle-2, Dhaka-1212, Bangladesh',
    tradingHours: 'Sunday - Thursday (10:00 AM - 2:00 PM)',
  ),
  store: HouseStoreListing(
    androidPackageId: 'com.fisbd.oms.app',
    iosBundleId: 'com.fisbd.oms.app',
    appStoreId: 'TODO',
    playStoreShareUrl:
        'https://play.google.com/store/apps/details?id=com.fisbd.oms.app',
    appStoreShareUrl: 'TODO',
  ),
  // dseOnly (default) | cseOnly | dseAndCse
  exchangeMode: ExchangeMode.dseOnly,
);
