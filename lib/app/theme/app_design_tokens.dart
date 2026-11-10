import 'package:flutter/material.dart';

/// LifePilot design tokens — color palette, spacing, radius, durations.
abstract final class AppColors {
  // ── Primary Palette ──
  static const darkNavy = Color(0xFF0A1628);
  static const deepBlack = Color(0xFF050A12);
  static const electricBlue = Color(0xFF2979FF);
  static const electricBlueLight = Color(0xFF5C9AFF);
  static const electricBlueDark = Color(0xFF0056CB);
  static const white = Color(0xFFFFFFFF);
  static const softGray = Color(0xFFB0BEC5);

  // ── Neutral Grays ──
  static const gray50 = Color(0xFFFAFAFA);
  static const gray100 = Color(0xFFF5F5F5);
  static const gray200 = Color(0xFFEEEEEE);
  static const gray300 = Color(0xFFE0E0E0);
  static const gray400 = Color(0xFFBDBDBD);
  static const gray500 = Color(0xFF9E9E9E);
  static const gray600 = Color(0xFF757575);
  static const gray700 = Color(0xFF616161);
  static const gray800 = Color(0xFF424242);
  static const gray900 = Color(0xFF212121);

  // ── Surface (Dark) ──
  static const surfaceDark = Color(0xFF0D1B2A);
  static const surfaceDarkElevated = Color(0xFF122240);
  static const cardDark = Color(0xFF152238);

  // ── Surface (Light) ──
  static const surfaceLight = Color(0xFFF8F9FB);
  static const cardLight = Color(0xFFFFFFFF);

  // ── Semantic ──
  static const success = Color(0xFF00E676);
  static const warning = Color(0xFFFFAB00);
  static const error = Color(0xFFFF5252);
  static const info = Color(0xFF40C4FF);
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 400);
  static const slow = Duration(milliseconds: 600);
  static const splash = Duration(milliseconds: 2500);
}
