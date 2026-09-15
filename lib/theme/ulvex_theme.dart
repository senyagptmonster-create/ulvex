import 'package:flutter/material.dart';

class UlvexTheme {
  static const bg = Color(0xFF0B0C12);
  static const surface = Color(0xFF121520);
  static const edge = Color(0xFF1C2030);
  static const accent = Color(0xFF06B6D4); // Cyan
  static const accentLight = Color(0xFF67E8F9);
  static const ink = Color(0xFFECFEFF);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const muted = Color(0xFF717D96);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      fontFamily: 'AppFont',
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: ink,
      ),
    );
  }
}
