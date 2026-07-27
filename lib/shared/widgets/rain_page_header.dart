import 'package:flutter/material.dart';

/// Consistent screen title with optional leading icon, subtitle, and trailing action.
class RainPageHeader extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const RainPageHeader({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: title,
                    child: Text(title, style: theme.textTheme.headlineLarge),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Semantics(
                      label: subtitle,
                      child: Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Semantics(
                label: 'Open settings',
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}
