import 'package:flutter/material.dart';

import 'brand.dart';

class AppTheme {
  static const Color cBg = Color(0xFF0B0C12);
  static const Color cSurface = Color(0xFF121520);
  static const Color cEdge = Color(0xFF1C2030);
  static const Color cAccent = Color(0xFF06B6D4);
  static const Color cAccent2 = Color(0xFF67E8F9);
  static const Color cInk = Color(0xFFECFEFF);

  static const Color textPrimary = cInk;
  static Color get textSecondary => Color.alphaBlend(
        cInk.withValues(alpha: 0.65),
        cBg,
      );
  static Color get textMuted => Color.alphaBlend(
        cInk.withValues(alpha: 0.40),
        cBg,
      );

  static ThemeData get themeData => build();

  static ThemeData build() {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: cBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cAccent,
        brightness: Brightness.dark,
        surface: cSurface,
        primary: cAccent,
        secondary: cAccent2,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: cEdge,
    );
  }

  static TextStyle display([dynamic p1, dynamic p2, dynamic p3]) {
    double size = 20.0;
    Color? color;
    FontWeight weight = FontWeight.w700;

    for (final p in [p1, p2, p3]) {
      if (p is num) size = p.toDouble();
      if (p is Color) color = p;
      if (p is FontWeight) weight = p;
    }

    return TextStyle(
      fontFamily: kFont,
      fontSize: size,
      height: 1.15,
      letterSpacing: -0.3,
      fontWeight: weight,
      color: color ?? textPrimary,
    );
  }

  static TextStyle text([dynamic p1, dynamic p2, dynamic p3]) {
    double size = 14.0;
    Color? color;
    FontWeight weight = FontWeight.w500;
    double spacing = 0.0;

    for (final p in [p1, p2, p3]) {
      if (p is num) size = p.toDouble();
      if (p is Color) color = p;
      if (p is FontWeight) weight = p;
    }

    return TextStyle(
      fontFamily: kFont,
      fontSize: size,
      height: 1.35,
      letterSpacing: spacing,
      fontWeight: weight,
      color: color ?? textSecondary,
    );
  }
}