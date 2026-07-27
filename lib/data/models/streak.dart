/// Tracks the user's hydration streak.
///
/// A streak day is any day where total intake >= 800ml.
/// Consecutive streak days = currentStreak.
class Streak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final List<DateTime> streakDates;

  const Streak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.streakDates = const [],
  });

  Streak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    List<DateTime>? streakDates,
  }) {
    return Streak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      streakDates: streakDates ?? this.streakDates,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastActiveDate': lastActiveDate?.millisecondsSinceEpoch,
        'streakDates':
            streakDates.map((d) => d.millisecondsSinceEpoch).toList(),
      };

  factory Streak.fromJson(Map<String, dynamic> json) => Streak(
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        lastActiveDate: json['lastActiveDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['lastActiveDate'] as int)
            : null,
        streakDates: (json['streakDates'] as List<dynamic>?)
                ?.map((e) =>
                    DateTime.fromMillisecondsSinceEpoch((e as num).toInt()))
                .toList() ??
            [],
      );
}
