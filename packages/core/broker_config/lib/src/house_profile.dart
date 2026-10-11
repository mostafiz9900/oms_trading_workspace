/// Company-owned details of a broker house that do not change between UAT and
/// production: contact page content and store listings.
///
/// Each deployable app declares one `const HouseProfile` and passes it to the
/// shared app bootstrap. Endpoint and branding values that vary per
/// environment stay in the `--dart-define-from-file` profile instead.
class HouseProfile {
  const HouseProfile({
    required this.houseId,
    required this.legalName,
    required this.companyName,
    required this.contact,
    required this.store,
  });

  /// Must match `OMS_HOUSE_ID` from the environment profile.
  final String houseId;

  /// Registered company name, e.g. used as the support email subject.
  final String legalName;

  /// Short company name used in marketing/share text.
  final String companyName;

  final HouseContact contact;
  final HouseStoreListing store;
}

/// Content of the "Contact us" page.
class HouseContact {
  const HouseContact({
    required this.phone,
    required this.whatsApp,
    required this.email,
    required this.websiteUrl,
    required this.officeAddressShort,
    required this.officeAddressFull,
    required this.tradingHours,
  });

  final String phone;

  /// Local number without the country code; `wa.me` links prefix `88`.
  final String whatsApp;
  final String email;
  final String websiteUrl;
  final String officeAddressShort;
  final String officeAddressFull;
  final String tradingHours;
}

/// Store identity used for update checks and app share links.
class HouseStoreListing {
  const HouseStoreListing({
    required this.androidPackageId,
    required this.iosBundleId,
    required this.appStoreId,
    required this.playStoreShareUrl,
    required this.appStoreShareUrl,
  });

  final String androidPackageId;
  final String iosBundleId;

  /// Numeric Apple App Store id (without the `id` prefix).
  final String appStoreId;
  final String playStoreShareUrl;
  final String appStoreShareUrl;

  String get playStoreUrl =>
      'https://play.google.com/store/apps/details?id=$androidPackageId';
  String get appStoreUrl => 'https://apps.apple.com/app/id$appStoreId';
}
