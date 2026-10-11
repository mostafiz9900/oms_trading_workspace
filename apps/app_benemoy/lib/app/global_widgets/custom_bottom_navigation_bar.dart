import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../app_pkg.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key, required this.onClick});
  final Function(int? value) onClick;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeCon) {
        return BottomNavigationBar(
          currentIndex: homeCon.currentIndex,
          onTap: onClick,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: ColorConstants.secondaryColorLight,
          unselectedItemColor: ColorConstants.unselectedItemColor,
          selectedLabelStyle: TextStyle(color: ColorConstants.secondaryColorLight),
          unselectedLabelStyle: TextStyle(color: ColorConstants.unselectedItemColor),
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(AssetsConstants.quoteIconSvg),
              label: 'Quote',
              activeIcon: SvgPicture.asset(
                AssetsConstants.quoteIconSvg,
                colorFilter: ColorFilter.mode(ColorConstants.secondaryColorLight, BlendMode.srcIn),
              ),
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(AssetsConstants.watchListIconSvg),
              label: 'Watch List',
              activeIcon: SvgPicture.asset(
                AssetsConstants.watchListIconSvg,
                colorFilter: ColorFilter.mode(ColorConstants.secondaryColorLight, BlendMode.srcIn),
              ),
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                AssetsConstants.marketIconSvg,
                colorFilter: ColorFilter.mode(ColorConstants.unselectedItemColor, BlendMode.srcIn),
              ),
              label: 'Market',
              activeIcon: SvgPicture.asset(
                AssetsConstants.marketIconSvg,
                colorFilter: ColorFilter.mode(ColorConstants.secondaryColorLight, BlendMode.srcIn),
              ),
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(AssetsConstants.portfolioIconSvg),
              label: 'Portfolio',
              activeIcon: SvgPicture.asset(
                AssetsConstants.portfolioIconSvg,
                colorFilter: ColorFilter.mode(ColorConstants.secondaryColorLight, BlendMode.srcIn),
              ),
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(AssetsConstants.tradeIconSvg),
              label: 'Trade',
              activeIcon: SvgPicture.asset(
                AssetsConstants.tradeIconSvg,
                colorFilter: ColorFilter.mode(ColorConstants.secondaryColorLight, BlendMode.srcIn),
              ),
            ),
          ],
        );
      },
    );
  }
}
