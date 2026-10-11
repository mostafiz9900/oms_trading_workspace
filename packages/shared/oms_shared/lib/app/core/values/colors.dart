import 'package:flutter/material.dart';

import '../../app_pkg.dart';

class ColorConstants {
  static Color lightScaffoldBackgroundColor = hexToColor('#F9F9F9');
  static Color darkScaffoldBackgroundColor = hexToColor('#0E1327');
  static Color backgroundColorLight = hexToColor("#FFFFFF");
  static Color backgroundColorDark = hexToColor("#0E1327");
  static Color primaryColor = hexToColor(AppConfig.house.primaryColor);
  static Color primaryColorLight = HexColor('#FFFFFF');
  static Color primaryColorDark = hexToColor('#1C2546');
  static Color buttonColorLight = hexToColor(AppConfig.house.buttonColor);
  static Color buttonColorDark = hexToColor(AppConfig.house.buttonColor);
  static Color secondaryColorDark = hexToColor(AppConfig.house.accentColor);
  static Color secondaryColorLight = hexToColor(AppConfig.house.accentColor);
  static Color unselectedItemColor = HexColor('#6F6F6F');
  static Color unselectedItemColorLight = HexColor('#F8F9FA');
  static Color tapBgLight = HexColor('#EBF2FC');
  static Color tapBgDark = HexColor('#161A33');
  //text color
  static Color textColorLight = hexToColor("#000000");
  static Color textColorDark = hexToColor("#FFFFFF");
  static Color containerSecondLight = hexToColor("#EBF2FC");
  static Color containerSecondDark = hexToColor("#EBF2FC");
  static Color gray = hexToColor("#6E839F");
  static Color white = const Color(0xFFFFFFFF);
  //#929292
  //same as
  static Color error = HexColor('#F70042');
  static Color success = HexColor('#15D350');
  static Color lightBlue = HexColor('#50C7FF');
  static Color brightBlue = HexColor('#6964FE');
  static Color goldenYellow = HexColor('#DFA614');
  static Color coralRed = HexColor('#FF4960');
  static Color yaleBlue = HexColor('#184A94');
  static Color forestGreen = HexColor('#0DB75F');
  //----------------------------------------------------------------
  static Color secondaryAppColor = hexToColor('#22DDA6');
  static Color secondaryDarkAppColor = Colors.white;
  static Color tipColor = hexToColor('#B6B6B6');
  static Color lightGray = const Color(0xFFF6F6F6);
  static Color darkGray = const Color(0xFF9F9F9F);
  static Color black = const Color(0xFF000000);

  static Color whiteColor = Colors.white;

  static Color editTextFillColorLight = hexToColor("#EBF2FC");
  static Color editTextFillColorDart = hexToColor("#EBF2FC");
  static Color iconColor = hexToColor("#CCCCCC");
  static Color mainTextColor = hexToColor("#000000");

  static Color secondaryTextColor = hexToColor("#6B6B6B");
  static Color labelTextColor = hexToColor("#111111");
  static Color hintTextColor = hexToColor("#CCCCCC");
  static Color subTextColor = hexToColor("#B7B7B7");
  static Color blueColor = hexToColor("#177DFF");
  static Color redColor = hexToColor("#F70042");
  static Color greenColor = hexToColor("#3BC900");
  static Color homeTopSectionTextColor = hexToColor("#1E1E1E");
  static Color imgBgColor = hexToColor("#0092D2");
  static Color outlineBorderRedColor = hexToColor("#EF693D");
  static Color textFormBGColor = hexToColor("#F7F7F7");
  static Color lightThemeLightBackTable = hexToColor("#EBF2FC");
  static Color lightThemeDeepBackTable = hexToColor("#D3E0F3");
  static Color lightThemeDividerRightTable = hexToColor("#E0E0E0");
  static Color lightThemeDividerLeftTable = hexToColor("#E2E2E2");
  static Color upColor = hexToColor("#22C665");
  static Color downColor = hexToColor("#F54D64");
  static Color unchangedColor = hexToColor("#177DFF");
}

Color hexToColor(String hex) {
  assert(
    RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex),
    'hex color must be #rrggbb or #rrggbbaa',
  );

  return Color(
    int.parse(hex.substring(1), radix: 16) +
        (hex.length == 7 ? 0xff000000 : 0x00000000),
  );
}

class ColorUtils {
  /// Convert opacity (0.0 – 1.0) to Color alpha (0 – 255)
  static Color applyAlpha(Color color, double opacity) {
    final alpha = (opacity * 255).round();
    return color.withAlpha(alpha);
  }

  /// Safe version for nullable colors
  static Color? applyAlphaSafe(Color? color, double opacity) {
    if (color == null) return null;
    final alpha = (opacity * 255).round();
    return color.withAlpha(alpha);
  }
}

/// ------------------------------------------------------------
/// COLOR EXTENSION — Cleanest way to apply alpha on any Color
/// ------------------------------------------------------------
extension AlphaExtension on Color {
  /// Apply alpha using 0.0 – 1.0 opacity
  Color alphaSafe(double opacity) {
    return withAlpha((opacity * 255).round());
  }

  /// Predefined shortcuts
  Color a10() => alphaSafe(0.10);
  Color a20() => alphaSafe(0.20);
  Color a30() => alphaSafe(0.30);
  Color a40() => alphaSafe(0.40);
  Color a50() => alphaSafe(0.50);
  Color a60() => alphaSafe(0.60);
  Color a70() => alphaSafe(0.70);
  Color a80() => alphaSafe(0.80);
  Color a90() => alphaSafe(0.90);
}
