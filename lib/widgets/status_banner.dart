import 'package:flutter/material.dart';

import '../state/home_controller.dart';

/// Inline status banner: info / success / warning / error.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.status,
    required this.onDismiss,
  });

  final HomeStatus status;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;

    final (color, lightText, darkText, icon) = switch (status.kind) {
      StatusKind.info => (
        const Color(0xFFE3F0EA),
        const Color(0xFF22503A),
        const Color(0xFFA7D3B9),
        Icons.info_rounded,
      ),
      StatusKind.success => (
        const Color(0xFFE8F7EE),
        const Color(0xFF006B3C),
        const Color(0xFF7BE3AE),
        Icons.check_circle_rounded,
      ),
      StatusKind.warning => (
        const Color(0xFFFFF6E5),
        const Color(0xFF7A5A00),
        const Color(0xFFFFD68A),
        Icons.warning_amber_rounded,
      ),
      StatusKind.error => (
        const Color(0xFFFDECEB),
        const Color(0xFFB3261E),
        const Color(0xFFFFB4AB),
        Icons.error_rounded,
      ),
    };

    final textColor = light ? lightText : darkText;
    final bannerColor = light ? color : color.withValues(alpha: 0.16);

    return Dismissible(
      key: ValueKey(status.message),
      direction: DismissDirection.vertical,
      onDismissed: (_) => onDismiss(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        decoration: BoxDecoration(
          color: bannerColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: light
                ? textColor.withValues(alpha: 0.18)
                : theme.colorScheme.outline.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 19, color: textColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                status.message,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close_rounded, size: 18),
              color: textColor,
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
