import 'package:hive_flutter/hive_flutter.dart';
import '../models/water_entry.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils_app.dart';

class HiveStorage {
  Box? _box;
  Box? _settingsBox;

  Future<void> init() async {
    _box = await Hive.openBox(AppConstants.hiveBoxName);
    _settingsBox = await Hive.openBox(AppConstants.hiveSettingsBox);
  }

  Box get _b => _box!;
  Box get _s => _settingsBox!;

  List<WaterEntry> getEntriesForDate(DateTime date) {
    final start = DateUtilsApp.startOfDay(date).millisecondsSinceEpoch;
    final end = DateUtilsApp.endOfDay(date).millisecondsSinceEpoch;
    return getAllEntries().where((e) {
      final ms = e.timestamp.millisecondsSinceEpoch;
      return ms >= start && ms <= end;
    }).toList();
  }

  List<WaterEntry> getAllEntries() {
    final data = _b.get('entries', defaultValue: <List<dynamic>>[]) as List;
    return data.map((e) => WaterEntry.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> addEntry(WaterEntry entry) async {
    final entries = getAllEntries();
    entries.add(entry);
    await _saveEntries(entries);
  }

  Future<void> removeEntry(WaterEntry entry) async {
    final entries = getAllEntries();
    entries.removeWhere((e) =>
        e.timestamp == entry.timestamp && e.amountMl == entry.amountMl);
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
    await _b.delete('entries');
  }

  Future<void> clearDate(DateTime date) async {
    final remaining = getAllEntries().where((e) {
      return !DateUtilsApp.isSameDay(e.timestamp, date);
    }).toList();
    await _saveEntries(remaining);
  }

  Future<void> _saveEntries(List<WaterEntry> entries) async {
    final data = entries.map((e) => e.toJson()).toList();
    await _b.put('entries', data);
  }

  String getUserName() {
    return _s.get('userName', defaultValue: 'Friend') as String;
  }

  Future<void> setUserName(String name) async {
    await _s.put('userName', name);
  }

  int getGoal() {
    return _s.get('dailyGoal', defaultValue: AppConstants.defaultDailyGoalMl) as int;
  }

  Future<void> setGoal(int ml) async {
    await _s.put('dailyGoal', ml.clamp(
      AppConstants.minDailyGoalMl,
      AppConstants.maxDailyGoalMl,
    ));
  }

  int getTotalForDate(DateTime date) {
    return getEntriesForDate(date).fold(0, (sum, e) => sum + e.amountMl);
  }

  // --- Daily Notes ---
  String getNoteForDate(DateTime date) {
    final key = 'note_${DateUtilsApp.formatDateKey(date)}';
    return _s.get(key, defaultValue: '') as String;
  }

  Future<void> setNoteForDate(DateTime date, String note) async {
    final key = 'note_${DateUtilsApp.formatDateKey(date)}';
    await _s.put(key, note);
  }

  Future<void> deleteNoteForDate(DateTime date) async {
    final key = 'note_${DateUtilsApp.formatDateKey(date)}';
    await _s.delete(key);
  }
}
