import 'package:oms_shared/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;
  double get dynamicHeight => MediaQuery.of(this).size.height;
  double get dynamicWidth => MediaQuery.of(this).size.width;
  ColorScheme get colorScheme => theme.colorScheme;
  Brightness get brightness => theme.brightness;
  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;
  Color get bgColor => isDark
      ? ColorConstants.darkScaffoldBackgroundColor
      : ColorConstants.primaryColorLight;
  Color get textColor =>
      isDark ? ColorConstants.textColorDark : ColorConstants.textColorLight;
  Color get buttonColor =>
      isDark ? ColorConstants.buttonColorDark : ColorConstants.buttonColorLight;
  Color get containerSecond => isDark
      ? ColorConstants.containerSecondDark
      : ColorConstants.containerSecondLight;
  Color get titleTextAlertDialog =>
      isDark ? ColorConstants.white : hexToColor('#177DFF');
  Color get borderColor =>
      isDark ? hexToColor('#242C43') : hexToColor('#D6D6D6');
  Color get dividerColor =>
      isDark ? hexToColor('#2E3566') : hexToColor('#ECECEC');
  Color get tableDeepColor =>
      isDark ? hexToColor('#2E3566') : hexToColor('#D3E0F3');
  Color get tableLightColor =>
      isDark ? hexToColor('#2E3566') : hexToColor('#EBF2FC');
  Color get tapCustomBgColor =>
      isDark ? hexToColor('#21264A') : hexToColor('#EBF2FC');
  Color get cardColor => isDark ? hexToColor('#161A33') : hexToColor('#FFFFFF');
  Color get tapBg =>
      isDark ? ColorConstants.tapBgDark : ColorConstants.tapBgLight;
  Color get evenColor => isDark
      ? hexToColor('#1C2546')
      : ColorConstants.containerSecondLight; // Light mode even color
  Color get oddColor =>
      isDark ? ColorConstants.backgroundColorDark : ColorConstants.white;
  Color get borderSideColor =>
      isDark ? hexToColor('#1F3759') : hexToColor('#D9E7FC');
  Color get unselectColor =>
      isDark ? hexToColor('#B9C1D9') : hexToColor('#6F6F6F');
  Color get iconDefColor =>
      isDark ? ColorConstants.textColorDark : HexColor('#184A94');
  String get bannerLogo =>
      isDark ? AssetsConstants.darkLogoSvg : AssetsConstants.logoSvg;
}

extension CustomFontWeight on FontWeight {
  // Custom weights
  static const FontWeight w450 = FontWeight(450);
  static const FontWeight w550 = FontWeight(550);
  static const FontWeight w650 = FontWeight(650);
  static const FontWeight w750 = FontWeight(750);
  static const FontWeight w850 = FontWeight(850);
}

extension NetworkCheck on GetxController {
  Future<bool> checkInternet({bool showSnackbar = true}) async {
    bool hasInternet = await NetworkUtil.isConnected();
    if (!hasInternet && showSnackbar && !Get.isSnackbarOpen) {
      Get.snackbar(
        "No Internet",
        "Please check your internet connection.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return hasInternet;
  }
}
