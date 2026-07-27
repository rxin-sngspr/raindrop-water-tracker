import 'package:flutter/material.dart';

/// Animated shimmer placeholder for loading states.
/// Draws a subtle gradient sweep across the given shape.
/// Falls back to a static container when reduced motion is enabled.
class RainShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const RainShimmer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  State<RainShimmer> createState() => _RainShimmerState();
}

class _RainShimmerState extends State<RainShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final reducedMotion = MediaQuery.of(context).accessibleNavigation;
    _controller = AnimationController(
      vsync: this,
      duration: reducedMotion ? Duration.zero : const Duration(milliseconds: 1500),
    );
    if (!reducedMotion) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reducedMotion = MediaQuery.of(context).accessibleNavigation;
    final baseColor = cs.surfaceContainerHighest;
    final highlightColor =
        Color.lerp(cs.surfaceContainerHighest, cs.surface, 0.4)!;

    // Static fallback when reduced motion is preferred
    if (reducedMotion) {
      return Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end: Alignment(1.0 + _controller.value * 2, 0),
            ),
          ),
        );
      },
    );
  }
}
