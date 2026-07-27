import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Streak card using the Serenity color palette.
/// Background: primaryContainer tint, flame: secondary (pink), button: primary text.
class RainStreakCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final VoidCallback? onViewBadges;

  const RainStreakCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.onViewBadges,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = cs.brightness == Brightness.light;

    final bgColor = isLight
        ? cs.primaryContainer.withValues(alpha: 0.5)
        : cs.surfaceContainerLow;
    final borderColor = cs.primary.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.flame, color: cs.secondary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentStreak-day streak!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  'Best: $longestStreak days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onViewBadges != null)
            TextButton(
              onPressed: onViewBadges,
              child: Text(
                'View Badges',
                style: TextStyle(color: cs.primary),
              ),
            ),
        ],
      ),
    );
  }
}
