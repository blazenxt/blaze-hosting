import 'package:flutter/material.dart';

class BlazeTheme {
  static const bg = Color(0xFF070708);
  static const panel = Color(0xFF101014);
  static const card = Color(0xFF16161C);
  static const text = Color(0xFFF5F4F8);
  static const muted = Color(0xFF8B8794);
  static const accent = Color(0xFFC94F59);
  static const accentBright = Color(0xFFF08A90);
  static const line = Color(0x14FFFFFF);
  static const ok = Color(0xFF5EE9A8);
  static const warn = Color(0xFFF5C36E);
  static const bad = Color(0xFFFB7185);
  static const ink = Color(0xFF1A0709);

  static ThemeData data() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      splashFactory: InkRipple.splashFactory,
      colorScheme: const ColorScheme.dark(
        surface: panel,
        primary: accent,
        onPrimary: ink,
        secondary: accentBright,
        onSurface: text,
      ),
      fontFamily: 'Segoe UI',
      textTheme: const TextTheme(
        displaySmall: TextStyle(color: text, fontWeight: FontWeight.w700, letterSpacing: -1.4, height: 1.05),
        headlineMedium: TextStyle(color: text, fontWeight: FontWeight.w700, letterSpacing: -0.8),
        titleMedium: TextStyle(color: text, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: text, height: 1.4),
        bodySmall: TextStyle(color: muted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerColor: line,
    );
  }
}
