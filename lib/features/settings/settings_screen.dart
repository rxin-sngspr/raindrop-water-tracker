import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/streak.dart';
import '../../data/models/achievement.dart';
import '../../data/repositories/water_repository.dart';
import '../achievements/achievements_screen.dart';
import '../../shared/widgets/rain_page_header.dart';
import '../../shared/widgets/rain_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final today = ref.watch(todayProvider);
    final currentTheme = ref.watch(themeModeProvider);
    final currentPreset = ref.watch(themePresetProvider);
    final userName = ref.watch(userNameProvider);
    final achievements = ref.watch(achievementsProvider);
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    final presetLabels = <String, String>{
      AppThemePresets.pink: 'Pink',
      AppThemePresets.purple: 'Purple',
      AppThemePresets.purpink: 'PurPink',
      AppThemePresets.serenity: 'Serenity',
    };

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
                      title: 'Settings',
                    ),
                    SizedBox(height: AppDimensions.sectionGap),

                    // ── Profile ──
                    RainCard(
                      child: FocusTraversalGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              icon: LucideIcons.user,
                              label: 'Profile',
                            ),
                            SizedBox(height: AppDimensions.insetGap),
                            _NameField(userName: userName),
                            SizedBox(height: AppDimensions.sp4),
                            _DailyGoalSlider(today: today),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.elementGap),

                    // ── Achievements ──
                    RainCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            icon: LucideIcons.trophy,
                            label: 'Achievements',
                          ),
                          SizedBox(height: AppDimensions.tightGap),
                          Text(
                            '$unlockedCount badges earned',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: AppDimensions.sp4),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  _slidePageRoute(
                                    const AchievementsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                LucideIcons.eye,
                                size: 18,
                              ),
                              label: const Text('View All'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusLg,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.elementGap),

                    // ── Theme Mode ──
                    RainCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            icon: LucideIcons.palette,
                            label: 'Appearance',
                          ),
                          SizedBox(height: AppDimensions.insetGap),
                          _ThemeOption(
                            icon: LucideIcons.sunMoon,
                            label: 'Follow system',
                            selected: currentTheme == ThemeMode.system,
                            onTap: () => ref
                                .read(themeModeProvider.notifier)
                                .setTheme(ThemeMode.system),
                          ),
                          Divider(
                            height: 1,
                            color: cs.outlineVariant.withValues(alpha: 0.3),
                          ),
                          _ThemeOption(
                            icon: LucideIcons.sun,
                            label: 'Light',
                            selected: currentTheme == ThemeMode.light,
                            onTap: () => ref
                                .read(themeModeProvider.notifier)
                                .setTheme(ThemeMode.light),
                          ),
                          Divider(
                            height: 1,
                            color: cs.outlineVariant.withValues(alpha: 0.3),
                          ),
                          _ThemeOption(
                            icon: LucideIcons.moon,
                            label: 'Dark',
                            selected: currentTheme == ThemeMode.dark,
                            onTap: () => ref
                                .read(themeModeProvider.notifier)
                                .setTheme(ThemeMode.dark),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.elementGap),

                    // ── Theme Preset ──
                    RainCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            icon: LucideIcons.palette,
                            label: 'Theme Colors',
                          ),
                          SizedBox(height: AppDimensions.insetGap),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<String>(
                              segments: AppThemePresets.all.map((preset) {
                                return ButtonSegment<String>(
                                  value: preset,
                                  label: Text(
                                    presetLabels[preset] ?? preset,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              selected: {currentPreset},
                              onSelectionChanged: (selected) {
                                ref
                                    .read(themePresetProvider.notifier)
                                    .setPreset(selected.first);
                              },
                              style: ButtonStyle(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.elementGap),

                    // ── Notifications ──
                    RainCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            icon: LucideIcons.bell,
                            label: 'Notifications',
                          ),
                          SizedBox(height: AppDimensions.tightGap),
                          Builder(builder: (context) {
                            final morning =
                                ref.watch(notifTimeProvider('morning'));
                            final evening =
                                ref.watch(notifTimeProvider('evening'));
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily reminders at ${DateFormat('h:mm a').format(morning)} and ${DateFormat('h:mm a').format(evening)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: AppDimensions.tightGap),
                                _NotificationTimePicker(
                                  label: 'Morning',
                                  current: morning,
                                  onChanged: (time) {
                                    ref
                                        .read(storageProvider)
                                        .setNotifTime(
                                          'morning_hour',
                                          'morning_minute',
                                          time.hour,
                                          time.minute,
                                        );
                                    ref.invalidate(
                                        notifTimeProvider('morning'));
                                  },
                                ),
                                SizedBox(height: AppDimensions.tightGap),
                                _NotificationTimePicker(
                                  label: 'Evening',
                                  current: evening,
                                  onChanged: (time) {
                                    ref
                                        .read(storageProvider)
                                        .setNotifTime(
                                          'evening_hour',
                                          'evening_minute',
                                          time.hour,
                                          time.minute,
                                        );
                                    ref.invalidate(
                                        notifTimeProvider('evening'));
                                  },
                                ),
                              ],
                            );
                          }),
                          SizedBox(height: AppDimensions.tightGap),
                          Text(
                            'Reminders stop once you hit your daily goal.',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: AppDimensions.sp4),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ref
                                    .read(notificationServiceProvider)
                                    .sendTestNotification();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Test notification sent!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(
                                LucideIcons.bellRing,
                                size: 18,
                              ),
                              label: const Text('Send Test Notification'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusLg,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.elementGap),

                    // ── Data ──
                    RainCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            icon: LucideIcons.database,
                            label: 'Data',
                          ),
                          SizedBox(height: AppDimensions.sp4),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _confirmReset(context, ref),
                              icon: const Icon(LucideIcons.delete,
                                  size: 18),
                              label: const Text('Reset All Data'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: cs.error,
                                side: BorderSide(
                                  color: cs.error.withValues(alpha: 0.5),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusLg,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.sp6),

                    // Data integrity indicator
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'All data stored locally on device',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.sp3),

                    // App info
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.droplet,
                              color: cs.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rain Drop v3.0.0',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.sp8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will delete all your water intake history. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final storage = ref.read(storageProvider);
                await storage.clearAll();
                ref.read(todayProvider.notifier).refresh();
                await ref
                    .read(streakProvider.notifier)
                    .saveStreak(const Streak());
                await ref
                    .read(achievementsProvider.notifier)
                    .saveAchievements(List.from(Achievement.all));
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to reset: $e'),
                      backgroundColor: cs.errorContainer,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

PageRoute _slidePageRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

// --- Section Header ---
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Icon(icon, color: cs.primary, size: 16),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// --- Name Field ---
class _NameField extends ConsumerStatefulWidget {
  final String userName;

  const _NameField({required this.userName});

  @override
  ConsumerState<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends ConsumerState<_NameField> {
  late TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.userName);
  }

  @override
  void didUpdateWidget(_NameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userName != oldWidget.userName &&
        widget.userName != _controller.text) {
      _controller.text = widget.userName;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      ref.read(userNameProvider.notifier).setName(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      maxLength: AppConstants.maxNameLength,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
      ],
      decoration: InputDecoration(
        labelText: 'Your Name',
        hintText: 'Enter your name',
        counterText: '',
        prefixIcon: const Icon(LucideIcons.user),
      ),
      onFieldSubmitted: (_) {
        _save();
        _focusNode.unfocus();
      },
      onTapOutside: (_) {
        _save();
        _focusNode.unfocus();
      },
    );
  }
}

