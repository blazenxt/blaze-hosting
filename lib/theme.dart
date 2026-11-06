import 'package:flutter/material.dart';

/// Tokens taken from panel.nawazfx.com ember theme (SiteConfiguration + blaze-matte).
class BlazeTheme {
  static const bg = Color(0xFF09090A);
  static const panel = Color(0xFF111318);
  static const card = Color(0xFF191B1F);
  static const raised = Color(0xFF202328);
  static const text = Color(0xFFECEEF1);
  static const muted = Color(0xFFA1A6AF);
  static const accent = Color(0xFFC94F59);
  static const accentBright = Color(0xFFF08A90);
  static const line = Color(0xFF2C3036);
  static const ok = Color(0xFF22C55E);
  static const warn = Color(0xFFEAB308);
  static const disk = Color(0xFF38BDF8);
  static const bad = Color(0xFFEF4444);
  static const ink = Color(0xFFFFFFFF);

  static ThemeData data() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Segoe UI',
      colorScheme: const ColorScheme.dark(
        surface: panel,
        primary: accent,
        onPrimary: ink,
        secondary: accentBright,
        onSurface: text,
      ),
    );
  }
}
