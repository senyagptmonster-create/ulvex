import 'package:flutter/material.dart';

class MeterPalette {
  MeterPalette._();

  // Dark Industrial Palette
  static const Color darkBg = Color(0xFF0D1117);
  static const Color panelSurface = Color(0xFF161B22);
  static const Color panelElevated = Color(0xFF21262D);
  static const Color panelBorder = Color(0xFF30363D);

  // Precision Industrial Accents
  static const Color cyanPrecision = Color(0xFF00E5FF);
  static const Color cyanDim = Color(0x2800E5FF);
  static const Color amberWarning = Color(0xFFFBBF24);
  static const Color amberDim = Color(0x28FBBF24);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color safeGreen = Color(0xFF10B981);

  // Text
  static const Color textMain = Color(0xFFF3F4F6);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textSubtle = Color(0xFF6B7280);

  static Color getDecibelZoneColor(double db) {
    if (db < 70) {
      return safeGreen;
    } else if (db < 85) {
      return amberWarning;
    } else {
      return dangerRed;
    }
  }

  static String getDecibelZoneLabel(double db) {
    if (db < 70) {
      return 'SAFE';
    } else if (db < 85) {
      return 'MODERATE';
    } else {
      return 'HAZARDOUS';
    }
  }

  static ThemeData themeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: cyanPrecision,
        onPrimary: darkBg,
        secondary: amberWarning,
        onSecondary: darkBg,
        error: dangerRed,
        onError: Colors.white,
        surface: panelSurface,
        onSurface: textMain,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textMain),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: panelSurface,
        indicatorColor: cyanDim,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: cyanPrecision,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: textMuted,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: cyanPrecision);
          }
          return const IconThemeData(color: textMuted);
        }),
      ),
      cardTheme: CardThemeData(
        color: panelSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: panelBorder, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
