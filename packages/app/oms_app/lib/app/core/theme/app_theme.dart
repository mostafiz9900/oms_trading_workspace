import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_pkg.dart';

class AppTheme {
  static const List<FontFeature> stockFontFeatures = [
    FontFeature.tabularFigures(), // নম্বরগুলো কলাম বরাবর সোজা রাখবে
    FontFeature.slashedZero(), // শূন্য (0) এর মাঝখানে দাগ (slash) দেবে
    FontFeature.liningFigures(), // সবগুলো নম্বর সমান বেসলাইনে রাখবে
  ];

  /// Light Theme
  ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: ColorConstants.primaryColorLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.white,
      brightness: Brightness.light,
      surface: ColorConstants.primaryColorLight,
      onSurface: Colors.black,
      primary: Colors.black,
      secondary: Colors.red,
    ),
    scaffoldBackgroundColor: ColorConstants.backgroundColorLight,
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Colors.blue.shade300,
      selectionHandleColor: Colors.blue,
      cursorColor: Colors.blue,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.blue[100], // Background color for context menu
      textStyle: TextStyle(color: Colors.black), // Text color
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorConstants.white,
      elevation: 0,
      // systemOverlayStyle: SystemUiOverlayStyle.dark, // modified system overlay style for dark theme
      iconTheme: IconThemeData(color: ColorConstants.black),
      titleTextStyle: TextStyle(color: ColorConstants.primaryColor, fontWeight: FontWeight.w500, fontSize: 21),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white, // <-- Status bar color
        statusBarIconBrightness: Brightness.dark, // <-- For Android (dark icons)
        statusBarBrightness: Brightness.light, // <-- For iOS (dark icons)
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        // foregroundColor: ColorConstants.secondaryColorLight,
        backgroundColor: ColorConstants.buttonColorLight,
        textStyle: GoogleFonts.ibmPlexSans(
          // fontFeatures: stockFontFeatures,
          textStyle: TextStyle(
            color: ColorConstants.white,
            fontSize: 16,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: ColorConstants.primaryColorLight),
    ),
    cardTheme: const CardThemeData(color: Colors.white),
    brightness: Brightness.light,

    // primaryTextTheme: TextTheme(
    //   bodyMedium: AppTextStyleLight.displayMedium,
    // ),
    dividerColor: hexToColor('#D8D8D8'),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: ColorConstants.editTextFillColorLight,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppDimens.space14)),
        borderSide: BorderSide(color: ColorConstants.primaryColorLight.withAlpha((0.20 * 255).toInt()), width: 1.2),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDimens.space14)),
        borderSide: BorderSide(color: Colors.transparent, width: 1.2),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.primaryColorLight,
          fontSize: 57,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
        ),
      ),
      displayMedium: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.primaryColorLight.withAlpha((0.80 * 255).toInt()),
          fontSize: 45,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
        ),
      ),
      displaySmall: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.primaryColorLight.withAlpha((0.60 * 255).toInt()),
          fontSize: 36,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
        ),
      ),
      headlineMedium: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.textColorLight,
          fontSize: 32,
          height: 40,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
        ),
      ),
      headlineSmall: GoogleFonts.ibmPlexSans(
        textStyle: TextStyle(
          color: ColorConstants.textColorLight.withAlpha((0.80 * 255).toInt()),
          fontSize: 24,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
        ),
      ),
      titleLarge: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.yaleBlue,
          fontSize: 25,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w700,
        ),
      ),
      titleMedium: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.yaleBlue.withAlpha((0.90 * 255).toInt()),
          fontSize: 20,
          letterSpacing: 0.15,
          fontWeight: FontWeight.w500,
        ),
      ),
      titleSmall: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.yaleBlue.withAlpha((0.60 * 255).toInt()),
          fontSize: 18,
          letterSpacing: 0.1,
          fontWeight: FontWeight.w400,
        ),
      ),
      bodyLarge: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(color: ColorConstants.textColorLight, fontSize: 16, fontWeight: FontWeight.normal),
      ),
      bodyMedium: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.textColorLight.withAlpha((0.60 * 255).toInt()),
          fontSize: 14,
          letterSpacing: 0.25,
          fontWeight: FontWeight.normal,
        ),
      ),
      bodySmall: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.textColorLight.withAlpha((0.50 * 255).toInt()),
          fontSize: 12,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w500,
        ),
      ),
      labelLarge: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.textColorLight,
          fontSize: 14,
          letterSpacing: 0.1,
          fontWeight: FontWeight.w500,
        ),
      ),
      labelMedium: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.textColorLight,
          fontSize: 12,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      labelSmall: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(color: HexColor('#9ba0a5'), fontSize: 11, letterSpacing: 0.5, fontWeight: FontWeight.w500),
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white, size: 25.0),
    buttonTheme: ButtonThemeData(
      buttonColor: ColorConstants.buttonColorLight,
      disabledColor: Colors.grey,
      textTheme: ButtonTextTheme.accent,
    ),
    // appBarTheme: AppBarTheme(
    //   backgroundColor: AppColors.primaryColor,
    //   titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
    //   iconTheme: const IconThemeData(color: Colors.white),
    //   systemOverlayStyle: SystemUiOverlayStyle(
    //       statusBarIconBrightness: Brightness.light,
    //       statusBarColor: AppColors.primaryColor),
    // ),
    tabBarTheme: TabBarThemeData(
      //salmasharif013@gmail.com
      labelColor: hexToColor('#EBF2FC'),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Colors.white),
    bottomAppBarTheme: BottomAppBarThemeData(color: ColorConstants.buttonColorLight),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: ColorConstants.primaryColorLight),
    navigationBarTheme: NavigationBarThemeData(backgroundColor: ColorConstants.primaryColorLight),
  );

  /// Dark Theme
  /// Dark Theme
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    primaryColor: Colors.amber,
    scaffoldBackgroundColor: ColorConstants.backgroundColorDark,
    cardColor: Colors.black,
    cardTheme: CardThemeData(color: Colors.red),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorConstants.darkScaffoldBackgroundColor,
      titleTextStyle: const TextStyle(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: ColorConstants.primaryColorDark,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorConstants.buttonColorDark,
        textStyle: GoogleFonts.ibmPlexSans(
          // fontFeatures: stockFontFeatures,
          textStyle: TextStyle(
            color: ColorConstants.white,
            fontSize: 16,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      //salmasharif013@gmail.com
      labelColor: hexToColor('#161A33'),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: ColorConstants.primaryColorDark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: ColorConstants.editTextFillColorDart,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppDimens.space14)),
        borderSide: BorderSide(color: Colors.grey.shade600, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppDimens.space14)),
        borderSide: BorderSide(color: Colors.grey.shade800, width: 1.2),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.textColorDark,
          fontSize: 57,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
        ),
      ),
      displayMedium: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.textColorDark.withAlpha((0.80 * 255).toInt()),
          fontSize: 45,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
        ),
      ),
      displaySmall: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.textColorDark.withAlpha((0.60 * 255).toInt()),
          fontSize: 36,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
        ),
      ),
      headlineMedium: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.textColorDark,
          fontSize: 32,
          height: 40,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
        ),
      ),
      headlineSmall: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.textColorDark.withAlpha((0.80 * 255).toInt()),
          fontSize: 24,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
        ),
      ),
      titleLarge: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.textColorDark,
          fontSize: 25,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w700,
        ),
      ),
      bodyLarge: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(color: ColorConstants.textColorDark, fontSize: 16, fontWeight: FontWeight.normal),
      ),
      bodyMedium: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(
          color: ColorConstants.textColorDark.withAlpha((0.80 * 255).toInt()),

          fontSize: 14,
          letterSpacing: 0.25,
          fontWeight: FontWeight.normal,
        ),
      ),
      bodySmall: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(color: HexColor("#ffffff"), fontSize: 12, letterSpacing: 0.4, fontWeight: FontWeight.w500),
      ),
      labelSmall: GoogleFonts.ibmPlexSans(
        // fontFeatures: stockFontFeatures,
        textStyle: TextStyle(color: HexColor('#AEAEB2'), fontSize: 11, letterSpacing: 0.5, fontWeight: FontWeight.w500),
      ),
    ),

    iconTheme: const IconThemeData(color: Colors.white, size: 25.0),
    buttonTheme: const ButtonThemeData(buttonColor: Colors.amber, disabledColor: Colors.grey),
    drawerTheme: DrawerThemeData(backgroundColor: hexToColor('#293563')),
    dividerColor: Colors.grey.shade700,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: ColorConstants.primaryColorDark),
    navigationBarTheme: NavigationBarThemeData(backgroundColor: ColorConstants.primaryColorDark),
  );
}
