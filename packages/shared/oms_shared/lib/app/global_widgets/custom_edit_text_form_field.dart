import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../app_pkg.dart';

class CustomEditTextFormField extends StatelessWidget {
  final String? hintText;
  final bool? isBorder;
  final bool isIcon;
  final int? maxLine;
  final IconData? icon;
  final double? borderRadius;
  final TextEditingController? controller;
  final bool? readOnly;
  final bool isFocusedBorder;
  final bool isEnabledBorder;
  final bool autoFocus;
  final GestureTapCallback? onTap;
  final VoidCallback? suffixOnTap;
  final String? suffixIcon;
  final String? prefixIcon;
  final TextInputType? keyboardType;
  final Color? backgroundColor;
  final Color? hintTextColor;
  final String? Function(String?)? validator;
  final bool? passwordVisible;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final AutovalidateMode? validateMode;
  final TextStyle? hintStyle;
  final Function()? onChanging;
  final double? cursorHeight;
  final double? cursorWidth;
  final bool? enableInteractiveSelection;

  //  New Properties for Flexibility & Accessibility (Backward Compatible)
  final double minHeight;
  final double? fontSize;

  const CustomEditTextFormField({
    super.key,
    this.hintText,
    this.isBorder = false,
    this.controller,
    this.maxLine,
    this.borderRadius,
    this.isIcon = false,
    this.icon,
    this.readOnly,
    this.onTap,
    this.isFocusedBorder = true,
    this.suffixOnTap,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType,
    this.backgroundColor,
    this.hintTextColor,
    this.validator,
    this.passwordVisible,
    this.inputFormatters,
    this.hintStyle,
    this.initialValue,
    required this.onChanged,
    this.validateMode,
    this.onChanging,
    this.autoFocus = false,
    this.isEnabledBorder = true,
    this.cursorHeight,
    this.cursorWidth,
    this.enableInteractiveSelection,
    this.minHeight = 54.0, //  Default 54 रखा হয়েছে যাতে আগের কোনো UI না ভাঙে
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTapOutside: (PointerDownEvent event) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      controller: controller,
      cursorHeight: cursorHeight,
      cursorWidth: cursorWidth ?? 2.0,
      autovalidateMode: validateMode ?? AutovalidateMode.onUserInteraction,
      readOnly: readOnly ?? false,
      enableInteractiveSelection: enableInteractiveSelection ?? true,
      onTap: onTap,
      maxLines: maxLine ?? 1,
      keyboardType: keyboardType,
      textAlign: TextAlign.left,
      initialValue: initialValue,
      textAlignVertical: TextAlignVertical.center,

      onFieldSubmitted: (String? value) {
        if (value != null) {
          onChanged(value);
        }
      },
      //  Accessible text styling
      style: TextStyle(
        color: context.textColor,
        fontSize: fontSize ?? 14, //  বয়স্কদের পড়ার সুবিধার জন্য 13 থেকে 14 করা হয়েছে (M3 Standard)
        fontWeight: FontWeight.w500,
      ),
      onChanged: (String? value) {
        if (value != null) {
          onChanged(value);
        }
      },
      autofocus: autoFocus,
      validator: validator,
      inputFormatters: inputFormatters,
      obscureText: passwordVisible ?? false,
      decoration: InputDecoration(
        isDense: true,
        //  Touch Target বড় করার জন্য প্যাডিং ব্যালেন্স করা হয়েছে
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),

        filled: true,
        fillColor: backgroundColor ?? context.tapBg,
        //  ডায়নামিক হাইট কন্ট্রোল
        constraints: BoxConstraints(minHeight: minHeight, maxWidth: Get.width),
        hintTextDirection: TextDirection.ltr,
        hintText: hintText,
        hintStyle:
            hintStyle ??
            Get.textTheme.bodyMedium?.copyWith(
              color: hintTextColor ?? context.textColor?.withValues(alpha: 0.50), //  Deprecated API Fixed
              fontSize: fontSize ?? 14,
            ),
        errorMaxLines: 2,
        enabled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? AppDimens.space10)),
          borderSide: BorderSide(
            color: isEnabledBorder ? ColorConstants.primaryColorLight.alphaSafe(0.50) : Colors.transparent,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? AppDimens.space10)),
          borderSide: BorderSide(
            color: isFocusedBorder ? ColorConstants.primaryColorLight.alphaSafe(0.50) : Colors.transparent,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? AppDimens.space10)),
          borderSide: BorderSide(color: Colors.red.alphaSafe(0.60), width: 1.2),
        ),
        //  Added Error Border (Missing before)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? AppDimens.space10)),
          borderSide: BorderSide(color: Colors.red.alphaSafe(0.60), width: 1.2),
        ),
        suffixIcon: suffixIcon != null
            ? InkWell(
                onTap: suffixOnTap,
                borderRadius: BorderRadius.circular(AppDimens.space14), //  Added Ripple Effect Radius
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.space14), //  Syntax Fixed (.all to EdgeInsets.all)
                  child: SvgPicture.asset(
                    suffixIcon.toString(),
                    height: AppDimens.space10,
                    width: AppDimens.space10,
                    colorFilter: ColorFilter.mode(hexToColor('#177DFF'), BlendMode.srcIn),
                  ),
                ),
              )
            : null,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(
                  left: AppDimens.space20,
                  top: AppDimens.space8,
                  bottom: AppDimens.space8,
                  right: AppDimens.space12,
                ),
                child: SvgPicture.asset(
                  prefixIcon.toString(),
                  height: AppDimens.space16,
                  width: AppDimens.space16,
                  colorFilter: ColorFilter.mode(hexToColor('#177DFF'), BlendMode.srcIn),
                ),
              )
            : null,
      ),
    );
  }
}
