import 'package:flutter/material.dart';

/// Rounded linear progress bar with animation.
class RainProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? color;
  final bool animate;
  final String? label;

  const RainProgressBar({
    super.key,
    required this.progress,
    this.height = 12,
    this.color,
    this.animate = true,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fillColor = color ?? cs.primary;
    final clamped = progress.clamp(0.0, 1.0);
    final reducedMotion = MediaQuery.of(context).accessibleNavigation;

    return Semantics(
      label: 'Progress, ${(clamped * 100).toInt()} percent',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: reducedMotion ? clamped : 0, end: clamped),
              duration: animate && !reducedMotion
                  ? const Duration(milliseconds: 600)
                  : Duration.zero,
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Stack(
                  children: [
                    Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(label!, style: Theme.of(context).textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}
