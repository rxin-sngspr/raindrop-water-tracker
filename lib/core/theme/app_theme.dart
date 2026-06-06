import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum LightAccent { blue, lavender, sand }

enum DarkAccent { navy, black, charcoal, maroon }

class _LightPalette {
  final Color primary;
  final Color primaryAlt;
  final Color accent;

  const _LightPalette({
    required this.primary,
    required this.primaryAlt,
    required this.accent,
  });
}

class _DarkPalette {
  final Color primary;
  final Color primaryAlt;
  final Color accent;
  final Color surface;
  final Color background;
  final Color card;

  const _DarkPalette({
    required this.primary,
    required this.primaryAlt,
    required this.accent,
    required this.surface,
    required this.background,
    required this.card,
  });
}

class AppTheme {
  AppTheme._();

  // Error and success (shared across all themes)
  static const Color _error = Color(0xFFFF453A);
  static const Color _success = Color(0xFF30D158);

  // --- Light mode palettes ---
  static const _LightPalette _blueLight = _LightPalette(
    primary: Color(0xFF0A84FF),
    primaryAlt: Color(0xFF5E9EFF),
    accent: Color(0xFF64D2FF),
  );

  static const _LightPalette _lavenderLight = _LightPalette(
    primary: Color(0xFF8B7BD6),
    primaryAlt: Color(0xFFB4A8E8),
    accent: Color(0xFFD4C9F8),
  );

  static const _LightPalette _sandLight = _LightPalette(
    primary: Color(0xFFC28B5E),
    primaryAlt: Color(0xFFD9B28A),
    accent: Color(0xFFE8D5B8),
  );

  // --- Dark mode palettes ---
  static const _DarkPalette _navyDark = _DarkPalette(
    primary: Color(0xFF4A9EFF),
    primaryAlt: Color(0xFF80B8FF),
    accent: Color(0xFF64D2FF),
    surface: Color(0xFF0D1520),
    background: Color(0xFF070B14),
    card: Color(0xFF141E2E),
  );

  static const _DarkPalette _blackDark = _DarkPalette(
    primary: Color(0xFF6B7280),
    primaryAlt: Color(0xFF9CA3AF),
    accent: Color(0xFFD1D5DB),
    surface: Color(0xFF111111),
    background: Color(0xFF000000),
    card: Color(0xFF1A1A1A),
  );

  static const _DarkPalette _charcoalDark = _DarkPalette(
    primary: Color(0xFF8E8E93),
    primaryAlt: Color(0xFFAEAEB2),
    accent: Color(0xFFC7C7CC),
    surface: Color(0xFF1C1C1E),
    background: Color(0xFF121214),
    card: Color(0xFF262629),
  );

  static const _DarkPalette _maroonDark = _DarkPalette(
    primary: Color(0xFFBF5B5B),
    primaryAlt: Color(0xFFD98A8A),
    accent: Color(0xFFE8B4B4),
    surface: Color(0xFF1A0E0E),
    background: Color(0xFF0F0707),
    card: Color(0xFF261515),
  );

  static _LightPalette _lightPaletteFor(LightAccent accent) {
    switch (accent) {
      case LightAccent.blue:
        return _blueLight;
      case LightAccent.lavender:
        return _lavenderLight;
      case LightAccent.sand:
        return _sandLight;
    }
  }

  static _DarkPalette _darkPaletteFor(DarkAccent accent) {
    switch (accent) {
      case DarkAccent.navy:
        return _navyDark;
      case DarkAccent.black:
        return _blackDark;
      case DarkAccent.charcoal:
        return _charcoalDark;
      case DarkAccent.maroon:
        return _maroonDark;
    }
  }

  // Glass card helper
  static BoxDecoration glassDecoration({
    required Color bgColor,
    required Color borderColor,
    double blur = 12,
    double radius = 20,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: shadows ?? [
        BoxShadow(
          color: borderColor.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Light background gradient
  static BoxDecoration get lightBackground => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFF0F6FF),
        Color(0xFFE8F0FE),
        Color(0xFFF5F7FA),
      ],
      stops: [0.0, 0.5, 1.0],
    ),
  );

