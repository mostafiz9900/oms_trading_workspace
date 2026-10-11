import 'app_config.dart';

class ApiUrl {
  //authentication
  static const login = 'api/users/app/login/';
  static const biometricActiveDeactive = 'api/users/biometric-key/';
  static const register = 'api/broker_house/investor/registration-request/';
  static const verifyBoid = 'api/broker_house/investor/verify-boid/';
  static const selectMedia = 'api/broker_house/investor/select-media/';
  static const verifyMedia = 'api/broker_house/investor/verify-media/';
  static const verifyOtp = 'api/broker_house/investor/verify-otp/';
  static const verifyOtpForgot = 'api/users/auth/check-otp-for-forgot-password/';
  static const forgotPassword = 'api/users/auth/send-otp-in-email/';
  static const tokenRefresh = 'api/users/token/refresh/';
  static const logoutUrl = 'api/users/logout/';
  static const forgotPasswordUrl = 'api/users/auth/change-password-for-forgot-password/';
  static const changePasswordPutUrl = 'api/users/auth/change-password/';
  static const withdrawCreateUrl = 'api/broker_house/withdraw/create/';
  static String withdrawGetUrl(String investorCode) => 'api/broker_house/withdraw/?investor_code=$investorCode';

  //watchlist fav
  static const createFavoriteTable = 'api/app_settings/custom-watch-list/create-tab/'; //create fav category name
  static const createFavoriteCategory = 'api/mobile_watchlist/watchlists/'; //create fav category name

  static const getFavoriteTablesUrl = 'api/app_settings/user-custom-table-list/'; //fav category name

  static String addMarketDataToFav = 'api/app_settings/custom-watch-list/add-instrument/';

  static String favoriteMarketData({int? id}) => 'api/app_settings/custom-watch-list/$id/';
  static String favoriteAllMarketData = 'api/app_settings/user-wise-custom-watchlist/';

  static String deleteFavTable(int id) => 'api/app_settings/table/manage/$id/child/';

  static String updateFavTableName(int id) => 'api/app_settings/table/manage/$id/child/';
  static String unfavoriteMarketData(int orderBookId) => 'api/app_settings/custom-watch-list/manage/$orderBookId/';
  static String getHistoricalVolumeData = '${AppConfig.baseURLItch}api/itch/get_historical_volume/';
  static String getIndexChart(String name, String fromDate, String toDate) =>
      '${AppConfig.baseURLItch}api/itch/get-minute-data-from-to?code=$name&from=$fromDate&upto=$toDate&adjust=0&interval=1';
}
