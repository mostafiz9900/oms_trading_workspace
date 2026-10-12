part of '../home_controller.dart';

/// WebSocket lifecycle: connect, route messages, reconnect, disconnect.
mixin HomeSocketMixin on HomeState {
  //new socket code start

  void _initializeAllWebSockets() {
    _initializeMarketWebSocket();
    _initializeNotificationWebSocket();
    _initializeNewsWebSocket();
    _initializeMarketDepthWebSocket();
    _initializeNewsTimeSalesWebSocket();
    printLog('All WebSockets initialized');
  }

  void _initializeSocket({
    required String socketId,
    required String url,
    required Function(String) messageHandler,
  }) {
    if (url.isEmpty || url == 'null') {
      printLog('URL not available for: $socketId');
      _socketData[socketId] = 'URL not available';
      _socketStatus[socketId] = false;
      update([socketId]);
      return;
    }

    _socketUrls[socketId] = url;
    _socketData[socketId] = 'Connecting...';
    _socketStatus[socketId] = false;

    _webSocketService.connect(
      socketId: socketId,
      url: url,
      onMessage: (message) {
        _handleSocketMessage(socketId, message, messageHandler);
      },
      onConnected: () {
        _handleSocketConnected(socketId);
      },
      onDisconnected: () {
        _handleSocketDisconnected(socketId);
      },
      onError: (error) {
        _handleSocketError2(socketId, error);
      },
    );
  }

  void _handleSocketMessage(
    String socketId,
    String message,
    Function(String) handler,
  ) {
    try {
      _socketData[socketId] = 'Connected';
      handler(message);
      update([socketId]);
    } catch (e) {
      printLog('Error handling message for $socketId: $e');
      _socketData[socketId] = 'Error processing data';
      update([socketId]);
    }
  }

  void _handleSocketConnected(String socketId) {
    _socketStatus[socketId] = true;
    _socketData[socketId] = 'Connected';
    printLog('✅ $socketId connected successfully');

    // অ্যাপ মিনিমাইজ করে আবার ওপেন করলে সকেট অটোমেটিক আগের আইটেমের ডেটা চাইবে
    if (marketData.orderBook != null) {
      if (socketId == AppConfig.marketDepthSocketId) {
        printLog(
          '🔄 Auto Re-subscribing Market Depth for: ${marketData.orderBook}',
        );
        _sendMarketDepthPayload(AppConstants.subscribe, marketData.orderBook!);
      } else if (socketId == AppConfig.newsTimeSalesSocketId) {
        printLog(
          '🔄 Auto Re-subscribing Time & Sales for: ${marketData.orderBook}',
        );
        subscribeTimeAndSales('tsm', '01', "${marketData.orderBook}");
        subscribeTimeAndSales('tsb', '02', "${marketData.orderBook}");
        subscribeTimeAndSales('news_hist', '04', "${marketData.orderBook}");
      }
    }
    update([socketId]);
  }

  void _handleSocketDisconnected(String socketId) {
    _socketStatus[socketId] = false;
    _socketData[socketId] = 'Disconnected';
    printLog('📡 $socketId disconnected (this is normal during refresh)');
    update([socketId]);
  }

  void _handleSocketError2(String socketId, dynamic error) {
    _socketStatus[socketId] = false;
    _socketData[socketId] = 'Connection error';
    printLog('⚠️ $socketId error: $error');
    update([socketId]);
  }

  // Individual WebSocket initializations
  void _initializeMarketWebSocket() async {
    printLog(AppConfig.marketUrl);
    try {
      _resetMarketState();
      _initializeFilters();
      _initializeSocket(
        socketId: AppConfig.marketSocketId,
        url: AppConfig.marketUrl,
        messageHandler: _handleMarketMessage,
      );
    } catch (e) {
      printLog('Market socket initialization error: $e');
      _scheduleReconnection();
    }
  }

  void _initializeNotificationWebSocket() {}

  void _initializeNewsWebSocket() {}

  void _initializeMarketDepthWebSocket() {
    _initializeSocket(
      socketId: AppConfig.marketDepthSocketId,
      url: AppConfig.marketDepthUrl,
      messageHandler: _handleMarketDepthMessage,
    );
  }

  void _initializeNewsTimeSalesWebSocket() {
    _initializeSocket(
      socketId: AppConfig.newsTimeSalesSocketId,
      url: AppConfig.newsAndTimeAndSalesUrl,
      messageHandler: _handleNewsTimeSalesMessage,
    );
  }

  //  ১. এই ফাংশনটি অ্যাপ ওপেন হওয়ার সাথে সাথেই কল হবে
  @override
  Future<void> _initializeOrderConfirmWebSocket() async {
    printLog('Initializing Order Confirm WebSocket...');
    var deviceId = await Helpers.getDeviceIdUuid();
    var boId = userInfo.userDetail?.boId;
    var token = await StorageService.read(StorageConstants.token);

    if (boId == null || token == null) {
      printLog('❌ Cannot connect Order Confirm Socket: missing parameters');
      return;
    }

    final wsUrl =
        '${AppConfig.socketBaseUrl}order/$boId/?token=$token&individual_id=$deviceId';
    printLog('Initializing Order Confirm Socket: $wsUrl');

    //  আপনার কমন _initializeSocket ফাংশনটি ব্যবহার করা হলো
    _initializeSocket(
      socketId: AppConfig.orderConfirmSocketId,
      url: wsUrl,
      messageHandler: _handleOrderConfirmMessage,
    );
  }

  @override
  Future<void> _initializeUserBalanceWebSocket() async {
    printLog('Initializing User Balance WebSocket...');
    var token = await StorageService.read(StorageConstants.token);
    final boId = userInfo.userDetail?.investorCode;

    if (token == null || boId == null) {
      printLog('❌ Cannot connect balance socket. Missing token or boId');
      return;
    }

    final url = '${AppConfig.socketBaseUrl}report_cash/$boId/?token=$token';
    printLog('🔗 Initializing Balance Socket: $url');

    // 🚀 আপনার কমন _initializeSocket ফাংশনটি ব্যবহার করা হলো
    _initializeSocket(
      socketId: AppConfig.userBalanceSocketId,
      url: url,
      messageHandler: _handleUserBalanceMessage,
    );
  }

  void _scheduleReconnection() {
    Future.delayed(const Duration(seconds: 5), () {
      printLog('Attempting to reconnect market socket...');
    });
  }

  void _handleNotificationMessage(String message) {
    // Process notification
    printLog('Notification: $message');
  }

  void _handleNewsMessage(String message) {
    // Process news
    printLog('News: $message');
  }

  //end market depth
  Function(String) _getMessageHandler(String socketId) {
    switch (socketId) {
      case AppConfig.marketSocketId:
        return _handleMarketMessage;
      case AppConfig.marketDepthSocketId:
        return _handleMarketDepthMessage;
      case AppConfig.indexSocketId:
        return _handleIndexMessage;
      case AppConfig.notificationSocketId:
        return _handleNotificationMessage;
      case AppConfig.newsSocketId:
        return _handleNewsMessage;
      case AppConfig.newsTimeSalesSocketId:
        return _handleNewsTimeSalesMessage;
      case AppConfig.orderConfirmSocketId: //  এটি নতুন অ্যাড হলো
        return _handleOrderConfirmMessage;
      case AppConfig.userBalanceSocketId: //  এটি নতুন অ্যাড হলো
        return _handleUserBalanceMessage;
      default:
        return (message) {};
    }
  }

  // Public API
  @override
  void sendMessage(String socketId, String message) {
    _webSocketService.sendMessage(socketId, message);
  }

  void reconnectSocket(String socketId) {}

  // Reinitialize specific socket
  void _reinitializeSocket(String socketId) {
    final url = _socketUrls[socketId];
    if (url != null) {
      printLog('🔄 Reinitializing socket: $socketId');
      // Clear existing data
      _clearSocketData(socketId);
      // Update UI to show loading
      _socketStatus[socketId] = false;
      _socketData[socketId] = 'Reconnecting...';
      update([socketId]);
      // Disconnect first
      _webSocketService.disconnect(socketId);
      // Reinitialize after short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _initializeSocket(
          socketId: socketId,
          url: url,
          messageHandler: _getMessageHandler(socketId),
        );
      });
    }
  }

  // Refresh methods for public use
  Future<void> refreshMarket() async {
    await _refreshSocket(AppConfig.marketSocketId);
    isMarket = false;
    update(['marketList']);
  }

  Future<void> refreshIndex() async {
    await _refreshSocket(AppConfig.indexSocketId);
  }

  Future<void> _refreshSocket(String socketId) async {
    printLog('🎯 Refreshing socket: $socketId');
    _reinitializeSocket(socketId);
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _clearSocketData(String socketId) {
    switch (socketId) {
      case AppConfig.marketSocketId:
        _resetMarketState();
        printLog('🧹 Cleared market data');
        break;
      case AppConfig.indexSocketId:
        indexList.clear();
        newArr = IndexModel(sn: "DSEX");
        break;
      case AppConfig.marketDepthSocketId:
        buys.clear();
        sells.clear();
        break;
      case AppConfig.newsTimeSalesSocketId:
        timeAndSales.clear();
        timeAndSalesHistory.clear();
        news.clear();
        newsSingleItem.clear();
        printLog('🧹 Cleared time & sales data');
        break;
      case AppConfig.orderConfirmSocketId:
        orderAlertsList.clear();
        break;
      // Add other socket types as needed
    }
  }

  // Check if any socket is loading (for RefreshIndicator)
  bool get isLoading {
    // _disconnectAll clears _socketStatus but keeps _socketUrls, so a missing
    // status means "not connected" (the `!` used to throw here).
    return _socketUrls.keys.any(
      (socketId) => !(_socketStatus[socketId] ?? false),
    );
  }

  // Refresh all sockets

  // Connection status checkers
  @override
  bool isSocketConnected(String socketId) => _socketStatus[socketId] ?? false;

  @override
  bool get isOrderConfirmConnected =>
      isSocketConnected(AppConfig.orderConfirmSocketId);

  // Data getters
  String getSocketData(String socketId) => _socketData[socketId] ?? '';

  void _disconnectAll() {
    for (var socketId in _socketUrls.keys) {
      _webSocketService.disconnect(socketId);
    }
    _socketData.clear();
    _socketStatus.clear();
  }

  //new socket code end
  void reconnect() {
    Future.delayed(const Duration(seconds: 3), initConnect);
  }

  void disconnect() {
    _disconnectAll();
  }

  void initConnect() async {
    zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.x,
      enablePanning: true,
    );
    tooltipBehavior = TooltipBehavior(enable: true);
    _initializeAllWebSockets();
  }
}
