import '/app/app_pkg.dart';
import '/app/modules/trade/views/local_widgets/trade_confirm_order.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../global_widgets/appbar_right_search_tap.dart';
import 'local_widgets/trade_client_code_widget.dart';
import 'local_widgets/bank_percentage_widget.dart';
import 'local_widgets/market_depth_sticky_delegate.dart';

class TradeWidget extends StatelessWidget {
  const TradeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> quickValues = ['2', '5', '20', '100', '500', '1K'];

    // মেইন GetBuilder - শুধুমাত্র নতুন স্টক সিলেক্ট হলে পুরো পেজ রেন্ডার হবে
    return GetBuilder<HomeController>(
      id: 'trade_root',
      builder: (homeCon) {
        return Scaffold(
          drawer: const CustomDrawer(),
          appBar: CustomAppBar(
            isBackButtonIcon: true,
            backButtonOnClick: () => homeCon.changeCurrentIndex(0),
            titleText: homeCon.marketData.shortName ?? '',
            right: AppbarRightSearchTapWidget(),
          ),
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ==========================================
                  //  TOP SECTION
                  // ==========================================
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TradeClientCodeWidget(),
                        AppSpace.spaceH6,
                        // শুধুমাত্র সকেটের রিয়েল-টাইম ডেটা আসলে এটি আপডেট হবে
                        VisibleGetBuilder<HomeController>(
                          id: 'trade_ticker_data',
                          builder: (tickerCon) =>
                              BankPercentageWidget(homeController: tickerCon),
                        ),
                        AppSpace.spaceH6,
                      ],
                    ),
                  ),

                  // ==========================================
                  //  STICKY MARKET DEPTH SECTION
                  // ==========================================
                  VisibleGetBuilder<HomeController>(
                    id: 'market_depth',
                    builder: (depthCon) {
                      return SliverPersistentHeader(
                        pinned: true,
                        delegate: MarketDepthStickyDelegate(
                          homeController: depthCon,
                          backgroundColor: Get.theme.scaffoldBackgroundColor,
                        ),
                      );
                    },
                  ),

