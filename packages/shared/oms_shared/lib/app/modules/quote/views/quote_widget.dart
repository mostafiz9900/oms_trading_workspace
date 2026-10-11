import '/app/app_pkg.dart';
import '/app/modules/quote/views/local_widgets/quote_tab_widget.dart';
import '/app/modules/quote/views/local_widgets/time_sales_tab_history_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global_widgets/appbar_right_search_tap.dart';
import 'local_widgets/price_table_tab_widget.dart';
import 'local_widgets/time_sales_tab_widget.dart';

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
        titleText: '${homeController.marketData.shortName}',
        titleFontSize: 16,
        isBackButtonIcon: true,
        backButtonOnClick: () => homeController.changeCurrentIndex(0),

        right: Row(
          children: [
            CommonWidget.buySell(context: context, onTap: () => Get.find<HomeController>().changeCurrentIndex(5)),
            AppbarRightSearchTapWidget(),
            AppSpace.spaceW4,
          ],
        ),
      ),
      body: const _CustomTabWidget(),
    );
  }
}

class _CustomTabWidget extends StatelessWidget {
  const _CustomTabWidget();
  @override
  Widget build(BuildContext context) {
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
                    Tab(icon: Text("T&S Main")),
                    Tab(icon: Text("T&S Business")),
                    Tab(icon: Text("Price Table")),
                  ],
                  onTap: (index) async {
                    homeConTap.changeTabQuote(index); // Update index
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    QuoteTabWidget(),
                    const TimeSalesTabWidget(),
                    const TimeSalesTabHistoryWidget(),
                    const PriceTableTabWidget(),
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

