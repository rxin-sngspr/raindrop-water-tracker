import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/water_entry.dart';
import '../models/streak.dart';
import '../models/achievement.dart';
import '../storage/hive_storage.dart';
import '../../core/utils/date_utils_app.dart';

final storageProvider = Provider<HiveStorage>((ref) {
  throw UnimplementedError('Storage not initialized');
});

final todayProvider = StateNotifierProvider<TodayNotifier, TodayState>((ref) {
  final storage = ref.watch(storageProvider);
  return TodayNotifier(ref, storage);
});

final monthProvider =
    StateNotifierProvider.autoDispose.family<MonthNotifier, List<WaterEntry>, DateTime>(
  (ref, month) {
    final storage = ref.watch(storageProvider);
    return MonthNotifier(storage, month);
  },
);

class TodayState {
  final List<WaterEntry> entries;
  final int total;
  final int goal;

  TodayState({
    required this.entries,
    required this.total,
    required this.goal,
  });
}

class TodayNotifier extends StateNotifier<TodayState> {
  final Ref _ref;
  final HiveStorage _storage;
  DateTime _today = DateTime.now();
  Timer? _dateCheckTimer;
  bool _disposed = false;

  TodayNotifier(this._ref, this._storage)
      : super(TodayState(entries: [], total: 0, goal: 0)) {
    _refresh();
  }

  void refresh() => _refresh();

  void _refresh() {
    _dateCheckTimer?.cancel();
    _dateCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_disposed) return;
      final now = DateTime.now();
      if (now.day != _today.day ||
          now.month != _today.month ||
          now.year != _today.year) {
        _today = DateTime(now.year, now.month, now.day);
        if (!_disposed) _refresh();
      }
    });
    final entries = _storage.getEntriesForDate(DateTime.now());
    final total = entries.fold(0, (sum, e) => sum + e.amountMl);
    final goal = _storage.getGoal();
    state = TodayState(entries: entries, total: total, goal: goal);
  }

  @override
  void dispose() {
    _disposed = true;
    _dateCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> addWater(int ml) async {
    try {
      await _storage.addEntry(WaterEntry(
        timestamp: DateTime.now(),
        amountMl: ml,
      ));
      _refresh();
      await _ref.read(streakProvider.notifier).recalculate();
      await _ref.read(achievementsProvider.notifier).recalculate();
    } catch (_) {}
  }

  Future<void> undoLast() async {
    await _storage.removeLastEntry();
    _refresh();
    _ref.read(streakProvider.notifier).recalculate();
    _ref.read(achievementsProvider.notifier).recalculate();
  }

  Future<void> setGoal(int ml) async {
    await _storage.setGoal(ml);
    _refresh();
  }
}

final userNameProvider = StateNotifierProvider<UserNameNotifier, String>((ref) {
  final storage = ref.watch(storageProvider);
  return UserNameNotifier(storage);
});

class UserNameNotifier extends StateNotifier<String> {
  final HiveStorage _storage;

  UserNameNotifier(this._storage) : super('') {
    state = _storage.getUserName();
  }

  Future<void> setName(String name) async {
    await _storage.setUserName(name);
    state = name;
  }
}

// --- Daily Note ---
final noteProvider = StateNotifierProvider.autoDispose.family<NoteNotifier, String, DateTime>((ref, date) {
  final storage = ref.watch(storageProvider);
  return NoteNotifier(storage, date);
});

class NoteNotifier extends StateNotifier<String> {
  final HiveStorage _storage;
  final DateTime _date;

  NoteNotifier(this._storage, this._date) : super('') {
    state = _storage.getNoteForDate(_date);
  }

  Future<void> setNote(String note) async {
    if (note.trim().isEmpty) {
      await _storage.deleteNoteForDate(_date);
      state = '';
    } else {
      await _storage.setNoteForDate(_date, note.trim());
      state = note.trim();
    }
  }

  Future<void> deleteNote() async {
    await _storage.deleteNoteForDate(_date);
    state = '';
  }
}

// --- Notification Time ---
final notifTimeProvider = Provider.family<DateTime, String>((ref, key) {
  final storage = ref.watch(storageProvider);
  final hour = storage.getNotifHour('${key}_hour', key == 'morning' ? 9 : 18);
  final minute = storage.getNotifMinute('${key}_minute', 0);
  return DateTime(2024, 1, 1, hour, minute);
});

// --- Quick Add Amounts ---
final quickAddProvider = StateNotifierProvider<QuickAddNotifier, List<int>>((ref) {
  return QuickAddNotifier(ref.watch(storageProvider));
});

class QuickAddNotifier extends StateNotifier<List<int>> {
  final HiveStorage _storage;

  QuickAddNotifier(this._storage) : super(_storage.getQuickAddAmounts());

  Future<void> setAmounts(List<int> amounts) async {
    await _storage.setQuickAddAmounts(amounts);
    state = amounts;
  }
}

