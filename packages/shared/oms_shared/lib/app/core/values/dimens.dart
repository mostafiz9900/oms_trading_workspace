import 'package:flutter/material.dart';

abstract class AppDimens {
  AppDimens._();

  static EdgeInsets pagePadding({double? horizontal, double? vertical}) => EdgeInsets.symmetric(horizontal: horizontal ?? 15, vertical: vertical ?? 15);
  static const double mobileScreenSize = 340;
  static const double tabletScreenSize = 640;
  static const double desktopScreenSize = 1440;

  static const double defaultScreenWidth = 320.0;
  static const double defaultScreenHeight = 640.0;
  static const bool allowFontScalling = false;
  static const double activityHorizontalMargin = 16.0;
  static const double navHeaderVerticalSpacing = 8.0;
  static const double navHeaderHeight = 176.0;

  static const double progressBarHeight = 2.0;

  static const double marginXSmall = 16.0;
  static const double marginSmall = 32.0;
  static const double marginNormal = 42.0;
  static const double marginMedium = 48.0;
  static const double marginXLarge = 92.0;

  static const double spacingSmall = 4.0;
  static const double spacingMedium = 8.0;

  static const double otherButtonSmall = 20.0;

  // VIDEO TRIMMER
  static const double progressVideoLineHeight = 2.0;
  static const double framesVideoHeight = 40.0;

  static const double textSizeVerySmall = 13.0;
  static const double textSizeSmall = 16.0;
  static const double textSizeMedium = 18.0;
  static const double textSizeLarge = 18.0; // Note: this duplicates textSizeLarge from Android, check if needed
  static const double textSizeTiny = 10.0;
  static const double textHeader = 25.0;
  static const double textProfile = 32.0;

  static const double activityVerticalMargin = 16.0;
  static const double localPreviewMarginTop = 28.0;
  static const double localPreviewMarginRight = 24.0;

  // buttons
  static const double callButtonSize = 60.0;

  static double spacePageHorizontal = 15;
  static double spacePageVertical = 15;
  static int timeout = 500;

  static const double space1 = 1;
  static const double space2 = 2;
  static const double space3 = 3;
  static const double space4 = 4;
  static const double space5 = 5;
  static const double space6 = 6;
  static const double space7 = 7;
  static const double space8 = 8;
  static const double space9 = 9;
  static const double space10 = 10;
  static const double space11 = 11;
  static const double space12 = 12;
  static const double space13 = 13;
  static const double space14 = 14;
  static const double space15 = 15;
  static const double space16 = 16;
  static const double space17 = 17;
  static const double space18 = 18;
  static const double space19 = 19;
  static const double space20 = 20;
  static const double space21 = 21;
  static const double space22 = 22;
  static const double space23 = 23;
  static const double space24 = 24;
  static const double space25 = 25;
  static const double space26 = 26;
  static const double space27 = 27;
  static const double space28 = 28;
  static const double space29 = 29;
  static const double space30 = 30;
  static const double space31 = 31;
  static const double space32 = 32;
  static const double space33 = 33;
  static const double space34 = 34;
  static const double space35 = 35;
  static const double space36 = 36;
  static const double space37 = 37;
  static const double space38 = 38;
  static const double space39 = 39;
  static const double space40 = 40;
  static const double space41 = 41;
  static const double space42 = 42;
  static const double space43 = 43;
  static const double space44 = 44;
  static const double space45 = 45;
  static const double space46 = 46;
  static const double space47 = 47;
  static const double space48 = 48;
  static const double space49 = 49;
  static const double space50 = 50;
  static const double space51 = 51;
  static const double space52 = 52;
  static const double space53 = 53;
  static const double space54 = 54;
  static const double space55 = 55;
  static const double space56 = 56;
  static const double space57 = 57;
  static const double space58 = 58;
  static const double space59 = 59;
  static const double space60 = 60;
  static const double space61 = 61;
  static const double space62 = 62;
  static const double space63 = 63;
  static const double space64 = 64;
  static const double space65 = 65;
  static const double space66 = 66;
  static const double space67 = 67;
  static const double space68 = 68;
  static const double space69 = 69;
  static const double space70 = 70;
  static const double space71 = 71;
  static const double space72 = 72;
  static const double space73 = 73;
  static const double space74 = 74;
  static const double space75 = 75;
  static const double space76 = 76;
  static const double space77 = 77;
  static const double space78 = 78;
  static const double space79 = 79;
  static const double space80 = 80;
  static const double space81 = 81;
  static const double space82 = 82;
  static const double space83 = 83;
  static const double space84 = 84;
  static const double space85 = 85;
  static const double space86 = 86;
  static const double space87 = 87;
  static const double space88 = 88;
  static const double space89 = 89;
  static const double space90 = 90;
  static const double space91 = 91;
  static const double space92 = 92;
  static const double space93 = 93;
  static const double space94 = 94;
  static const double space95 = 95;
  static const double space96 = 96;
  static const double space97 = 97;
  static const double space98 = 98;
  static const double space99 = 99;
  static const double space100 = 100;

  static const bool allowFontScaling = false;

  static double paddingWidthMint = 2.0;
  static double paddingWidthExtraSmall = 5.0;
  static double paddingWidthRadius = 8.0;
  static double paddingWidthSmall = 10.0;
  static double paddingWidthDefault = 16.0;
  static double paddingWidthMedium = 20.0;
  static double paddingWidthLarge = 24.0;
  static double paddingWidthExtraLarge = 32.0;

  static double paddingHeightMint = 2.0;
  static double paddingHeightExtraSmall = 5.0;
  static double paddingHeightRadius = 8.0;
  static double paddingHeightSmall = 10.0;
  static double paddingHeightDefault = 16.0;
  static double paddingHeightMedium = 20.0;
  static double paddingHeightLarge = 24.0;
  static double paddingHeightExtraLarge = 32.0;
  static double paddingHeightMoreExtraLarge = 52.0;

  static double fontSizeMint = 8;
  static double fontSizeExtraSmall = 10;
  static double fontSizeSmall = 12;
  static double fontSizeDefault = 14;
  static double fontSizeMedium = 16;
  static double fontSizeExtraMedium = 18;
  static double fontSizeExtra = 21;
  static double fontSizeLarge = 24;

  static double radiusMint = 3.0;
  static double radiusSmall = 5.0;
  static double radiusDefault = 10.0;
  static double radiusLarge = 15.0;
  static double radiusExtraLarge = 20.0;
  static double radiusExtraMoreLarge = 50.0;

  static double iconDefault = 24;
}
