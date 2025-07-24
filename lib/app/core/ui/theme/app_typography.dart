// lib/app/core/theme/app_typography.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static final TextTheme _baseTextTheme = GoogleFonts.interTextTheme();

  static TextStyle get headlineLarge => _baseTextTheme.headlineLarge!.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextStyle get headlineMedium => _baseTextTheme.headlineMedium!
      .copyWith(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2);

  static TextStyle get headlineSmall => _baseTextTheme.headlineSmall!.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static TextStyle get bodyLarge => _baseTextTheme.bodyLarge!.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodyMedium => _baseTextTheme.bodyMedium!.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get bodySmall => _baseTextTheme.bodySmall!.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get labelLarge => _baseTextTheme.labelLarge!.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static TextStyle get labelMedium => _baseTextTheme.labelMedium!.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static TextStyle get labelSmall => _baseTextTheme.labelSmall!.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static TextTheme get textTheme => TextTheme(
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
