part of '../home_controller.dart';

/// Orders for order_list_tab_widget: list, modify, cancel, confirmations.
mixin OrderListMixin on HomeState {
  void changeOrderTypeOrderList(String data) {
    selectOrderType = data;
    update([AppConstants.orderList]);
  }

  void changeTypeOrderList(String data) {
    selectType = data;
    update([AppConstants.orderList]);
  }

  void changeValidityOrderList(String data) {
    selectValidity = data;
    update([AppConstants.orderList]);
  }

  // =========================================================================
  // =========================================================================
  @override
  void _handleOrderConfirmMessage(String message) {
    printLog(' RAW Socket Message: $message');

    try {
      final jsonResponse = jsonDecode(message);

      //  Safe Type Casting
      final messageType = jsonResponse['message_type']?.toString();
      final dataPayload = jsonResponse['data'];
      final alertPayload = jsonResponse['alert'];

      final rawMessage = jsonResponse['message'];
      String messageText = "Unknown Error";
      if (rawMessage is List && rawMessage.isNotEmpty) {
        messageText = rawMessage[0]
            .toString(); // যদি Array হয়, তবে প্রথম এররটি নিবে
      } else if (rawMessage != null) {
        messageText = rawMessage.toString(); // যদি সাধারণ String হয়
      }

      //  DRY Principle: ব্যাকগ্রাউন্ড ইভেন্ট (connection/alert) ছাড়া বাকি সব রেসপন্সেই লোডিং অফ হবে
      if (messageType != AppConstants.connection &&
          messageType != 'connection' &&
          messageType != AppConstants.alert &&
          messageType != 'alert') {
        _endOrderConfirmLoading();
      }

      //  Switch-Case Architecture
      switch (messageType) {
        // ==========================================
        // 🟢 ১. Connection State
        // ==========================================
        case AppConstants.connection:
          debugPrint('✅ Order Socket Connected: $messageText');

          if (alertPayload is List) {
            orderAlertsList = alertPayload
                .map((item) => OrderAlertModel.fromJson(item))
                .toList();
          }

          if (dataPayload is List) {
            userOrder = UserOrderModel.fromJson(jsonResponse);
            userOrderList = dataPayload
                .map((order) => UserOrder.fromJson(order))
                .toList();
            printLog('📦 Initial Orders loaded: ${userOrderList.length}');
          }

          isLoadingUserOrder = false;
          update([AppConstants.orderList, AppConstants.orderAlertsUpdate]);
          break;

        // ==========================================
        // 🟢 ২. Order Submitted Success
        // ==========================================
        case AppConstants.orderSubmitted:
          printLog("✅ Order Success: $messageText");

          Get.snackbar(
            "Success",
            messageText.isNotEmpty
                ? messageText
                : "Action completed successfully.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          clearAllFields();
          currentIndex = 4;
          currentTabIndexPortfolio = 1;
          update();
          if (Get.currentRoute != Routes.HOME) {
            printLog('🔄 Redirecting to Home Page from: ${Get.currentRoute}');
            Get.offNamed(Routes.HOME);
          } else {
            printLog('🏠 User is already on Home Page. Skipping navigation.');
          }
          break;
        // ==========================================
        // ==========================================
        case AppConstants.orderError:
          printLog("❌ Order Error: $messageText");
          Get.snackbar(
            "Order Failed",
            messageText,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          update();
          break;

        // ==========================================
        // 🗑️ ৪. Order Report Remove
        // ==========================================
        case AppConstants.orderReportRemove:
          if (messageText != "Unknown Error" && messageText.isNotEmpty) {
            Get.snackbar(
              "Order Removed",
              messageText,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
          if (dataPayload is Map<String, dynamic>) {
            _removeOrderFromList(UserOrder.fromJson(dataPayload));
          }
          update([AppConstants.orderList]);
          break;

        // ==========================================
        // 🔔 ৫. Single Alert
        // ==========================================
        case AppConstants.alert:
          if (dataPayload is Map<String, dynamic>) {
            orderAlertsList.insert(0, OrderAlertModel.fromJson(dataPayload));
            printLog('🔔 New Single Alert Added: ${dataPayload['status']}');
          }
          update([AppConstants.orderAlertsUpdate]);
          break;

        // ==========================================
        // ==========================================
        case AppConstants.orderReport:
          if (dataPayload is Map<String, dynamic>) {
            final rejectionReason = dataPayload['rejectionReason']?.toString();
            if (rejectionReason != null && rejectionReason.isNotEmpty) {
              Get.snackbar(
                "Order Rejected",
                rejectionReason,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
            _updateOrInsertOrder(UserOrder.fromJson(dataPayload));
          }
          update([AppConstants.orderList]);
          break;

        // ==========================================
        // 📊 ৭. Order Status
        // ==========================================
        case AppConstants.orderStatus: // অথবা case 'order_status':
          printLog("✅ orderStatus Success Received");

          if (dataPayload is Map<String, dynamic>) {
            // এরর মেসেজ থাকলে দেখাবে
            final rejectionReason = dataPayload['rejectionReason']?.toString();
            if (rejectionReason != null && rejectionReason.isNotEmpty) {
              Get.snackbar(
                "Status Error",
                rejectionReason,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }

            // সাকসেস হলে ডিটেইলস পেজে পাঠাবে
            final execType =
                dataPayload['execType'] ?? dataPayload['exec_type'];
            if (execType == 'ORDER_STATUS' || execType != null) {
              orderStatusDetails = OrderStatusDetailsModel.fromJson(
                dataPayload,
              );

              clearAllFields(); //  আপনার রিকোয়ারমেন্ট অনুযায়ী ফিল্ড ক্লিয়ার করা হলো
              Get.to(
                () => OrderStatusDetailsView(order: orderStatusDetails),
                fullscreenDialog: true,
              );
            }
          }
          update([AppConstants.orderList]);
          break;

        // ==========================================
        // 🚫 ৮. Session Reject
        // ==========================================
        case 'session_reject':
          String rejectMsg = (dataPayload is Map<String, dynamic>)
              ? (dataPayload['reason']?.toString() ?? "Session Rejected")
              : "Session Rejected";
          Get.snackbar(
            "Session Error",
            rejectMsg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          update();
          break;

        // ==========================================
        // ⚠️ Default / Unknown Type
        // ==========================================
        default:
          printLog('⚠️ Unknown Message Type received: $messageType');
          break;
      }
    } catch (e) {
      _orderResponseTimer?.cancel();
      isOrderConfirmLoading = false;
      isLoadingUserOrder = false;
      update([AppConstants.orderList, 'order_confirm_btn']);
      printLog("❌ Error parsing socket message: $e");
    }
  }

  // =========================================================================
  // =========================================================================

  void _removeOrderFromList(UserOrder singleData) {
    final clientId = singleData.clientOrderId?.trim();
    if (clientId == null || clientId.isEmpty) return;

    // Remove from main model safely
    if (userOrder.data != null) {
      userOrder.data!.removeWhere(
        (element) => element.clientOrderId?.trim() == clientId,
      );
    }
    // Remove from active list
    userOrderList.removeWhere((e) => e.clientOrderId?.trim() == clientId);
  }

  void _updateOrInsertOrder(UserOrder singleData) {
    final clientId = singleData.clientOrderId?.trim();
    if (clientId == null || clientId.isEmpty) return;

    //  ১. Update Main Model (userOrder) efficiently
    final currentData = userOrder.data ?? [];
    final modelIndex = currentData.indexWhere(
      (e) => e.clientOrderId?.trim() == clientId,
    );

    if (modelIndex != -1) {
      // Create a mutable copy, update it, and pass it to copyWith (More efficient than .map)
      final newData = List<UserOrder>.from(currentData);
      newData[modelIndex] = singleData;
      userOrder = userOrder.copyWith(data: newData);
    } else {
      userOrder = userOrder.copyWith(data: [singleData, ...currentData]);
    }

    final listIndex = userOrderList.indexWhere(
      (e) => e.clientOrderId?.trim() == clientId,
    );
    if (listIndex != -1) {
      userOrderList[listIndex] = singleData;
    } else {
      userOrderList.insert(0, singleData); // New orders go to the top
    }
  }

  //  আপনার ডুপ্লিকেট সকেট মুছে ফেলা হলো। এখন এটি শুধু কমন সকেটটি কানেক্ট করবে।
  @override
  Future<void> getUserOrder() async {
    printLog('Fetching User Orders...');
    isLoadingUserOrder = true;
    update([AppConstants.orderList]);

    // যদি আগে থেকে কানেক্ট করা না থাকে, তবে কানেকশন তৈরি করবে
    if (!isOrderConfirmConnected) {
      await _initializeOrderConfirmWebSocket();
    } else {
      isLoadingUserOrder = false;
      update([AppConstants.orderList]);
    }
  }

  void orderDuplicateSubmitted(ActionsType action, {UserOrder? order}) async {
    //  ১. ইন্টারনেট চেক
    if (!await checkInternet()) return;

    //  ২. অর্ডার ডেটা ভ্যালিডেশন
    if (order == null) {
      printLog(
        '❌ Error: Cannot duplicate order because original order data is missing.',
      );
      return;
    }

    var clientCode = userInfo.userDetail?.investorCode ?? '';
    final safeOrderBookId = order.orderBookId ?? 0;
    final marketFindByOrderBookId = getMarketByOrderBookId(safeOrderBookId);

    //  ৩. মার্কেট ডেটা ভ্যালিডেশন
    if (marketFindByOrderBookId.orderBook == null ||
        marketFindByOrderBookId.shortName == null) {
      printLog(
        '❌ Error: Market data not found for OrderBookId: $safeOrderBookId',
      );
      Get.snackbar(
        "Invalid Market Data",
        "Market data not found for this order. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return; // অবৈধ ডেটা সকেটে পাঠানো বন্ধ করা হলো
    }

    // .parse এর বদলে .tryParse ব্যবহার করা হয়েছে, যাতে null/ফাঁকা আসলে ক্র্যাশ না করে 0.0 বসিয়ে দেয়।
    var price = double.tryParse('${order.limit}') ?? 0.0;
    var qty = int.tryParse('${order.sentQty}') ?? 0;

    OrderConfirmRequest requestBody = OrderConfirmRequest(
      action: actionValues[action],
      traderPk: userInfo.userDetail?.traderId,
      traderId: userInfo.userDetail?.traderCode,
      boId: "${userInfo.userDetail?.boId}",
      clientCode: clientCode,
      branchId: userInfo.userDetail?.branchId,
      userId: userInfo.id,
      orderType: order.ordType?.toUpperCase(),
      qty: qty,
      price: price,
      symbol: marketFindByOrderBookId.shortName,
      side: order.side, // 'BUY':'SELL',
      isin: marketFindByOrderBookId.isinCode,
      assetClass: marketFindByOrderBookId.instrumentType,
      securityCode: marketFindByOrderBookId.ticker,
      orderBookId: marketFindByOrderBookId.orderBook,
      board: marketFindByOrderBookId.board,
      session: currentSession.value,
      category: marketFindByOrderBookId.shareType?.toUpperCase(),
      marketType: marketFindByOrderBookId.marketType,
      group: marketFindByOrderBookId.group?.toUpperCase(),
      timeInForce: "0",
      displayQty: order.displayQty == 0 ? null : order.displayQty,
      minQty: order.minQty == 0 ? null : order.minQty,
    );

    final jsonRequest = jsonEncode(requestBody.toJson());
    printWrapped('📤 Sending duplicate order: $jsonRequest');

    try {
      //  ৫. Socket Connection Check & Auto-Reconnect
      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        printLog('🔌 Order Socket is disconnected. Reconnecting...');
        await _initializeOrderConfirmWebSocket();

        // রিকানেক্ট হওয়ার জন্য ১ সেকেন্ড অপেক্ষা
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        Get.snackbar(
          "Connection Failed",
          "Unable to connect to the trading server. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return; // ডেটা সেন্ড করবে না
      }

      //  ৭. Send Data via Common Socket
      sendMessage(AppConfig.orderConfirmSocketId, jsonRequest);
      printLog('✅ Duplicate order request sent successfully.');

      currentTabIndexPortfolio = 1;
      update([AppConstants.orderList]);

      // অপশনাল: ইউজারকে একটি সাকসেস স্নাইকবার দেখানো যেতে পারে
    } catch (e) {
      printLog('❌ Unknown exception during duplicate order: $e');
      Get.snackbar(
        "Submission Failed",
        "Failed to send duplicate order. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    update();
  }

  void orderConfirmSubmittedReplaceOrder(
    SideType2 sideType,
    ActionsType action, {
    UserOrder? order,
  }) async {
    //  1. SAFEGUARD: Check internet
    if (!await checkInternet()) return;

    //  2. SAFEGUARD: A replace order MUST have an existing order to replace.
    if (order == null || order.orderId == null || order.orderId!.isEmpty) {
      printLog(
        '❌ Error: Cannot replace order because original order data is missing.',
      );
      Get.snackbar(
        "Invalid Order",
        "Cannot replace this order because original data is missing.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    printLog('🔄 Initiating Replace Order Request...');

    //  3. SAFEGUARD: Handle orderBookId safely.
    final safeOrderBookId = order.orderBookId ?? 0;
    final marketFindByOrderBookId = getMarketByOrderBookId(safeOrderBookId);

    //  4. SAFEGUARD: Check if market data was actually found
    if (marketFindByOrderBookId.orderBook == null ||
        marketFindByOrderBookId.shortName == null) {
      printLog(
        '❌ Error: Market data not found for OrderBookId: $safeOrderBookId',
      );
      Get.snackbar(
        "Invalid Market Data",
        "Market data not found for this order. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return; // Stop execution here. Do not send invalid data to the socket!
    }

    final userDetail = userInfo.userDetail;
    final traderCode = userDetail?.traderCode ?? '';
    final boId = userDetail?.boId ?? '';
    final clientCode = userDetail?.investorCode ?? '';

    //  5. SAFEGUARD: Ensure price and qty are parsed safely.
    final price = double.tryParse(tradPriceTextEditField.text) ?? 0.0;
    final qty = int.tryParse(qtyTextEditField.text) ?? 0;

    // Fetch the reference price safely
    final marketPrice = marketFindByOrderBookId.reference ?? 0.0;

    final sendPrice =
        (selectOrderType?.toUpperCase() != 'LIMIT' && sideType == SideType2.BUY)
        ? marketPrice
        : price;

    final requestBody = OrderConfirmRequest(
      action: actionValues[action],
      traderPk: userDetail?.traderId,
      traderId: traderCode,
      boId: boId,
      clientCode: clientCode,
      orderId: order.orderId ?? '',
      clientOrderId: order.clientOrderId ?? '',
      branchId: userDetail?.branchId,
      userId: userInfo.id,
      orderType: selectOrderType?.toUpperCase(),
      qty: qty,
      price: sendPrice,
      symbol: marketFindByOrderBookId.shortName,
      side: sideTypeEnumMap[sideType],
      isin: marketFindByOrderBookId.isinCode,
      assetClass: marketFindByOrderBookId.instrumentType,
      securityCode: marketFindByOrderBookId.ticker,
      orderBookId: marketFindByOrderBookId.orderBook,
      board: marketFindByOrderBookId.board,
      session: currentSession.value,
      category: marketFindByOrderBookId.shareType?.toUpperCase(),
      marketType: marketFindByOrderBookId.marketType,
      group: marketFindByOrderBookId.group?.toUpperCase(),
      timeInForce: "0",
      displayQty: _parseNullableInt(disclosedQtyTextEditField.text),
      minQty: _parseNullableInt(minQtyTextEditField.text),
    );

    final jsonRequest = jsonEncode(requestBody.toJsonReplaceOrder());
    printWrapped('📤 Sending replace order: $jsonRequest');

    try {
      //  6. SAFEGUARD: Socket Connection Check & Auto-Reconnect
      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        printLog('🔌 Order Socket is disconnected. Reconnecting...');
        await _initializeOrderConfirmWebSocket();

        // রিকানেক্ট হওয়ার জন্য ১ সেকেন্ড অপেক্ষা
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        Get.snackbar(
          "Connection Failed",
          "Unable to connect to the trading server. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return; // ডেটা সেন্ড করবে না
      }

      //  8. Send Data via Common Socket
      sendMessage(AppConfig.orderConfirmSocketId, jsonRequest);
      printLog('✅ Replace order request sent successfully.');

      // Only update UI if the send attempt didn't throw an error
      currentTabIndexPortfolio = 1;
      update([AppConstants.orderList]);

    } catch (e) {
      printLog('❌ WebSocket send failed: $e');
      Get.snackbar(
        "Modification Failed",
        "Failed to send order modification. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void orderCancelSubmitted(String action, UserOrder order) async {
    //  ১. ইন্টারনেট চেক
    if (!await checkInternet()) return;

    if (order.orderId == null || order.orderId!.isEmpty) {
      printLog('❌ Error: Cannot cancel order because Order ID is missing.');
      Get.snackbar(
        "Invalid Order",
        "Cannot cancel this order because the Order ID is missing.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    printLog('🔄 Initiating Order Cancel Request...');

    var clientCode = userInfo.userDetail?.investorCode ?? '';

    //  ৩. Symbol (shortName) বের করা হচ্ছে
    final shortName =
        marketListAll
            .firstWhereOrNull((market) => market.orderBook == order.orderBookId)
            ?.shortName ??
        '';

    if (shortName.isEmpty) {
      printLog(
        '⚠️ Warning: ShortName (Symbol) not found for OrderBookId: ${order.orderBookId}',
      );
    }

    UpdateOrderHolder requestBody = UpdateOrderHolder(
      action: action,
      traderId: userInfo.userDetail?.traderCode,
      boId: "${userInfo.userDetail?.boId}",
      clientCode: clientCode,
      userId: userInfo.id,
      symbol: shortName,
      side: order.side ?? '', // Safe null check
      orderId: order.orderId ?? '',
      origClientOrderId: order.clientOrderId ?? "",
      clientOrderId: "", // ক্যান্সেলের সময় নতুন ক্লায়েন্ট আইডি লাগে না
      session: currentSession.value,
    );

    final jsonRequest = jsonEncode(requestBody.toJson());
    printWrapped('📤 Sending Cancel Order: $jsonRequest');

    try {
      //  ৪. Socket Connection Check & Auto-Reconnect
      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        printLog('🔌 Order Socket is disconnected. Reconnecting...');
        await _initializeOrderConfirmWebSocket();

        // রিকানেক্ট হওয়ার জন্য ১ সেকেন্ড অপেক্ষা
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        Get.snackbar(
          "Connection Failed",
          "Unable to connect to the trading server. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return; // ডেটা সেন্ড করবে না
      }

      //  ৬. Send Data via Common Socket
      sendMessage(AppConfig.orderConfirmSocketId, jsonRequest);
      printLog('✅ Cancel order request sent successfully.');

      // 🔄 UI Update
      currentTabIndexPortfolio = 1;
      update([AppConstants.orderList]);

      // অপশনাল: ইউজারকে একটি ওয়ার্নিং/সাকসেস স্নাইকবার দেখানো যেতে পারে
    } catch (e) {
      printLog('❌ Unknown exception during order cancel: $e');
      Get.snackbar(
        "Cancellation Failed",
        "Failed to send cancel request. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void orderStatusChangeConfirmSubmitted(
    ActionsType action,
    UserOrder order,
  ) async {
    //  ১. ইন্টারনেট চেক
    if (!await checkInternet()) return;

    printLog('🔄 Initiating Order Status Change Request...');

    var traderCode = userInfo.userDetail?.traderCode ?? '';
    var boId = userInfo.userDetail?.boId ?? '';

    //  ২. Symbol (shortName) বের করা হচ্ছে
    final shortName =
        marketListAll
            .firstWhereOrNull((market) => market.orderBook == order.orderBookId)
            ?.shortName ??
        '';

    if (shortName.isEmpty) {
      printLog(
        '⚠️ Warning: ShortName (Symbol) not found for OrderBookId: ${order.orderBookId}',
      );
    }

    //  ৩. Request Body তৈরি
    var requestBody = {
      'action': actionValues[action],
      'trader_id': traderCode,
      'request_sender': boId,
      'client_order_id': order.clientOrderId,
      'symbol': shortName,
      'side': order.side,
      'session': "continuous",
    };

    final jsonRequest = jsonEncode(requestBody);
    printWrapped('📤 Sending Status Change Request: $jsonRequest');

    try {
      //  ৪. Socket Connection Check & Auto-Reconnect
      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        printLog('🔌 Order Socket is disconnected. Reconnecting...');
        await _initializeOrderConfirmWebSocket();

        // রিকানেক্ট হওয়ার জন্য ১ সেকেন্ড অপেক্ষা
        await Future.delayed(const Duration(seconds: 1));
      }

      //  ৫. Final Verification
      if (!isSocketConnected(AppConfig.orderConfirmSocketId)) {
        Get.snackbar(
          "Connection Failed",
          "Unable to connect to the trading server. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return; // ডেটা সেন্ড করবে না
      }

      sendMessage(AppConfig.orderConfirmSocketId, jsonRequest);
      printLog('✅ Order status change request sent successfully.');

      // 🔄 UI Update
      currentTabIndexPortfolio = 1;
      update([AppConstants.orderList]);
    } catch (e) {
      printLog('❌ WebSocket connection failed: $e');
      Get.snackbar(
        "Request Failed",
        "Failed to send status change request. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Change instrument filter and refresh UI
  void changeInstrument(String instrument) {
    selectedInstrument = instrument;
    // Ekhane obossoi orderList tag diye update dite hobe, taholei list re-render hobe
    update([AppConstants.orderList]);
  }

}
