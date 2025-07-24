import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.textColor,
    required this.backgroundColor,
    required this.primaryColor,
    required this.primaryFgColor,
    required this.secondaryColor,
    required this.secondaryFgColor,
    required this.accentColor,
    required this.accentFgColor,
    required this.errorColor,
    required this.errorFgColor,
    required this.successColor,
    required this.successFgColor,
    required this.warningColor,
    required this.warningFgColor,
    required this.outlineColor,
    required this.shadowColor,
    required this.surfaceColor,
    required this.surfaceFgColor,
    required this.highPriority,
    required this.mediumPriority,
    required this.lowPriority,
    required this.categoryColors,
  });

  final Color textColor;
  final Color backgroundColor;
  final Color primaryColor;
  final Color primaryFgColor;
  final Color secondaryColor;
  final Color secondaryFgColor;
  final Color accentColor;
  final Color accentFgColor;
  final Color errorColor;
  final Color errorFgColor;
  final Color successColor;
  final Color successFgColor;
  final Color warningColor;
  final Color warningFgColor;
  final Color outlineColor;
  final Color shadowColor;
  final Color surfaceColor;
  final Color surfaceFgColor;
  final Color highPriority;
  final Color mediumPriority;
  final Color lowPriority;
  final List<Color> categoryColors;

  static const light = AppColors(
    textColor: Color(0xFF1F2937),
    backgroundColor: Color(0xFFF9FAFB),
    primaryColor: Color(0xFF6366F1),
    primaryFgColor: Color(0xFFF9FAFB),
    secondaryColor: Color(0xFF10B981),
    secondaryFgColor: Color(0xFF1F2937),
    accentColor: Color(0xFF374151),
    accentFgColor: Color(0xFFF9FAFB),
    errorColor: Color(0xFFDC2626),
    errorFgColor: Color(0xFFFFFFFF),
    successColor: Color(0xFF059669),
    successFgColor: Color(0xFFFFFFFF),
    warningColor: Color(0xFFD97706),
    warningFgColor: Color(0xFFFFFFFF),
    outlineColor: Color(0xFFD1D5DB),
    shadowColor: Color(0x1A000000),
    surfaceColor: Color(0xFFFFFFFF),
    surfaceFgColor: Color(0xFF1F2937),
    highPriority: Color(0xFFEF4444),
    mediumPriority: Color(0xFFF59E0B),
    lowPriority: Color(0xFF22C55E),
    categoryColors: [
      Color(0xFF6366F1),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
      Color(0xFF8B5CF6),
      Color(0xFFF97316),
    ],
  );

  static const dark = AppColors(
    textColor: Color(0xFFC8D2E0),
    backgroundColor: Color(0xFF1E1E1E),
    primaryColor: Color(0xFF818CF8),
    primaryFgColor: Color(0xFF1F2937),
    secondaryColor: Color(0xFF34D399),
    secondaryFgColor: Color(0xFF1F2937),
    accentColor: Color(0xFFADB7C7),
    accentFgColor: Color(0xFF1E1E1E),
    errorColor: Color(0xFFEF4444),
    errorFgColor: Color(0xFF1F2937),
    successColor: Color(0xFF10B981),
    successFgColor: Color(0xFF1F2937),
    warningColor: Color(0xFFF59E0B),
    warningFgColor: Color(0xFF1F2937),
    outlineColor: Color(0xFF4B5563),
    shadowColor: Color(0x33000000),
    surfaceColor: Color(0xFF1F2937),
    surfaceFgColor: Color(0xFFC8D2E0),
    highPriority: Color(0xFFF87171),
    mediumPriority: Color(0xFFFBBF24),
    lowPriority: Color(0xFF4ADE80),
    categoryColors: [
      Color(0xFF818CF8),
      Color(0xFFF472B6),
      Color(0xFF22D3EE),
      Color(0xFFC4B5FD),
      Color(0xFFFB923C),
    ],
  );

  @override
  ThemeExtension<AppColors> copyWith({
    Color? textColor,
    Color? backgroundColor,
    Color? primaryColor,
    Color? primaryFgColor,
    Color? secondaryColor,
    Color? secondaryFgColor,
    Color? accentColor,
    Color? accentFgColor,
    Color? errorColor,
    Color? errorFgColor,
    Color? successColor,
    Color? successFgColor,
    Color? warningColor,
    Color? warningFgColor,
    Color? outlineColor,
    Color? shadowColor,
    Color? surfaceColor,
    Color? surfaceFgColor,
    Color? highPriority,
    Color? mediumPriority,
    Color? lowPriority,
    List<Color>? categoryColors,
  }) {
    return AppColors(
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      primaryColor: primaryColor ?? this.primaryColor,
      primaryFgColor: primaryFgColor ?? this.primaryFgColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      secondaryFgColor: secondaryFgColor ?? this.secondaryFgColor,
      accentColor: accentColor ?? this.accentColor,
      accentFgColor: accentFgColor ?? this.accentFgColor,
      errorColor: errorColor ?? this.errorColor,
      errorFgColor: errorFgColor ?? this.errorFgColor,
      successColor: successColor ?? this.successColor,
      successFgColor: successFgColor ?? this.successFgColor,
      warningColor: warningColor ?? this.warningColor,
      warningFgColor: warningFgColor ?? this.warningFgColor,
      outlineColor: outlineColor ?? this.outlineColor,
      shadowColor: shadowColor ?? this.shadowColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      surfaceFgColor: surfaceFgColor ?? this.surfaceFgColor,
      highPriority: highPriority ?? this.highPriority,
      mediumPriority: mediumPriority ?? this.mediumPriority,
      lowPriority: lowPriority ?? this.lowPriority,
      categoryColors: categoryColors ?? this.categoryColors,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      textColor: Color.lerp(textColor, other.textColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      primaryFgColor: Color.lerp(primaryFgColor, other.primaryFgColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      secondaryFgColor: Color.lerp(
        secondaryFgColor,
        other.secondaryFgColor,
        t,
      )!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      accentFgColor: Color.lerp(accentFgColor, other.accentFgColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      errorFgColor: Color.lerp(errorFgColor, other.errorFgColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      successFgColor: Color.lerp(successFgColor, other.successFgColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      warningFgColor: Color.lerp(warningFgColor, other.warningFgColor, t)!,
      outlineColor: Color.lerp(outlineColor, other.outlineColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      surfaceFgColor: Color.lerp(surfaceFgColor, other.surfaceFgColor, t)!,
      highPriority: Color.lerp(highPriority, other.highPriority, t)!,
      mediumPriority: Color.lerp(mediumPriority, other.mediumPriority, t)!,
      lowPriority: Color.lerp(lowPriority, other.lowPriority, t)!,
      categoryColors: other.categoryColors != null
          ? List.generate(
              categoryColors.length,
              (index) => Color.lerp(
                categoryColors[index],
                other.categoryColors[index],
                t,
              )!,
            )
          : [],
    );
  }
}
