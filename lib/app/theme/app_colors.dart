import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color primaryGreenDark = Color(0xFF0D2218);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C97A);
  static const Color goldDark = Color(0xFF9A7A2E);
  // WCAG AA compliant gold for text on light backgrounds (≥4.5:1 on backgroundParchment)
  static const Color goldText = Color(0xFF7B5F00);

  // Background & Surface
  static const Color backgroundParchment = Color(0xFFF5E6C8);
  static const Color surfaceIvory = Color(0xFFFAF0DC);
  static const Color surfaceCard = Color(0xFFF0E0BE);

  // Text
  static const Color textDark = Color(0xFF3D1F00);
  static const Color textMedium = Color(0xFF6B3A1F);
  static const Color textMuted = Color(0xFF7A5C3C);
  static const Color textOnDark = Color(0xFFFAF0DC);

  // Dark Mode
  static const Color darkBackground = Color(0xFF1A1209);
  static const Color darkSurface = Color(0xFF2A1F0E);
  static const Color darkCard = Color(0xFF332810);

  // Status Colors
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFC9A84C);
  static const Color error = Color(0xFF8B0000);

  // Navigation
  static const Color navBackground = Color(0xFF0A1A10);
  static const Color navActive = Color(0xFFC9A84C);
  static const Color navInactive = Color(0x80FAF0DC);

  // Card Shadows (pre-computed ARGB — gold at 30% and 20% opacity)
  static const Color cardShadowLight = Color(0x4DC9A84C);
  static const Color cardShadowDark = Color(0x33C9A84C);

  // Dark nav bar base (deeper than navBackground for layering)
  static const Color darkNavBarBackground = Color(0xFF0A0A05);
}
