import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/telecom_provider.dart';

/// Provider selection: two compact side-by-side cards (Ethio telecom /
/// Safaricom) showing the active SIM status for each carrier.
class ProviderSelector extends StatelessWidget {
  const ProviderSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
    this.statusOf,
    this.activeOf,
  });

  final TelecomProvider selected;
  final ValueChanged<TelecomProvider> onSelected;
  final bool enabled;

  /// Optional compact status line (for example "SIM 1 · Active").
  final String Function(TelecomProvider provider)? statusOf;

  /// Whether the SIM shown in [statusOf] is active.
  final bool Function(TelecomProvider provider)? activeOf;

  @override
  Widget build(BuildContext context) {
    final values = TelecomProvider.values;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _ProviderCard(
              provider: values[i],
              status: statusOf?.call(values[i]),
              active: activeOf?.call(values[i]) ?? false,
              isSelected: values[i] == selected,
              enabled: enabled,
              onTap: () => onSelected(values[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.provider,
    required this.status,
    required this.active,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final TelecomProvider provider;
  final String? status;
  final bool active;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final light = theme.brightness == Brightness.light;
    final l10n = AppLocalizations.of(context);

    final accent = provider == TelecomProvider.ethioTelecom
        ? (light ? AppColors.primaryLight : AppColors.primaryDark)
        : (light ? AppColors.gameCoral : const Color(0xFFFF9A9A));
    final accentInk = light ? AppColors.gameInkLight : colorScheme.onSurface;
    final simActive = active;

    return Semantics(
      button: true,
      selected: isSelected,
      label:
          '${l10n.selectProvider(provider.selectorLabel)}'
          '${status == null ? '' : ', $status'}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isSelected
                  ? accent.withValues(alpha: light ? 0.2 : 0.22)
                  : colorScheme.surface,
              colorScheme.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? accent
                : (light
                      ? AppColors.gameInkLight.withValues(alpha: 0.14)
                      : colorScheme.outline),
            width: isSelected ? 2.4 : 1.4,
          ),
          boxShadow: isSelected ? AppShadows.of(context) : const [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Icon(provider.icon, size: 16, color: accent),
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: isSelected
                            ? Container(
                                key: const ValueKey('selected'),
                                width: 19,
                                height: 19,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: light
                                        ? AppColors.gameInkLight.withValues(
                                            alpha: 0.22,
                                          )
                                        : Colors.transparent,
                                    width: 1.2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.radio_button_unchecked_rounded,
                                key: const ValueKey('idle'),
                                size: 16,
                                color: colorScheme.outline,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.selectorLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? accentInk : colorScheme.onSurface,
                    ),
                  ),
                  if (status != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: simActive
                                  ? accent
                                  : colorScheme.onSurfaceVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              status!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: accentInk.withValues(alpha: 0.82),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
