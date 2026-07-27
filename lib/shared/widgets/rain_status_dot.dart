import 'package:flutter/material.dart';

/// Colored dot with label for status indicators and legends.
class RainStatusDot extends StatelessWidget {
  final Color color;
  final String label;
  final double dotSize;

  const RainStatusDot({
    super.key,
    required this.color,
    required this.label,
    this.dotSize = 8,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