class MonthNotifier extends StateNotifier<List<WaterEntry>> {
  final HiveStorage _storage;
  final DateTime _month;

  MonthNotifier(this._storage, this._month) : super([]) {
    _refresh();
  }

  void _refresh() {
    state = _storage.getAllEntries().where((e) {
      return e.timestamp.year == _month.year &&
          e.timestamp.month == _month.month;
    }).toList();
  }

  void refresh() => _refresh();
}

// --- Streak ---
final streakProvider =
    StateNotifierProvider<StreakNotifier, Streak>((ref) {
  final storage = ref.watch(storageProvider);
  return StreakNotifier(storage);
});

class StreakNotifier extends StateNotifier<Streak> {
  final HiveStorage _storage;

  StreakNotifier(this._storage) : super(const Streak()) {
    recalculate();
  }

  Future<void> recalculate() async {
    final entries = _storage.getAllEntries();
    final dailyGoal = _storage.getGoal();
    final computed = StreakCalculator.calculate(entries, dailyGoal: dailyGoal);
    state = computed;
    await _storage.saveStreak(computed);
  }

  Future<void> saveStreak(Streak updated) async {
    state = updated;
    await _storage.saveStreak(updated);
  }
}

// --- Achievements ---
final achievementsProvider =
    StateNotifierProvider<AchievementsNotifier, List<Achievement>>(
        (ref) {
  final storage = ref.watch(storageProvider);
  return AchievementsNotifier(storage);
});

class AchievementsNotifier extends StateNotifier<List<Achievement>> {
  final HiveStorage _storage;

  AchievementsNotifier(this._storage) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = _storage.loadAchievements();
    await recalculate();
  }

  Future<void> recalculate() async {
    final allEntries = _storage.getAllEntries();
    final dailyGoal = _storage.getGoal();
    final updated = AchievementChecker.evaluateAll(
        state, allEntries, dailyGoal: dailyGoal);
    state = updated;
    await _storage.saveAchievements(updated);
  }

  Future<void> saveAchievements(List<Achievement> updated) async {
    state = updated;
    await _storage.saveAchievements(updated);
  }
}

// --- Water logged event (for mascot trigger) ---
final waterLoggedEventProvider = StateProvider<int>((ref) => 0);

// --- Goal reached event ---
final goalReachedEventProvider = StateProvider<bool>((ref) => false);

// ──────────────────────────────────────────────
// StreakCalculator
// ──────────────────────────────────────────────

/// Computes [Streak] from raw [WaterEntry] data.
class StreakCalculator {
  StreakCalculator._();

