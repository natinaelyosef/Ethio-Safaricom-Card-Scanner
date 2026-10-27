import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_info.dart';
import '../l10n/app_localizations.dart';
import '../models/telecom_provider.dart';
import '../services/settings_service.dart';
import '../services/ussd_service.dart';
import '../state/app_controller.dart';
import '../widgets/app_brand_header.dart';
import '../widgets/section_card.dart';

/// Settings: theme, default provider, history toggle, USSD reader, tips,
/// privacy, about — grouped into cards on a single scrollable page.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.appController,
    required this.ussdService,
  });

  final AppController appController;
  final UssdService ussdService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  AppController get _app => widget.appController;

  bool _readerEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshReader();
    if (Platform.isAndroid) {
      // Load the SIM list once per session (async, updates via notifier).
      _app.refreshSims();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshReader();
    }
  }

  Future<void> _refreshReader() async {
    final enabled = await widget.ussdService.isUssdReaderEnabled();
    if (mounted && enabled != _readerEnabled) {
      setState(() => _readerEnabled = enabled);
    }
  }

  Future<void> _openReaderSettings() async {
    await widget.ussdService.openUssdReaderSettings();
    await _refreshReader();
  }

  Future<void> _openDeveloperPortfolio() async {
    final uri = Uri.tryParse(appDeveloperUrl);
    if (uri == null) return;
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).couldNotOpenPortfolio),
        ),
      );
    }
  }

  /// Returns [subId] when it still matches an installed SIM, otherwise
  /// -1 (device default) so a removed SIM never sticks in the dropdown.
  int _validSubId(TelecomProvider provider, int subId) {
    if (subId <= 0) return -1;
    return _app.sims.any((sim) => sim.subId == subId) ? subId : -1;
  }

  Future<void> _confirmClearHistory() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearHistoryTitle),
        content: Text(l10n.clearHistoryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _app.clearHistory();
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(l10n.scanHistoryCleared)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final history = _app.history;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width >= 620
                  ? 560
                  : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              child: ListenableBuilder(
                listenable: _app,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppBrandHeader(subtitle: l10n.settingsTitle),
                    const SizedBox(height: 16),
                    // ---------------- Language ----------------
                    SectionCard(
                      icon: Icons.language_rounded,
                      title: l10n.languageTitle,
                      description: l10n.languageDescription,
                      child: SegmentedButton<String>(
                        showSelectedIcon: true,
                        selected: {_app.languageCode},
                        onSelectionChanged: (selection) =>
                            _app.setLanguageCode(selection.first),
                        style: SegmentedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          iconSize: 17,
                          visualDensity: VisualDensity.compact,
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        segments: [
                          ButtonSegment(
                            value: 'en',
                            label: Text(l10n.english),
                            icon: const Icon(Icons.translate_rounded),
                          ),
                          ButtonSegment(
                            value: 'am',
                            label: Text(l10n.amharic),
                            icon: const Icon(Icons.abc_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // ---------------- Appearance ----------------
                    SectionCard(
                      icon: Icons.dark_mode_rounded,
                      title: l10n.appearanceTitle,
                      description: l10n.appearanceDescription,
                      child: SegmentedButton<AppThemeMode>(
                        showSelectedIcon: true,
                        selected: {_app.themeMode},
                        onSelectionChanged: (selection) =>
                            _app.setThemeMode(selection.first),
                        style: SegmentedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          iconSize: 17,
                          visualDensity: VisualDensity.compact,
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        segments: [
                          ButtonSegment(
                            value: AppThemeMode.system,
                            label: Text(l10n.themeSystem),
                            icon: const Icon(Icons.brightness_auto_rounded),
                          ),
                          ButtonSegment(
                            value: AppThemeMode.light,
                            label: Text(l10n.themeLight),
                            icon: const Icon(Icons.light_mode_rounded),
                          ),
                          ButtonSegment(
                            value: AppThemeMode.dark,
                            label: Text(l10n.themeDark),
                            icon: const Icon(Icons.dark_mode_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ---------------- Default provider ----------------
                    SectionCard(
                      icon: Icons.swap_horiz_rounded,
                      title: l10n.defaultProviderTitle,
                      description: l10n.defaultProviderDescription,
                      child: RadioGroup<TelecomProvider>(
                        groupValue: _app.defaultProvider,
                        onChanged: (value) => _app.setDefaultProvider(value!),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final provider in TelecomProvider.values) ...[
                              RadioListTile<TelecomProvider>(
                                value: provider,
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                secondary: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    provider.icon,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                title: Text(provider.label),
                                subtitle: Text(
                                  l10n.providerRechargeBalance(
                                    provider.rechargeUssdExample,
                                    provider.balanceUssdCode,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                              if (provider != TelecomProvider.values.last)
                                Divider(color: colorScheme.outline),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ---------------- Dual-SIM (Android only) ----------------
                    if (Platform.isAndroid) ...[
                      SectionCard(
                        icon: Icons.sim_card_rounded,
                        title: l10n.simTitle,
                        description: l10n.simDescription,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.simExplanation,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_app.simsLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            else if (_app.sims.length <= 1 &&
                                _app.simsError == null)
                              Text(
                                _app.sims.isEmpty
                                    ? l10n.noSimDetected
                                    : l10n.oneSimDetected,
                                style: theme.textTheme.bodyMedium,
                              )
                            else ...[
                              for (final provider in TelecomProvider.values)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          provider.label,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      DropdownButton<int>(
                                        value: _validSubId(
                                          provider,
                                          _app.simSubIdFor(provider),
                                        ),
                                        isDense: true,
                                        items: [
                                          DropdownMenuItem(
                                            value: -1,
                                            child: Text(l10n.defaultValue),
                                          ),
                                          for (final sim in _app.sims)
                                            DropdownMenuItem(
                                              value: sim.subId,
                                              child: Text(
                                                l10n.simName(
                                                  sim.slot + 1,
                                                  sim.displayName,
                                                ),
                                              ),
                                            ),
                                        ],
                                        onChanged: (subId) => _app.setSimSubId(
                                          provider,
                                          subId ?? -1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              TextButton.icon(
                                onPressed: () => _app.refreshSims(force: true),
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                ),
                                label: Text(l10n.refreshSimList),
                              ),
                            ],
                            if (_app.simsError != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _app.simsError!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ---------------- Local history ----------------
                    SectionCard(
                      icon: Icons.history_rounded,
                      title: l10n.historyTitle,
                      description: l10n.historyDescription,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(l10n.saveRecentScans),
                            subtitle: Text(l10n.saveRecentScansSubtitle),
                            value: _app.historyEnabled,
                            onChanged: (value) => _app.setHistoryEnabled(value),
                            activeThumbColor: colorScheme.primary,
                          ),
                          if (history.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                              ),
                              onPressed: _confirmClearHistory,
                              icon: const Icon(Icons.delete_forever_rounded),
                              label: Text(
                                l10n.clearHistoryCount(history.length),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ---------------- Carrier USSD reader ----------------
                    if (Platform.isAndroid) ...[
                      SectionCard(
                        icon: Icons.record_voice_over_rounded,
                        title: l10n.ussdReaderTitle,
                        description: l10n.ussdReaderDescription,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _readerEnabled
                                      ? Icons.check_circle_rounded
                                      : Icons.warning_amber_rounded,
                                  size: 18,
                                  color: _readerEnabled
                                      ? colorScheme.primary
                                      : colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _readerEnabled
                                        ? l10n.ussdReaderEnabled
                                        : l10n.ussdReaderDisabled,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.ussdReaderExplanation,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.tonalIcon(
                              onPressed: _openReaderSettings,
                              icon: const Icon(Icons.accessibility_new_rounded),
                              label: Text(
                                _readerEnabled
                                    ? l10n.reviewAccessibilitySetting
                                    : l10n.enableInAccessibilitySettings,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextButton.icon(
                              onPressed: _refreshReader,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: Text(l10n.refreshStatus),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ---------------- Scanning tips ----------------
                    SectionCard(
                      icon: Icons.tips_and_updates_rounded,
                      title: l10n.scanningHelpTitle,
                      description: l10n.scanningHelpDescription,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final tip in [
                            l10n.scanningTip1,
                            l10n.scanningTip2,
                            l10n.scanningTip3,
                            l10n.scanningTip4,
                            l10n.scanningTip5,
                            l10n.scanningTip6,
                          ])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(tip)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ---------------- Privacy ----------------
                    SectionCard(
                      icon: Icons.privacy_tip_rounded,
                      title: l10n.privacyTitle,
                      description: l10n.privacyDescription,
                      child: Text(
                        l10n.privacyBody,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ---------------- About ----------------
                    SectionCard(
                      icon: Icons.info_rounded,
                      title: l10n.aboutTitle(appName),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$appName · ${l10n.appSubtitle}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.versionLine(appVersion, appBuildInfo),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.aboutBody(appName),
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outline,
                                width: 1.3,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        borderRadius: BorderRadius.circular(13),
                                        border: Border.all(
                                          color: colorScheme.outline,
                                          width: 1.3,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 22,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.developerLabel,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.9,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            appDeveloper,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Semantics(
                                  link: true,
                                  label: l10n.openDeveloperPortfolio(
                                    appDeveloper,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _openDeveloperPortfolio,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surface,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.outline,
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.link_rounded,
                                              size: 17,
                                              color: colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                appDeveloperUrl,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme.primary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      decorationColor:
                                                          colorScheme.primary,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Icon(
                                              Icons.open_in_new_rounded,
                                              size: 15,
                                              color: colorScheme.primary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: 14,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      l10n.offlineBadge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color:
                                                colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
