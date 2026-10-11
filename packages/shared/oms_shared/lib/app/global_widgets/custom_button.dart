import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../core/values/colors.dart';
import '../core/values/dimens.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? title;
  final Color? titleTextColor;
  final double? width;
  final double? height;
  final double? iconHeight;
  final double? radius;
  final double? fontSize;
  final String? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool? isBorder;
  final Color? borderColor;
  final bool? isLoading;
  final FontWeight? fontWeight;

  const CustomButton({
    super.key,
    this.onPressed,
    this.title,
    this.titleTextColor,
    this.width,
    this.height,
    this.fontSize,
    this.iconHeight,
    this.radius,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.isBorder = false,
    this.borderColor,
    this.isLoading,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading == true ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? ColorConstants.buttonColorLight,
        minimumSize: Size(width ?? Get.width * 0.40, height ?? 56),
        padding: const .symmetric(horizontal: 2, vertical: 2),
        textStyle: Get.textTheme.labelLarge!.copyWith(
          color: titleTextColor ?? ColorConstants.white,
          fontSize: 20,
          fontWeight: fontWeight ?? FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius ?? AppDimens.space12)),
        side: isBorder!
            ? BorderSide(width: 1, color: borderColor ?? ColorConstants.buttonColorLight, style: BorderStyle.solid)
            : null,
      ),
      child: Padding(
        padding: const .symmetric(horizontal: AppDimens.space5),
        child: isLoading == true
            ? Center(
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 3.0, color: ColorConstants.buttonColorLight),
                ),
              )
            : Row(
                mainAxisAlignment: .center,
                crossAxisAlignment: .center,
                children: [
                  icon != null
                      ? SvgPicture.asset(
                          icon.toString(),
                          colorFilter: ColorFilter.mode(iconColor ?? ColorConstants.white, BlendMode.srcIn),
                          height: iconHeight ?? 20,
                        ).paddingOnly(right: title != null ? AppDimens.space8 : 0)
                      : const SizedBox.shrink(),
                  title != null
                      ? Text(
                          title.toString(),
                          style: Get.textTheme.labelLarge!.copyWith(
                            fontSize: fontSize ?? AppDimens.fontSizeMedium,
                            color: titleTextColor ?? ColorConstants.white,
                            fontWeight: fontWeight ?? FontWeight.w600,
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
      ),
    );
  }
}
