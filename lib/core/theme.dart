import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF5FAF7);
  static const Color phoneFrameBg = Color(0xFFE8F4ED);
  static const Color primaryText = Color(0xFF1F1D1B);
  static const Color primaryGreen = Color(0xFF006633);
  static const Color clayShadowColor = Color(0xFFC5D1CB);
  static const Color white = Colors.white;
}

class AppTheme {
  static ThemeData get lightTheme {
    // Use a system-safe text theme — no network fonts, works offline on all devices.
    const TextTheme baseTheme = TextTheme(
      displayLarge: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.w800),
      displayMedium: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.w700),
      displaySmall: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.w700),
      headlineLarge: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontFamily: 'sans-serif'),
      bodyMedium: TextStyle(fontFamily: 'sans-serif'),
      bodySmall: TextStyle(fontFamily: 'sans-serif'),
      labelLarge: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontFamily: 'sans-serif'),
      labelSmall: TextStyle(fontFamily: 'sans-serif'),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        surface: AppColors.background,
      ),
      textTheme: baseTheme,
      scaffoldBackgroundColor: AppColors.phoneFrameBg,
    );
  }

  static List<BoxShadow> get clayShadow => [
        const BoxShadow(
          color: AppColors.clayShadowColor,
          offset: Offset(20, 20),
          blurRadius: 60,
        ),
        const BoxShadow(
          color: AppColors.white,
          offset: Offset(-20, -20),
          blurRadius: 60,
        ),
      ];

  // Note: Flutter doesn't support 'inset' shadows natively. 
  // For 'clay-inset', we might need a custom painter or a package, 
  // but for the splash screen, we'll focus on the primary layout first.
}