  /// Calculates current streak, longest streak, and streak dates.
  ///
  /// Walks backward from today (or yesterday if today hasn't met the goal)
  /// and counts consecutive calendar days where total intake >= [dailyGoal].
  static Streak calculate(List<WaterEntry> entries,
      {required int dailyGoal}) {
    if (entries.isEmpty) return const Streak();

    // Group entries by day and sum daily totals.
    final dayTotals = <String, int>{};
    for (final entry in entries) {
      final key = DateUtilsApp.formatDateKey(entry.timestamp);
      dayTotals.update(key, (v) => v + entry.amountMl,
          ifAbsent: () => entry.amountMl);
    }

    final today = DateUtilsApp.todayDate;
    final todayKey = DateUtilsApp.formatDateKey(today);
    final todayTotal = dayTotals[todayKey];

    // Start from today if it qualifies, otherwise from yesterday.
    var cursor =
        (todayTotal != null && todayTotal >= dailyGoal) ? today : today.subtract(const Duration(days: 1));

    int currentStreakCount = 0;
    final List<DateTime> currentDates = [];

    for (int i = 0; i < 366; i++) {
      final key = DateUtilsApp.formatDateKey(cursor);
      final total = dayTotals[key];
      if (total != null && total >= dailyGoal) {
        currentDates.add(cursor);
        currentStreakCount++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    currentDates.sort();

    // Longest streak: scan all calendar days from earliest entry to today.
    int longestStreak = 0;
    if (dayTotals.isNotEmpty) {
      final sortedKeys = dayTotals.keys.toList()..sort();
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      final earliest = dateFormat.parse(sortedKeys.first);

      var scanDate = earliest;
      int currentRun = 0;
      while (!scanDate.isAfter(today)) {
        final key = DateUtilsApp.formatDateKey(scanDate);
        final total = dayTotals[key];
        if (total != null && total >= dailyGoal) {
          currentRun++;
          if (currentRun > longestStreak) {
            longestStreak = currentRun;
          }
        } else {
          currentRun = 0;
        }
        scanDate = scanDate.add(const Duration(days: 1));
      }
    }

    return Streak(
      currentStreak: currentStreakCount,
      longestStreak: longestStreak,
      lastActiveDate: currentDates.isNotEmpty ? currentDates.last : null,
      streakDates: currentDates,
    );
  }
}

// ──────────────────────────────────────────────
// AchievementChecker
// ──────────────────────────────────────────────

/// Evaluates all [Achievement]s against raw [WaterEntry] data.
class AchievementChecker {
  AchievementChecker._();

  /// Re-evaluates every achievement in [achievements] using [allEntries].
  ///
  /// Returns a new list with updated [currentProgress] and [isUnlocked].
  static List<Achievement> evaluateAll(
      List<Achievement> achievements, List<WaterEntry> allEntries,
      {required int dailyGoal}) {
    // ── Aggregate metrics ──────────────────────────────────────────
    final totalEntries = allEntries.length;

    // Group by day and compute daily totals.
    final dayMap = <String, List<WaterEntry>>{};
    for (final e in allEntries) {
      final key = DateUtilsApp.formatDateKey(e.timestamp);
      dayMap.putIfAbsent(key, () => []).add(e);
    }

    final dayTotals = dayMap.map(
        (k, v) => MapEntry(k, v.fold(0, (s, e) => s + e.amountMl)));

    final maxDailyTotal =
        dayTotals.values.isEmpty ? 0 : dayTotals.values.reduce(
            (a, b) => a > b ? a : b);

    final earlyBirdDays = dayMap.values
        .where((entries) => entries.any((e) => e.timestamp.hour < 8))
        .length;

    final nightOwlDays = dayMap.values
        .where((entries) => entries.any((e) => e.timestamp.hour >= 22))
        .length;

    // Compute streak from raw data (same logic as StreakCalculator).
    final today = DateUtilsApp.todayDate;
    final todayKey = DateUtilsApp.formatDateKey(today);
    final todayTotal = dayTotals[todayKey] ?? 0;

    int currentStreak = 0;
    {
      var cursor = (todayTotal >= dailyGoal)
          ? today
          : today.subtract(const Duration(days: 1));
      for (int i = 0; i < 366; i++) {
        final key = DateUtilsApp.formatDateKey(cursor);
        final total = dayTotals[key];
        if (total != null && total >= dailyGoal) {
          currentStreak++;
          cursor = cursor.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    // Consecutive-3-day check for sixty_six (any 3 consecutive days with >=2000ml).
    bool hasThreeConsecutiveAbove2000 = false;
    if (dayTotals.isNotEmpty) {
      final sortedKeys = dayTotals.keys.toList()..sort();
      int run = 0;
      for (final key in sortedKeys) {
        if ((dayTotals[key] ?? 0) >= 2000) {
          run++;
          if (run >= 3) {
            hasThreeConsecutiveAbove2000 = true;
            break;
          }
        } else {
          run = 0;
        }
      }
    }

    // ── Evaluate each achievement ──────────────────────────────────
    return achievements.map((a) {
      int progress;
      bool unlocked;

      switch (a.id) {
        case 'first_drop':
          progress = totalEntries >= 1 ? 1 : 0;
          unlocked = totalEntries >= 1;
          break;

        case 'first_week':
          progress = currentStreak.clamp(0, 7);
          unlocked = currentStreak >= 7;
          break;

        case 'fourteen_day':
          progress = currentStreak.clamp(0, 14);
          unlocked = currentStreak >= 14;
          break;

        case 'thirty_day':
          progress = currentStreak.clamp(0, 30);
          unlocked = currentStreak >= 30;
          break;

        case 'hundred_glasses':
          progress = totalEntries.clamp(0, a.targetCount);
          unlocked = totalEntries >= a.targetCount;
          break;

        case 'gallon_club':
          progress = maxDailyTotal.clamp(0, a.targetCount);
          unlocked = maxDailyTotal >= a.targetCount;
          break;

        case 'early_bird':
          progress = earlyBirdDays.clamp(0, a.targetCount);
          unlocked = earlyBirdDays >= a.targetCount;
          break;

        case 'night_owl':
          progress = nightOwlDays.clamp(0, a.targetCount);
          unlocked = nightOwlDays >= a.targetCount;
          break;

        case 'perfect_week':
          progress = currentStreak.clamp(0, 7);
          unlocked = currentStreak >= 7;
          break;

        case 'half_gallon':
          progress = maxDailyTotal.clamp(0, a.targetCount);
          unlocked = maxDailyTotal >= a.targetCount;
          break;

        case 'sixty_six':
          progress = hasThreeConsecutiveAbove2000 ? 3 : 0;
          unlocked = hasThreeConsecutiveAbove2000;
          break;

        case 'perfect_month':
          progress = currentStreak.clamp(0, 30);
          unlocked = currentStreak >= 30;
          break;

        default:
          progress = a.currentProgress;
          unlocked = a.isUnlocked;
      }

      final now = DateTime.now();
      return a.copyWith(
        currentProgress: progress,
        isUnlocked: unlocked,
        unlockedDate: unlocked
            ? (a.isUnlocked ? a.unlockedDate : now)
            : null,
      );
    }).toList();
  }
}
