import 'package:flutter/material.dart';

class AppColors {

  static const primary = Color(0xFF2D5BE3);
  static const primaryLight = Color(0xFFE8EEFF);

  static const background = Color(0xFFF5F6FA);
  static const surface = Colors.white;
  static const inputFill = Colors.white;
  static const inputBorder = Color(0xFFE5E7EB);

  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);
  static const divider = Color(0xFFE5E7EB);

  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  static const successBorder = Color(0xFF6EE7B7);
  static const warning = Color(0xFFF59E0B);
  static const warningText = Color(0xFFD97706);
  static const warningLight = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFCD34D);
  static const ratingColor = Color(0xFFF59E0B);

  static const speciesCat = Color(0xFF8B5CF6);

  static const statusOpen = Color(0xFFF59E0B);
  static const statusAccepted = Color(0xFF3B82F6);
  static const statusInProgress = Color(0xFF10B981);
  static const statusCompleted = Color(0xFF6B7280);
  static const statusCancelled = Color(0xFFEF4444);
  static const statusRefused = Color(0xFFF97316);

  static const statusOpenBg = Color(0xFFFEF3C7);
  static const statusAcceptedBg = Color(0xFFDBEAFE);
  static const statusInProgressBg = Color(0xFFD1FAE5);
  static const statusCompletedBg = Color(0xFFF3F4F6);
  static const statusCancelledBg = Color(0xFFFEE2E2);
  static const statusRefusedBg = Color(0xFFFFF7ED);

  static const warningBg = warningLight;
  static const successBg = successLight;
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
          background: AppColors.background,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.divider),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          hintStyle: const TextStyle(color: AppColors.textHint),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
      );
}
