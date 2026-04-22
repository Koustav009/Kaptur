import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
///  FotoOwl — Centralised Theme
///
///  Usage in GetMaterialApp:
///    theme:       AppTheme.light,
///    darkTheme:   AppTheme.dark,
///    themeMode:   ThemeMode.system,   // or .light / .dark
/// ─────────────────────────────────────────────────────────────

abstract class AppTheme {
  // ── Brand palette ──────────────────────────────────────────

  // Primary accent — a warm amber that reads well on both themes
  static const Color _primaryLight = Color(0xFFE8A838);
  static const Color _primaryDark = Color(0xFFF2BC5E);

  // Surfaces
  static const Color _bgLight = Color(0xFFF7F4EF); // warm ivory
  static const Color _bgDark = Color(0xFF0F1218); // deep midnight
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF1A2030); // navy card

  // On-colors (text/icons drawn on top of surfaces)
  static const Color _onBgLight = Color(0xFF1A1A2E);
  static const Color _onBgDark = Color(0xFFECE8DF);

  // Muted / hint text
  static const Color _hintLight = Color(0xFF8A8A9A);
  static const Color _hintDark = Color(0xFF6B7280);

  // Divider / border
  static const Color _borderLight = Color(0xFFDDD8CF);
  static const Color _borderDark = Color(0xFF2C3347);

  // Error
  static const Color _error = Color(0xFFE05B5B);

  // ── Typography ─────────────────────────────────────────────
  //  Body: 'DM Sans' (clean, modern sans)
  //  Display: slight weight variation — no external font needed;
  //  you can swap fontFamily to 'Playfair Display' or 'DM Serif Display'
  //  once you add them to pubspec.yaml.

  static TextTheme _buildTextTheme(Color onBackground) {
    return TextTheme(
      // Large brand heading on auth screens
      displayMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: onBackground,
      ),
      // Section titles
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: onBackground,
      ),
      // Normal body
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: onBackground,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: onBackground.withOpacity(0.75),
      ),
      // Buttons
      labelLarge: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  // ── Input decoration theme ─────────────────────────────────

  static InputDecorationTheme _inputTheme({
    required Color fill,
    required Color border,
    required Color hint,
    required Color focus,
  }) {
    final radius = BorderRadius.circular(14);
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: TextStyle(color: hint, fontSize: 14),
      floatingLabelStyle: TextStyle(color: focus, fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: border, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: focus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: _error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: _error, width: 2),
      ),
    );
  }

  // ── Elevated button theme ──────────────────────────────────

  static ElevatedButtonThemeData _elevatedButtonTheme(Color primary) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── Outlined button theme ──────────────────────────────────

  static OutlinedButtonThemeData _outlinedButtonTheme({
    required Color border,
    required Color fg,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: BorderSide(color: border, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ── Text button theme ──────────────────────────────────────

  static TextButtonThemeData _textButtonTheme(Color primary) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ── App bar theme ──────────────────────────────────────────

  static AppBarTheme _appBarTheme({required Color bg, required Color fg}) {
    return AppBarTheme(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: fg,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ── Public ThemeData ───────────────────────────────────────

  /// Light theme
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _primaryLight,
      onPrimary: Colors.white,
      secondary: _primaryLight,
      onSecondary: Colors.white,
      surface: _surfaceLight,
      onSurface: _onBgLight,
      error: _error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: _bgLight,
    textTheme: _buildTextTheme(_onBgLight),
    inputDecorationTheme: _inputTheme(
      fill: _surfaceLight,
      border: _borderLight,
      hint: _hintLight,
      focus: _primaryLight,
    ),
    elevatedButtonTheme: _elevatedButtonTheme(_primaryLight),
    outlinedButtonTheme: _outlinedButtonTheme(
      border: _borderLight,
      fg: _onBgLight,
    ),
    textButtonTheme: _textButtonTheme(_primaryLight),
    appBarTheme: _appBarTheme(bg: _bgLight, fg: _onBgLight),
    dividerColor: _borderLight,
    cardColor: _surfaceLight,
    cardTheme: CardThemeData(
      color: _surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: _borderLight),
      ),
    ),
  );

  /// Dark theme
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _primaryDark,
      onPrimary: Colors.black,
      secondary: _primaryDark,
      onSecondary: Colors.black,
      surface: _surfaceDark,
      onSurface: _onBgDark,
      error: _error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: _bgDark,
    textTheme: _buildTextTheme(_onBgDark),
    inputDecorationTheme: _inputTheme(
      fill: _surfaceDark,
      border: _borderDark,
      hint: _hintDark,
      focus: _primaryDark,
    ),
    elevatedButtonTheme: _elevatedButtonTheme(_primaryDark),
    outlinedButtonTheme: _outlinedButtonTheme(
      border: _borderDark,
      fg: _onBgDark,
    ),
    textButtonTheme: _textButtonTheme(_primaryDark),
    appBarTheme: _appBarTheme(bg: _bgDark, fg: _onBgDark),
    dividerColor: _borderDark,
    cardColor: _surfaceDark,
    cardTheme: CardThemeData(
      color: _surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: _borderDark),
      ),
    ),
  );
}
