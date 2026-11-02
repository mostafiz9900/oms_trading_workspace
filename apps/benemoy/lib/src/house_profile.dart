import 'package:oms_shared/oms_shared.dart';

/// Company details shown in the app: contact page, share text, store links.
/// Server URLs, app name and colors live in `env/uat.json` / `env/prod.json`.
const houseProfile = HouseProfile(
  houseId: 'benemoy',
  legalName: 'Benemoy Securities Ltd',
  companyName: 'Benemoy Securities',
  contact: HouseContact(
    phone: '01940660088',
    whatsApp: '01940660088',
    email: 'contact@benemoysecurities.com',
    websiteUrl: 'https://benemoysecurities.com',
    officeAddressShort: 'Praasad Paltan Square (9th Floor), 3/11 Naya Paltan, Motijheel, Dhaka-1000',
    officeAddressFull: 'Praasad Paltan Square (9th Floor), 3/11 Naya Paltan, Box Culvert Road, Motijheel, Dhaka-1000, Bangladesh',
    tradingHours: 'Sunday - Thursday (10:00 AM - 2:00 PM)',
  ),
  store: HouseStoreListing(
    androidPackageId: 'com.benemoysecurity.app',
    iosBundleId: 'com.benemoysecurities.app',
    appStoreId: '6751455371',
    playStoreShareUrl: 'https://play.google.com/store/apps/details?id=com.benemoysecurity.app&pcampaignid=web_share',
    appStoreShareUrl: 'https://apps.apple.com/us/app/benemoy/id6751455371',
  ),
  // dseOnly (default) | cseOnly | dseAndCse
  exchangeMode: ExchangeMode.dseOnly,
);
