import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A large circular water progress indicator (160px).
///
/// Shows a ring that fills as water is consumed, with a water drop icon
/// and ml count in the center. Tappable to add a default amount of water.
/// The arc and icon use `cs.secondary` (or `cs.tertiary` when goal reached)
/// so each theme preset produces a visually distinct look.
class RainWaterCircle extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int currentMl;
  final int goalMl;
  final VoidCallback onTap;
  final bool isGoalReached;

  const RainWaterCircle({
    super.key,
    required this.progress,
    required this.currentMl,
    required this.goalMl,
    required this.onTap,
    this.isGoalReached = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final reducedMotion = MediaQuery.of(context).accessibleNavigation;
    final clamped = progress.clamp(0.0, 1.0);
    const size = 160.0;
    final arcColor = isGoalReached ? cs.tertiary : cs.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label:
            'Add 250ml water. Progress $currentMl of $goalMl milliliters',
        child: AnimatedContainer(
          duration: reducedMotion
              ? Duration.zero
              : const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.surface,
            border: Border.all(
              color: isGoalReached ? cs.tertiary : cs.outlineVariant,
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              SizedBox(
                width: size - 16,
                height: size - 16,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  backgroundColor: cs.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(
                      cs.surfaceContainerHighest.withValues(alpha: 0.3)),
                ),
              ),
              // Animated progress arc
              TweenAnimationBuilder<double>(
                tween: Tween(
                    begin: reducedMotion ? clamped : 0, end: clamped),
                duration: reducedMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return SizedBox(
                    width: size - 16,
                    height: size - 16,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(arcColor),
                      strokeCap: StrokeCap.round,
                    ),
                  );
                },
              ),
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isGoalReached ? LucideIcons.trophy : LucideIcons.droplet,
                    size: 36,
                    color: arcColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currentMl',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    'of $goalMl ml',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              // Goal-reached badge
              if (isGoalReached)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cs.tertiaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(LucideIcons.check, size: 14, color: cs.tertiary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
