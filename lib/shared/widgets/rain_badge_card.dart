import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Achievement badge card for the grid view.
///
/// Unlocked: full opacity, primary glow border, pulsing trophy indicator,
/// tiered progress bar (tertiary when complete, primary otherwise).
/// Locked: muted (40% opacity), centered lock icon overlay.
class RainBadgeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final double progress;
  final bool unlocked;
  final String progressLabel;

  const RainBadgeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    required this.unlocked,
    required this.progressLabel,
  });

  @override
  State<RainBadgeCard> createState() => _RainBadgeCardState();
}

class _RainBadgeCardState extends State<RainBadgeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    final reduced = MediaQuery.of(context).accessibleNavigation;
    _pulseController = AnimationController(
      vsync: this,
      duration: reduced ? Duration.zero : const Duration(milliseconds: 800),
    );
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.unlocked && !reduced) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(RainBadgeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final reduced = MediaQuery.of(context).accessibleNavigation;
    if (widget.unlocked && !oldWidget.unlocked && !reduced) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.unlocked && oldWidget.unlocked) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final opacity = widget.unlocked ? 1.0 : 0.4;
    final progressColor = widget.progress >= 1.0 ? cs.tertiary : cs.primary;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.unlocked
            ? cs.surface
            : cs.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.unlocked
              ? cs.primary.withValues(alpha: 0.3)
              : cs.outlineVariant.withValues(alpha: 0.3),
          width: widget.unlocked ? 1.5 : 1,
        ),
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Opacity(
              opacity: opacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.unlocked
                          ? cs.primaryContainer
                          : cs.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.unlocked
                          ? cs.primary
                          : cs.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    widget.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.unlocked
                          ? cs.onSurface
                          : cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Description
                  Text(
                    widget.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: widget.progress.clamp(0.0, 1.0),
                      backgroundColor:
                          cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      color: widget.unlocked
                          ? progressColor
                          : cs.onSurfaceVariant.withValues(alpha: 0.3),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Progress label
                  Text(
                    widget.progressLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: widget.unlocked
                          ? cs.onSurfaceVariant
                          : cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Unlocked: pulsing trophy indicator ──
          if (widget.unlocked)
            Positioned(
              top: 4,
              right: 4,
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, _) {
                  return Transform.scale(
                    scale: _pulseAnim.value,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: cs.tertiary.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.trophy,
                        size: 14,
                        color: cs.onTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),

          // ── Locked: lock icon overlay ──
          if (!widget.unlocked)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.lock,
                  size: 14,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
