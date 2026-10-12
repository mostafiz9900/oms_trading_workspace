import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/utils/helpers/hex_color.dart';
import '../../../../core/values/colors.dart';
import '../../../../core/values/dimens.dart';
import '../../../home/controllers/home_controller.dart';

import 'package:flutter/material.dart';
import '../../../../data/models/response/market_depth_model.dart' show MarketDepthModel;

import '../../../quote/views/local_widgets/market_depth_single_widget.dart';

// 🟢 Delegate এবং Table আগের মতোই থাকবে
class MarketDepthStickyDelegate extends SliverPersistentHeaderDelegate {
  final HomeController homeController;
  final Color backgroundColor;

  MarketDepthStickyDelegate({
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
  bool shouldRebuild(covariant MarketDepthStickyDelegate oldDelegate) => true;
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
                  ? HexColor('#223167').withAlpha(153)
                  : HexColor('#EBF2FC').withAlpha(204),
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
