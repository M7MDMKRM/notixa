import 'package:flutter/material.dart';
import 'notixa_palette.dart';
import 'notixa_typography.dart';

class NotixaTheme {
  NotixaTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NotixaPalette.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: NotixaPalette.primary,
        secondary: NotixaPalette.secondary,
        tertiary: NotixaPalette.tertiary,
        surface: NotixaPalette.darkSurface,
        error: NotixaPalette.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: NotixaPalette.textPrimaryDark,
      ),
      textTheme: NotixaTypography.darkTextTheme,
      cardTheme: CardTheme(
        color: NotixaPalette.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: NotixaPalette.darkBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NotixaPalette.darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: NotixaPalette.textPrimaryDark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NotixaPalette.darkSurface,
        selectedItemColor: NotixaPalette.primary,
        unselectedItemColor: NotixaPalette.textMutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: NotixaPalette.darkDivider,
        thickness: 1,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: NotixaPalette.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: NotixaPalette.primary,
        secondary: NotixaPalette.secondary,
        tertiary: NotixaPalette.tertiary,
        surface: NotixaPalette.lightSurface,
        error: NotixaPalette.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: NotixaPalette.textPrimaryLight,
      ),
      textTheme: NotixaTypography.lightTextTheme,
      cardTheme: CardTheme(
        color: NotixaPalette.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: NotixaPalette.lightBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NotixaPalette.lightBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: NotixaPalette.textPrimaryLight),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NotixaPalette.lightSurface,
        selectedItemColor: NotixaPalette.primary,
        unselectedItemColor: NotixaPalette.textMutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: NotixaPalette.lightDivider,
        thickness: 1,
      ),
    );
  }
}