// --- Daily Goal Slider ---
class _DailyGoalSlider extends ConsumerWidget {
  final TodayState today;

  const _DailyGoalSlider({required this.today});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.flag,
                size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text('Daily Goal',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Set your daily hydration target',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '${AppConstants.minDailyGoalMl}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: Slider(
                value: today.goal.toDouble(),
                min: AppConstants.minDailyGoalMl.toDouble(),
                max: AppConstants.maxDailyGoalMl.toDouble(),
                divisions: 9,
                label: '${today.goal} ml',
                onChanged: (value) {
                  ref
                      .read(todayProvider.notifier)
                      .setGoal(value.toInt());
                },
              ),
            ),
            Text(
              '${AppConstants.maxDailyGoalMl}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusLg,
              ),
            ),
            child: Text(
              '${today.goal} ml',
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Theme Option ---
class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: selected
                    ? cs.primary
                    : cs.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? cs.onSurface
                    : cs.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (selected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.check,
                    color: cs.primary, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Notification Time Picker ---
class _NotificationTimePicker extends StatelessWidget {
  final String label;
  final DateTime current;
  final ValueChanged<DateTime> onChanged;

  const _NotificationTimePicker({
    required this.label,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(current),
        );
        if (picked != null) {
          final newTime = DateTime(
            current.year,
            current.month,
            current.day,
            picked.hour,
            picked.minute,
          );
          onChanged(newTime);
        }
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.clock, size: 18, color: cs.primary),
            const SizedBox(width: 10),
            Text(
              '$label reminder',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              DateFormat('h:mm a').format(current),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            Icon(LucideIcons.chevronRight,
                size: 20, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
