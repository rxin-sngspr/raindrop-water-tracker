import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Types of achievements available in the app.
enum AchievementType { streak, volume, consistency }

/// A single achievement with progress tracking.
///
/// Each achievement has a target count. Progress is calculated
/// dynamically based on real user data.
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon; // Material icon
  final int targetCount;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final AchievementType type;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetCount,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedDate,
    required this.type,
  });

  double get progress => (currentProgress / targetCount).clamp(0.0, 1.0);

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    int? targetCount,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedDate,
    AchievementType? type,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      targetCount: targetCount ?? this.targetCount,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'targetCount': targetCount,
        'currentProgress': currentProgress,
        'isUnlocked': isUnlocked,
        'unlockedDate': unlockedDate?.millisecondsSinceEpoch,
        'type': type.name,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    return Achievement(
      id: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: iconForId(id),
      targetCount: json['targetCount'] as int? ?? 1,
      currentProgress: json['currentProgress'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedDate: json['unlockedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['unlockedDate'] as int)
          : null,
      type: AchievementType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AchievementType.volume,
      ),
    );
  }

  /// Resolve the const [IconData] for a given achievement [id].
  static IconData iconForId(String id) {
    switch (id) {
      case 'first_drop':
        return LucideIcons.droplet;
      case 'first_week':
        return LucideIcons.trophy;
      case 'fourteen_day':
        return LucideIcons.flame;
      case 'thirty_day':
        return LucideIcons.diamond;
      case 'hundred_glasses':
        return LucideIcons.crosshair;
      case 'gallon_club':
        return LucideIcons.award;
      case 'early_bird':
        return LucideIcons.sun;
      case 'night_owl':
        return LucideIcons.moon;
      case 'perfect_week':
        return LucideIcons.sparkles;
      case 'half_gallon':
        return LucideIcons.dumbbell;
      case 'sixty_six':
        return LucideIcons.shield;
      case 'perfect_month':
        return LucideIcons.medal;
      default:
        return LucideIcons.droplet;
    }
  }

  /// The full list of built-in achievements.
  static const List<Achievement> all = [
    Achievement(
      id: 'first_drop',
      title: 'First Drop',
      icon: LucideIcons.droplet,
      description: 'Log your first glass of water',
      targetCount: 1,
      type: AchievementType.volume,
    ),
    Achievement(
      id: 'first_week',
      title: 'First Week',
      icon: LucideIcons.trophy,
      description: 'Log water for 7 consecutive days',
      targetCount: 7,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'fourteen_day',
      title: '14-Day Streak',
      icon: LucideIcons.flame,
      description: '14 consecutive days of hydration',
      targetCount: 14,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'thirty_day',
      title: '30-Day Streak',
      icon: LucideIcons.diamond,
      description: 'A full month of daily hydration',
      targetCount: 30,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'hundred_glasses',
      title: '100 Glasses',
      icon: LucideIcons.crosshair,
      description: 'Log 100 glasses of water total',
      targetCount: 100,
      type: AchievementType.volume,
    ),
    Achievement(
      id: 'gallon_club',
      title: '1 Gallon Club',
      icon: LucideIcons.award,
      description: 'Drink 3,785ml in a single day',
      targetCount: 3785,
      type: AchievementType.volume,
    ),
    Achievement(
      id: 'early_bird',
      title: 'Early Bird',
      icon: LucideIcons.sun,
      description: 'Log water before 8 AM for 5 days',
      targetCount: 5,
      type: AchievementType.consistency,
    ),
    Achievement(
      id: 'night_owl',
      title: 'Night Owl',
      icon: LucideIcons.moon,
      description: 'Log water after 10 PM for 3 days',
      targetCount: 3,
      type: AchievementType.consistency,
    ),
    Achievement(
      id: 'perfect_week',
      title: 'Perfect Week',
      icon: LucideIcons.sparkles,
      description: 'Reach your goal every day for a week',
      targetCount: 7,
      type: AchievementType.consistency,
    ),
    Achievement(
      id: 'half_gallon',
      title: 'Half Gallon',
      icon: LucideIcons.dumbbell,
      description: 'Drink 1,890ml in a single day',
      targetCount: 1890,
      type: AchievementType.volume,
    ),
    Achievement(
      id: 'sixty_six',
      title: '66 oz Warrior',
      icon: LucideIcons.shield,
      description: 'Drink 2,000ml for 3 consecutive days',
      targetCount: 3,
      type: AchievementType.consistency,
    ),
    Achievement(
      id: 'perfect_month',
      title: 'Perfect Month',
      icon: LucideIcons.medal,
      description: 'Reach your goal every single day for a month',
      targetCount: 30,
      type: AchievementType.consistency,
    ),
  ];
}
