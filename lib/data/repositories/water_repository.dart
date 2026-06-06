import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/water_entry.dart';
import '../storage/hive_storage.dart';

final storageProvider = Provider<HiveStorage>((ref) {
  throw UnimplementedError('Storage not initialized');
});

final todayProvider = StateNotifierProvider<TodayNotifier, TodayState>((ref) {
  final storage = ref.watch(storageProvider);
  return TodayNotifier(storage);
});

final monthProvider =
    StateNotifierProvider.family<MonthNotifier, List<WaterEntry>, DateTime>(
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
  final HiveStorage _storage;

  TodayNotifier(this._storage)
      : super(TodayState(entries: [], total: 0, goal: 0)) {
    _refresh();
  }

  void refresh() => _refresh();

  void _refresh() {
    final entries = _storage.getEntriesForDate(DateTime.now());
    final total = entries.fold(0, (sum, e) => sum + e.amountMl);
    final goal = _storage.getGoal();
    state = TodayState(entries: entries, total: total, goal: goal);
  }

  Future<void> addWater(int ml) async {
    await _storage.addEntry(WaterEntry(
      timestamp: DateTime.now(),
      amountMl: ml,
    ));
    _refresh();
  }

  Future<void> undoLast() async {
    await _storage.removeLastEntry();
    _refresh();
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
final noteProvider = StateNotifierProvider.family<NoteNotifier, String, DateTime>((ref, date) {
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
