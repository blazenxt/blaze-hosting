import 'package:flutter/material.dart';

class BlazeTheme {
  static const bg = Color(0xFF080808);
  static const panel = Color(0xFF0E0E10);
  static const text = Color(0xFFF4F3F7);
  static const muted = Color(0xFF8A8792);
  static const accent = Color(0xFFC94F59);
  static const accentBright = Color(0xFFF08A90);
  static const line = Color(0x17FFFFFF);

  static ThemeData data() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        surface: bg,
        primary: accent,
        onPrimary: Color(0xFF1A0709),
        secondary: accentBright,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: panel,
        foregroundColor: text,
        elevation: 0,
      ),
    );
  }
}
