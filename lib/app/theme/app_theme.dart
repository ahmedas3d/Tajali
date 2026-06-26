import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: AppFonts.amiri,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryGreen,
          secondary: AppColors.gold,
          surface: AppColors.surfaceIvory,
          error: AppColors.error,
          onPrimary: AppColors.textOnDark,
          onSecondary: AppColors.textDark,
          onSurface: AppColors.textDark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundParchment,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.textOnDark,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: AppTextStyles.onDarkBold,
          iconTheme: IconThemeData(color: AppColors.gold),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.surfaceIvory,
          elevation: 2,
          shadowColor: AppColors.cardShadowLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: AppColors.gold, width: 1),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.gold,
          thickness: 0.8,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.navBackground,
          selectedItemColor: AppColors.navActive,
          unselectedItemColor: AppColors.navInactive,
          selectedLabelStyle: TextStyle(
            fontFamily: AppFonts.amiri,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: AppFonts.amiri,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.heading1,
          displayMedium: AppTextStyles.heading2,
          displaySmall: AppTextStyles.heading3,
          bodyLarge: AppTextStyles.body,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.goldLabel,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: AppFonts.amiri,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.primaryGreen,
          surface: AppColors.darkSurface,
          error: AppColors.error,
          onPrimary: AppColors.darkBackground,
          onSecondary: AppColors.textOnDark,
          onSurface: AppColors.textOnDark,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.textOnDark,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: AppFonts.amiri,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
          iconTheme: IconThemeData(color: AppColors.gold),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.darkCard,
          elevation: 2,
          shadowColor: AppColors.cardShadowDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: AppColors.goldDark, width: 1),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkNavBarBackground,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.navInactive,
          type: BottomNavigationBarType.fixed,
        ),
      );
}
