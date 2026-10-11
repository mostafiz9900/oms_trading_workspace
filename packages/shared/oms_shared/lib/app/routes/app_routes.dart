// Route names keep the GetX CLI generated SCREAMING_CASE style.
// ignore_for_file: constant_identifier_names

/// Route names shared by every feature. Each app builds its own route table
/// (GetPage list) from these in `lib/src/routing/`.
library;

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const SPLASH = _Paths.SPLASH;
  static const APP_NETWORK = _Paths.APP_NETWORK;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const TOP_SHARE = _Paths.TOP_SHARE;
  static const SEARCH_WATCH_LIST = _Paths.SEARCH_WATCH_LIST;
  static const CLIENT_LIMIT = _Paths.CLIENT_LIMIT;
  static const CONTACT_US_VIEW = _Paths.CONTACT_US_VIEW;
  static const CONTACT_US = _Paths.CONTACT_US;
  static const ORDER_ALERT = _Paths.ORDER_ALERT;
  static const LIMIT_REQUEST = _Paths.LIMIT_REQUEST;
  static const WITHDRAWAL_REQUEST = _Paths.WITHDRAWAL_REQUEST;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const SPLASH = '/splash';
  static const APP_NETWORK = '/app-network';
  static const ONBOARDING = '/onboarding';
  static const TOP_SHARE = '/top-share';
  static const SEARCH_WATCH_LIST = '/search-watch-list';
  static const CLIENT_LIMIT = '/client-limit';
  static const CONTACT_US_VIEW = '/contact-us-view';
  static const CONTACT_US = '/contact-us';
  static const ORDER_ALERT = '/order-alert';
  static const LIMIT_REQUEST = '/limit-request';
  static const WITHDRAWAL_REQUEST = '/withdrawal-request';
}
