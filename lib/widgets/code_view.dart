import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/code_parser.dart';
import '../logic/ussd_builder.dart';
import '../l10n/app_localizations.dart';
import '../models/telecom_provider.dart';
import '../state/home_controller.dart';
import 'section_card.dart';

/// Large formatted preview of the current code.
class BigCodePreview extends StatelessWidget {
  const BigCodePreview({super.key, required this.digits, this.height = 58});

  final String digits;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final clean = UssdBuilder.sanitizeDigits(digits);
    final formatted = clean.isEmpty ? '—' : formatCode(clean);
    // Long codes shrink a little so they stay on one line on narrow
    // screens instead of ellipsizing away digits.
    final fontSize = switch (clean.length) {
      > 18 => 17.0,
      > 14 => 20.0,
      _ => 23.0,
    };
    final spacing = clean.length > 14 ? 2.0 : 3.0;
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Text(
        formatted,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: spacing,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Review stage: captured photo, editable code + formatted preview +
/// retake/pick/confirm actions.
class CodeReviewPanel extends StatelessWidget {
  const CodeReviewPanel({
    super.key,
    required this.controller,
    required this.onConfirm,
    required this.onRescan,
    required this.onGallery,
    required this.onCancel,
  });

  final HomeController controller;
  final VoidCallback onConfirm;
  final VoidCallback onRescan;
  final VoidCallback onGallery;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.codeField,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final clean = UssdBuilder.sanitizeDigits(controller.codeField.text);
        final hint = controller.provider.voucherLengthHint;
        final inWindow = clean.length >= hint.min && clean.length <= hint.max;
        final photo = controller.capturedPhotoPath;
        final l10n = AppLocalizations.of(context);

        return SectionCard(
          title: l10n.checkRecognizedPin,
          icon: Icons.edit_note_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (photo != null) ...[
                _PhotoPreview(path: photo),
                const SizedBox(height: 10),
                Text(
                  l10n.capturedPhotoNote,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              BigCodePreview(digits: clean),
              const SizedBox(height: 12),
              TextField(
                controller: controller.codeField,
                maxLength: 24,
                autofillHints: const [],
                keyboardType: TextInputType.number,
                inputFormatters: [DigitsOnlyFormatter()],
                decoration: InputDecoration(
                  counterText: l10n.digitCount(clean.length),
                  prefixIcon: Icon(
                    inWindow ? Icons.tag_rounded : Icons.warning_amber_rounded,
                    color: inWindow
                        ? colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  filled: true,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.compareDigitsHelp,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: controller.busy ? null : onConfirm,
                icon: const Icon(Icons.flash_on_rounded),
                label: Text(l10n.confirmAndRecharge),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.busy ? null : onRescan,
                      icon: const Icon(Icons.photo_camera_rounded),
                      label: Text(l10n.retake),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.busy ? null : onGallery,
                      icon: const Icon(Icons.photo_library_rounded),
                      label: Text(l10n.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Center(
                child: TextButton.icon(
                  onPressed: controller.busy ? null : onCancel,
                  icon: const Icon(Icons.block_rounded, size: 18),
                  label: Text(l10n.discard),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// In-app preview of the captured card photo.
class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 160,
        width: double.infinity,
        color: colorScheme.surfaceContainerHighest,
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).photoPreviewUnavailable,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ready stage: confirmed code + recharge / balance actions.
class CodeConfirmedPanel extends StatelessWidget {
  const CodeConfirmedPanel({
    super.key,
    required this.controller,
    required this.ussdString,
    required this.onRecharge,
    required this.onCheckBalance,
    required this.onEdit,
    required this.onDiscard,
    required this.onCopy,
  });

  final HomeController controller;
  final String ussdString;
  final VoidCallback onRecharge;
  final VoidCallback onCheckBalance;
  final VoidCallback onEdit;
  final VoidCallback onDiscard;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return SectionCard(
      title: l10n.readyToRecharge,
      icon: Icons.verified_rounded,
      trailing: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              controller.provider.icon,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              controller.provider.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BigCodePreview(digits: controller.codeField.text),
          const SizedBox(height: 12),
          Text(
            l10n.ussdThatWillDial,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onCopy,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      ussdString,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const Icon(Icons.copy_rounded, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: controller.dialInFlight ? null : onRecharge,
            icon: controller.dialInFlight
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.flash_on_rounded),
            label: Text(
              controller.dialInFlight
                  ? l10n.openingUssd
                  : l10n.rechargeProvider(controller.provider.label),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.busy ? null : onCheckBalance,
                  icon: const Icon(Icons.account_balance_wallet_rounded),
                  label: Text(l10n.balance),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.busy ? null : onEdit,
                  icon: const Icon(Icons.edit_rounded),
                  label: Text(l10n.editCode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: controller.busy ? null : onDiscard,
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(l10n.scanNextCard),
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps only digits while typing.
class DigitsOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final stripped = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (stripped == newValue.text) return newValue;
    final delta = newValue.text.length - stripped.length;
    return TextEditingValue(
      text: stripped,
      selection: TextSelection.collapsed(
        offset: (newValue.selection.baseOffset - delta).clamp(
          0,
          stripped.length,
        ),
      ),
    );
  }
}
