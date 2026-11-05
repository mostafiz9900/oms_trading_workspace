import 'package:oms_shared/oms_shared.dart';

/// Company details shown in the app: contact page, share text, store links.
/// Server URLs, app name and colors live in `env/uat.json` / `env/prod.json`.
const houseProfile = HouseProfile(
  houseId: 'arena',
  legalName: 'Arena Securities Ltd',
  companyName: 'Arena Securities Ltd',
  contact: HouseContact(
    phone: '02-47114153',
    whatsApp: '+8801841777727', // আগের রেকর্ডকৃত অফিশিয়াল মোবাইল নম্বর
    email: 'arenasecurities@yahoo.com',
    websiteUrl: 'https://arenasecurities.com.bd/',
    officeAddressShort: 'Motijheel, Dhaka',
    officeAddressFull: 'Modhumita Building (2nd Floor), 160, Motijheel C/A, Dhaka-1000, Bangladesh',
    tradingHours: 'Sunday - Thursday (10:00 AM - 2:00 PM)',
  ),
  store: HouseStoreListing(
    androidPackageId: 'com.arenasecurities.oms.app',
    iosBundleId: 'com.arenasecurities.oms.app',
    appStoreId: 'TODO',
    playStoreShareUrl: 'https://play.google.com/store/apps/details?id=com.arenasecurities.oms.app',
    appStoreShareUrl: 'TODO',
  ),
  // dseOnly (default) | cseOnly | dseAndCse
  exchangeMode: ExchangeMode.dseOnly,
);
