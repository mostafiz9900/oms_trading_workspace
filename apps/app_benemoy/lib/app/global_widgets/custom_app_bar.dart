import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../app_pkg.dart';

class CustomAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final bool? isBackButtonIcon;
  final VoidCallback? backButtonOnClick;
  final VoidCallback? searchButtonOnClick;
  final String? titleText;
  final double height;
  final Widget? right;

  const CustomAppBar2({
    super.key,
    this.isBackButtonIcon,
    this.backButtonOnClick,
    this.searchButtonOnClick,
    this.titleText,
    this.height = kToolbarHeight,
    this.right,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: preferredSize.height,
      alignment: Alignment.center,
      child: AppBar(
        titleSpacing: 15.0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        // leadingWidth: 8, // <-- Use this
        // centerTitle: false,
        // leading: Container(
        //   color: Colors.red,
        //   width: 24,height: 29,
        //     child: SvgPicture.asset(AssetsConstants.moreIconSvg,width: 24,height: 29,)),
        title: Row(
          mainAxisAlignment: .spaceBetween,
          crossAxisAlignment: .center,
          children: [
            InkWell(
              onTap: backButtonOnClick,
              child: Container(
                padding: const .only(bottom: 5),
                alignment: Alignment.center,
                child: isBackButtonIcon == true
                    ? SvgPicture.asset(AssetsConstants.backIconSvg, width: 20, height: 16)
                    : SvgPicture.asset(AssetsConstants.moreIconSvg, width: 24, height: 24),
              ),
            ),
            AppSpace.spaceW8,
            titleText != null
                ? Text(titleText ?? "", textAlign: TextAlign.center, style: Get.textTheme.titleMedium)
                : SvgPicture.asset(AssetsConstants.logoSvg, width: 120, height: 30),
            AppSpace.spaceW6,
            Flexible(
              child:
                  right ??
                  InkWell(
                    onTap: searchButtonOnClick ?? () => Get.toNamed(Routes.SEARCH_WATCH_LIST),
                    child: SvgPicture.asset(AssetsConstants.searchIconSvg, width: 20, height: 20),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? isBackButtonIcon;
  final VoidCallback? backButtonOnClick;
  final VoidCallback? searchButtonOnClick;
  final String? titleText;
  final double height;
  final Widget? right;
  final Widget? leading;
  final double? titleFontSize;

  const CustomAppBar({
    super.key,
    this.isBackButtonIcon,
    this.backButtonOnClick,
    this.searchButtonOnClick,
    this.titleText,
    this.height = kToolbarHeight,
    this.right,
    this.leading,
    this.titleFontSize,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading:
          leading ??
          IconButton(
            onPressed: backButtonOnClick ?? () => Navigator.of(context).maybePop(),
            icon: isBackButtonIcon == true
                ? SvgPicture.asset(
                    AssetsConstants.backIconSvg,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(context.iconDefColor, BlendMode.srcIn),
                  )
                : SvgPicture.asset(
                    AssetsConstants.drawerIconSvg,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(context.iconDefColor, BlendMode.srcIn),
                  ),
          ),
      title: titleText != null
          ? Text(titleText!, style: Get.textTheme.titleMedium?.copyWith(fontSize: titleFontSize))
          : SvgPicture.asset(
              context.bannerLogo,
              width: 120,
              height: 35,
              // colorFilter: ColorFilter.mode(context.textColor, BlendMode.srcIn)
            ),
      actions: [
        right ??
            IconButton(
              onPressed: searchButtonOnClick ?? () => Get.toNamed(Routes.SEARCH_WATCH_LIST),
              icon: SvgPicture.asset(
                AssetsConstants.searchIconSvg,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(context.iconDefColor, BlendMode.srcIn),
              ),
            ),
      ],
    );
  }
}

// Widget setAppBar() {
//   return AppBar(
//     //backgroundColor: Colors.blue,
//     //automaticallyImplyLeading: true
//       elevation: 0.0, // for elevation
//       titleSpacing: 0.0, // if you want remove title spacing with back button
//       title:  UtilCommonWidget.addTextMedium('About US', Colors.white, 20.0, 1),
//       actions: <Widget>[
//         addAppBarActionWidgetProfile(icon, 30.0, 30.0, 15.0) // add your custom action widget
//       ],//Action icon search as search icon, notification icon
//       leading: new Material( //Custom leading icon, such as back icon or other icon
//         color: Colors.transparent,
//         child: new InkWell(
//             onTap: () {
//               Navigator.of(context).pop();
//             },
//             splashColor: UniQueryColors.colorGradientEnd.alphaSafe(.5),
//             child: new Container(
//                 padding: const .fromLTRB(12.0, 16.0, 16.0, 16.0),
//                 child: UtilCommonWidget.addImage(Constant.iconBack, 19.0, 10.0))
//         ),
//       )
//   );
// }

/*

class CustomAppBar extends AppBar {
  CustomAppBar()
      : super(
    title: Text('MyApp'),
    actions: [
      IconButton(icon: Icon(Icons.search), onPressed: () {}),
    ],
  );
}*/
