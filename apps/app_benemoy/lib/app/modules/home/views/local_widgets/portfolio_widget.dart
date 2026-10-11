import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import '../../../../app_pkg.dart';
import 'account_summery_tab_widget.dart';
import 'appbar_right_search_tap.dart';
import 'order_list_tab_widget.dart';
import 'order_summery_tab_widget.dart';
import 'position_tab_widget.dart';

class PortfolioWidget extends StatelessWidget {
  const PortfolioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // var controller=Get.put(PositionController());
    // printLog('${controller.hashCode}===PositionTabWidget');
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
            CommonWidget.buySell(context: context, onTap: () => Get.find<HomeController>().changeCurrentIndex(5)),
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

class _CustomTabWidgetState extends State<_CustomTabWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final homeCon = Get.find<HomeController>();
    _tabController = TabController(length: 3, vsync: this, initialIndex: homeCon.currentTabIndexPortfolio);
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
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            indicator: BoxDecoration(borderRadius: BorderRadius.circular(0), color: ColorConstants.buttonColorLight),
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
            children: const [PositionTabWidget(), OrderListTabWidget(), AccountSummeryTabWidget()],
          ),
        ),
      ],
    );
  }
}

class _CustomTabWidget2 extends HookWidget {
  const _CustomTabWidget2();

  @override
  Widget build(BuildContext context) {
    final homeCon = Get.find<HomeController>();

    // 🚀 flutter_hooks এর মাধ্যমে TabController ইনিশিয়ালাইজ ও অটো-ডিসপোজ হবে
    final tabController = useTabController(initialLength: 3, initialIndex: homeCon.currentTabIndexPortfolio);

    return Column(
      children: [
        Container(
          color: context.tapBg,
          height: 45,
          child: TabBar(
            controller: tabController,
            dividerHeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: context.textColor,
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            indicator: BoxDecoration(borderRadius: BorderRadius.circular(0), color: ColorConstants.buttonColorLight),
            onTap: (index) {
              // 🚀 ট্যাবে ক্লিক করলে ইনডেক্স কন্ট্রোলারে সেভ হবে, সকেট রিফ্রেশে ট্যাব রিসেট হবে না
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
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [PositionTabWidget(), OrderListTabWidget(), AccountSummeryTabWidget()],
          ),
        ),
      ],
    );
  }
}
