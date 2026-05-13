import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global typography for AquaSave.
///
/// A consistent two-font system: **Manrope** for display & headline text (the
/// strong, expressive sizes) and **Inter** for titles, body and labels (clean
/// and highly legible). Every text slot is defined so no widget ever falls back
/// to an unstyled Material default.
class AppTextStyles {
  AppTextStyles._();

  static TextTheme of(BuildContext context) => Theme.of(context).textTheme;

  static TextStyle _display(double size, {double height = 1.14}) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: height,
        letterSpacing: 0,
      );

  static TextStyle _heading(double size, {double height = 1.22}) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: height,
        letterSpacing: 0,
      );

  static TextStyle _title(double size, {double height = 1.3}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: height,
      );

  static TextStyle _body(
    double size, {
    double height = 1.42,
    FontWeight weight = FontWeight.w500,
  }) => GoogleFonts.inter(fontSize: size, fontWeight: weight, height: height);

  static TextStyle _label(double size, {double height = 1.3}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: height,
        letterSpacing: 0.2,
      );

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: _display(44, height: 1.12),
      displayMedium: _display(30, height: 1.16),
      displaySmall: _display(26, height: 1.2),
      headlineLarge: _heading(28),
      headlineMedium: _heading(24),
      headlineSmall: _heading(20),
      titleLarge: _title(19, height: 1.26),
      titleMedium: _title(17, height: 1.28),
      titleSmall: _title(15, height: 1.3),
      bodyLarge: _body(19, height: 1.4),
      bodyMedium: _body(16, height: 1.42),
      bodySmall: _body(14, height: 1.36),
      labelLarge: _label(13.5, height: 1.25),
      labelMedium: _label(13),
      labelSmall: _label(11.5),
    );
  }
}
