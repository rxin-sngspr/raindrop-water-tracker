import 'package:flutter/material.dart';
import 'app_typography.dart';

/// Theme factory using a custom ColorScheme per preset.
///
/// Each preset has a distinct primary/secondary/tertiary triad and
/// slightly different surface tones so switching feels like a
/// completely different look.
class AppTheme {
  AppTheme._();

  static ThemeData light({String preset = 'purple'}) {
    final cs = AppThemePresets.light(preset);
    return _build(cs, preset: preset);
  }

  static ThemeData dark({String preset = 'purple'}) {
    final cs = AppThemePresets.dark(preset);
    return _build(cs, preset: preset);
  }

  static ThemeData _build(ColorScheme cs, {String? preset}) {
    // Derive card border treatment per preset
    Color cardBorderColor;
    switch (preset) {
      case 'serenity':
        cardBorderColor = cs.primary.withValues(alpha: 0.35);
        break;
      case 'pink':
        cardBorderColor = cs.primaryContainer;
        break;
      case 'purpink':
        cardBorderColor = cs.secondary.withValues(alpha: 0.25);
        break;
      default: // purple
        cardBorderColor = cs.outlineVariant;
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      textTheme: AppTypography.textTheme(cs),
      cardTheme: CardThemeData(
        color: cs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cardBorderColor, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: cs.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

/// Pre-built color schemes for each theme preset.
///
/// Each preset uses a distinct color triad and different surface tones
/// so that switching feels genuinely different, not just a border tweak.
class AppThemePresets {
  AppThemePresets._();

  static const String pink = 'pink';
  static const String purple = 'purple';
  static const String purpink = 'purpink';
  static const String serenity = 'serenity';

  static const List<String> all = [pink, purple, purpink, serenity];

  // ── LIGHT ──────────────────────────────────────────────────

  static ColorScheme light(String preset) {
    switch (preset) {
      case 'pink':
        return ColorScheme.light(
          primary: const Color(0xFFE91E63),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFFCE4EC),
          onPrimaryContainer: const Color(0xFF880E4F),
          secondary: const Color(0xFF9C27B0),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFF3E5F5),
          onSecondaryContainer: const Color(0xFF4A0072),
          tertiary: const Color(0xFF2196F3),
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFE3F2FD),
          onTertiaryContainer: const Color(0xFF0D47A1),
          surface: const Color(0xFFFFF8F0),
          onSurface: const Color(0xFF1C1B1F),
          surfaceContainerHighest: const Color(0xFFF5EDE0),
          onSurfaceVariant: const Color(0xFF49454F),
          outline: const Color(0xFF79747E),
          outlineVariant: const Color(0xFFCAC4D0),
          error: const Color(0xFFB3261E),
          onError: Colors.white,
          brightness: Brightness.light,
        );
      case 'purple':
        return ColorScheme.light(
          primary: const Color(0xFF7B1FA2),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFF3E5F5),
          onPrimaryContainer: const Color(0xFF4A0072),
          secondary: const Color(0xFFD81B60),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFFCE4EC),
          onSecondaryContainer: const Color(0xFF880E4F),
          tertiary: const Color(0xFF1976D2),
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFE3F2FD),
          onTertiaryContainer: const Color(0xFF0D47A1),
          surface: Colors.white,
          onSurface: const Color(0xFF1C1B1F),
          surfaceContainerHighest: const Color(0xFFEDEDF0),
          onSurfaceVariant: const Color(0xFF49454F),
          outline: const Color(0xFF79747E),
          outlineVariant: const Color(0xFFCAC4D0),
          error: const Color(0xFFB3261E),
          onError: Colors.white,
          brightness: Brightness.light,
        );
      case 'purpink':
        return ColorScheme.light(
          primary: const Color(0xFF9C27B0),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFF3E5F5),
          onPrimaryContainer: const Color(0xFF4A0072),
          secondary: const Color(0xFFFF4081),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFFCE4EC),
          onSecondaryContainer: const Color(0xFF880E4F),
          tertiary: const Color(0xFF448AFF),
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFE3F2FD),
          onTertiaryContainer: const Color(0xFF0D47A1),
          surface: const Color(0xFFF8F5FF),
          onSurface: const Color(0xFF1C1B1F),
          surfaceContainerHighest: const Color(0xFFEEE8F5),
          onSurfaceVariant: const Color(0xFF49454F),
          outline: const Color(0xFF79747E),
          outlineVariant: const Color(0xFFCAC4D0),
          error: const Color(0xFFB3261E),
          onError: Colors.white,
          brightness: Brightness.light,
        );
      case 'serenity':
        return ColorScheme.light(
          primary: const Color(0xFFD4737A),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFFDE8E8),
          onPrimaryContainer: const Color(0xFF7B2D31),
          secondary: const Color(0xFF9B6B9B),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFF3E5F5),
          onSecondaryContainer: const Color(0xFF4A0072),
          tertiary: const Color(0xFF6B9BC4),
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFE3F2FD),
          onTertiaryContainer: const Color(0xFF0D47A1),
          surface: const Color(0xFFFFF9F5),
          onSurface: const Color(0xFF1C1B1F),
          surfaceContainerHighest: const Color(0xFFF5EDE8),
          onSurfaceVariant: const Color(0xFF49454F),
          outline: const Color(0xFF79747E),
          outlineVariant: const Color(0xFFCAC4D0),
          error: const Color(0xFFB3261E),
          onError: Colors.white,
          brightness: Brightness.light,
        );
      default:
        return ColorScheme.light(
          primary: const Color(0xFFD81B60),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFFCE4EC),
          onPrimaryContainer: const Color(0xFF880E4F),
          secondary: const Color(0xFF7B1FA2),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFF3E5F5),
          onSecondaryContainer: const Color(0xFF4A0072),
          tertiary: const Color(0xFF1976D2),
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFE3F2FD),
          onTertiaryContainer: const Color(0xFF0D47A1),
          surface: Colors.white,
          onSurface: const Color(0xFF1C1B1F),
          surfaceContainerHighest: const Color(0xFFEDEDF0),
          onSurfaceVariant: const Color(0xFF49454F),
          outline: const Color(0xFF79747E),
          outlineVariant: const Color(0xFFCAC4D0),
          error: const Color(0xFFB3261E),
          onError: Colors.white,
          brightness: Brightness.light,
        );
    }
  }

  // ── DARK ───────────────────────────────────────────────────

  static ColorScheme dark(String preset) {
    switch (preset) {
      case 'pink':
        return ColorScheme.dark(
          primary: const Color(0xFFF48FB1),
          onPrimary: const Color(0xFF880E4F),
          primaryContainer: const Color(0xFFAD1457),
          onPrimaryContainer: const Color(0xFFFCE4EC),
          secondary: const Color(0xFFCE93D8),
          onSecondary: const Color(0xFF4A0072),
          secondaryContainer: const Color(0xFF6A1B9A),
          onSecondaryContainer: const Color(0xFFF3E5F5),
          tertiary: const Color(0xFF90CAF9),
          onTertiary: const Color(0xFF0D47A1),
          tertiaryContainer: const Color(0xFF1565C0),
          onTertiaryContainer: const Color(0xFFE3F2FD),
          surface: const Color(0xFF1C1418),
          onSurface: const Color(0xFFE6E1E5),
          surfaceContainerHighest: const Color(0xFF2B2128),
          onSurfaceVariant: const Color(0xFFCAC4D0),
          outline: const Color(0xFF938F99),
          outlineVariant: const Color(0xFF49454F),
          error: const Color(0xFFF2B8B5),
          onError: const Color(0xFF601410),
          brightness: Brightness.dark,
        );
      case 'purple':
        return ColorScheme.dark(
          primary: const Color(0xFFCE93D8),
          onPrimary: const Color(0xFF4A0072),
          primaryContainer: const Color(0xFF6A1B9A),
          onPrimaryContainer: const Color(0xFFF3E5F5),
          secondary: const Color(0xFFF48FB1),
          onSecondary: const Color(0xFF880E4F),
          secondaryContainer: const Color(0xFFAD1457),
          onSecondaryContainer: const Color(0xFFFCE4EC),
          tertiary: const Color(0xFF90CAF9),
          onTertiary: const Color(0xFF0D47A1),
          tertiaryContainer: const Color(0xFF1565C0),
          onTertiaryContainer: const Color(0xFFE3F2FD),
          surface: const Color(0xFF1C1B1F),
          onSurface: const Color(0xFFE6E1E5),
          surfaceContainerHighest: const Color(0xFF2B2930),
          onSurfaceVariant: const Color(0xFFCAC4D0),
          outline: const Color(0xFF938F99),
          outlineVariant: const Color(0xFF49454F),
          error: const Color(0xFFF2B8B5),
          onError: const Color(0xFF601410),
          brightness: Brightness.dark,
        );
      case 'purpink':
        return ColorScheme.dark(
          primary: const Color(0xFFCE93D8),
          onPrimary: const Color(0xFF4A0072),
          primaryContainer: const Color(0xFF6A1B9A),
          onPrimaryContainer: const Color(0xFFF3E5F5),
          secondary: const Color(0xFFFF80AB),
          onSecondary: const Color(0xFF880E4F),
          secondaryContainer: const Color(0xFFAD1457),
          onSecondaryContainer: const Color(0xFFFCE4EC),
          tertiary: const Color(0xFF82B1FF),
          onTertiary: const Color(0xFF0D47A1),
          tertiaryContainer: const Color(0xFF1565C0),
          onTertiaryContainer: const Color(0xFFE3F2FD),
          surface: const Color(0xFF1A1820),
          onSurface: const Color(0xFFE6E1E5),
          surfaceContainerHighest: const Color(0xFF292730),
          onSurfaceVariant: const Color(0xFFCAC4D0),
          outline: const Color(0xFF938F99),
          outlineVariant: const Color(0xFF49454F),
          error: const Color(0xFFF2B8B5),
          onError: const Color(0xFF601410),
          brightness: Brightness.dark,
        );
      case 'serenity':
        return ColorScheme.dark(
          primary: const Color(0xFFF2A7AD),
          onPrimary: const Color(0xFF7B2D31),
          primaryContainer: const Color(0xFF9B4B50),
          onPrimaryContainer: const Color(0xFFFDE8E8),
          secondary: const Color(0xFFC9A2C9),
          onSecondary: const Color(0xFF4A0072),
          secondaryContainer: const Color(0xFF7B4D7B),
          onSecondaryContainer: const Color(0xFFF3E5F5),
          tertiary: const Color(0xFFA1C9E3),
          onTertiary: const Color(0xFF0D47A1),
          tertiaryContainer: const Color(0xFF4B7B9B),
          onTertiaryContainer: const Color(0xFFE3F2FD),
          surface: const Color(0xFF1C1818),
          onSurface: const Color(0xFFE6E1E5),
          surfaceContainerHighest: const Color(0xFF2B2828),
          onSurfaceVariant: const Color(0xFFCAC4D0),
          outline: const Color(0xFF938F99),
          outlineVariant: const Color(0xFF49454F),
          error: const Color(0xFFF2B8B5),
          onError: const Color(0xFF601410),
          brightness: Brightness.dark,
        );
      default:
        return ColorScheme.dark(
          primary: const Color(0xFFF48FB1),
          onPrimary: const Color(0xFF880E4F),
          primaryContainer: const Color(0xFFAD1457),
          onPrimaryContainer: const Color(0xFFFCE4EC),
          secondary: const Color(0xFFCE93D8),
          onSecondary: const Color(0xFF4A0072),
          secondaryContainer: const Color(0xFF6A1B9A),
          onSecondaryContainer: const Color(0xFFF3E5F5),
          tertiary: const Color(0xFF90CAF9),
          onTertiary: const Color(0xFF0D47A1),
          tertiaryContainer: const Color(0xFF1565C0),
          onTertiaryContainer: const Color(0xFFE3F2FD),
          surface: const Color(0xFF1C1B1F),
          onSurface: const Color(0xFFE6E1E5),
          surfaceContainerHighest: const Color(0xFF2B2930),
          onSurfaceVariant: const Color(0xFFCAC4D0),
          outline: const Color(0xFF938F99),
          outlineVariant: const Color(0xFF49454F),
          error: const Color(0xFFF2B8B5),
          onError: const Color(0xFF601410),
          brightness: Brightness.dark,
        );
    }
  }
}
