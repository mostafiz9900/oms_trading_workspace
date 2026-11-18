class StorageConstants {
  static const String token = 'token';
  static const String refreshToken = 'refresh_token';
  static const String fcmToken = 'fcm_token';
  static const String userInfo = 'userInfo';
  static const String isDarkMode = 'isDarkMode';

  /// Legacy auto-selected order-book key. Kept only for logout cleanup.
  static const String orderBookId = 'orderBookId';
  static const String selectedQuoteOrderBookDse =
      'selected_quote_order_book_dse_v2';
  static const String selectedQuoteOrderBookCse =
      'selected_quote_order_book_cse_v2';
  static const String selectedExchange = 'selected_exchange';
  static String marketKey = 'market_data';
  static String deviceIdKey = 'device_id';
  static String deviceSecIdKey = 'device_secreate_id';
  static String biometricEnabled = 'biometric_enabled';
}
