import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_pkg.dart';
import '../controllers/update_controller.dart';
import 'fav_market_view.dart';
import 'local_widgets/market_widget.dart';
import 'local_widgets/portfolio_widget.dart';
import 'local_widgets/quote_widget.dart';
import 'local_widgets/trade_widget.dart';
import 'local_widgets/watch_list_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {

    final homeController = Get.find<HomeController>();
    final UpdateController updateController = Get.put(UpdateController());
    return GetBuilder<UpdateController>(
      builder: (_) {
        // Show alert dialog if app is outdated
        // Show alert dialog if app is outdated
        if (updateController.forceUpdate) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!Get.isDialogOpen!) {
              Get.dialog(
                PopScope(
                  canPop: false, // disable back gesture
                  child: AlertDialog(
                    title: const Text("Update Required"),
                    content: Text(
                      "Please update to the latest version:\n"
                      "${GetPlatform.isIOS ? updateController.iosLatestVersion : updateController.androidLatestVersion}",
                    ),
                    actions: [
                      CustomButton(
                        onPressed: () async {
                          final url = Uri.parse(updateController.updateUrl);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        title: "Update Now",
                      ),
                    ],
                  ),
                ),
                barrierDismissible: false, // cannot dismiss
              );
            }
          });
        }
        return PopScope(
          canPop: false, // system back button handle
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            printLog("🔙 Hardware Back Button Pressed");

            // 🚀 কন্ট্রোলার থেকে চেক করে দেখবে হিস্ট্রি শেষ কিনা
            bool shouldExit = homeController.goBack();

            if (shouldExit) {
              // যদি হিস্ট্রি শেষ হয়ে যায় (মানে ইউজার একদম প্রথম ট্যাবে চলে এসেছে), তখন Exit ডায়ালগ দেখাবে
              Helpers.openCustomAlertDialog(
                () {
                  Get.back(); // ডায়ালগ বন্ধ
                  // 👉 socket disconnect ও clean-up
                  homeController.disconnect();
                  // 👉 app exit
                  exit(0); // force exit
                },
                title: "Exit App",
                bodyText: "Do you really want to exit the app?",
              );
            }
          },
          child: GetBuilder<HomeController>(
            builder: (homeCon) {
              return buildScafoldWidget(homeCon, context);
            },
          ),
        );
      },
    );
  }

  Scaffold buildScafoldWidget(HomeController homeCon, BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: homeCon.currentIndex,
        children: [MarketWidget(), QuoteWidget(), WatchListWidget(), FavMarketView(), PortfolioWidget(), TradeWidget()],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: homeCon.currentIndex,
        onTap: homeCon.changeCurrentIndex2,
        type: BottomNavigationBarType.fixed, // ✅ 6 items allowed
        selectedItemColor: ColorConstants.secondaryColorLight,
        unselectedItemColor: context.unselectColor,
        showUnselectedLabels: true,

        selectedLabelStyle: TextStyle(
          color: ColorConstants.secondaryColorLight,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          color: ColorConstants.unselectedItemColor,
          fontWeight: FontWeight.normal,
          fontSize: 10,
        ),
        items: [
          /// 3️⃣ Market
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AssetsConstants.marketIconSvg,
              colorFilter: ColorFilter.mode(context.unselectColor, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              AssetsConstants.marketIconSvg,
              colorFilter: ColorFilter.mode(ColorConstants.secondaryColorLight, BlendMode.srcIn),
            ),
            label: 'Home',
          ),

          /// 1️⃣ Quote
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AssetsConstants.quoteIconSvg,
              colorFilter: ColorFilter.mode(context.unselectColor, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              AssetsConstants.quoteIconSvg,
              colorFilter: ColorFilter.mode(ColorConstants.secondaryColorLight, BlendMode.srcIn),
            ),
            label: 'Details',
          ),

          /// 2️⃣ Watch List
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AssetsConstants.watchListIconSvg,
              colorFilter: ColorFilter.mode(context.unselectColor, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              AssetsConstants.watchListIconSvg,
              colorFilter: ColorFilter.mode(ColorConstants.secondaryColorLight, BlendMode.srcIn),
            ),
            label: 'Watch List',
          ),

          /// 6️⃣ Favorite (Newly Added)
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AssetsConstants.starIconSvg, // 🔹 তোমার SVG path এখানে দাও
              height: 25,
              width: 25,
              colorFilter: ColorFilter.mode(context.unselectColor, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              AssetsConstants.starIconSvg,
              height: 25,
              width: 25,
              colorFilter: ColorFilter.mode(ColorConstants.secondaryColorLight, BlendMode.srcIn),
            ),
            label: 'Favorite',
          ),

          /// 4️⃣ Portfolio
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AssetsConstants.portfolioIconSvg,
              colorFilter: ColorFilter.mode(context.unselectColor, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              AssetsConstants.portfolioIconSvg,
              colorFilter: ColorFilter.mode(ColorConstants.secondaryColorLight, BlendMode.srcIn),
            ),
            label: 'Portfolio',
          ),

          /// 5️⃣ Trade
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AssetsConstants.tradeIconSvg,
              colorFilter: ColorFilter.mode(context.unselectColor, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              AssetsConstants.tradeIconSvg,
              colorFilter: ColorFilter.mode(ColorConstants.secondaryColorLight, BlendMode.srcIn),
            ),
            label: 'Trade',
          ),
        ],
      ),
    );
  }
}
