import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notixa_palette.dart';

class NotixaTypography {
  NotixaTypography._();

  static TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.cairo(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: NotixaPalette.textPrimaryDark,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.cairo(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: NotixaPalette.textPrimaryDark,
    ),
    displaySmall: GoogleFonts.cairo(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: NotixaPalette.textPrimaryDark,
    ),
    headlineMedium: GoogleFonts.cairo(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: NotixaPalette.textPrimaryDark,
    ),
    titleLarge: GoogleFonts.cairo(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: NotixaPalette.textPrimaryDark,
    ),
    titleMedium: GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: NotixaPalette.textPrimaryDark,
    ),
    bodyLarge: GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: NotixaPalette.textPrimaryDark,
    ),
    bodyMedium: GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: NotixaPalette.textSecondaryDark,
    ),
    bodySmall: GoogleFonts.cairo(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: NotixaPalette.textMutedDark,
    ),
    labelLarge: GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: NotixaPalette.textPrimaryDark,
    ),
  );

  static TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.cairo(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: NotixaPalette.textPrimaryLight,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.cairo(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: NotixaPalette.textPrimaryLight,
    ),
    displaySmall: GoogleFonts.cairo(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: NotixaPalette.textPrimaryLight,
    ),
    headlineMedium: GoogleFonts.cairo(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: NotixaPalette.textPrimaryLight,
    ),
    titleLarge: GoogleFonts.cairo(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: NotixaPalette.textPrimaryLight,
    ),
    titleMedium: GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: NotixaPalette.textPrimaryLight,
    ),
    bodyLarge: GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: NotixaPalette.textPrimaryLight,
    ),
    bodyMedium: GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: NotixaPalette.textSecondaryLight,
    ),
    bodySmall: GoogleFonts.cairo(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: NotixaPalette.textMutedLight,
    ),
    labelLarge: GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: NotixaPalette.textPrimaryLight,
    ),
  );
}
