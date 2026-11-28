import 'package:flutter/material.dart';

/// Centralized color palette for Notixa application
class NotixaPalette {
  NotixaPalette._();

  // Brand Accent Colors
  static const Color primary = Color(0xFF7C3AED); // Signature Notixa Purple
  static const Color primaryLight = Color(0xFF9333EA);
  static const Color primaryDark = Color(0xFF6D28D9);
  static const Color secondary = Color(0xFF8B5CF6); // Soft Purple
  static const Color purpleBadge = Color(0xFFF3E8FF); // Lavender pill background
  static const Color purpleBadgeText = Color(0xFF7C3AED);
  static const Color tertiary = Color(0xFF38BDF8); // Cyan Accent

  // Financial & Functional Indicators
  static const Color received = Color(0xFF10B981); // Emerald Green
  static const Color receivedBackground = Color(0xFFDCFCE7); // Light green background
  static const Color spent = Color(0xFFEF4444); // Red/Coral
  static const Color spentBackground = Color(0xFFFEE2E2); // Light red background

  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Dark Theme Neutral Colors
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155); // Slate 700
  static const Color darkDivider = Color(0xFF334155);

  // Light Theme Neutral Colors (Matching Screenshots)
  static const Color lightBackground = Color(0xFFF8F9FE); // Clean soft lavender-white
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightFieldFill = Color(0xFFF3F4F6); // Soft gray for inputs
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFF3F4F6);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);
}