                  // ==========================================
                  //  BOTTOM FORM SECTION
                  // ==========================================
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //  Buy / Sell Tabs (Isolated ID)
                        GetBuilder<HomeController>(
                          id: 'buy_sell_tab',
                          builder: (con) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: [
                                buildBuySellTab(
                                  context,
                                  "Buy",
                                  con.buySellTabActive == SideType2.BUY,
                                  HexColor("#22C665"),
                                  () => con.setBuySellActive(SideType2.BUY),
                                ),
                                buildBuySellTab(
                                  context,
                                  "Sell",
                                  con.buySellTabActive == SideType2.SELL,
                                  HexColor("#F70042"),
                                  () => con.setBuySellActive(SideType2.SELL),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppSpace.spaceH8,
                        GetBuilder<HomeController>(
                          id: 'trade_dropdowns',
                          builder: (con) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: OrderTypeDropdownListWidget(
                                    height: AppDimens.space44,
                                    valueChanged: (String? value) {
                                      con.changeOrderType(value!);
                                    },
                                    selectedValueNotifier:
                                        ValueNotifier<String?>(
                                          con.selectOrderType,
                                        ),
                                  ),
                                ),
                                AppSpace.spaceW8,
                                Flexible(
                                  child: Container(
                                    height: AppDimens.space44,
                                    decoration: BoxDecoration(
                                      color: context.tapBg,
                                    ),
                                    child: TypeDropdownListWidget(
                                      valueChanged: (String? value) {
                                        con.changeType(value!);
                                      },
                                      value: con.selectType,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppSpace.spaceH8,

                        //  Disclosed & Validity TextFields
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimens.space15,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  height: AppDimens.space44,
                                  decoration: BoxDecoration(
                                    color: context.tapBg,
                                  ),
                                  child: TextFormField(
                                    controller:
                                        homeCon.disclosedQtyTextEditField,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      hintText: 'Disclosed Qty.',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        fontSize: 14.0,
                                        color: context.textColor.alphaSafe(
                                          0.50,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              AppSpace.spaceW8,
                              Expanded(
                                child: GetBuilder<HomeController>(
                                  id: 'trade_dropdowns',
                                  builder: (con) => Container(
                                    height: AppDimens.space44,
                                    decoration: BoxDecoration(
                                      color: context.tapBg,
                                    ),
                                    child: ValidityDropdownListWidget(
                                      height: AppDimens.space44,
                                      valueChanged: (String? value) {
                                        con.changeValidity(value!);
                                      },
                                      value: con.selectValidity,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpace.spaceH8,
                        //  Qty & Min Qty TextFields
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimens.space15,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  height: AppDimens.space40,
                                  decoration: BoxDecoration(
                                    color: context.tapBg,
                                  ),
                                  child: TextFormField(
                                    controller: homeCon.qtyTextEditField,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      hintText: 'Qty.',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        fontSize: 14.0,
                                        color: context.textColor.alphaSafe(
                                          0.50,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              AppSpace.spaceW8,
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimens.space6,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  height: AppDimens.space40,
                                  decoration: BoxDecoration(
                                    color: context.tapBg,
                                  ),
                                  child: TextFormField(
                                    controller: homeCon.minQtyTextEditField,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      hintText: 'Min Qty.',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        fontSize: 14.0,
                                        color: context.textColor.alphaSafe(
                                          0.50,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpace.spaceH8,
                        //  Quick Add Quantity Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: [
                              for (final value in quickValues)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: InkWell(
                                      onTap: () =>
                                          homeCon.updateQuantity(value),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        height: 33,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: context.borderColor,
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        AppSpace.spaceH8,

                        //  Trading Price Field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: InkWell(
                                  onTap: () => homeCon.decrementTradValue(),
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: AppDimens.space44,
                                    decoration: BoxDecoration(
                                      color: context.tapBg,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Icon(
                                        Icons.minimize,
                                        weight: 700,
                                        size: AppDimens.space20,
                                        color: context.textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              AppSpace.spaceW8,
                              Flexible(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimens.space6,
                                  ),
                                  alignment: Alignment.center,
                                  height: AppDimens.space44,
                                  decoration: BoxDecoration(
                                    color: context.tapBg,
                                  ),
                                  child: TextFormField(
                                    controller: homeCon.tradPriceTextEditField,
                                    textAlignVertical: TextAlignVertical.center,
                                    textAlign: TextAlign.center,
                                    textInputAction: TextInputAction.done,
                                    focusNode: homeCon.tradePriceFocusNode,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d?'),
                                      ),
                                    ],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    onChanged: (String value) =>
                                        homeCon.onChanged(value),
                                    decoration: const InputDecoration(
                                      isCollapsed: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 0,
                                      ),
                                      border: InputBorder.none,
                                      hintText: "0.0",
                                    ),
                                    style: Get.textTheme.titleLarge?.copyWith(
                                      fontSize: AppDimens.space16,
                                      fontWeight: FontWeight.w500,
                                      color: context.textColor,
                                    ),
                                  ),
                                ),
                              ),
                              AppSpace.spaceW8,
                              Flexible(
                                child: InkWell(
                                  onTap: () => homeCon.incrementTradValue(),
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: AppDimens.space44,
                                    decoration: BoxDecoration(
                                      color: context.tapBg,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      weight: 700,
                                      size: AppDimens.space20,
                                      color: context.textColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpace.spaceH6,

                        //  Total Value Display (Isolated ID to stop UI Lag)
                        GetBuilder<HomeController>(
                          id: 'total_amount_update',
                          builder: (con) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Value: ${NumberFormatter.bdFormat(con.totalAmount)} BDT",
                              style: Get.textTheme.bodyMedium?.copyWith(
                                fontSize: AppDimens.space16,
                                color: context.textColor,
                              ),
                            ),
                          ),
                        ),
                        AppSpace.spaceH6,

                        //  Submit Button
                        GetBuilder<HomeController>(
                          id: 'buy_sell_tab',
                          builder: (con) => CustomButton(
                            fontSize: AppDimens.space20,
                            fontWeight: FontWeight.w700,
                            height: AppDimens.space48,
                            backgroundColor:
                                con.buySellTabActive == SideType2.BUY
                                ? HexColor("#22C665")
                                : HexColor("#F70042"),
                            onPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (con.selectOrderType == null) {
                                Helpers.snackbarForErorr2(
                                  bodyText: 'Select order type',
                                );
                              } else if (con.selectType == null) {
                                Helpers.snackbarForErorr2(
                                  bodyText: 'Select type',
                                );
                              } else if (con.selectValidity == null) {
                                Helpers.snackbarForErorr2(
                                  bodyText: 'Select validity',
                                );
                              } else if (con.qtyTextEditField.text.isEmpty) {
                                Helpers.snackbarForErorr2(
                                  bodyText: 'Input qty',
                                );
                              } else if (con
                                  .tradPriceTextEditField
                                  .text
                                  .isEmpty) {
                                Helpers.snackbarForErorr2(
                                  bodyText: 'Input price',
                                );
                              } else {
                                final orderConfirmData = OrderConfirmHolder(
                                  sideType: con.buySellTabActive,
                                  marketData: con.marketData,
                                  orderType: con.selectOrderType,
                                  type: con.selectType,
                                  validity: con.selectValidity,
                                  qty: con.qtyTextEditField.text,
                                  disclosedQty:
                                      con.disclosedQtyTextEditField.text.isEmpty
                                      ? "0"
                                      : con.disclosedQtyTextEditField.text,
                                  minQty: con.minQtyTextEditField.text.isEmpty
                                      ? '0'
                                      : con.minQtyTextEditField.text,
                                  price: double.parse(
                                    con.tradPriceTextEditField.text,
                                  ),
                                );
                                Get.to(
                                  () => TradeConfirmOrders(
                                    orderConfirm: orderConfirmData,
                                  ),
                                );
                              }
                            },
                            title: con.buySellTabActive == SideType2.BUY
                                ? "Buy"
                                : "Sell",
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildBuySellTab(
    BuildContext context,
    String title,
    bool isSelected,
    Color activeColor,
    VoidCallback onTap,
  ) {
    return Expanded(
      flex: isSelected ? 3 : 2,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          alignment: Alignment.center,
          height: AppDimens.space46,
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor
                : (context.isDark
                      ? ColorConstants.tapBgDark
                      : ColorConstants.tapBgLight),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? ColorConstants.white : HexColor('#62666C'),
              fontWeight: FontWeight.w700,
              fontSize: isSelected ? AppDimens.space19 : AppDimens.space15,
            ),
          ),
        ),
      ),
    );
  }
}
