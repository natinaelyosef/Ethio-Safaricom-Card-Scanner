import 'package:flutter/material.dart';

import '../core/app_info.dart';
import '../core/theme/app_theme.dart';

/// Shared page header: branded icon on the left, the app title, a short
/// page subtitle, and an optional slot for page-specific controls.
class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({
    super.key,
    required this.subtitle,
    this.child,
    this.trailing,
  });

  final String subtitle;
  final Widget? child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final light = theme.brightness == Brightness.light;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppBrandIcon(size: 52),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                            letterSpacing: -0.1,
                            color: light
                                ? AppColors.gameInkLight
                                : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: light
                                  ? AppColors.gameInkLight.withValues(
                                      alpha: 0.14,
                                    )
                                  : colorScheme.outline,
                              width: 1.1,
                            ),
                          ),
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
              if (child != null) ...[const SizedBox(height: 10), child!],
            ],
          ),
        ),
      ],
    );
  }
}

/// Branded launcher icon with a graceful fallback for missing assets.
class AppBrandIcon extends StatelessWidget {
  const AppBrandIcon({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final borderColor = light
        ? AppColors.gameInkLight.withValues(alpha: 0.28)
        : AppColors.borderDark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.3),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: AppShadows.of(context),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.3 - 2),
              child: Image.asset(
                'assets/branding/app_icon.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: light
                      ? AppColors.primaryDarkGreen
                      : AppColors.primaryDark,
                  child: Icon(
                    Icons.smartphone_rounded,
                    color: Colors.white,
                    size: size * 0.55,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: BoxDecoration(
                color: AppColors.gameYellow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: light ? AppColors.gameInkLight : AppColors.borderDark,
                  width: 1.6,
                ),
              ),
              child: Icon(
                Icons.bolt_rounded,
                size: size * 0.23,
                color: AppColors.gameInkLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
