import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme of(BuildContext context) => Theme.of(context).textTheme;

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.manrope(
        fontSize: 44,
        fontWeight: FontWeight.w800,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.manrope(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.16,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.22,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.28,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
        height: 1.25,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.38,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.42,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.36,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        height: 1.32,
      ),
    );
  }
}
