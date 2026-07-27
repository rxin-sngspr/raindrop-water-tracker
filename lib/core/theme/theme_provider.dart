import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/storage/hive_storage.dart';
import '../../data/repositories/water_repository.dart';
import 'app_theme.dart';

/// Holds both light and dark ThemeData for MaterialApp.
class AppThemePair {
  final ThemeData light;
  final ThemeData dark;
  const AppThemePair({required this.light, required this.dark});
}

/// Provides the current theme mode (light / dark / system).
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(storageProvider);
  return ThemeModeNotifier(storage);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final HiveStorage _storage;

  ThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _load();
  }

  void _load() {
    final saved = _storage.getThemeMode();
    state = _fromString(saved);
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _storage.setThemeMode(_toString(mode));
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

/// Provides the current theme preset (pink / purple / purpink / serenity).
final themePresetProvider =
    StateNotifierProvider<ThemePresetNotifier, String>((ref) {
  final storage = ref.watch(storageProvider);
  return ThemePresetNotifier(storage);
});

class ThemePresetNotifier extends StateNotifier<String> {
  final HiveStorage _storage;

  ThemePresetNotifier(this._storage) : super(AppThemePresets.purple) {
    _load();
  }

  void _load() {
    final saved = _storage.getThemePreset();
    if (AppThemePresets.all.contains(saved)) {
      state = saved;
    }
  }

  Future<void> setPreset(String preset) async {
    if (AppThemePresets.all.contains(preset)) {
      state = preset;
      await _storage.setThemePreset(preset);
    }
  }
}

/// Provides both light and dark themes, watching the current preset.
final appThemeProvider = Provider<AppThemePair>((ref) {
  final preset = ref.watch(themePresetProvider);
  return AppThemePair(
    light: AppTheme.light(preset: preset),
    dark: AppTheme.dark(preset: preset),
  );
});
