import '/app/app_pkg.dart';
import '/app/modules/home/views/local_widgets/trade_confirm_order.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:market/market.dart' show MarketDepthModel;

import 'appbar_right_search_tap.dart';
import 'market_dept_single_widget.dart';

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
                        const _ClineCodeWidget(),
                        AppSpace.spaceH6,
                        // শুধুমাত্র সকেটের রিয়েল-টাইম ডেটা আসলে এটি আপডেট হবে
                        GetBuilder<HomeController>(
                          id: 'trade_ticker_data',
                          builder: (tickerCon) =>
                              _BankPercentageWidget(homeController: tickerCon),
                        ),
                        AppSpace.spaceH6,
                      ],
                    ),
                  ),

                  // ==========================================
                  //  STICKY MARKET DEPTH SECTION
                  // ==========================================
                  GetBuilder<HomeController>(
                    id: 'market_depth',
                    builder: (depthCon) {
                      return SliverPersistentHeader(
                        pinned: true,
                        delegate: _MarketDepthStickyDelegate(
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
                        //  Dropdowns (Isolated ID)
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

class _ClineCodeWidget extends StatelessWidget {
  const _ClineCodeWidget();

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration = BoxDecoration(
      border: Border.all(width: 1, color: context.borderSideColor),
      borderRadius: BorderRadius.circular(4),
    );
    return GetBuilder<HomeController>(
      id: 'user_balance_update',
      builder: (homeConBalance) {
        if (homeConBalance.userBalanceData == null) return const SizedBox();
        final user = homeConBalance.userBalanceData;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  decoration: decoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client Code',
                        style: Get.textTheme.bodySmall?.copyWith(fontSize: 13),
                      ),
                      Text(
                        homeConBalance.userInfo.userDetail?.investorCode ?? "",
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpace.spaceW10,
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  decoration: decoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance',
                        style: Get.textTheme.bodySmall?.copyWith(fontSize: 13),
                      ),
                      Text(
                        'BDT ${double.parse('${user?.amount ?? 0}').toStringAsFixed(2)}',
                        maxLines: 1,
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BankPercentageWidget extends StatelessWidget {
  const _BankPercentageWidget({required this.homeController});
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: InkWell(
              onTap: () async {
                final result = await SearchHelper.open();
                if (result != null &&
                    result.orderBook != null &&
                    result.shortName != null) {
                  homeController.goBottomNabBarPage(5, result.orderBook!);
                  homeController.tradingChart();
                  homeController.tradPriceTextEditField.text =
                      (result.last?.toStringAsFixed(2) ?? '0.00');
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: homeController.marketData.fullName ?? "",
                      style: Get.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.success,
                      ),
                      children: [
                        TextSpan(
                          text:
                              ' [${homeController.marketData.shareType ?? ""}]',
                          style: TextStyle(
                            fontSize: 10,
                            color: context.textColor,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' [${homeController.marketData.marketType ?? ""}]',
                          style: TextStyle(
                            fontSize: 10,
                            color: context.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text:
                          "Vol: ${NumberFormatter.croreFormat(homeController.marketData.val)},",
                      style: Get.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: context.textColor,
                      ),
                      children: [
                        TextSpan(
                          text:
                              " Val: ${NumberFormatter.bdFormat(homeController.marketData.volume)},",
                        ),
                        TextSpan(
                          text: " Trd: ${homeController.marketData.trades} ",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpace.spaceW6,
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Open: ${homeController.marketData.open?.toStringAsFixed(1) ?? 0}",
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textColor,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: "High:",
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textColor,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  ' ${homeController.marketData.high?.toStringAsFixed(1) ?? 0}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: ColorConstants.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: "Max:",
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textColor,
                          ),
                          children: [
                            // MAGIC FIX: 'dh?.toStringAsFixed(1)Ợ' এর টাইপো মুছে সেফ কোড বসানো হয়েছে
                            TextSpan(
                              text:
                                  ' ${homeController.marketData.dh?.toStringAsFixed(1) ?? 0}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: ColorConstants.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${(homeController.marketData.last ?? 0).toStringAsFixed(1)} :Close",
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textColor,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text:
                              "${homeController.marketData.low?.toStringAsFixed(1) ?? 0}",
                          style: TextStyle(
                            color: ColorConstants.error,
                            fontSize: 11,
                          ),
                          children: const [
                            TextSpan(
                              text: ' :Low',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text:
                              "${homeController.marketData.dl?.toStringAsFixed(1) ?? 0} ",
                          style: TextStyle(
                            color: ColorConstants.error,
                            fontSize: 11,
                          ),
                          children: const [
                            TextSpan(
                              text: ' :Min',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🟢 Delegate এবং Table আগের মতোই থাকবে
class _MarketDepthStickyDelegate extends SliverPersistentHeaderDelegate {
  final HomeController homeController;
  final Color backgroundColor;

  _MarketDepthStickyDelegate({
    required this.homeController,
    required this.backgroundColor,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    if (homeController.buys.isEmpty && homeController.sells.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      color: backgroundColor,
      alignment: Alignment.topCenter,
      child: _QytPriceTableWidget(homeController: homeController),
    );
  }

  @override
  double get maxExtent {
    int buyLen = homeController.buys.length;
    int sellLen = homeController.sells.length;
    int totalMaxRows = buyLen > sellLen ? buyLen : sellLen;
    if (totalMaxRows == 0) return 0.0;
    bool showButton = totalMaxRows > 3;
    int displayRows = (showButton && !homeController.isMarketDepthExpanded)
        ? 3
        : totalMaxRows;
    double buttonHeight = showButton ? 30.0 : 0.0;
    return AppDimens.space34 + 4.0 + (displayRows * 26.0) + buttonHeight;
  }

  @override
  double get minExtent => maxExtent;

  @override
  bool shouldRebuild(covariant _MarketDepthStickyDelegate oldDelegate) => true;
}

class _QytPriceTableWidget extends StatelessWidget {
  const _QytPriceTableWidget({required this.homeController});
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    final List<MarketDepthModel> buys = homeController.buys;
    final List<MarketDepthModel> sells = homeController.sells;
    if (buys.isEmpty && sells.isEmpty) return const SizedBox.shrink();

    final int maxBuyQty = buys.fold(
      0,
      (max, e) => (e.q ?? 0) > max ? (e.q ?? 0) : max,
    );
    final int maxSellQty = sells.fold(
      0,
      (max, e) => (e.q ?? 0) > max ? (e.q ?? 0) : max,
    );
    int totalMaxRows = buys.length > sells.length ? buys.length : sells.length;
    bool showButton = totalMaxRows > 3;
    int itemLength = (showButton && !homeController.isMarketDepthExpanded)
        ? 3
        : totalMaxRows;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.space12,
                  ),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? HexColor('#223167')
                        : HexColor('#EBF2FC'),
                  ),
                  height: AppDimens.space26,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Qty",
                        style: TextStyle(
                          color: ColorConstants.blueColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Bid",
                        style: TextStyle(
                          color: ColorConstants.blueColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.space12,
                  ),
                  height: AppDimens.space26,
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? HexColor('#1F2B55')
                        : HexColor('#D3E0F3'),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Ask",
                        style: TextStyle(
                          color: ColorConstants.blueColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Qty",
                        style: TextStyle(
                          color: ColorConstants.blueColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 1),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemLength,
            itemBuilder: (context, index) {
              final buyItem = index < buys.length ? buys[index] : null;
              final sellItem = index < sells.length ? sells[index] : null;
              return SizedBox(
                height: 26,
                child: Row(
                  children: [
                    Expanded(
                      child: buyItem != null
                          ? BidRowItem(
                              model: buyItem,
                              maxQty: maxBuyQty,
                              onTap: () =>
                                  homeController.onRowTapUpdatePrice(buyItem.p),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: sellItem != null
                          ? AskRowItem(
                              model: sellItem,
                              maxQty: maxSellQty,
                              onTap: () => homeController.onRowTapUpdatePrice(
                                sellItem.p,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            },
          ),
          if (showButton)
            Material(
              color: context.isDark
                  ? HexColor('#223167').withOpacity(0.6)
                  : HexColor('#EBF2FC').withOpacity(0.8),
              child: InkWell(
                onTap: () => homeController.toggleMarketDepth(),
                child: Container(
                  height: 30,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        homeController.isMarketDepthExpanded
                            ? "Show Less"
                            : "Show More",
                        style: TextStyle(
                          color: ColorConstants.blueColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        homeController.isMarketDepthExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: ColorConstants.blueColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
