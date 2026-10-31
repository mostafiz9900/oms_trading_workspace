part of '../home_controller.dart';

/// Market depth for the trade screen depth panel.
mixin MarketDepthMixin on HomeState {
  // https://bnpnama.info/
  @override
  void _handleMarketDepthMessage(String message) {
    try {
      final jsonResponse = jsonDecode(message);

      if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse.containsKey('message')) {
          printLog('✅ Connected Market Depth: ${jsonResponse['message']}');
          return;
        }
        if (jsonResponse['type'] == 'heartbeat') return;

        jsonResponse.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            try {
              final depth = MarketDepthData.fromJson(value);
              buys = depth.buy; // Removed ?? [] as the model already handles it
              sells = depth.sell;
            } catch (e) {
              printLog('❌ Error parsing depth key $key: $e');
            }
          }
        });
        update(["market_depth"]);
      }
    } catch (e) {
      printLog('❌ Error parsing market depth data: $e');
    }
  }

  void toggleMarketDepth() {
    isMarketDepthExpanded = !isMarketDepthExpanded;
    update(["market_depth"]);
  }

  // Message send
  @override
  void _sendMarketDepthPayload(String type, int orderbookId) {
    final payload = {"type": type, "ob": orderbookId}; //ob orderbook
    //change for new
    printLog('SendPayload :: $payload');
    _webSocketService.sendMessage(
      AppConfig.marketDepthSocketId,
      jsonEncode(payload),
    );
  }

  @override
  Future<void> manageMarketDepth(int newOrderBookId) async {
    printLog('newOrderBookId:: $newOrderBookId');
    int oldOrderBookId =
        await StorageService.read(_selectedOrderBookKey) ?? 0;
    printLog('old order book id:: $oldOrderBookId');
    if (oldOrderBookId != newOrderBookId) {
      _sendMarketDepthPayload(AppConstants.unsubscribe, oldOrderBookId);
      _sendMarketDepthPayload(AppConstants.subscribe, newOrderBookId);
      await StorageService.save(_selectedOrderBookKey, newOrderBookId);
      await markerInfo();
    } else {
      _sendMarketDepthPayload(AppConstants.subscribe, newOrderBookId);
      await markerInfo();
    }
  }

}
