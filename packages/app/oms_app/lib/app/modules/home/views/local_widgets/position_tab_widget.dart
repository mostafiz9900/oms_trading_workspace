import 'package:oms_app/app/data/models/response/position_response.dart';
import 'package:oms_app/app/modules/home/controllers/position_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app_pkg.dart';
import 'index_value_loader.dart';

class PositionTabWidget extends StatelessWidget {
  const PositionTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PositionController());

    return GetBuilder<HomeController>(
      builder: (homeController) {
        return GetBuilder<PositionController>(
          builder: (positionCont) {
            if (positionCont.isLoading && positionCont.positions.data == null) {
              return const PositionLoader();
            }

            return RefreshIndicator(
              onRefresh: () async {
                positionCont.initializePosition();
                homeController.userBalance();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _TopSummaryDashboard(positionCont: positionCont, homeCont: homeController),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Holdings (${positionCont.filteredPositions.length})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Obx(() {
                            String currentView = positionCont.selectedViewMode.value == 0
                                ? 'All'
                                : positionCont.selectedViewMode.value == 2
                                ? 'Value'
                                : positionCont.selectedViewMode.value == 3
                                ? 'P&L'
                                : positionCont.selectedViewMode.value == 4
                                ? 'Change'
                                : 'Last';

                            return CommonMinimalDropdown(
                              currentValue: currentView,
                              items: const ['All', 'Last', 'Value', 'P&L', 'Change'],
                              onSelected: (val) {
                                if (val == 'All') {
                                  positionCont.selectedViewMode.value = 0;
                                } else if (val == 'Value') {
                                  positionCont.selectedViewMode.value = 2;
                                } else if (val == 'P&L') {
                                  positionCont.selectedViewMode.value = 3;
                                } else if (val == 'Change') {
                                  positionCont.selectedViewMode.value = 4;
                                } else {
                                  positionCont.selectedViewMode.value = 1; // Default: Last
                                }
                              },
                              widthDropdown: 105,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: positionCont.positions.data == null
                        ? const CustomLoaderWidget()
                        : positionCont.filteredPositions.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: Center(child: Text('No positions found')),
                          )
                        : Obx(
                            () => _Pro2LineHorizontalTable(
                              positionCont: positionCont,
                              homeCont: homeController,
                              viewMode: positionCont.selectedViewMode.value,
                            ),
                          ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 50)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ----------------------------------------------------------------------
//  Top Dashboard Widget
// ----------------------------------------------------------------------
class _TopSummaryDashboard extends StatelessWidget {
  final PositionController positionCont;
  final HomeController homeCont;

  const _TopSummaryDashboard({required this.positionCont, required this.homeCont});

  @override
  Widget build(BuildContext context) {
    double totalValue = positionCont.currentPortfolioValue;
    double unrealizedAmount = positionCont.totalUnrealizedPnL;
    double unrealizedPct = positionCont.totalUnrealizedPnLPercentage;

    Color pnlColor = unrealizedAmount >= 0 ? HexColor("#22C665") : HexColor("#F70042");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.isDark ? HexColor('#151D3B') : HexColor('#D3E0F3'),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Market Value', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(
                NumberFormatter.bdFormat(totalValue),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text('BDT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Gain', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(
                '${unrealizedPct > 0 ? "+" : ""}${unrealizedPct.toStringAsFixed(2)}%',
                style: TextStyle(color: pnlColor, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '${unrealizedAmount > 0 ? "+" : ""}${NumberFormatter.bdFormat(unrealizedAmount)}',
                style: TextStyle(color: pnlColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
//  Dynamic Table (Original UI Maintained)
// ----------------------------------------------------------------------
class _Pro2LineHorizontalTable extends StatelessWidget {
  final PositionController positionCont;
  final HomeController homeCont;
  final int viewMode;

  //  আপনার অরিজিনাল কলামগুলো একটু অ্যাডজাস্ট করা হলো নতুন ডেটা বসানোর জন্য
  final double colInstrument = 100.0;
  final double colPositions = 90.0;
  final double colIntraday = 90.0; //  নতুন: Intraday Buy/Sell এর জন্য
  final double colPrices = 90.0;
  final double colCostValue = 110.0;
  final double colUnrealized = 100.0;
  final double colRealized = 100.0; //  নতুন: Realized P&L এবং Weight% এর জন্য

  const _Pro2LineHorizontalTable({required this.positionCont, required this.homeCont, required this.viewMode});

  String _formatTime(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return "14:05:29";
    try {
      final parts = rawTime.split(':');
      if (parts.length >= 3) {
        String hour = parts[0].padLeft(2, '0');
        String min = parts[1].padLeft(2, '0');
        String sec = parts[2].split('.')[0].padLeft(2, '0');
        return "$hour:$min:$sec";
      } else if (parts.length == 2) {
        return "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:00";
      }
    } catch (e) {}
    return rawTime;
  }

  @override
  Widget build(BuildContext context) {
    if (viewMode == 0) {
      // 🟢 ১. SHOW ALL (Original 2-Line UI)
      double totalTableWidth =
          colInstrument + colPositions + colIntraday + colPrices + colCostValue + colUnrealized + colRealized;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: SizedBox(
            width: totalTableWidth,
            child: Column(
              children: [
                Container(
                  color: context.isDark ? HexColor('#151D3B') : HexColor('#D3E0F3'),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: colInstrument,
                        child: _HeaderCell2Line(
                          'Ticker',
                          'Trend',
                          CrossAxisAlignment.start,
                          padding: const EdgeInsets.only(left: 10),
                        ),
                      ),
                      SizedBox(
                        width: colPositions,
                        child: _HeaderCell2Line('Total Pos', 'Rem. Pos', CrossAxisAlignment.end),
                      ),
                      SizedBox(
                        width: colIntraday,
                        child: _HeaderCell2Line('Int. Buy', 'Int. Sell', CrossAxisAlignment.end),
                      ), //  নতুন
                      SizedBox(width: colPrices, child: _HeaderCell2Line('Avg Cost', 'LTP', CrossAxisAlignment.end)),
                      SizedBox(
                        width: colCostValue,
                        child: _HeaderCell2Line('Total Cost', 'Market Val', CrossAxisAlignment.end),
                      ),
                      SizedBox(
                        width: colUnrealized,
                        child: _HeaderCell2Line('Unrealized', 'P&L (%)', CrossAxisAlignment.end),
                      ),
                      SizedBox(
                        width: colRealized,
                        child: _HeaderCell2Line(
                          'Realized',
                          'Weight %',
                          CrossAxisAlignment.end,
                          padding: const EdgeInsets.only(right: 10),
                        ),
                      ), //  নতুন
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: positionCont.filteredPositions.length,
                  itemBuilder: (context, index) {
                    return _buildRowItem(context, positionCont.filteredPositions[index], index, isScrollable: true);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // 🟢 ২. ৩-কলাম লেআউট (Mobile View - Original Code)
      String col2HeaderTop, col2HeaderBottom, col3HeaderTop, col3HeaderBottom;

      if (viewMode == 1) {
        col2HeaderTop = 'Pos';
        col2HeaderBottom = 'Avg';
        col3HeaderTop = 'Last';
        col3HeaderBottom = 'Time';
      } else if (viewMode == 2) {
        col2HeaderTop = 'Value';
        col2HeaderBottom = 'Cost';
        col3HeaderTop = 'Weight%';
        col3HeaderBottom = '';
      } else if (viewMode == 3) {
        col2HeaderTop = 'Pos';
        col2HeaderBottom = 'Avg';
        col3HeaderTop = 'PL%';
        col3HeaderBottom = 'PL';
      } else {
        col2HeaderTop = 'Avg Cost';
        col2HeaderBottom = 'LTP';
        col3HeaderTop = 'SBL Val';
        col3HeaderBottom = "Today's PnL";
      }

      return Column(
        children: [
          Container(
            color: context.isDark ? HexColor('#151D3B') : HexColor('#D3E0F3'),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _HeaderCell2Line(
                    'Ticker',
                    'Trend',
                    CrossAxisAlignment.start,
                    padding: const EdgeInsets.only(left: 10),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _HeaderCell2Line(
                    col2HeaderTop,
                    col2HeaderBottom,
                    CrossAxisAlignment.end,
                    padding: const EdgeInsets.only(right: 15),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _HeaderCell2Line(
                    col3HeaderTop,
                    col3HeaderBottom,
                    CrossAxisAlignment.end,
                    padding: const EdgeInsets.only(right: 10),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: positionCont.filteredPositions.length,
            itemBuilder: (context, index) {
              return _buildRowItem(context, positionCont.filteredPositions[index], index, isScrollable: false);
            },
          ),
        ],
      );
    }
  }

  Widget _buildRowItem(BuildContext context, PositionModel model, int index, {required bool isScrollable}) {
    MarketModel marketData = positionCont.getMarketData(model.isin);
    bool isEven = index % 2 == 0;

    //  Exact Calculations
    int remQty = model.quantity ?? 0;
    int intBuyQty = model.intradayBuyQuantity ?? 0;
    int intSellQty = model.intradaySellQuantity ?? 0;

    double avgPrice = model.avgPrice ?? 0.0;
    double intBuyAvgPrice = model.intradayBuyPriceAvg ?? 0.0;
    double intSellAvgPrice = model.intradaySellPriceAvg ?? 0.0;

    //  2. JS Logic: closeOrSettle and Last
    double closeOrSettle = marketData.closeOrSettle;
    double activeLast = marketData.activeLast;

    //  3. JS Logic: Market Value (Only Rem. Qty)
    double marketValue = remQty * activeLast;

    //  4. JS Logic: Unrealized PnL
    double unrealizedPnL = ((remQty + intBuyQty) * activeLast) - ((remQty * avgPrice) + (intBuyQty * intBuyAvgPrice));

    // Total Cost Calculation for Gain/Loss Percentage
    double totalCostCalculated = model.totalCost ?? 0.0; //(remQty * avgPrice) + (intBuyQty * intBuyAvgPrice)
    double gainLossPct = totalCostCalculated > 0 ? (unrealizedPnL / totalCostCalculated) * 100 : 0.0;

    //  5. JS Logic: Realized PnL
    double realizedPnL = (intSellQty * intSellAvgPrice) - (intSellQty * avgPrice);

    //  6. Weight Percentage
    double totalPortfolioValue = positionCont.currentPortfolioValue;
    double weightPct = totalPortfolioValue > 0 ? (marketValue / totalPortfolioValue) * 100 : 0.0;

    String instrumentName = model.securityCode?.toUpperCase() ?? "N/A";
    double dayAbsChg = marketData.activePrice - (marketData.reference ?? 0.0);
    double dayPctChg = marketData.d?.toDouble() ?? 0.0;

    String dayIcon = dayAbsChg > 0 ? "▲" : (dayAbsChg < 0 ? "▼" : "▬");
    String dayTrendText = '$dayIcon ${dayAbsChg.abs().toStringAsFixed(2)} (${dayPctChg.abs().toStringAsFixed(2)}%)';
    Color dayTrendColor = dayAbsChg > 0
        ? HexColor("#22C665")
        : (dayAbsChg < 0 ? HexColor("#F70042") : context.textColor.withOpacity(0.6));

    Color unPnLColor = unrealizedPnL >= 0 ? HexColor("#22C665") : HexColor("#F70042");
    Color realPnLColor = realizedPnL >= 0 ? HexColor("#22C665") : HexColor("#F70042");
    String unPnLSign = unrealizedPnL > 0 ? "+" : (unrealizedPnL < 0 ? "-" : "");
    String realPnLSign = realizedPnL > 0 ? "+" : (realizedPnL < 0 ? "-" : "");

    //  JS code fallback: UI displaying 'Total Qty' should be Rem Qty + Intraday Buy
    int totalQty = remQty + intBuyQty;

    Widget rowContent;

    if (isScrollable) {
      // 🟢 'All' View Row - অরিজিনাল UI, নতুন ডেটা
      rowContent = Row(
        children: [
          SizedBox(
            width: colInstrument,
            child: _DataCell2Line(
              topText: instrumentName,
              bottomText: dayTrendText,
              alignment: CrossAxisAlignment.start,
              topBold: true,
              bottomColor: dayTrendColor,
              padding: const EdgeInsets.only(left: 10),
            ),
          ),

          //  Total & Rem. Pos
          SizedBox(
            width: colPositions,
            child: _DataCell2Line(
              topText: NumberFormatter.bdFormat(totalQty, decimalPlaces: 0),
              bottomText: NumberFormatter.bdFormat(remQty, decimalPlaces: 0),
              alignment: CrossAxisAlignment.end,
              topBold: true,
              bottomColor: context.textColor.withOpacity(0.7),
            ),
          ),

          //  Int. Buy & Int. Sell
          SizedBox(
            width: colIntraday,
            child: _DataCell2Line(
              topText: NumberFormatter.bdFormat(intBuyQty, decimalPlaces: 0),
              bottomText: NumberFormatter.bdFormat(intSellQty, decimalPlaces: 0),
              alignment: CrossAxisAlignment.end,
              topBold: true,
              bottomColor: context.textColor.withOpacity(0.7),
            ),
          ),

          SizedBox(
            width: colPrices,
            child: _DataCell2Line(
              topText: avgPrice.toStringAsFixed(2),
              bottomText: activeLast.toStringAsFixed(2),
              alignment: CrossAxisAlignment.end,
            ),
          ),
          SizedBox(
            width: colCostValue,
            child: _DataCell2Line(
              topText: NumberFormatter.bdFormat(model.totalCost),
              bottomText: NumberFormatter.bdFormat(marketValue),
              alignment: CrossAxisAlignment.end,
              bottomBold: true,
            ),
          ),

          //  Unrealized
          SizedBox(
            width: colUnrealized,
            child: _DataCell2Line(
              topText: '$unPnLSign${NumberFormatter.bdFormat(unrealizedPnL.abs())}',
              bottomText: '$unPnLSign${gainLossPct.abs().toStringAsFixed(2)}%',
              alignment: CrossAxisAlignment.end,
              topColor: unPnLColor,
              topBold: true,
              bottomColor: unPnLColor,
              bottomBold: true,
            ),
          ),

          //  Realized & Weight
          SizedBox(
            width: colRealized,
            child: _DataCell2Line(
              topText: '$realPnLSign${NumberFormatter.bdFormat(realizedPnL.abs())}',
              bottomText: '${weightPct.toStringAsFixed(2)}%',
              alignment: CrossAxisAlignment.end,
              topColor: realPnLColor,
              topBold: true,
              padding: const EdgeInsets.only(right: 10),
            ),
          ),
        ],
      );
    } else {
      // 🟢 Mobile View (Original Logic Kept Intact)
      String col2DataTop, col2DataBottom, col3DataTop, col3DataBottom;
      bool col2TopBold = false, col2BottomBold = false, col3TopBold = false, col3BottomBold = false;
      Color? col2TopColor, col2BottomColor, col3TopColor, col3BottomColor;

      if (viewMode == 1) {
        col2DataTop = NumberFormatter.bdFormat(totalQty, decimalPlaces: 0);
        col2DataBottom = '${avgPrice.toStringAsFixed(2)} BDT';
        col2TopBold = true;
        col2BottomColor = context.textColor.withOpacity(0.7);
        col3DataTop = activeLast.toStringAsFixed(2);
        col3DataBottom = _formatTime(marketData.lastTradeTime);
        col3TopColor = (marketData.d ?? 0) >= 0 ? HexColor("#22C665") : HexColor("#F70042");
        col3TopBold = true;
        col3BottomColor = context.textColor.withOpacity(0.7);
      } else if (viewMode == 2) {
        col2DataTop = NumberFormatter.bdFormat(marketValue);
        col2DataBottom = NumberFormatter.bdFormat(model.totalCost);
        col2TopBold = true;
        col2BottomColor = context.textColor.withOpacity(0.7);
        col3DataTop = '${weightPct.toStringAsFixed(2)}%';
        col3DataBottom = '';
        col3TopBold = true;
      } else if (viewMode == 3) {
        col2DataTop = NumberFormatter.bdFormat(totalQty, decimalPlaces: 0);
        col2DataBottom = '${avgPrice.toStringAsFixed(2)} BDT';
        col2TopBold = true;
        col2BottomColor = context.textColor.withOpacity(0.7);
        col3DataTop = '$unPnLSign${gainLossPct.abs().toStringAsFixed(2)}%';
        col3DataBottom = unrealizedPnL.abs() >= 1000
            ? '$unPnLSign${(unrealizedPnL.abs() / 1000).toStringAsFixed(2)}K'
            : '$unPnLSign${unrealizedPnL.abs().toStringAsFixed(2)}';
        col3TopColor = unPnLColor;
        col3TopBold = true;
        col3BottomColor = unPnLColor;
        col3BottomBold = true;
      } else {
        col2DataTop = avgPrice.toStringAsFixed(2);
        col2DataBottom = activeLast.toStringAsFixed(2);
        col3DataTop = NumberFormatter.bdFormat(marketValue);
        col3DataBottom = '${realizedPnL > 0 ? "+" : ""}${NumberFormatter.bdFormat(realizedPnL)}';
        col3TopColor = HexColor("#007BFF");
        col3TopBold = true;
        col3BottomColor = realPnLColor;
        col3BottomBold = true;
      }

      rowContent = Row(
        children: [
          Expanded(
            flex: 3,
            child: _DataCell2Line(
              topText: instrumentName,
              bottomText: dayTrendText,
              alignment: CrossAxisAlignment.start,
              topBold: true,
              bottomColor: dayTrendColor,
              padding: const EdgeInsets.only(left: 10),
            ),
          ),
          Expanded(
            flex: 2,
            child: _DataCell2Line(
              topText: col2DataTop,
              bottomText: col2DataBottom,
              alignment: CrossAxisAlignment.end,
              topBold: col2TopBold,
              bottomBold: col2BottomBold,
              topColor: col2TopColor,
              bottomColor: col2BottomColor,
              padding: const EdgeInsets.only(right: 15),
            ),
          ),
          Expanded(
            flex: 2,
            child: _DataCell2Line(
              topText: col3DataTop,
              bottomText: col3DataBottom,
              alignment: CrossAxisAlignment.end,
              topBold: col3TopBold,
              bottomBold: col3BottomBold,
              topColor: col3TopColor,
              bottomColor: col3BottomColor,
              padding: const EdgeInsets.only(right: 10),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: () {
        if (marketData.isValidShare) {
          if (marketData.orderBook != null && marketData.shortName != null) {
            Get.find<HomeController>().goBottomNabBarPage(5, marketData.orderBook!);
            Get.find<HomeController>().tradingChart();
            Get.find<HomeController>().tradPriceTextEditField.text = (marketData.last?.toStringAsFixed(2) ?? '0.00');
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isEven ? Get.theme.scaffoldBackgroundColor : context.tapBg,
          border: Border(bottom: BorderSide(color: context.borderSideColor.withOpacity(0.5))),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: rowContent,
      ),
    );
  }
}

// ----------------------------------------------------------------------
//  Table Cell Helpers (অপরিবর্তিত)
// ----------------------------------------------------------------------
class _HeaderCell2Line extends StatelessWidget {
  final String topTitle;
  final String bottomTitle;
  final CrossAxisAlignment alignment;
  final EdgeInsetsGeometry? padding;

  const _HeaderCell2Line(this.topTitle, this.bottomTitle, this.alignment, {this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            topTitle,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textColor),
          ),
          if (bottomTitle.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              bottomTitle,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: context.textColor.withOpacity(0.7)),
            ),
          ],
        ],
      ),
    );
  }
}

class _DataCell2Line extends StatelessWidget {
  final String topText;
  final String bottomText;
  final CrossAxisAlignment alignment;
  final EdgeInsetsGeometry? padding;
  final Color? topColor;
  final Color? bottomColor;
  final bool topBold;
  final bool bottomBold;

  const _DataCell2Line({
    required this.topText,
    required this.bottomText,
    required this.alignment,
    this.padding,
    this.topColor,
    this.bottomColor,
    this.topBold = false,
    this.bottomBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment == CrossAxisAlignment.end ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              topText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: topBold ? FontWeight.bold : FontWeight.w500,
                color: topColor ?? context.textColor,
              ),
            ),
          ),
          if (bottomText.isNotEmpty) ...[
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: alignment == CrossAxisAlignment.end ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                bottomText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: bottomBold ? FontWeight.bold : FontWeight.w500,
                  color: bottomColor ?? context.textColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
