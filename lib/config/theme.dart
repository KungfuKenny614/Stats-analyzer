import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF3D8BFF);
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);

  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color darkBackground = Color(0xFF0F1113);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF24282D);
  static const Color lightPrimaryText = Color(0xFF202124);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color lightSecondaryText = Color(0xFF5F6368);
  static const Color darkSecondaryText = Color(0xFF9BA3AF);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: primary,
      surface: lightSurface,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: lightBackground,
      foregroundColor: lightPrimaryText,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.4, color: lightPrimaryText),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.4, color: lightPrimaryText),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.4, color: lightPrimaryText),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4, color: lightPrimaryText),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4, color: lightPrimaryText),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4, color: lightPrimaryText),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, height: 1.4, color: lightSecondaryText),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: primaryDark,
      surface: darkSurface,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: darkBackground,
      foregroundColor: darkPrimaryText,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.4, color: darkPrimaryText),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.4, color: darkPrimaryText),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.4, color: darkPrimaryText),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4, color: darkPrimaryText),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4, color: darkPrimaryText),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4, color: darkPrimaryText),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, height: 1.4, color: darkSecondaryText),
    ),
  );
}
