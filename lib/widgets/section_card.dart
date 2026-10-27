import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Rounded, bordered white card used for every content section, with a
/// soft shadow that keeps the surface floating above the background.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.description,
    this.icon,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final String? title;
  final String? description;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final light = theme.brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color: light
              ? AppColors.gameInkLight.withValues(alpha: 0.14)
              : colorScheme.outline,
          width: 1.6,
        ),
        boxShadow: AppShadows.of(context),
      ),
      padding: padding,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: light
                            ? AppColors.gameYellow.withValues(alpha: 0.72)
                            : colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: light
                              ? AppColors.gameInkLight.withValues(alpha: 0.18)
                              : colorScheme.outline,
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: light
                            ? AppColors.gameInkLight
                            : colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 3),
                          Text(description!, style: theme.textTheme.labelSmall),
                        ],
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
