import 'package:flutter/material.dart';

/// Central color constants and extensions for Rain Drop.
///
/// Uses a custom ColorScheme built from explicit primary/secondary/tertiary
/// colors (purple, pink, blue) specified in app_theme.dart.
/// This file holds brand constants and semantic colors outside the scheme.
class AppColors {
  AppColors._();

  /// Deep purple — the primary hue for the Serenity-inspired palette.
  static const Color seed = Color(0xFF7B1FA2);

  /// Serenity-inspired warm rose accent.
  static const Color warmRose = Color(0xFFD4737A);

  /// Custom brand colors.
  static const Color maroon = Color(0xFF800000);
  static const Color charcoal = Color(0xFF1C1C1E);

  /// Amber accent for streaks, achievements, highlights.
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
}

/// Extends ColorScheme with Rain Drop semantic colors.
extension AppColorScheme on ColorScheme {
  Color get success => brightness == Brightness.light
      ? const Color(0xFF22C55E)
      : const Color(0xFF4ADE80);

  Color get warning => brightness == Brightness.light
      ? const Color(0xFFF59E0B)
      : const Color(0xFFFBBF24);

  Color get info => brightness == Brightness.light
      ? const Color(0xFF1976D2)
      : const Color(0xFF90CAF9);

  Color get accent => brightness == Brightness.light
      ? const Color(0xFFF59E0B)
      : const Color(0xFFFBBF24);

  Color get warmRose => AppColors.warmRose;

  Color get maroon => AppColors.maroon;

  Color get charcoal => AppColors.charcoal;

  Color get border => brightness == Brightness.light
      ? const Color(0xFFE4E4E7)
      : const Color(0xFF27272A);

  Color get muted => brightness == Brightness.light
      ? const Color(0xFFF4F4F5)
      : const Color(0xFF18181B);

  Color get mutedForeground => brightness == Brightness.light
      ? const Color(0xFF71717A)
      : const Color(0xFFA1A1AA);
}
