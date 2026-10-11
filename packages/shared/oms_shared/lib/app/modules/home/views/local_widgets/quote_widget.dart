import '/app/app_pkg.dart';
import '/app/modules/home/views/local_widgets/quote_tab_widget.dart';
import '/app/modules/home/views/local_widgets/time_sales_tab_history_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'appbar_right_search_tap.dart';
import 'candle_series_charts.dart';
import 'historical/price_table_tab_widget.dart';
import 'market_depth_tab_widget.dart';
import 'time_sales_tab_widget.dart';

class QuoteWidget extends StatelessWidget {
  const QuoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final homeController = Get.find<HomeController>();
    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        // automaticallyImplyLeading: false,
        titleText: '${homeController.marketData.shortName}',
        titleFontSize: 16,
        isBackButtonIcon: true,
        backButtonOnClick: () => homeController.changeCurrentIndex(0),
        // backButtonOnClick: () {
        //   final state = scaffoldKey.currentState;
        //   if (state == null) return; // safe-guard

        //   if (state.isDrawerOpen) {
        //     state.openEndDrawer();
        //   } else {
        //     state.openDrawer();
        //   }
        // },
        right: Row(
          children: [
            CommonWidget.buySell(context: context, onTap: () => Get.find<HomeController>().changeCurrentIndex(5)),
            AppbarRightSearchTapWidget(),
            AppSpace.spaceW4,
          ],
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       // Get.toNamed(Routes.SEARCH_WATCH_LIST);
        //       Get.find<HomeController>().changeCurrentIndex(2);
        //     },
        //     icon: SvgPicture.asset(AssetsConstants.searchIconSvg, width: 20, height: 20),
        //   ),
        // ],
      ),
      body: const _CustomTabWidget(),
    );
  }
}

class _CustomTabWidget extends StatelessWidget {
  const _CustomTabWidget();
  @override
  Widget build(BuildContext context) {
    // var homeCon = Get.find<HomeController>();
    return GetBuilder<HomeController>(
      builder: (homeConTap) {
        return DefaultTabController(
          key: Key('tab_quote_${homeConTap.currentTabIndexQuote}'),
          length: 4,
          initialIndex: homeConTap.currentTabIndexQuote,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Container(
                color: context.tapBg,
                height: 40,
                width: Get.width,
                child: TabBar(
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: Colors.white,
                  unselectedLabelColor: context.textColor,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                  padding: const .symmetric(horizontal: 4, vertical: 0),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: ColorConstants.buttonColorLight,
                  ),
                  tabs: const [
                    Tab(icon: Text("Details")),
                    // Tab(icon: Text("Depth")),
                    Tab(icon: Text("T&S Main")),
                    Tab(icon: Text("T&S Business")),
                    Tab(icon: Text("Price Table")),
                    // Tab(icon: Text("Chart")),
                  ],
                  onTap: (index) async {
                    homeConTap.changeTabQuote(index); // Update index
                    // await homeConTap.loadTabData(index);
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    QuoteTabWidget(),
                    // const MarketDepthTabWidget(),
                    const TimeSalesTabWidget(),
                    const TimeSalesTabHistoryWidget(),
                    const PriceTableTabWidget(),
                    // const FastLineWithBarChart(),
                    // const CandleSeriesChartsWidget(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
/*  Get.bottomSheet(
                              Container(
                                width: Get.width,
                                height: 400,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: .all(20),
                                  child: Column(
                                    crossAxisAlignment: .start,mainAxisAlignment: .start,
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          alignment: Alignment.topCenter,
                                                                            height:3,width: 47,
                                          decoration: BoxDecoration(
                                            color: hexToColor('#FFD3DD'),
                                            borderRadius: BorderRadius.circular(10)

                                          ),
                                        ),
                                      ),
                                      AppSpace.spaceH8,
                                      Text("Filter",style: TextStyle(
                                        color: hexToColor('#000000'),
                                        fontSize: 17.38 , fontWeight: FontWeight.w700,

                                      ),),
                                      SizedBox(height: 20),
                                      LabeledCheckbox(
                                        label: 'Newest',
                                        value: true,
                                        onChanged: (value){},

                                      ),
                                      LabeledCheckbox(
                                        label: 'Oldest',
                                        value: false,
                                        onChanged: (value){},

                                      ),
                                      Row(
                                        mainAxisAlignment: .spaceBetween,
                                        crossAxisAlignment: .start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              width: 155, // <-- match_parent
                                              height: 62,
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: hexToColor('#000000').alphaSafe(0.08), // Shadow color with opacity
                                                    spreadRadius: 0, // Spread value
                                                    blurRadius: 14, // Blur value
                                                    offset: Offset(0, -10), // Offset (horizontal, vertical)
                                                  ),
                                                ],
                                              ),

                                              child: ElevatedButton(onPressed: (){

                                              }, child: Text('Cancle',style: TextStyle(
                                                color: hexToColor('#818995'),fontSize: 17,fontWeight: FontWeight.w400
                                              ),),style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12.0)),

                                              )),
                                            ),
                                          ),
                                          AppSpace.spaceW10,
                                          Expanded(
                                            child: Container(
                                              // width: 155, // <-- match_parent
                                              height: 62,
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: hexToColor('#000000').alphaSafe(0.08), // Shadow color with opacity
                                                    spreadRadius: 0, // Spread value
                                                    blurRadius: 14, // Blur value
                                                    offset: Offset(0, -10), // Offset (horizontal, vertical)
                                                  ),
                                                ],
                                              ),
                                              child: ElevatedButton(onPressed: (){

                                              }, child: Text('Apply',style: TextStyle(
                                                color: hexToColor('#FFFFFF'),fontSize: 17,fontWeight: FontWeight.w400
                                              ),),style: ElevatedButton.styleFrom(
                                                backgroundColor: hexToColor('#1ABC9C'),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12.0)),

                                              )),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );*/

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Row(
        children: <Widget>[
          Transform.scale(
            scale: 1.3,
            child: Checkbox(
              value: value,
              onChanged: (bool? newValue) {
                onChanged(newValue);
              },
              activeColor: hexToColor('#FF708A'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              side: BorderSide(color: hexToColor('#FF708A'), width: 1.25),
            ),
          ),
          Text(
            label,
            style: TextStyle(color: hexToColor('#000000'), fontWeight: FontWeight.w400, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
