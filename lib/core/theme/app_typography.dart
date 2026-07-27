import 'package:flutter/material.dart';

/// Text theme builder using Inter at 5 weights for hierarchy.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(ColorScheme cs) {
    final color = cs.onSurface;
    final muted = cs.onSurfaceVariant;

    return TextTheme(
      headlineLarge: _style(28, FontWeight.w700, 1.2, color),
      headlineMedium: _style(24, FontWeight.w600, 1.3, color),
      headlineSmall: _style(20, FontWeight.w600, 1.3, color),

      titleLarge: _style(18, FontWeight.w600, 1.3, color),
      titleMedium: _style(16, FontWeight.w600, 1.4, color),
      titleSmall: _style(14, FontWeight.w500, 1.4, color),

      bodyLarge: _style(16, FontWeight.w400, 1.5, color),
      bodyMedium: _style(14, FontWeight.w400, 1.5, color),
      bodySmall: _style(13, FontWeight.w400, 1.4, muted),

      labelLarge: _style(14, FontWeight.w500, 1.3, color, 0.1),
      labelMedium: _style(12, FontWeight.w500, 1.3, muted, 0.25),
      labelSmall: _style(11, FontWeight.w500, 1.2, muted, 0.4),

      displaySmall: _style(36, FontWeight.w700, 1.1, color, -0.5),
    );
  }

  static TextStyle _style(
    double size,
    FontWeight weight,
    double height,
    Color color, [
    double letterSpacing = 0,
  ]) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      letterSpacing: letterSpacing == 0 ? null : letterSpacing,
    );
  }
}
