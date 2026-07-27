import 'package:flutter/material.dart';

/// Compact outlined or filled pill for quick actions.
/// Default height 44px. Outlined style with 8px radius.
/// Includes a spring-scale animation on press for tactile feel.
class RainPillButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isOutlined;
  final double height;

  const RainPillButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isOutlined = true,
    this.height = 44,
  });

  @override
  State<RainPillButton> createState() => _RainPillButtonState();
}

class _RainPillButtonState extends State<RainPillButton> {
  bool _tapped = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bgColor = _pressed && !widget.isOutlined
        ? cs.primary.withValues(alpha: 0.85)
        : _pressed
            ? cs.primaryContainer.withValues(alpha: 0.4)
            : Colors.transparent;

    final borderColor = widget.isOutlined
        ? (_pressed ? cs.primary : cs.outline)
        : Colors.transparent;

    Widget button;
    if (widget.isOutlined) {
      button = SizedBox(
        height: widget.height,
        child: OutlinedButton(
          onPressed: widget.onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: borderColor, width: 1.5),
            backgroundColor: bgColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: cs.primary),
                const SizedBox(width: 4),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      button = SizedBox(
        height: widget.height,
        child: FilledButton(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: bgColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18),
                const SizedBox(width: 4),
              ],
              Text(widget.label,
                  style:
                      const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() {
        _tapped = true;
        _pressed = true;
      }),
      onTapUp: (_) => setState(() {
        _tapped = false;
        _pressed = false;
      }),
      onTapCancel: () => setState(() {
        _tapped = false;
        _pressed = false;
      }),
      child: AnimatedScale(
        scale: _tapped ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Semantics(
          button: true,
          enabled: true,
          label: widget.label,
          child: button,
        ),
      ),
    );
  }
}
