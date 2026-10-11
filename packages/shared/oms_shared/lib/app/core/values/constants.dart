import 'app_config.dart';

class AppConstants {
  // String constants
  static String get appName => AppConfig.house.displayName;
  static String get welcomeMessage => 'Welcome to $appName';
  static const String data = 'data';
  static const String message = 'message';
  static const String messageType = 'message_type';
  static const String success = 'success';
  static const String pendingOrderStatus = 'Pending';
  static const String filledOrderStatus = 'Filled';
  static const String updatedOrderStatus = 'Updated';
  static const String partiallyFilledOrderStatus = 'Partially Filled';
  static const connection = 'connection';
  static const orderSubmitted = 'order_submitted';
  static const orderError = 'order_error';
  static const orderReport = 'order_report';
  static const orderStatus = 'order_status';
  static const orderReportRemove = 'order_report_remove';
  static const alert = 'alert';
  static const continuous = 'continuous';
  static const subscribe = 'subscribe';
  static const unsubscribe = 'unsubscribe';
  static const orderList = 'order_list';
  static const orderAlertsUpdate = 'orderAlertsUpdate';
  // Color constants

  // Size constants
  static const int successStatus = 200;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 32.0;

  // URL constants
  static const String apiBaseUrl = 'https://api.myflutterapp.com';
}

