import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings
  static const TextStyle heading1 = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.goldText,
    height: 1.4,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.4,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.4,
  );

  // Body
  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 16,
    color: AppColors.textDark,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 13,
    color: AppColors.textMedium,
    height: 1.5,
  );

  // Quran Text
  static const TextStyle quranText = TextStyle(
    fontFamily: AppFonts.amiriQuran,
    fontSize: 24,
    color: AppColors.textDark,
    height: 2.0,
  );

  // Gold Label
  static const TextStyle goldLabel = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.goldText,
    letterSpacing: 0.5,
  );

  // On Dark Background
  static const TextStyle onDark = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 16,
    color: AppColors.textOnDark,
    height: 1.6,
  );

  static const TextStyle onDarkBold = TextStyle(
    fontFamily: AppFonts.amiri,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnDark,
  );
}
