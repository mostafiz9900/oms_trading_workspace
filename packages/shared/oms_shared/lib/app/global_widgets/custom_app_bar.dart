import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../core/utils/extensions/app_context.dart';
import '../core/values/assets.dart';
import '../routes/app_routes.dart';

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

//     //automaticallyImplyLeading: true

