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
    update();
  }

  void onRowTapUpdatePrice(double? price) {
    if (price != null) {
      tradPriceTextEditField.text = price.toStringAsFixed(2);
    }
    update(['total_amount_update']);
  }

  void onChanged(String value) {
    tradPrice = double.tryParse(value) ?? 0.0;
    update();
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
    if (!await checkInternet()) return;

    isOrderConfirmLoading = true;
    update(['order_confirm_btn']);

    try {
      //  সেফটি চেক: যদি কোনো কারণে সকেট ডিসকানেক্ট হয়ে থাকে, তাহলে আবার কানেক্ট করে নিবে
      if (!isOrderConfirmConnected) {
        await _initializeOrderConfirmWebSocket();
        await Future.delayed(
          const Duration(milliseconds: 500),
        ); // কানেকশনের জন্য আধা সেকেন্ড অপেক্ষা
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
    } catch (e) {
      isOrderConfirmLoading = false;
      update(['order_confirm_btn']);
      printLog('❌ WebSocket connection failed: $e');
    }
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
