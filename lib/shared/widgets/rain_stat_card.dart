import 'package:flutter/material.dart';

/// Shows a primary metric with unit, label, and optional percentage badge.
/// No gradient. No border-top.
class RainStatCard extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final Widget? badge;
  final Color? color;

  const RainStatCard({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    this.badge,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: -0.5,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      unit,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null) badge!,
        ],
      ),
    );
  }
}

/// Percentage badge chip for use inside RainStatCard.
class RainPercentageBadge extends StatelessWidget {
  final int percent;
  final Color? color;

  const RainPercentageBadge({
    super.key,
    required this.percent,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final badgeColor = color ?? cs.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$percent%',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
      ),
    );
  }
}
