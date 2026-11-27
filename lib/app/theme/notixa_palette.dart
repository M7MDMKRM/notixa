import 'package:flutter/material.dart';

/// Centralized color palette for Notixa application
class NotixaPalette {
  NotixaPalette._();

  // Brand Accent Colors
  static const Color primary = Color(0xFF6366F1); // Indigo Primary
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF7C3AED); // Violet
  static const Color tertiary = Color(0xFF38BDF8); // Cyan Accent

  // Financial & Functional Indicators
  static const Color received = Color(0xFF4ADE80); // Income Green
  static const Color receivedBackground = Color(0x1A4ADE80);
  static const Color spent = Color(0xFFFF6E84); // Expense Coral/Pink
  static const Color spentBackground = Color(0x1AFF6E84);

  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Dark Theme Neutral Colors
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155); // Slate 700
  static const Color darkDivider = Color(0xFF334155);

  // Light Theme Neutral Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightDivider = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);
}
