import 'package:hive_flutter/hive_flutter.dart';
import '../models/water_entry.dart';
import '../models/streak.dart';
import '../models/achievement.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils_app.dart';

class HiveStorage {
  Box? _box;
  Box? _settingsBox;

  Future<void> init() async {
    _box = await Hive.openBox(AppConstants.hiveBoxName);
    _settingsBox = await Hive.openBox(AppConstants.hiveSettingsBox);
  }

  Future<void> close() async {
    await _box?.close();
    await _settingsBox?.close();
  }

  Box<dynamic>? get _b => _box;
  Box<dynamic>? get _s => _settingsBox;

  List<WaterEntry> getEntriesForDate(DateTime date) {
    final box = _b;
    if (box == null) return [];
    final start = DateUtilsApp.startOfDay(date).millisecondsSinceEpoch;
    final end = DateUtilsApp.endOfDay(date).millisecondsSinceEpoch;
    return getAllEntries().where((e) {
      final ms = e.timestamp.millisecondsSinceEpoch;
      return ms >= start && ms <= end;
    }).toList();
  }

  List<WaterEntry> getAllEntries() {
    final box = _b;
    if (box == null) return [];
    try {
      final data = box.get('entries', defaultValue: <List<dynamic>>[]) as List;
      return data.map((e) => WaterEntry.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addEntry(WaterEntry entry) async {
    final entries = getAllEntries();
    entries.add(entry);
    await _saveEntries(entries);
  }

  Future<void> removeLastEntry() async {
    final entries = getAllEntries();
    if (entries.isNotEmpty) {
      entries.removeLast();
      await _saveEntries(entries);
    }
  }

  Future<void> clearAll() async {
    final box = _b;
    if (box == null) return;
    final settingsBox = _s;
    if (settingsBox == null) return;
    await box.delete('entries');
    await settingsBox.delete('dailyGoal');
    await settingsBox.delete('userName');
    await settingsBox.delete('streak');
    await settingsBox.delete('streak_dates');
    await settingsBox.delete('achievements');
    await settingsBox.delete('themeMode');
    await settingsBox.delete('themePreset');
    await settingsBox.delete('quickAddAmounts');
    await settingsBox.delete('morning_hour');
    await settingsBox.delete('morning_minute');
    await settingsBox.delete('evening_hour');
    await settingsBox.delete('evening_minute');
    final keys = settingsBox.keys.toList();
    for (final key in keys) {
      if (key is String && key.startsWith('note_')) {
        await settingsBox.delete(key);
      }
    }
  }

  Future<void> _saveEntries(List<WaterEntry> entries) async {
    final box = _b;
    if (box == null) return;
    final data = entries.map((e) => e.toJson()).toList();
    await box.put('entries', data);
  }

  String getUserName() {
    final box = _s;
    if (box == null) return 'Friend';
    return box.get('userName', defaultValue: 'Friend') as String;
  }

  Future<void> setUserName(String name) async {
    final box = _s;
    if (box == null) return;
    await box.put('userName', name);
  }

  int getGoal() {
    final box = _s;
    if (box == null) return AppConstants.defaultDailyGoalMl;
    return box.get('dailyGoal', defaultValue: AppConstants.defaultDailyGoalMl) as int;
  }

  Future<void> setGoal(int ml) async {
    final box = _s;
    if (box == null) return;
    await box.put('dailyGoal', ml.clamp(
      AppConstants.minDailyGoalMl,
      AppConstants.maxDailyGoalMl,
    ));
  }

  // --- Notification Times ---
  int getNotifHour(String key, int defaultVal) {
    final box = _s;
    if (box == null) return defaultVal;
    return box.get(key, defaultValue: defaultVal) as int;
  }

  int getNotifMinute(String key, int defaultVal) {
    final box = _s;
    if (box == null) return defaultVal;
    return box.get(key, defaultValue: defaultVal) as int;
  }

  Future<void> setNotifTime(String hourKey, String minKey, int hour, int minute) async {
    final box = _s;
    if (box == null) return;
    await box.put(hourKey, hour.clamp(0, 23));
    await box.put(minKey, minute.clamp(0, 59));
  }

  String getThemeMode() {
    final box = _s;
    if (box == null) return 'system';
    return box.get('themeMode', defaultValue: 'system') as String;
  }

  Future<void> setThemeMode(String mode) async {
    final box = _s;
    if (box == null) return;
    await box.put('themeMode', mode);
  }

  String getThemePreset() {
    final box = _s;
    if (box == null) return 'purple';
    final saved = box.get('themePreset', defaultValue: 'purple') as String;
    // Migrate old presets to the new naming scheme.
    if (saved == 'purplePink') return 'purple';
    return saved;
  }

  Future<void> setThemePreset(String preset) async {
    final box = _s;
    if (box == null) return;
    await box.put('themePreset', preset);
  }

  // --- Quick Add Amounts ---
  List<int> getQuickAddAmounts() {
    final box = _s;
    if (box == null) return AppConstants.quickAddAmounts;
    final data = box.get('quickAddAmounts', defaultValue: AppConstants.quickAddAmounts);
    if (data is List) {
      return data.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 200).toList();
    }
    return AppConstants.quickAddAmounts;
  }

  Future<void> setQuickAddAmounts(List<int> amounts) async {
    final box = _s;
    if (box == null) return;
    await box.put('quickAddAmounts', amounts);
  }

  // --- Daily Notes ---
  String getNoteForDate(DateTime date) {
    final box = _s;
    if (box == null) return '';
    final key = 'note_${DateUtilsApp.formatDateKey(date)}';
    return box.get(key, defaultValue: '') as String;
  }

  Future<void> setNoteForDate(DateTime date, String note) async {
    final box = _s;
    if (box == null) return;
    final key = 'note_${DateUtilsApp.formatDateKey(date)}';
    await box.put(key, note);
  }

  Future<void> deleteNoteForDate(DateTime date) async {
    final box = _s;
    if (box == null) return;
    final key = 'note_${DateUtilsApp.formatDateKey(date)}';
    await box.delete(key);
  }

  // ──────────────────────────────────────────────
  // Streak Persistence
  // ──────────────────────────────────────────────

  Future<void> saveStreak(Streak streak) async {
    final box = _s;
    if (box == null) return;
    await box.put('streak', streak.toJson());
    await box.put('streak_dates',
        streak.streakDates.map((d) => d.millisecondsSinceEpoch).toList());
  }

  Streak loadStreak() {
    final box = _s;
    if (box == null) return const Streak();
    try {
      final data = box.get('streak');
      if (data == null) return const Streak();
      return Streak.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return const Streak();
    }
  }

  // ──────────────────────────────────────────────
  // Achievement Persistence
  // ──────────────────────────────────────────────

  Future<void> saveAchievements(List<Achievement> achievements) async {
    final box = _s;
    if (box == null) return;
    await box.put(
        'achievements', achievements.map((a) => a.toJson()).toList());
  }

  List<Achievement> loadAchievements() {
    final box = _s;
    if (box == null) return List.from(Achievement.all);
    try {
      final data = box.get('achievements');
      if (data == null) return List.from(Achievement.all);
      final list = (data as List)
          .map((e) => Achievement.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return list;
    } catch (_) {
      return List.from(Achievement.all);
    }
  }
}
