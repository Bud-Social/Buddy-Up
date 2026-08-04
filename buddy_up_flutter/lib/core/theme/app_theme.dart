import 'package:flutter/material.dart';

class BuddyColors {
  static const Color green = Color(0xFF4ADE80);
  static const Color black = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1C1C1C);
  static const Color surfaceRaised = Color(0xFF2C2C2C);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color red = Color(0xFFEF4444);
  static const Color gold = Color(0xFFEAB308);
  static const Color border = Color(0xFF333333);
}

ThemeData buildBuddyTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: BuddyColors.black,
    colorScheme: const ColorScheme.dark(
      primary: BuddyColors.green,
      secondary: BuddyColors.green,
      surface: BuddyColors.surface,
      error: BuddyColors.red,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: BuddyColors.black,
      foregroundColor: BuddyColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: BuddyColors.black,
      selectedItemColor: BuddyColors.green,
      unselectedItemColor: BuddyColors.textSecondary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BuddyColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: BuddyColors.green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: BuddyColors.red, width: 1),
      ),
      labelStyle: const TextStyle(color: BuddyColors.textSecondary),
      hintStyle: const TextStyle(color: BuddyColors.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BuddyColors.green,
        foregroundColor: BuddyColors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BuddyColors.green,
        side: const BorderSide(color: BuddyColors.green),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: BuddyColors.green,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: BuddyColors.surfaceRaised,
      thickness: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: BuddyColors.surface,
      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: BuddyColors.textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: const BorderSide(color: BuddyColors.surfaceRaised),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: BuddyColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: BuddyColors.surfaceRaised,
      contentTextStyle: const TextStyle(color: BuddyColors.textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
