import 'package:flutter/material.dart';

// Fonts: Source Serif 4 (headings), Source Sans Pro (body), Poppins (nav/labels)
// Register these in pubspec.yaml when font files are added.
// Currently uses generic fallbacks; swap fontFamily strings once assets are available.

class AppTextStyles {
  AppTextStyles._();

  static const String _serif   = 'SourceSerif4';
  static const String _sans    = 'SourceSansPro';
  static const String _poppins = 'Poppins';

  // Desktop/wide text theme (width >= 800)
  static const TextTheme textTheme = TextTheme(
    // "Bienvenido de vuelta" — 40sp SemiBold serif
    displayLarge: TextStyle(
      fontFamily: _serif,
      fontSize: 40,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    // Screen titles — 26sp SemiBold serif
    displayMedium: TextStyle(
      fontFamily: _serif,
      fontSize: 26,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    // Section headings — 20sp Bold serif
    headlineMedium: TextStyle(
      fontFamily: _serif,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    // Nav items, labels — 15sp Medium Poppins
    titleMedium: TextStyle(
      fontFamily: _poppins,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    // Field labels — 14sp Bold serif
    labelLarge: TextStyle(
      fontFamily: _serif,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
    // Body text — 18sp Regular Source Sans Pro
    bodyLarge: TextStyle(
      fontFamily: _sans,
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    // General body — 15sp Regular Source Sans Pro
    bodyMedium: TextStyle(
      fontFamily: _sans,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    // Small/hint — 13sp Regular Source Sans Pro
    bodySmall: TextStyle(
      fontFamily: _sans,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    // Button label — 16sp SemiBold Source Sans Pro
    labelMedium: TextStyle(
      fontFamily: _sans,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
  );

  // Mobile text theme (width < 800) — smaller scale
  static const TextTheme mobileTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _serif,
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontFamily: _serif,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontFamily: _serif,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontFamily: _poppins,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    labelLarge: TextStyle(
      fontFamily: _serif,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    ),
    bodyLarge: TextStyle(
      fontFamily: _sans,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      fontFamily: _sans,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontFamily: _sans,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontFamily: _sans,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
  );

  /// Returns the appropriate TextTheme based on screen width.
  static TextTheme of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 800 ? textTheme : mobileTextTheme;
  }
}
