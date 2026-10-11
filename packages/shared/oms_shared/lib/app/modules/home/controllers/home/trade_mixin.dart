part of '../home_controller.dart';

/// Order entry for trade_widget: order type, price, quantity, submit.
mixin TradeMixin on HomeState {
  void setBuySellActive(SideType2 value) {
    buySellTabActive = value;
    update();
    update(['buy_sell_tab']);
  }

  void changeOrderType(String data) {
    selectOrderType = data;
    update(['trade_dropdowns']);
  }

  void changeType(String data) {
    selectType = data;
    update(['trade_dropdowns']);
  }

  void changeValidity(String data) {
    selectValidity = data;
    update(['trade_dropdowns']);
  }

  // optionally explicit setters

  /// Call ONCE when page opens (or when marketData arrives)
  void setInitialPrice(double? reference) {
    _priceCents = ((reference ?? 0.0) * 100).round();
    _updateText();
  }

  void incrementTradValue() {
    _syncFromText();
    _priceCents += 10; // +0.10
    _updateText();
  }

  void decrementTradValue() {
    _syncFromText();
    _priceCents = (_priceCents - 10).clamp(0, 1 << 31); // -0.10, not below 0
    _updateText();
  }

  /// Read current text safely into cents
  void _syncFromText() {
    final raw = tradPriceTextEditField.text.trim();
    final parsed = double.tryParse(raw.replaceAll(',', '')) ?? 0.0;
    _priceCents = (parsed * 100).round();
  }

  /// Write back as 2 decimals and keep cursor at end
  void _updateText() {
    final newText = (_priceCents / 100).toStringAsFixed(2);
    if (tradPriceTextEditField.text != newText) {
      tradPriceTextEditField.value = tradPriceTextEditField.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
        composing: TextRange.empty,
      );
    }
    // No full update(): the field repaints itself and its listener
    // (calculateTotal) refreshes 'total_amount_update'. A bare update()
    // here rebuilt every home tab on each +/- tap.
  }

  void onRowTapUpdatePrice(double? price) {
    if (price != null) {
      tradPriceTextEditField.text = price.toStringAsFixed(2);
    }
    update(['total_amount_update']);
  }

  void onChanged(String value) {
    tradPrice = double.tryParse(value) ?? 0.0;
    // No full update() per keystroke; only the total depends on the price.
    calculateTotal();
  }

  void calculateTotal() {
    double qty = double.tryParse(qtyTextEditField.text) ?? 0.0;
    double price = double.tryParse(tradPriceTextEditField.text) ?? 0.0;
    totalAmount = qty * price;
    update(['total_amount_update']);
  }

  void updateQuantity(String value) {
    double currentValue = double.tryParse(qtyTextEditField.text) ?? 0.0;

    double newValue = (value == '1K')
        ? 1000.0
        : (double.tryParse(value) ?? 0.0);

    // ৩. যোগফল বের করা
    double total = currentValue + newValue;

    // যদি আপনার কোয়ান্টিটি দশমিক হতে পারে তবে .toInt() বাদ দিবেন
    qtyTextEditField.text = total.toInt().toString();

    // ৫. কার্সার শেষে রাখা
    qtyTextEditField.selection = TextSelection.collapsed(
      offset: qtyTextEditField.text.length,
    );

    // আপনার লিসেনার অটোমেটিক calculateTotal() কল করবে এবং টোটাল আপডেট হবে।
  }

  void showBuySellDialog(BuildContext ctx, int orderBookId) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text("Choose Action"),
        content: const Text("Do you want to Buy or Sell?"),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor("#22C665"),
            ),
            onPressed: () {
              Get.back();
              setBuySellActive(SideType2.BUY);
              goBottomNabBarPage(5, orderBookId);
            },
            child: Text(
              "Buy",
              style: Get.textTheme.bodyLarge!.copyWith(
                color: ColorConstants.white,
              ),
            ),
          ),
          AppSpace.spaceW10,
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor("#F70042"),
            ),
            onPressed: () {
              Get.back();
              setBuySellActive(SideType2.SELL);
              goBottomNabBarPage(5, orderBookId);
            },
            child: Text(
              "Sell",
              style: Get.textTheme.bodyLarge!.copyWith(
                color: ColorConstants.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void orderConfirmSubmitted(
    SideType2 sideType,
    ActionsType action, {
    UserOrder? order,
  }) async {
    // Set the in-flight flag before any await, so a second tap cannot send a
    // second order while the first one is still being prepared.
    if (isOrderConfirmLoading) return;
    isOrderConfirmLoading = true;
    update(['order_confirm_btn']);

    if (!await checkInternet()) {
      _endOrderConfirmLoading();
      return;
    }

    try {
      //  সেফটি চেক: যদি কোনো কারণে সকেট ডিসকানেক্ট হয়ে থাকে, তাহলে আবার কানেক্ট করে নিবে
      if (!isOrderConfirmConnected) {
        await _initializeOrderConfirmWebSocket();
        await _waitForOrderSocket();
      }

      // A send on a closed socket is dropped silently; tell the user instead.
      if (!isOrderConfirmConnected) {
        _endOrderConfirmLoading();
        Get.snackbar(
          "Connection Failed",
          "Unable to connect to the trading server. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      var marketPrice = marketData.reference;
      var price = double.tryParse(tradPriceTextEditField.text) ?? 0.0;
      var qty = int.tryParse(qtyTextEditField.text) ?? 0;

      final sendPrice =
          (selectOrderType?.toUpperCase() != 'LIMIT' &&
              sideType == SideType2.BUY)
          ? marketPrice
          : price;

      final reqBody = _buildReqBody(action, sideType, qty, sendPrice);
      var actionData = action == ActionsType.ORDER
          ? reqBody.toJson()
          : reqBody.toJsonReplaceOrder();

      printLog('📤 Sending Order Data: ${jsonEncode(actionData)}');
      sendMessage(AppConfig.orderConfirmSocketId, jsonEncode(actionData));
      _startOrderResponseTimeout();
    } catch (e) {
      _endOrderConfirmLoading();
      printLog('❌ WebSocket connection failed: $e');
    }
  }

  /// Waits up to 3 s for the order socket to report connected.
  Future<void> _waitForOrderSocket() async {
    for (var i = 0; i < 30 && !isOrderConfirmConnected; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// If the server never answers, release the button and tell the user to
  /// check the order list. The order is never re-sent automatically.
  void _startOrderResponseTimeout() {
    _orderResponseTimer?.cancel();
    _orderResponseTimer = Timer(const Duration(seconds: 15), () {
      if (!isOrderConfirmLoading) return;
      _endOrderConfirmLoading();
      Get.snackbar(
        "No Response",
        "Order status is unknown. Please check the order list before placing it again.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    });
  }

  @override
  int? _parseNullableInt(String value) {
    if (value.isEmpty || value == '0') return null;
    return int.tryParse(value);
  }

  OrderConfirmRequest _buildReqBody(
    ActionsType type,
    SideType2? side,
    dynamic qty,
    dynamic sendPrice,
  ) {
    var traderCode = userInfo.userDetail?.traderCode;
    var boId = "${userInfo.userDetail?.boId}";
    var clientCode = userInfo.userDetail?.investorCode;
    var traderId = userInfo.userDetail?.traderId;
    switch (type) {
      case ActionsType.ORDER:
        return OrderConfirmRequest(
          action: actionValues[type],
          traderPk: traderId,
          traderId: traderCode,
          boId: boId,
          clientCode: '$clientCode',
          branchId: userInfo.userDetail?.branchId,
          userId: userInfo.id,
          orderType: selectOrderType?.toUpperCase(),
          qty: int.parse(qtyTextEditField.text),
          price: double.parse(tradPriceTextEditField.text),
          symbol: marketData.shortName,
          side: sideTypeEnumMap[side], // 'BUY':'SELL',
          isin: marketData.isinCode,
          assetClass: marketData.instrumentType,
          securityCode: marketData.ticker,
          orderBookId: marketData.orderBook,
          board: marketData.board,
          session: currentSession.value,
          category: marketData.shareType?.toUpperCase(),
          marketType: marketData.marketType,
          group: marketData.group?.toUpperCase(),
          timeInForce: "0",
          displayQty:
              disclosedQtyTextEditField.text == "" ||
                  disclosedQtyTextEditField.text == '0'
              ? null
              : int.parse(disclosedQtyTextEditField.text),
          minQty:
              minQtyTextEditField.text == '' || minQtyTextEditField.text == '0'
              ? null
              : int.parse(minQtyTextEditField.text),
        );
      case ActionsType.REPLACE_ORDER:
        return OrderConfirmRequest(
          action: actionValues[type],
          traderPk: userInfo.userDetail?.traderId,
          traderId: userInfo.userDetail?.traderCode,
          boId: "${userInfo.userDetail?.boId}",
          clientCode: '$clientCode',
          branchId: userInfo.userDetail?.branchId,
          userId: userInfo.id,
          orderType: selectOrderType?.toUpperCase(),
          qty: int.parse(qtyTextEditField.text),
          price: double.parse(tradPriceTextEditField.text),
          symbol: marketData.shortName,
          side: sideTypeEnumMap[side], // 'BUY':'SELL',
          isin: marketData.isinCode,
          assetClass: marketData.instrumentType,
          securityCode: marketData.ticker,
          orderBookId: marketData.orderBook,
          board: marketData.board,
          session: currentSession.value,
          category: marketData.shareType?.toUpperCase(),
          marketType: marketData.marketType,
          group: marketData.group?.toUpperCase(),
          timeInForce: "0",
          displayQty:
              disclosedQtyTextEditField.text == "" ||
                  disclosedQtyTextEditField.text == '0'
              ? null
              : int.parse(disclosedQtyTextEditField.text),
          minQty:
              minQtyTextEditField.text == '' || minQtyTextEditField.text == '0'
              ? null
              : int.parse(minQtyTextEditField.text),
        );
      case ActionsType.CANCEL_ORDER:
        return OrderConfirmRequest();
      case ActionsType.ORDER_STATUS:
        return OrderConfirmRequest();
    }
  }

  @override
  void clearAllFields() {
    tradPriceTextEditField.clear();
    disclosedQtyTextEditField.clear();
    qtyTextEditField.clear();
    minQtyTextEditField.clear();
  }

}
