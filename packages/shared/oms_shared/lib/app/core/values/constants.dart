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

class EmptyMessages {
  // Generic
  static const nothingHere = "Nothing here yet";
  static const noData = "No data available";
  static const currentlyUnavailable = "Currently unavailable.";
  static const tryAgainLater = "Please try again later.";
  static const checkBackSoon = "Check back again soon.";

  // Stocks
  static const noStocks = "No stocks available";
  static const noWatchlist = "Your watchlist is empty";
  static const noFavorites = "You haven’t added any favorites yet";
  static const noMovers = "No top movers to display right now";
  static const noPortfolio = "Your portfolio is empty";
  static const noHoldings = "No holdings in your account";

  // Market Data
  static const noMarketData = "Market data is not available";
  static const noCharts = "No chart data available";
  static const noIndices = "No indices data available";
  static const marketClosed = "Market is closed";
  static const noTradingActivity = "No trading activity yet";

  // Orders & Transactions
  static const noOrders = "You haven’t placed any orders yet";
  static const noActiveOrders = "No active orders at the moment";
  static const noOrderHistory = "No past orders found";
  static const noTransactions = "No transactions recorded";
  static const noPendingOrders = "No pending orders";

  // Search
  static const noSearchResults = "No matching stocks found";
  static const refineSearch = "Try a different ticker or company name";
  static const emptySearch = "Search results will appear here";

  // News & Updates
  static const noNews = "No news available";
  static const noUpdates = "No updates to show";
  static const noAlerts = "You have no alerts set up";
  static const noNotifications = "No notifications at the moment";

  // Fun / Friendly
  static const allClear = "All clear 🚀";
  static const marketQuiet = "The market is quiet 💤";
  static const ghostTown = "Looks like a ghost town here 👻";
  static const emptyChart = "The chart is empty 📉";
}
