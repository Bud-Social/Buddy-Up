import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Web design tokens (tailwind.config.ts) mirrored here so both clients look
/// the same on every screen.
class BuddyColors {
  static const Color green = Color(0xFF00C896);
  static const Color greenDeep = Color(0xFF009E78);
  static const Color electric = Color(0xFF7B61FF);
  static const Color blue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFFF6B35);
  static const Color black = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceRaised = Color(0xFF1E1E1E);
  static const Color white = Color(0xFFF8F8F8);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color red = Color(0xFFFF4757);
  static const Color gold = Color(0xFFFFD700);
  static const Color border = Color(0xFF333333);
}

/// The four palettes the web offers in Appearance.
enum BuddyTheme { dark, light, highContrast, ambient }

ThemeData buildBuddyThemeFor(BuddyTheme theme) => switch (theme) {
  BuddyTheme.dark => buildBuddyTheme(),
  BuddyTheme.light => buildBuddyLightTheme(),
  BuddyTheme.highContrast => buildBuddyHighContrastTheme(),
  BuddyTheme.ambient => buildBuddyAmbientTheme(),
};

class BuddyLightColors {
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceRaised = Color(0xFFF4F4F5);
  static const Color surfaceCard = Color(0xFFF0FDF4);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
}

ThemeData buildBuddyTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: BuddyColors.black,
    cardTheme: const CardThemeData(
      color: BuddyColors.surface,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BuddyColors.green,
        side: const BorderSide(color: BuddyColors.green),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: BuddyColors.green),
    ),
    dividerTheme: const DividerThemeData(
      color: BuddyColors.surfaceRaised,
      thickness: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? BuddyColors.green
            : BuddyColors.surfaceRaised,
      ),
      overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: BuddyColors.surface,
      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: BuddyColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: BuddyColors.surfaceRaised),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: BuddyColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: BuddyColors.surfaceRaised,
      contentTextStyle: const TextStyle(color: BuddyColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  return base.copyWith(textTheme: _applyWebFonts(base.textTheme));
}

ThemeData buildBuddyLightTheme() {
  final base = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: BuddyLightColors.surfaceRaised,
    cardTheme: const CardThemeData(
      color: BuddyLightColors.surface,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),
    colorScheme: const ColorScheme.light(
      primary: BuddyColors.green,
      secondary: BuddyColors.green,
      surface: BuddyLightColors.surface,
      surfaceContainerHighest: BuddyLightColors.surfaceRaised,
      error: BuddyColors.red,
      onPrimary: BuddyLightColors.textPrimary,
      onSecondary: BuddyLightColors.textPrimary,
      onSurface: BuddyLightColors.textPrimary,
      onError: BuddyLightColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: BuddyLightColors.surface,
      foregroundColor: BuddyLightColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: BuddyLightColors.surface,
      selectedItemColor: BuddyColors.green,
      unselectedItemColor: BuddyLightColors.textSecondary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BuddyLightColors.surfaceRaised,
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
      labelStyle: const TextStyle(color: BuddyLightColors.textSecondary),
      hintStyle: const TextStyle(color: BuddyLightColors.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BuddyColors.green,
        foregroundColor: BuddyColors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BuddyColors.green,
        side: const BorderSide(color: BuddyColors.green),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: BuddyColors.green),
    ),
    dividerTheme: const DividerThemeData(
      color: BuddyLightColors.border,
      thickness: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? BuddyColors.green
            : BuddyLightColors.surfaceRaised,
      ),
      overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: BuddyLightColors.surface,
      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: BuddyLightColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: BuddyLightColors.border),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: BuddyLightColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: BuddyColors.black,
      contentTextStyle: const TextStyle(color: BuddyColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  return base.copyWith(textTheme: _applyWebFonts(base.textTheme));
}

ThemeData buildBuddyHighContrastTheme() {
  final base = buildBuddyTheme();
  return base.copyWith(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00FFB3),
      secondary: Color(0xFF00FFB3),
      surface: Colors.black,
      onSurface: Colors.white,
      error: Color(0xFFFF6B6B),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}

/// Maps the Material text roles onto the web's font stack: Syne for display /
/// headline, Plus Jakarta Sans for titles/labels, Inter for body copy — the same
/// trio the web loads from Google Fonts (`font-display`, `font-heading`,
/// `font-body`).
TextTheme _applyWebFonts(TextTheme base) {
  // Use the same actual font providers as the web client. Merely setting
  // `fontFamily` leaves Flutter silently falling back to Roboto unless the
  // family is bundled or supplied by GoogleFonts.
  TextStyle? displayFont(TextStyle? style) =>
      style == null ? null : GoogleFonts.syne(textStyle: style);
  TextStyle? headingFont(TextStyle? style) =>
      style == null ? null : GoogleFonts.plusJakartaSans(textStyle: style);
  TextStyle? bodyFont(TextStyle? style) =>
      style == null ? null : GoogleFonts.inter(textStyle: style);
  return base.copyWith(
    displayLarge: displayFont(base.displayLarge),
    displayMedium: displayFont(base.displayMedium),
    displaySmall: displayFont(base.displaySmall),
    headlineLarge: displayFont(base.headlineLarge),
    headlineMedium: displayFont(base.headlineMedium),
    headlineSmall: displayFont(base.headlineSmall),
    titleLarge: headingFont(base.titleLarge),
    titleMedium: headingFont(base.titleMedium),
    titleSmall: headingFont(base.titleSmall),
    bodyLarge: bodyFont(base.bodyLarge),
    bodyMedium: bodyFont(base.bodyMedium),
    bodySmall: bodyFont(base.bodySmall),
    labelLarge: headingFont(base.labelLarge),
    labelMedium: headingFont(base.labelMedium),
    labelSmall: headingFont(base.labelSmall),
  );
}

ThemeData buildBuddyAmbientTheme() {
  final base = buildBuddyTheme();
  const background = Color(0xFF0B1020);
  const surface = Color(0xFF141B2E);
  return base.copyWith(
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6EE7B7),
      secondary: BuddyColors.electric,
      surface: surface,
      onSurface: Colors.white,
      error: BuddyColors.red,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: base.cardTheme.copyWith(
      color: surface,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
