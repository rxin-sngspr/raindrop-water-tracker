import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Minimal log entry row with amount, time, and undo action.
class RainLogTile extends StatelessWidget {
  final int amountMl;
  final String formattedTime;
  final bool showUndo;
  final VoidCallback onUndo;
  final Animation<double>? fadeAnimation;

  const RainLogTile({
    super.key,
    required this.amountMl,
    required this.formattedTime,
    this.showUndo = true,
    required this.onUndo,
    this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Semantics(
            label: 'Water',
            child: Icon(LucideIcons.droplet, size: 16,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: '$amountMl milliliters',
            child: Text(
              '$amountMl ml',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Text(
            formattedTime,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          if (showUndo) ...[
            const SizedBox(width: 4),
            Semantics(
              button: true,
              label: 'Undo last entry',
              child: IconButton(
                icon: Icon(LucideIcons.undo, size: 18, color: cs.error),
                onPressed: onUndo,
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                tooltip: 'Undo',
              ),
            ),
          ],
        ],
      ),
    );

    if (fadeAnimation != null) {
      tile = FadeTransition(opacity: fadeAnimation!, child: tile);
    }

    return Column(
      children: [
        tile,
        Divider(
          height: 1,
          thickness: 1,
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}
