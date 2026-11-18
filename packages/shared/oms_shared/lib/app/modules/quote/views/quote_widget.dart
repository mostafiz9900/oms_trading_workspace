import '../../../core/utils/extensions/app_context.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/space.dart';
import '../../../global_widgets/common_widget.dart';
import '../../../global_widgets/custom_app_bar.dart';
import '../../../global_widgets/custom_drawer.dart';
import '../../home/controllers/home_controller.dart';
import '/app/modules/quote/views/local_widgets/quote_tab_widget.dart';
import '/app/modules/quote/views/local_widgets/time_sales_tab_history_widget.dart';

import 'package:material_ui/material_ui.dart';
import 'package:getxify/getxify.dart';

import '../../../global_widgets/appbar_right_search_tap.dart';
import '../../../global_widgets/exchange/exchange_switcher.dart';
import '../../../global_widgets/select_instrument_empty_state.dart';
import '../../../data/services/exchange_service.dart';
import 'local_widgets/price_table_tab_widget.dart';
import 'local_widgets/time_sales_tab_widget.dart';

class QuoteWidget extends StatefulWidget {
  const QuoteWidget({super.key});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  // Made once: a new key on every build threw the whole tab (drawer,
  // inner tabs, scroll) away and rebuilt it on every Home update.
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GetBuilder<HomeController>(
          id: 'selectedInstrument',
          builder: (controller) => CustomAppBar(
            titleText: controller.marketData.shortName ?? 'Select stock',
            titleFontSize: 16,
            isBackButtonIcon: true,
            backButtonOnClick: () => homeController.changeCurrentIndex(0),
            right: Row(
              children: [
                const ExchangeSwitcher(
                  padding: EdgeInsets.only(right: 8),
                  scope: ExchangeScope.quoteTrade,
                ),
                CommonWidget.buySell(
                  context: context,
                  onTap: () => homeController.changeCurrentIndex(5),
                ),
                const AppbarRightSearchTapWidget(targetIndex: 1),
                AppSpace.spaceW4,
              ],
            ),
          ),
        ),
      ),
      body: GetBuilder<HomeController>(
        id: 'selectedInstrument',
        builder: (controller) => controller.marketData.orderBook == null
            ? const SelectInstrumentEmptyState(targetIndex: 1)
            : const _CustomTabWidget(),
      ),
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
                width: Get.context!.width,
                child: TabBar(
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: Colors.white,
                  unselectedLabelColor: context.textColor,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
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
