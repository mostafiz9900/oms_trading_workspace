import 'package:flutter/material.dart';
import 'package:market/market.dart' show MarketDepthModel;
import 'package:get/get.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../../../app_pkg.dart';
import 'search_dialog_widger.dart';

class MarketDepthTabWidget extends StatelessWidget {
  const MarketDepthTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSpace.spaceH10,
        const Expanded(child: _CustomTabWidget()),
      ],
    );
  }
}

class _CustomTabWidget extends StatelessWidget {
  const _CustomTabWidget();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: context.tapBg,
            height: 40,
            child: TabBar(
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: context.buttonColor,
              unselectedLabelColor: context.textColor,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              indicatorColor: context.buttonColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Text("Mini View")),
                Tab(icon: Text("Depth View")),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(children: [_MiniTabWidget(), _DepthTabWidget()]),
          ),
        ],
      ),
    );
  }
}

class _MiniTabWidget extends StatelessWidget {
  const _MiniTabWidget();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'market_depth',
      builder: (homeCon) {
        return Column(
          crossAxisAlignment: .start,
          mainAxisAlignment: .start,
          children: [
            AppSpace.spaceH4,
            _TextWightButtonWidget(homeController: homeCon),
            _TotalQtyWidget(homeController: homeCon),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    padding: const .symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: context.tapBg),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('Quantity', textAlign: TextAlign.center),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Bid', textAlign: TextAlign.center),
                        ),
                        // Expanded(
                        //     flex: 3,
                        //     child: Text(
                        //       'Ask',
                        //       textAlign: TextAlign.center,
                        //     )),
                        // Expanded(
                        //     flex: 2,
                        //     child: Text(
                        //       'Quantity',
                        //       textAlign: TextAlign.center,
                        //     )),
                      ],
                    ),
                  ),
                ),
                AppSpace.spaceW8,
                Expanded(
                  child: Container(
                    height: 45,
                    padding: const .symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: context.tapBg),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text('Ask', textAlign: TextAlign.center),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('Quantity', textAlign: TextAlign.center),
                        ),

                        // Expanded(
                        //     flex: 3,
                        //     child: Text(
                        //       'Ask',
                        //       textAlign: TextAlign.center,
                        //     )),
                        // Expanded(
                        //     flex: 2,
                        //     child: Text(
                        //       'Quantity',
                        //       textAlign: TextAlign.center,
                        //     )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            AppSpace.spaceH10,
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: homeCon.buys.length,
                      itemBuilder: (context, index) {
                        // MarketOrderModel? model = homeCon.marketData.buyMarket?.elementAt(index);
                        MarketDepthModel? model = homeCon.buys.elementAt(index);
                        return Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                NumberFormatter.bdFormatInt(
                                  int.parse('${model.q ?? 0}'),
                                ),
                                textAlign: TextAlign.center,
                                style: Get.textTheme.bodyMedium?.copyWith(
                                  color: ColorConstants.success,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const .symmetric(
                                  horizontal: 2,
                                  vertical: 10,
                                ),
                                color: context.isDark
                                    ? hexToColor('#133923')
                                    : hexToColor('#E6FFF0'),
                                child: Text(
                                  '${model.p ?? 0}',
                                  textAlign: TextAlign.center,
                                  style: Get.textTheme.bodyMedium?.copyWith(
                                    color: ColorConstants.success,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: homeCon.sells.length,
                      itemBuilder: (context, index) {
                        // MarketOrderModel? model = homeCon.marketData.sellMarket?.elementAt(index);
                        MarketDepthModel? model = homeCon.sells.elementAt(
                          index,
                        );
                        return Row(
                          children: [
                            AppSpace.spaceW4,
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const .symmetric(
                                  horizontal: 2,
                                  vertical: 10,
                                ),
                                color: context.isDark
                                    ? hexToColor('#3F131F')
                                    : hexToColor('#FADDE4'),
                                child: Text(
                                  '${model.p?.toStringAsFixed(2) ?? 0.0}',
                                  textAlign: TextAlign.center,
                                  style: Get.textTheme.bodyMedium?.copyWith(
                                    color: ColorConstants.error,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const .symmetric(
                                  horizontal: 2,
                                  vertical: 10,
                                ),
                                // color: hexToColor('#FADDE4'),
                                child: Text(
                                  NumberFormatter.bdFormatInt(
                                    int.parse('${model.q ?? 0}'),
                                  ),
                                  textAlign: TextAlign.center,
                                  style: Get.textTheme.bodyMedium?.copyWith(
                                    color: ColorConstants.error,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // Expanded(
                            //     flex: 3,
                            //     child: Text('$totalQty', textAlign: TextAlign.center, style: Get.textTheme
                            //         .bodyMedium?.copyWith(
                            //       color: ColorConstants.success,
                            //       fontSize: 14,
                            //       fontWeight: FontWeight.w500,
                            //     ),)),
                            // Expanded(
                            //     flex: 2, child: Container(
                            //   padding: const .symmetric(horizontal: 2, vertical: 10),
                            //   color: hexToColor('#E6FFF0'),
                            //   child: Text('$totalPrice', textAlign: TextAlign.center,
                            //     style: Get.textTheme.bodyMedium?.copyWith(
                            //       color: ColorConstants.success,
                            //       fontSize: 14,
                            //       fontWeight: FontWeight.w500,
                            //     ),),
                            // )),
                            //
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DepthTabWidget extends StatelessWidget {
  const _DepthTabWidget();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'market_depth',
      builder: (homeCon) {
        return Column(
          crossAxisAlignment: .start,
          mainAxisAlignment: .start,
          children: [
            AppSpace.spaceH10,
            _TextWightButtonWithDepthWidget(homeController: homeCon),
            _TotalQtyWidget(homeController: homeCon),
            Container(
              height: 45,
              padding: const .symmetric(horizontal: 4),
              decoration: BoxDecoration(color: context.tapBg),
              child: Row(
                children: [
                  Expanded(child: Text('Orders', textAlign: TextAlign.center)),
                  Expanded(
                    child: Text(
                      homeCon.selectBuySell == SideType.buy ? 'Bid' : 'Ask',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(child: Text('Qty', textAlign: TextAlign.center)),
                  Expanded(child: Text('CumQ', textAlign: TextAlign.center)),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: homeCon.selectBuySell == SideType.buy
                          ? homeCon.buys.length
                          : homeCon.sells.length,
                      itemBuilder: (context, index) {
                        MarketDepthModel? model =
                            homeCon.selectBuySell == SideType.buy
                            ? homeCon.buys.elementAt(index)
                            : homeCon.sells.elementAt(index);
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${model.o ?? 0}',
                                textAlign: TextAlign.center,
                                style: Get.textTheme.bodyMedium?.copyWith(
                                  color: homeCon.selectBuySell == SideType.buy
                                      ? ColorConstants.success
                                      : ColorConstants.error,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${model.p ?? 0}',
                                textAlign: TextAlign.center,
                                style: Get.textTheme.bodyMedium?.copyWith(
                                  color: homeCon.selectBuySell == SideType.buy
                                      ? ColorConstants.success
                                      : ColorConstants.error,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                NumberFormatter.bdFormatInt(
                                  int.parse('${model.q ?? 0}'),
                                ),
                                textAlign: TextAlign.center,
                                style: Get.textTheme.bodyMedium?.copyWith(
                                  color: homeCon.selectBuySell == SideType.buy
                                      ? ColorConstants.success
                                      : ColorConstants.error,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const .symmetric(
                                  horizontal: 2,
                                  vertical: 10,
                                ),
                                color: homeCon.selectBuySell == SideType.buy
                                    ? (context.isDark
                                          ? hexToColor(
                                              '#133923',
                                            ) // Dark mode version of buy color
                                          : hexToColor('#E6FFF0')) // Light mode version of buy color
                                    : (context.isDark
                                          ? hexToColor(
                                              '#3F131F',
                                            ) // Dark mode version of sell color
                                          : hexToColor('#FADDE4')),
                                child: Text(
                                  NumberFormatter.bdFormatInt(
                                    int.parse('${model.cq ?? 0}'),
                                  ),
                                  textAlign: TextAlign.center,
                                  style: Get.textTheme.bodyMedium?.copyWith(
                                    color: homeCon.selectBuySell == SideType.buy
                                        ? ColorConstants.success
                                        : ColorConstants.error,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TotalQtyWidget extends StatelessWidget {
  const _TotalQtyWidget({required this.homeController});
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      mainAxisAlignment: .start,
      children: [
        // Padding(
        //   padding: const .symmetric(horizontal: 22, vertical: 8),
        //   child: Text(
        //     'Depth by Price At Present',
        //     style: Get.textTheme.headlineSmall?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        //   ),
        // ),
        PriceSlider(
          lowPrice: homeController.marketData.low ?? 0,
          highPrice: homeController.marketData.high ?? 0,
          currentPrice:
              homeController.marketData.last ??
              0, // try changing to 80 → turns green
        ),
        Padding(
          padding: const .symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 70,
                  padding: const .symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.tapBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      width: 1,
                      color: context.isDark
                          ? ColorConstants.backgroundColorDark
                          : hexToColor('#EBF2FC'),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        // height: 22,
                        width: 100,
                        padding: const .symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorConstants.success,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Total Buy Qty",
                          textAlign: TextAlign.center,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: ColorConstants.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      AppSpace.spaceH2,
                      if (homeController.buys.isNotEmpty) ...[
                        //homeController.buys.last.cq ?? 0
                        Text(
                          NumberFormatter.bdFormatInt(
                            int.parse('${homeController.buys.last.cq ?? 0}'),
                          ),
                          style: Get.textTheme.titleMedium?.copyWith(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              AppSpace.spaceW10,
              Expanded(
                child: Container(
                  height: 70,
                  padding: .symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.tapBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      width: 1,
                      color: context.isDark
                          ? ColorConstants.backgroundColorDark
                          : hexToColor('#EBF2FC'),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        // height: 22,
                        width: 110,
                        padding: const .symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorConstants.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Total Sale Qty",
                          textAlign: TextAlign.center,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: ColorConstants.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (homeController.sells.isNotEmpty) ...[
                        Text(
                          NumberFormatter.bdFormatInt(
                            int.parse('${homeController.sells.last.cq ?? 0}'),
                          ),
                          style: Get.textTheme.titleMedium?.copyWith(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PriceSlider extends StatelessWidget {
  final double lowPrice;
  final double highPrice;
  final double currentPrice;

  const PriceSlider({
    super.key,
    required this.lowPrice,
    required this.highPrice,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure min != max (Syncfusion throws assertion if equal)
    final double safeMin = lowPrice;
    final double safeMax = (highPrice == lowPrice)
        ? lowPrice +
              0.01 // fallback tiny range
        : highPrice;

    // Calculate 50% threshold of the high price
    double halfHigh = safeMax * 0.5;

    // Decide color based on price comparison
    final bool isBelowHalf = currentPrice < halfHigh;
    final Color activeColor = isBelowHalf ? Colors.red : Colors.green;
    final Color inactiveColor = isBelowHalf
        ? Colors.red.shade200
        : Colors.green.shade200;
    // String text = currentPrice.toStringAsFixed(1);

    return Column(
      mainAxisAlignment: .start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SfSliderTheme(
          data: const SfSliderThemeData(
            overlayRadius: 0,
            thumbRadius: 18,
            trackCornerRadius: 12,
            activeTrackHeight: 4,
            inactiveTrackHeight: 4,
          ),
          child: Builder(
            builder: (context) {
              // Convert current price to string
              String text = currentPrice.toStringAsFixed(1);

              // 🔹 Dynamically calculate thumb width
              double baseWidth = 26;
              double charWidth = 7;
              double thumbWidth = (baseWidth + text.length * charWidth).clamp(
                32,
                90,
              );
              return SfSlider(
                min: safeMin,
                max: safeMax,
                value: currentPrice.clamp(safeMin, safeMax),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                thumbIcon: Container(
                  width: thumbWidth,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(thumbWidth / 2),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                onChanged: (_) {},
              );
            },
          ),
        ),

        Padding(
          padding: const .symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                "Low: ${lowPrice.toStringAsFixed(1)}",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "High: ${highPrice.toStringAsFixed(1)}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/*class PriceSlider extends StatelessWidget {
  final double lowPrice;
  final double highPrice;
  final double currentPrice;

  const PriceSlider({
    super.key,
    required this.lowPrice,
    required this.highPrice,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate 50% threshold of the high price
    double halfHigh = highPrice * 0.5;

    // Decide color based on price comparison
    final bool isBelowHalf = currentPrice < halfHigh;
    final Color activeColor = isBelowHalf ? Colors.red : Colors.green;
    final Color inactiveColor =
    isBelowHalf ? Colors.red.shade200 : Colors.green.shade200;
    String text = currentPrice.toStringAsFixed(1);

    // Adjust thumb width dynamically based on number length
    double thumbWidth = (text.length <= 4)
        ? 36
        : (text.length <= 6)
        ? 48
        : 58;
    return Column(
      mainAxisAlignment: .start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SfSliderTheme(
          data: const SfSliderThemeData(
            overlayRadius: 0,
            thumbRadius: 18, // controls extra tap area, not the visual width
            trackCornerRadius: 12,
            activeTrackHeight: 4,
            inactiveTrackHeight: 4,
          ),
          child: Builder(
            builder: (context) {
              // Convert current price to string
              String text = currentPrice.toStringAsFixed(1);

              // 🔹 Calculate thumb width dynamically based on text length
              double baseWidth = 26; // minimum width
              double charWidth = 7;  // average width per character for fontSize 12
              double thumbWidth = (baseWidth + text.length * charWidth).clamp(32, 90);

              return SfSlider(
                min: lowPrice,
                max: highPrice,
                value: currentPrice,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                thumbIcon: Container(
                  width: thumbWidth,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(thumbWidth / 2),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                onChanged: (_) {
                  // no-op in Stateless widget, handled by parent if needed
                },
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const .symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                "Low: ${lowPrice.toStringAsFixed(1)}",
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              Text(
                "High: ${highPrice.toStringAsFixed(1)}",
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}*/

class _TextWightButtonWithDepthWidget extends StatelessWidget {
  const _TextWightButtonWithDepthWidget({required this.homeController});
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          SearchDialogWidget(
            child: RichText(
              text: TextSpan(
                text: homeController.marketData.shortName ?? "",
                style: Get.textTheme.bodySmall?.copyWith(
                  fontSize: AppDimens.space17,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.success,
                ),
                children: [
                  TextSpan(
                    text: ' [${homeController.marketData.shareType ?? ""}]',
                    style: Get.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: AppDimens.space14,
                      color: ColorConstants.black,
                    ),
                  ),
                ],
              ),
            ),
            // child: Text(
            //   homeController.marketData.shortName ?? '',
            //   style: Get.textTheme.titleMedium?.copyWith(color: context.buttonColor, fontSize: 16),
            // ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => homeController.toggleSide(SideType.buy),
                child: Container(
                  alignment: Alignment.center,
                  height: 30,
                  width: 71,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: ColorConstants.success,
                  ),
                  child: Text(
                    // homeController.selectBuySell.name.toCapitalize(),
                    "Buy",
                    textAlign: TextAlign.center,
                    style: Get.textTheme.titleLarge?.copyWith(
                      color: ColorConstants.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              AppSpace.spaceW4,
              GestureDetector(
                onTap: () => homeController.toggleSide(SideType.sell),
                child: Container(
                  alignment: Alignment.center,
                  height: 30,
                  width: 71,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: ColorConstants.error,
                  ),
                  child: Text(
                    // homeController.selectBuySell.name.toCapitalize(),
                    'Sell',
                    textAlign: TextAlign.center,
                    style: Get.textTheme.titleLarge?.copyWith(
                      color: ColorConstants.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              // AppSpace.spaceW12,
              // SvgPicture.asset(AssetsConstants.starAndManuIconSvg)
            ],
          ),
        ],
      ),
    );
  }
}

class _TextWightButtonWidget extends StatelessWidget {
  const _TextWightButtonWidget({required this.homeController});
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          SearchDialogWidget(
            child: RichText(
              text: TextSpan(
                text: homeController.marketData.shortName ?? "",
                style: Get.textTheme.bodySmall?.copyWith(
                  fontSize: AppDimens.space15,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.success,
                ),
                children: [
                  TextSpan(
                    text: ' [${homeController.marketData.shareType ?? ""}]',
                    style: Get.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: AppDimens.space10,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
            ),
            // child: Text(
            //   homeController.marketData.shortName ?? '',
            //   style: Get.textTheme.titleMedium?.copyWith(color: context.buttonColor, fontSize: 16),
            // ),
          ),
          Row(
            children: [
              // Container(
              //   alignment: Alignment.center,
              //   height: 30,
              //   width: 71,
              //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: context.buttonColor),
              //   child: Text(
              //     'BUY',
              //     textAlign: TextAlign.center,
              //     style: Get.textTheme.titleLarge?.copyWith(
              //       color: ColorConstants.white,
              //       fontWeight: FontWeight.w700,
              //       fontSize: 14,
              //     ),
              //   ),
              // ),
              // AppSpace.spaceW12,
              // SvgPicture.asset(AssetsConstants.starAndManuIconSvg)
            ],
          ),
        ],
      ),
    );
  }
}
