import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/repositories/water_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_dimensions.dart';
import '../../shared/widgets/rain_page_header.dart';
import '../../shared/widgets/rain_water_circle.dart';
import '../../shared/widgets/rain_pill_button.dart';
import '../../shared/widgets/rain_log_tile.dart';
import '../../shared/widgets/rain_empty_state.dart';
import '../../shared/widgets/rain_stat_card.dart';
import '../../shared/widgets/rain_streak_card.dart';
import '../../shared/widgets/rain_status_dot.dart';
import '../achievements/achievements_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final userName = ref.watch(userNameProvider);
    final quickAddAmounts = ref.watch(quickAddProvider);
    final streak = ref.watch(streakProvider);

    final progress =
        today.goal > 0 ? (today.total / today.goal).clamp(0.0, 1.0) : 0.0;
    final remaining = (today.goal - today.total).clamp(0, today.goal);
    final isGoalReached = today.total >= today.goal && today.total > 0;
    final isOverLimit = today.total >= AppConstants.maxDailyTotalMl;
    final reversedEntries = today.entries.reversed.toList();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasEntries = today.entries.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(todayProvider.notifier).refresh();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.pageH,
                    AppDimensions.pageV,
                    AppDimensions.pageH,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page header with greeting + status dot
                      RainPageHeader(
                        leading: Semantics(
                          button: true,
                          label: 'Quick add 250ml',
                          child: GestureDetector(
                            onTap: () =>
                                _addWaterWithCheck(context, ref, 250),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.droplet,
                                color: cs.primary,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        title: userName.isNotEmpty
                            ? 'Hey $userName'
                            : 'Hey Friend',
                        subtitle: _motivationalMessage(progress),
                        trailing: Semantics(
                          button: true,
                          label: 'Settings',
                          child: IconButton(
                            icon: Icon(
                              LucideIcons.settings,
                              color: cs.onSurfaceVariant,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                            tooltip: 'Open settings',
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimensions.sectionGap),

                      // Status dot — hydration status indicator
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Row(
                          children: [
                            RainStatusDot(
                              color: isOverLimit
                                  ? cs.error
                                  : isGoalReached
                                      ? cs.tertiary
                                      : hasEntries
                                          ? cs.primary
                                          : cs.onSurfaceVariant,
                              label: isOverLimit
                                  ? 'Over limit'
                                  : isGoalReached
                                      ? 'Goal reached'
                                      : hasEntries
                                          ? 'Tracking today'
                                          : 'No entries yet',
                              dotSize: 8,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppDimensions.tightGap),

                      // Streak card
                      if (streak.currentStreak > 0)
                        RainStreakCard(
                          currentStreak: streak.currentStreak,
                          longestStreak: streak.longestStreak,
                          onViewBadges: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AchievementsScreen(),
                              ),
                            );
                          },
                        ),
                      if (streak.currentStreak > 0)
                        SizedBox(height: AppDimensions.sectionGap),

                      // Big water circle (main visual + interaction)
                      Center(
                        child: RainWaterCircle(
                          progress: progress,
                          currentMl: today.total,
                          goalMl: today.goal,
                          isGoalReached: isGoalReached,
                          onTap: () => _addWaterWithCheck(context, ref, 250),
                        ),
                      ),
                      SizedBox(height: AppDimensions.sectionGap),

                      // Quick add buttons
                      Text(
                        'Quick Add',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppDimensions.tightGap),
                      Row(
                        children: [
                          for (final amount in quickAddAmounts) ...[
                            Expanded(
                              child: RainPillButton(
                                label: '$amount ml',
                                icon: amount <= 200
                                    ? LucideIcons.droplet
                                    : amount <= 350
                                        ? LucideIcons.droplets
                                        : LucideIcons.cupSoda,
                                onPressed: () =>
                                    _addWaterWithCheck(context, ref, amount),
                              ),
                            ),
                            if (amount != quickAddAmounts.last)
                              SizedBox(width: AppDimensions.tightGap),
                          ],
                        ],
                      ),
                      SizedBox(height: AppDimensions.tightGap),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: RainPillButton(
                          label: 'Custom Amount',
                          icon: LucideIcons.plus,
                          onPressed: () => _showCustomDialog(context, ref),
                        ),
                      ),
                      SizedBox(height: AppDimensions.sectionGap),

                      // Status section
                      if (isOverLimit)
                        RainStatCard(
                          value: '${AppConstants.maxDailyTotalMl}',
                          unit: 'ml',
                          label: 'Daily limit reached. Slow down!',
                          color: cs.error,
                        )
                      else if (isGoalReached)
                        _AnimatedGoalCard(
                          remaining: remaining,
                          cs: cs,
                          theme: theme,
                        )
                      else if (today.total > 0)
                        RainStatCard(
                          value: '$remaining',
                          unit: 'ml',
                          label: 'remaining to reach your goal',
                        ),
                      if (today.total > 0)
                        SizedBox(height: AppDimensions.elementGap),

                      // Log section
                      Text(
                        'Today\'s Log',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppDimensions.tightGap),
                    ],
                  ),
                ),
              ),

              // Water log list or empty state
              if (today.entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: RainEmptyState(
                    icon: LucideIcons.droplets,
                    title: 'No water logged yet',
                    message: 'Tap a button above to get started',
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.pageH,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = reversedEntries[index];
                        return RainLogTile(
                          amountMl: entry.amountMl,
                          formattedTime: _formatTime(entry.timestamp),
                          showUndo: index == 0,
                          onUndo: () =>
                              ref.read(todayProvider.notifier).undoLast(),
                        );
                      },
                      childCount: today.entries.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  void _addWaterWithCheck(
      BuildContext context, WidgetRef ref, int ml) async {
    final state = ref.read(todayProvider);
    final newTotal = state.total + ml;

    if (ml > AppConstants.maxPerEntryMl) {
      _showLimitSnackbar(
          context, 'Max ${AppConstants.maxPerEntryMl}ml per entry');
      return;
    }

    if (newTotal > AppConstants.maxDailyTotalMl) {
      _showLimitSnackbar(
          context, 'Daily limit is ${AppConstants.maxDailyTotalMl}ml');
      return;
    }

    try {
      await ref.read(todayProvider.notifier).addWater(ml);
      ref.read(waterLoggedEventProvider.notifier).state++;
      final updatedState = ref.read(todayProvider);
      if (updatedState.total >= updatedState.goal &&
          updatedState.entries.isNotEmpty) {
        ref.read(goalReachedEventProvider.notifier).state = true;
        Future.delayed(const Duration(seconds: 5), () {
          if (context.mounted) {
            ref.read(goalReachedEventProvider.notifier).state = false;
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        _showLimitSnackbar(context, 'Failed to save: $e');
      }
    }
  }

  void _showLimitSnackbar(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(LucideIcons.info,
                color: cs.onErrorContainer, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: cs.errorContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showCustomDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(LucideIcons.plus, color: cs.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Custom Amount',
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter amount between 1 and ${AppConstants.maxPerEntryMl}ml',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: 'e.g. 350',
                suffixText: 'ml',
                prefixIcon: const Icon(LucideIcons.droplets),
              ),
              onSubmitted: (value) => _submitCustomAmount(
                  ctx, context, ref, controller.text),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
          FilledButton(
            onPressed: () =>
                _submitCustomAmount(ctx, context, ref, controller.text),
            child: const Text('Add Water'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCustomAmount(
    BuildContext dialogCtx,
    BuildContext context,
    WidgetRef ref,
    String text,
  ) async {
    final ml = int.tryParse(text);
    if (ml == null || ml <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (ml > AppConstants.maxPerEntryMl) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Maximum ${AppConstants.maxPerEntryMl}ml per entry'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _addWaterWithCheck(context, ref, ml);
    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
  }

  String _motivationalMessage(double progress) {
    final messages = progress == 0
        ? ['Start your hydration journey', 'Ready to hydrate?', "Let's go!"]
        : progress < 0.25
            ? ['Great start!', 'Every drop counts', 'You got this']
            : progress < 0.5
                ? ['Keep it going!', 'Halfway to feeling great', 'Nice momentum']
                : progress < 0.75
                    ? ["More than halfway!", "You're on fire", 'Crushing it']
                    : progress < 1
                        ? ['Almost there!', 'Finish strong', 'So close!']
                        : ['Goal reached!', 'Fully hydrated', 'Nailed it!'];
    final daySeed = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    return messages[daySeed % messages.length];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final min = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $ampm';
  }
}

// ── Animated Goal Card ──
class _AnimatedGoalCard extends StatefulWidget {
  final int remaining;
  final ColorScheme cs;
  final ThemeData theme;

  const _AnimatedGoalCard({
    required this.remaining,
    required this.cs,
    required this.theme,
  });

  @override
  State<_AnimatedGoalCard> createState() => _AnimatedGoalCardState();
}

class _AnimatedGoalCardState extends State<_AnimatedGoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    final reducedMotion = MediaQuery.of(context).accessibleNavigation;
    _controller = AnimationController(
      vsync: this,
      duration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: RainStatCard(
        value: 'Goal',
        unit: 'reached',
        label: 'Great job staying hydrated!',
        color: widget.cs.tertiary,
        badge: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: widget.cs.tertiary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Icon(
            LucideIcons.partyPopper,
            size: 20,
            color: widget.cs.tertiary,
          ),
        ),
      ),
    );
  }
}

