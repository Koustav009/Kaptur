import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
///  FotoOwl — Centralised Theme
///  Palette inspired by MyWisdom Healthcare UI
///  Primary  : Soft Violet / Indigo
///  Secondary: Calm Teal / Mint
/// ─────────────────────────────────────────────────────────────

abstract class AppTheme {
  // ── Brand palette ──────────────────────────────────────────

  // Primary accent — soft violet (calm, trustworthy, modern)
  static const Color _primaryLight = Color(0xFF6B5FE4); // medium violet
  static const Color _primaryDark = Color(
    0xFF8B82F0,
  ); // lighter violet for dark bg

  // Secondary accent — calm teal / mint green
  static const Color _secondaryLight = Color(0xFF3CBFB4); // teal
  static const Color _secondaryDark = Color(
    0xFF57D4C9,
  ); // lighter teal for dark bg

  // Surfaces
  static const Color _bgLight = Color(0xFFF4F3FB); // very light lavender-white
  static const Color _bgDark = Color(0xFF0E0E1A); // deep dark violet-black
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF1C1B2E); // dark navy-violet card

  // On-colors (text/icons drawn on top of surfaces)
  static const Color _onBgLight = Color(0xFF1A1835); // deep indigo-black
  static const Color _onBgDark = Color(0xFFE8E6F8); // soft lavender-white

  // Muted / hint text
  static const Color _hintLight = Color(0xFF9A98B8);
  static const Color _hintDark = Color(0xFF6B6890);

  // Divider / border
  static const Color _borderLight = Color(0xFFDDDAF0);
  static const Color _borderDark = Color(0xFF2E2C4A);

  // Error
  static const Color _error = Color(0xFFE05B5B);

  // ── Typography ─────────────────────────────────────────────

  static TextTheme _buildTextTheme(Color onBackground) {
    return TextTheme(
      displayMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: onBackground,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: onBackground,
      ),
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
      secondary: _secondaryLight, // ← teal accent
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
      onPrimary: Colors.white,
      secondary: _secondaryDark, // ← teal accent
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