  // Dark background gradient
  static BoxDecoration get darkBackground => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF070B14),
        Color(0xFF0A1121),
        Color(0xFF070B14),
      ],
      stops: [0.0, 0.5, 1.0],
    ),
  );

  // Premium card gradient overlay
  static BoxDecoration cardGradient(bool isDark) => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              Colors.white.withValues(alpha: 0.04),
              Colors.white.withValues(alpha: 0.01),
            ]
          : [
              Colors.white.withValues(alpha: 0.6),
              Colors.white.withValues(alpha: 0.3),
            ],
    ),
  );

  static ThemeData lightThemeFor(LightAccent accent) {
    final p = _lightPaletteFor(accent);
    return _buildLightTheme(p.primary, p.primaryAlt, p.accent);
  }

  static ThemeData darkThemeFor(DarkAccent accent) {
    final p = _darkPaletteFor(accent);
    return _buildDarkTheme(p.primary, p.primaryAlt, p.accent, p.surface, p.background, p.card);
  }

  /// Keep backward compatibility for existing references
  static ThemeData get lightTheme => lightThemeFor(LightAccent.blue);
  static ThemeData get darkTheme => darkThemeFor(DarkAccent.navy);

  static ThemeData _buildLightTheme(Color primary, Color primaryAlt, Color accent) {
    final colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primary.withValues(alpha: 0.12),
      onPrimaryContainer: primary,
      secondary: _success,
      onSecondary: Colors.white,
      secondaryContainer: _success.withValues(alpha: 0.12),
      onSecondaryContainer: _success,
      tertiary: accent,
      surface: const Color(0xFFF5F7FA),
      onSurface: const Color(0xFF0A0E1A),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF0F3F8),
      surfaceContainer: const Color(0xFFE8ECF3),
      surfaceContainerHigh: const Color(0xFFDEE3EB),
      surfaceContainerHighest: const Color(0xFFD1D7E0),
      onSurfaceVariant: const Color(0xFF5A6070),
      outline: const Color(0xFFB0B8C8),
      outlineVariant: const Color(0xFFD1D7E0),
      error: _error,
      onError: Colors.white,
      errorContainer: _error.withValues(alpha: 0.12),
      onErrorContainer: _error,
      shadow: Colors.black.withValues(alpha: 0.08),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: -0.25,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: -0.3,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: 0.25,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white.withValues(alpha: 0.75),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF8E95A5),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F3F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFFD1D7E0),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF5A6070),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: const Color(0xFFD1D7E0).withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: const Color(0xFFD1D7E0),
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        indicatorColor: primary.withValues(alpha: 0.12),
        backgroundColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
              letterSpacing: 0.2,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8E95A5),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(size: 24, color: primary);
          }
          return const IconThemeData(size: 24, color: Color(0xFF8E95A5));
        }),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.1),
      ),
    );
  }

  static ThemeData _buildDarkTheme(Color primary, Color primaryAlt, Color accent, Color surface, Color background, Color card) {
    final colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primary.withValues(alpha: 0.15),
      onPrimaryContainer: primaryAlt,
      secondary: _success,
      onSecondary: Colors.white,
      secondaryContainer: _success.withValues(alpha: 0.15),
      onSecondaryContainer: _success,
      tertiary: accent,
      surface: surface,
      onSurface: const Color(0xFFE8ECF0),
      surfaceContainerLowest: const Color(0xFF0A0F1A),
      surfaceContainerLow: const Color(0xFF111A28),
      surfaceContainer: const Color(0xFF162030),
      surfaceContainerHigh: const Color(0xFF1C2838),
      surfaceContainerHighest: const Color(0xFF243040),
      onSurfaceVariant: const Color(0xFF8892A8),
      outline: const Color(0xFF3A4558),
      outlineVariant: const Color(0xFF2A3548),
      error: _error,
      onError: Colors.white,
      errorContainer: _error.withValues(alpha: 0.15),
      onErrorContainer: const Color(0xFFFF6961),
      shadow: Colors.black.withValues(alpha: 0.3),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.25,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF8892A8),
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.25,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF8892A8),
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: card.withValues(alpha: 0.85),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: 0.9),
        selectedItemColor: primaryAlt,
        unselectedItemColor: const Color(0xFF5A6880),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111A28),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF2A3548),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF8892A8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: const Color(0xFF2A3548).withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: const Color(0xFF2A3548),
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        indicatorColor: primary.withValues(alpha: 0.15),
        backgroundColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryAlt,
              letterSpacing: 0.2,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF5A6880),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(size: 24, color: primaryAlt);
          }
          return const IconThemeData(size: 24, color: Color(0xFF5A6880));
        }),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: card,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
    );
  }
}
