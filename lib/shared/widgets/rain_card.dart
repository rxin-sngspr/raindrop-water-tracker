import 'package:flutter/material.dart';

/// Flat card with 1px border, 12px radius, surface background.
/// No elevation, no gradients, no border-top accent.
class RainCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? borderColor;

  const RainCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: Border.all(
          color: borderColor ?? cs.outlineVariant.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
