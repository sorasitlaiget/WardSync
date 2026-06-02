import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color background = Color(0xFF0E0E0E);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFF252525);
  static const Color cardBorder = Color(0xFF2E2E2E);

  // Accent
  static const Color lime = Color(0xFFA8CC00);
  static const Color limeLight = Color(0xFFBDD900);

  // Triage colors
  static const Color triageRed = Color(0xFF8B1A1A);
  static const Color triageRedActive = Color(0xFFCC2200);
  static const Color triageYellow = Color(0xFF7A5500);
  static const Color triageYellowActive = Color(0xFFCC8800);
  static const Color triageGreen = Color(0xFF1A5C1A);
  static const Color triageGreenActive = Color(0xFF2E8B2E);
  static const Color triageBlack = Color(0xFF2A2A2A);
  static const Color triageBlackActive = Color(0xFF444444);

  // Dot indicators
  static const Color dotRed = Color(0xFFFF3333);
  static const Color dotYellow = Color(0xFFFFAA00);
  static const Color dotGreen = Color(0xFF44CC44);
  static const Color dotBlack = Color(0xFF888888);

  // Text
  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textMuted = Color(0xFF555555);

  // Status badge colors
  static const Color badgeNurse = Color(0xFF2E5C2E);
  static const Color badgeDoctor = Color(0xFF5C2E2E);
  static const Color badgeAdmin = Color(0xFF2E2E5C);
  static const Color badgeRed = Color(0xFFCC2200);

  // Admit button
  static const Color admitButton = Color(0xFFCC1100);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          background: AppColors.background,
          surface: AppColors.surface,
          primary: AppColors.lime,
          secondary: AppColors.lime,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.lime,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
          labelSmall: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            letterSpacing: 1.0,
          ),
        ),
        fontFamily: 'RobotoMono',
      );
}
