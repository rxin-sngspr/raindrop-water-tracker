import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_dimensions.dart';
import '../../data/repositories/water_repository.dart';
import '../../shared/widgets/rain_page_header.dart';
import '../../shared/widgets/rain_streak_card.dart';
import '../../shared/widgets/rain_badge_card.dart';
import '../../shared/widgets/rain_stat_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsProvider);
    final streak = ref.watch(streakProvider);
    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Sort: unlocked first, then locked
    final sortedAchievements = [...achievements]..sort((a, b) {
      if (a.isUnlocked && !b.isUnlocked) return -1;
      if (!a.isUnlocked && b.isUnlocked) return 1;
      return 0;
    });

    // Show back button when this screen was pushed (not a tab)
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.pageH,
                  AppDimensions.pageV,
                  AppDimensions.pageH,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RainPageHeader(
                      leading: canPop
                          ? Semantics(
                              button: true,
                              label: 'Back',
                              child: IconButton(
                                icon: const Icon(LucideIcons.arrowLeft),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            )
                          : null,
                      title: 'Achievements',
                      subtitle:
                          '$unlocked of ${achievements.length} unlocked',
                    ),
                    SizedBox(height: AppDimensions.sectionGap),

                    // Summary stat
                    RainStatCard(
                      value: '$unlocked',
                      unit: '/ ${achievements.length}',
                      label: 'Badges earned',
                      badge: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: unlocked == achievements.length
                              ? cs.tertiary.withValues(alpha: 0.15)
                              : cs.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: Text(
                          achievements.isNotEmpty
                              ? '${(unlocked / achievements.length * 100).toInt()}%'
                              : '0%',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: unlocked == achievements.length
                                ? cs.tertiary
                                : cs.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.sectionGap),

                    // Current streak card
                    if (streak.currentStreak > 0)
                      RainStreakCard(
                        currentStreak: streak.currentStreak,
                        longestStreak: streak.longestStreak,
                      ),
                    if (streak.currentStreak > 0)
                      SizedBox(height: AppDimensions.sectionGap),
                  ],
                ),
              ),
            ),

            // Badge grid — 2 columns, sorted unlocked first
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.pageH,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppDimensions.sp3,
                  mainAxisSpacing: AppDimensions.sp4,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final achievement = sortedAchievements[index];
                    return RainBadgeCard(
                      icon: achievement.icon,
                      title: achievement.title,
                      description: achievement.description,
                      progress: achievement.progress,
                      unlocked: achievement.isUnlocked,
                      progressLabel: achievement.isUnlocked
                          ? '${achievement.targetCount}/${achievement.targetCount}'
                          : '${achievement.currentProgress}/${achievement.targetCount}',
                    );
                  },
                  childCount: sortedAchievements.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
