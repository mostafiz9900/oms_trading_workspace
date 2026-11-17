import 'package:material_ui/material_ui.dart';
import 'package:getxify/getxify.dart';

import '../../../core/utils/extensions/app_context.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/space.dart';
import '../../../global_widgets/common_widget.dart';
import '../../../global_widgets/custom_app_bar.dart';
import '../../../global_widgets/custom_drawer.dart';
import '../../../global_widgets/exchange/exchange_switcher.dart';
import '../../home/controllers/home_controller.dart';
import 'local_widgets/account_summary_tab_widget.dart';
import '../../../global_widgets/appbar_right_search_tap.dart';
import '../../orders/views/order_list_tab_widget.dart';
import 'local_widgets/position_tab_widget.dart';

class PortfolioWidget extends StatefulWidget {
  const PortfolioWidget({super.key});

  @override
  State<PortfolioWidget> createState() => _PortfolioWidgetState();
}

class _PortfolioWidgetState extends State<PortfolioWidget> {
  // Made once: a new key on every build threw the whole tab (drawer,
  // inner tabs, scroll) away and rebuilt it on every Home update.
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        backButtonOnClick: () {
          final state = scaffoldKey.currentState;
          if (state == null) return; // safe-guard

          if (state.isDrawerOpen) {
            state.openEndDrawer();
          } else {
            state.openDrawer();
          }
        },
        right: Row(
          children: [
            // DSE | CSE; shows only for houses on both exchanges.
            const ExchangeSwitcher(padding: EdgeInsets.only(right: 8)),
            CommonWidget.buySell(
              context: context,
              onTap: () => Get.find<HomeController>().changeCurrentIndex(5),
            ),
            AppbarRightSearchTapWidget(),
          ],
        ),
      ),
      body: _CustomTabWidget(),
    );
  }
}

class _CustomTabWidget extends StatefulWidget {
  const _CustomTabWidget();

  @override
  State<_CustomTabWidget> createState() => _CustomTabWidgetState();
}

class _CustomTabWidgetState extends State<_CustomTabWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final homeCon = Get.find<HomeController>();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: homeCon.currentTabIndexPortfolio,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeCon = Get.find<HomeController>();

    return Column(
      children: [
        Container(
          color: context.tapBg,
          height: 45,
          child: TabBar(
            controller: _tabController,
            dividerHeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: context.textColor,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              color: ColorConstants.buttonColorLight,
            ),
            onTap: (index) {
              homeCon.currentTabIndexPortfolio = index;
            },
            tabs: const [
              Tab(icon: Text("Position")),
              Tab(icon: Text("Order List")),
              Tab(icon: Text("Account Summery")),
            ],
          ),
        ),
        AppSpace.spaceH10,
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              PositionTabWidget(),
              OrderListTabWidget(),
              AccountSummaryTabWidget(),
            ],
          ),
        ),
      ],
    );
  }
}
