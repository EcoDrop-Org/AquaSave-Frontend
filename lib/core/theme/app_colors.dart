import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light
  static const Color lightBackground = Color(0xFFF3F7EF);
  static const Color lightSurface = Color(0xFFEAF3E5);
  static const Color lightPrimary = Color(0xFF497654);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF2D3D2C);
  static const Color lightTextSub = Color(0xFF767575);
  static const Color lightCard = Color(0xFFF8FBF4);
  static const Color lightInputBg = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFD9E2D3);

  // Dark — rebalanced to break the green-on-green muddiness:
  // background is darker and slightly cooler, cards lift clearly off it,
  // primary is brighter for stronger pop on buttons/icons/borders.
  static const Color darkBackground = Color(0xFF0F1A18);
  static const Color darkSurface = Color(0xFF162421);
  static const Color darkPrimary = Color(0xFF7FD09E);
  static const Color darkOnPrimary = Color(0xFF06231A);
  static const Color darkText = Color(0xFFE7EFE9);
  static const Color darkTextSub = Color(0xFFA1B0A6);
  static const Color darkCard = Color(0xFF1D2E2A);
  static const Color darkInputBg = Color(0xFF162421);
  static const Color darkDivider = Color(0xFF2F433E);

  // Shared
  static const Color secondary = Color(0xFFFE5C73);
  static const Color darkTitleText = Color(0xFF2D3D2C);
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color linkColor = Color(0xFF497654);
}
