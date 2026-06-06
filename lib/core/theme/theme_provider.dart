import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import 'app_theme.dart';

// --- Base theme mode (system / light / dark) ---
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// --- Accent selection ---
final lightAccentProvider = StateNotifierProvider<LightAccentNotifier, LightAccent>((ref) {
  return LightAccentNotifier();
});

final darkAccentProvider = StateNotifierProvider<DarkAccentNotifier, DarkAccent>((ref) {
  return DarkAccentNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox(AppConstants.hiveSettingsBox);
    final saved = box.get('themeMode', defaultValue: 'system');
    state = _fromString(saved);
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final box = await Hive.openBox(AppConstants.hiveSettingsBox);
    await box.put('themeMode', _toString(mode));
  }

  ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}

class LightAccentNotifier extends StateNotifier<LightAccent> {
  LightAccentNotifier() : super(LightAccent.blue) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox(AppConstants.hiveSettingsBox);
    final saved = box.get('lightAccent', defaultValue: 'blue');
    state = _fromString(saved);
  }

  Future<void> setAccent(LightAccent accent) async {
    state = accent;
    final box = await Hive.openBox(AppConstants.hiveSettingsBox);
    await box.put('lightAccent', _toString(accent));
  }

  LightAccent _fromString(String value) {
    switch (value) {
      case 'lavender':
        return LightAccent.lavender;
      case 'sand':
        return LightAccent.sand;
      default:
        return LightAccent.blue;
    }
  }

  String _toString(LightAccent accent) {
    switch (accent) {
      case LightAccent.blue:
        return 'blue';
      case LightAccent.lavender:
        return 'lavender';
      case LightAccent.sand:
        return 'sand';
    }
  }
}

class DarkAccentNotifier extends StateNotifier<DarkAccent> {
  DarkAccentNotifier() : super(DarkAccent.navy) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox(AppConstants.hiveSettingsBox);
    final saved = box.get('darkAccent', defaultValue: 'navy');
    state = _fromString(saved);
  }

  Future<void> setAccent(DarkAccent accent) async {
    state = accent;
    final box = await Hive.openBox(AppConstants.hiveSettingsBox);
    await box.put('darkAccent', _toString(accent));
  }

  DarkAccent _fromString(String value) {
    switch (value) {
      case 'black':
        return DarkAccent.black;
      case 'charcoal':
        return DarkAccent.charcoal;
      case 'maroon':
        return DarkAccent.maroon;
      default:
        return DarkAccent.navy;
    }
  }

  String _toString(DarkAccent accent) {
    switch (accent) {
      case DarkAccent.navy:
        return 'navy';
      case DarkAccent.black:
        return 'black';
      case DarkAccent.charcoal:
        return 'charcoal';
      case DarkAccent.maroon:
        return 'maroon';
    }
  }
}

// --- Theme data provider (resolves both base mode and accent) ---
final themeDataProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeModeProvider);
  final lightAccent = ref.watch(lightAccentProvider);
  final darkAccent = ref.watch(darkAccentProvider);

  final isDark = switch (mode) {
    ThemeMode.dark => true,
    ThemeMode.light => false,
    ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
  };

  if (isDark) {
    return AppTheme.darkThemeFor(darkAccent);
  } else {
    return AppTheme.lightThemeFor(lightAccent);
  }
});
