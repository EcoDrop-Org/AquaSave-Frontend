import 'package:flutter/material.dart';

// Fonts: Source Serif 4 (headings), Source Sans Pro (body), Poppins (nav/labels)
// Register these in pubspec.yaml when font files are added.
// Currently uses generic fallbacks; swap fontFamily strings once assets are available.

class AppTextStyles {
  AppTextStyles._();

  static const String _serif   = 'SourceSerif4';
  static const String _sans    = 'SourceSansPro';
  static const String _poppins = 'Poppins';

  static const TextTheme textTheme = TextTheme(
    // "Bienvenido de vuelta" — 48sp SemiBold serif
    displayLarge: TextStyle(
      fontFamily: _serif,
      fontSize: 48,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    // Screen titles — 32sp SemiBold serif
    displayMedium: TextStyle(
      fontFamily: _serif,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    // Section headings — 24sp Bold serif
    headlineMedium: TextStyle(
      fontFamily: _serif,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    // Nav items, labels — 18sp Medium Poppins
    titleMedium: TextStyle(
      fontFamily: _poppins,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    // Field labels — 15sp Bold serif
    labelLarge: TextStyle(
      fontFamily: _serif,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
    // Body text — 24sp Regular Source Sans Pro
    bodyLarge: TextStyle(
      fontFamily: _sans,
      fontSize: 24,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    // General body — 16sp Regular Source Sans Pro
    bodyMedium: TextStyle(
      fontFamily: _sans,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    // Small/hint — 14sp Regular Source Sans Pro
    bodySmall: TextStyle(
      fontFamily: _sans,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    // Button label — 24sp SemiBold Source Sans Pro
    labelMedium: TextStyle(
      fontFamily: _sans,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
  );
}
