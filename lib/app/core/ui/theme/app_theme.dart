import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const colors = AppColors.light;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: const [colors],
      colorScheme: ColorScheme.light(
        primary: colors.primaryColor,
        onPrimary: colors.primaryFgColor,
        secondary: colors.secondaryColor,
        onSecondary: colors.secondaryFgColor,
        surface: colors.backgroundColor,
        onSurface: colors.textColor,
        error: colors.errorColor,
        onError: colors.errorFgColor,
        outline: colors.outlineColor,
        shadow: colors.shadowColor,
      ),
      scaffoldBackgroundColor: colors.backgroundColor,
      textTheme: AppTypography.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primaryColor,
        foregroundColor: colors.primaryFgColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: colors.primaryFgColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryColor,
          foregroundColor: colors.primaryFgColor,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primaryColor,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primaryColor,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: BorderSide(color: colors.outlineColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceColor,
        elevation: 2,
        shadowColor: colors.shadowColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const colors = AppColors.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: const [colors],
      colorScheme: ColorScheme.dark(
        primary: colors.primaryColor,
        onPrimary: colors.primaryFgColor,
        secondary: colors.secondaryColor,
        onSecondary: colors.secondaryFgColor,
        surface: colors.backgroundColor,
        onSurface: colors.textColor,
        error: colors.errorColor,
        onError: colors.errorFgColor,
        outline: colors.outlineColor,
        shadow: colors.shadowColor,
      ),
      scaffoldBackgroundColor: colors.backgroundColor,
      textTheme: AppTypography.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surfaceColor,
        foregroundColor: colors.surfaceFgColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: colors.surfaceFgColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryColor,
          foregroundColor: colors.primaryFgColor,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primaryColor,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primaryColor,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: BorderSide(color: colors.outlineColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceColor,
        elevation: 4,
        shadowColor: colors.shadowColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
