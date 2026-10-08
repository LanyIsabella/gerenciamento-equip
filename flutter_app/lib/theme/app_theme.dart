import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF596254);
  static const accent = Color(0xFFB8C98C);
  static const background = Color(0xFFF7F8F4);
  static const border = Color(0xFFE2E6DC);
  static const muted = Color(0xFF687064);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      secondary: accent,
      onSecondary: const Color(0xFF273020),
      surface: Colors.white,
      onSurface: const Color(0xFF252B24),
      outline: border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: Color(0xFF252B24),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF252B24),
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: Color(0xFF4F574D)),
        bodySmall: TextStyle(color: muted),
      ),
    );
  }
}
