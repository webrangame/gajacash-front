import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/constants/app_colors.dart';

export 'package:gajacash_sample/core/constants/app_colors.dart';

/// Custom Theme Extension to provide neumorphic/claymorphism design variables.
class NeumorphicTheme extends ThemeExtension<NeumorphicTheme> {
  final List<BoxShadow> clayShadow;
  final List<BoxShadow> clayShadowDeep;
  final List<BoxShadow> clayShadowSmall;
  final List<BoxShadow> navShadow;
  final List<BoxShadow> navShadowAction;
  final List<BoxShadow> floatBtnShadow;
  final List<BoxShadow> btnLightShadow;
  
  final Color accentAmber;
  final Color secondaryAmberText;
  final Color errorRed;
  final Color errorBg;
  final Color neutralMuted;
  
  final BoxDecoration clayCardDecoration;
  final BoxDecoration clayInputDecoration;

  const NeumorphicTheme({
    required this.clayShadow,
    required this.clayShadowDeep,
    required this.clayShadowSmall,
    required this.navShadow,
    required this.navShadowAction,
    required this.floatBtnShadow,
    required this.btnLightShadow,
    required this.accentAmber,
    required this.secondaryAmberText,
    required this.errorRed,
    required this.errorBg,
    required this.neutralMuted,
    required this.clayCardDecoration,
    required this.clayInputDecoration,
  });

  @override
  NeumorphicTheme copyWith({
    List<BoxShadow>? clayShadow,
    List<BoxShadow>? clayShadowDeep,
    List<BoxShadow>? clayShadowSmall,
    List<BoxShadow>? navShadow,
    List<BoxShadow>? navShadowAction,
    List<BoxShadow>? floatBtnShadow,
    List<BoxShadow>? btnLightShadow,
    Color? accentAmber,
    Color? secondaryAmberText,
    Color? errorRed,
    Color? errorBg,
    Color? neutralMuted,
    BoxDecoration? clayCardDecoration,
    BoxDecoration? clayInputDecoration,
  }) {
    return NeumorphicTheme(
      clayShadow: clayShadow ?? this.clayShadow,
      clayShadowDeep: clayShadowDeep ?? this.clayShadowDeep,
      clayShadowSmall: clayShadowSmall ?? this.clayShadowSmall,
      navShadow: navShadow ?? this.navShadow,
      navShadowAction: navShadowAction ?? this.navShadowAction,
      floatBtnShadow: floatBtnShadow ?? this.floatBtnShadow,
      btnLightShadow: btnLightShadow ?? this.btnLightShadow,
      accentAmber: accentAmber ?? this.accentAmber,
      secondaryAmberText: secondaryAmberText ?? this.secondaryAmberText,
      errorRed: errorRed ?? this.errorRed,
      errorBg: errorBg ?? this.errorBg,
      neutralMuted: neutralMuted ?? this.neutralMuted,
      clayCardDecoration: clayCardDecoration ?? this.clayCardDecoration,
      clayInputDecoration: clayInputDecoration ?? this.clayInputDecoration,
    );
  }

  @override
  NeumorphicTheme lerp(ThemeExtension<NeumorphicTheme>? other, double t) {
    if (other is! NeumorphicTheme) return this;
    return NeumorphicTheme(
      clayShadow: other.clayShadow,
      clayShadowDeep: other.clayShadowDeep,
      clayShadowSmall: other.clayShadowSmall,
      navShadow: other.navShadow,
      navShadowAction: other.navShadowAction,
      floatBtnShadow: other.floatBtnShadow,
      btnLightShadow: other.btnLightShadow,
      accentAmber: Color.lerp(accentAmber, other.accentAmber, t)!,
      secondaryAmberText: Color.lerp(secondaryAmberText, other.secondaryAmberText, t)!,
      errorRed: Color.lerp(errorRed, other.errorRed, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      neutralMuted: Color.lerp(neutralMuted, other.neutralMuted, t)!,
      clayCardDecoration: other.clayCardDecoration,
      clayInputDecoration: other.clayInputDecoration,
    );
  }
}

/// Global Application Theme configurations.
class AppTheme {
  static ThemeData get lightTheme {
    // Configures Nunito with sans-serif system fallback matching UI mockup font preferences
    const TextTheme baseTheme = TextTheme(
      displayLarge: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif'], fontWeight: FontWeight.w800),
      displayMedium: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif'], fontWeight: FontWeight.w700),
      displaySmall: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif'], fontWeight: FontWeight.w700),
      headlineLarge: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif'], fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif'], fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif'], fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif'], fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif'], fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif'], fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif']),
      bodyMedium: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif']),
      bodySmall: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif']),
      labelLarge: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif'], fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif']),
      labelSmall: TextStyle(fontFamily: 'Nunito', fontFamilyFallback: ['sans-serif']),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentAmber,
        surface: AppColors.phoneFrameBg,
        onPrimary: Colors.white,
        onSecondary: AppColors.primaryText,
        onSurface: AppColors.primaryText,
      ),
      textTheme: baseTheme,
      scaffoldBackgroundColor: AppColors.background,
      extensions: [
        NeumorphicTheme(
          clayShadow: const [
            BoxShadow(
              color: AppColors.clayShadowColor,
              offset: Offset(8, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-8, -8),
              blurRadius: 16,
            ),
          ],
          clayShadowDeep: const [
            BoxShadow(
              color: AppColors.clayShadowColor,
              offset: Offset(20, 20),
              blurRadius: 60,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-20, -20),
              blurRadius: 60,
            ),
          ],
          clayShadowSmall: const [
            BoxShadow(
              color: AppColors.clayShadowColor,
              offset: Offset(4, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 8,
            ),
          ],
          navShadow: const [
            BoxShadow(
              color: AppColors.navShadowColor,
              offset: Offset(8, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-8, -8),
              blurRadius: 16,
            ),
          ],
          navShadowAction: const [
            BoxShadow(
              color: AppColors.navShadowActionColor,
              offset: Offset(8, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-8, -8),
              blurRadius: 16,
            ),
          ],
          floatBtnShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.25),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
          btnLightShadow: const [
            BoxShadow(
              color: AppColors.clayShadowColor,
              offset: Offset(8, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-8, -8),
              blurRadius: 16,
            ),
          ],
          accentAmber: AppColors.accentAmber,
          secondaryAmberText: AppColors.secondaryAmberText,
          errorRed: AppColors.errorRed,
          errorBg: AppColors.errorBg,
          neutralMuted: AppColors.neutralMuted,
          clayCardDecoration: BoxDecoration(
            color: AppColors.phoneFrameBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.clayShadowColor,
                offset: Offset(8, 8),
                blurRadius: 16,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(-8, -8),
                blurRadius: 16,
              ),
            ],
          ),
          clayInputDecoration: BoxDecoration(
            color: AppColors.phoneFrameBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.clayShadowColor.withValues(alpha: 0.8), width: 1.0),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFDFEAE4),
                AppColors.phoneFrameBg,
              ],
            ),
          ),
        ),
      ],
    );
  }

  static List<BoxShadow> get clayShadow => [
        const BoxShadow(
          color: AppColors.clayShadowColor,
          offset: Offset(8, 8),
          blurRadius: 16,
        ),
        const BoxShadow(
          color: AppColors.white,
          offset: Offset(-8, -8),
          blurRadius: 16,
        ),
      ];
}

/// Extensions to access App Theme easily across the codebase.
extension ContextThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  NeumorphicTheme get neumorphic => theme.extension<NeumorphicTheme>()!;
  TextTheme get textTheme => theme.textTheme;
}
