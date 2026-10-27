import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_info.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../logic/ussd_builder.dart';
import '../logic/ussd_reply.dart';
import '../models/telecom_provider.dart';
import '../services/history_service.dart';
import '../services/ocr_service.dart';
import '../services/ussd_service.dart';
import '../state/app_controller.dart';
import '../state/home_controller.dart';
import '../widgets/app_brand_header.dart';
import '../widgets/code_view.dart';
import '../widgets/provider_selector.dart';
import '../widgets/scan_camera_panel.dart';
import '../widgets/scan_guide_box.dart';
import '../widgets/section_card.dart';
import '../widgets/status_banner.dart';

/// Home: provider selection → scan → confirm → recharge/balance, all as
/// stages inside this single screen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.appController,
    required this.ocrService,
    required this.ussdService,
  });

  final AppController appController;
  final OcrService ocrService;
  final UssdService ussdService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final HomeController _controller = HomeController(
    widget.appController.defaultProvider,
    widget.ocrService,
    widget.ussdService,
    widget.appController.historyService,
    resolveSubscriptionId: widget.appController.resolveSubscriptionId,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid) {
      // Load the SIM list once per session for the Home SIM selector.
      widget.appController.refreshSims();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.onAppLifecycle(state);
  }

  // ------------------------------------------------------------------
  // Actions
  // ------------------------------------------------------------------

  Future<void> _openManualUssdSheet(String ussd, String hint) {
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.dialCodeYourself,
                  style: Theme.of(sheetContext).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(hint, style: Theme.of(sheetContext).textTheme.bodyMedium),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _copy(ussd, sheetContext),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(sheetContext).colorScheme.primaryContainer
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(sheetContext).colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            ussd,
                            textAlign: TextAlign.center,
                            style: Theme.of(sheetContext).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                        ),
                        const Icon(Icons.copy_rounded),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.dialSteps,
                  style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                    color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copy(String text, [BuildContext? ctx]) {
    final messenger = ScaffoldMessenger.maybeOf(ctx ?? context);
    final l10n = AppLocalizations.of(context);
    unawaited(
      Clipboard.setData(ClipboardData(text: text)).then((_) {
        messenger?.showSnackBar(
          SnackBar(content: Text(l10n.copiedToClipboard)),
        );
      }),
    );
  }

  /// Shows the network's own USSD reply inside the app.
  Future<void> _showCarrierResponse(
    String response,
    String title,
    String contextLine,
  ) {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.cell_tower_rounded,
                  size: 18,
                  color: Theme.of(dialogContext).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contextLine,
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext).colorScheme.primaryContainer
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(dialogContext).colorScheme.outline,
                  ),
                ),
                child: SelectableText(
                  response,
                  style: Theme.of(dialogContext).textTheme.titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _copy(response, dialogContext),
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(l10n.copy),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.done),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRechargeDialog() async {
    final l10n = AppLocalizations.of(context);
    final provider = _controller.provider;
    final digits = _controller.codeField.text;
    final ussd = UssdBuilder.recharge(provider, digits);

    final goOn = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.confirmRecharge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.providerDigits(provider.label, digits.length),
                style: Theme.of(dialogContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext).colorScheme.primaryContainer
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(dialogContext).colorScheme.outline,
                  ),
                ),
                child: Text(
                  ussd,
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.confirmRechargeBody,
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
              if (_controller.isRecentDuplicate) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(dialogContext).colorScheme.errorContainer
                        .withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: Theme.of(dialogContext).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.duplicateWarning,
                          style: Theme.of(dialogContext).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(dialogContext)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (Platform.isAndroid) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.dualSimNote,
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.runUssd),
            ),
          ],
        );
      },
    );

    if (goOn != true) return;
    await _runRecharge(ussd);
  }

  /// The single confirmation in review ("Confirm and Continue") approves
  /// the PIN; on Android the recharge then runs automatically without
  /// another dialog, as requested. The Ready panel stays available for a
  /// retry. On iOS the copy-and-dial sheet remains user-initiated (Apple
  /// cannot run USSD from an app anyway).
  Future<void> _confirmAndRecharge() async {
    final confirmed = await _controller.confirmCode();
    if (!confirmed || !mounted || !Platform.isAndroid) return;
    final ussd = UssdBuilder.recharge(
      _controller.provider,
      _controller.codeField.text,
    );
    await _runRecharge(ussd);
  }

  Future<void> _runRecharge(String ussd) async {
    final l10n = AppLocalizations.of(context);
    final provider = _controller.provider;
    final outcome = await _controller.recharge();
    if (!mounted) return;
    switch (outcome.launch) {
      case UssdLaunch.ussdResponse:
        await _showCarrierResponse(
          outcome.response ?? l10n.networkNoTextReply,
          l10n.networkReply,
          l10n.rechargeRequestSentTo(provider.label),
        );
        break;
      case UssdLaunch.direct:
      case UssdLaunch.failed:
        break;
      case UssdLaunch.blocked:
        await _openManualUssdSheet(
          ussd,
          l10n.blockedManualHint(appName),
        );
        break;
      case UssdLaunch.manual:
        await _openManualUssdSheet(
          ussd,
          l10n.iosRechargeManualHint(provider.label),
        );
        break;
    }
  }

  /// Balance: runs the USSD query directly (no confirmation dialog, no
  /// external app) and reports inside the app. The result — parsed amount
  /// or the raw carrier text — always stays in the inline balance panel;
  /// no pop-up dialog is ever opened for a balance check.
  Future<void> _checkBalance() async {
    if (_controller.balanceBusy) return;
    final provider = _controller.provider;

    if (!Platform.isAndroid) {
      await _openManualUssdSheet(
        UssdBuilder.balance(provider),
        AppLocalizations.of(context).iosBalanceManualHint(provider.label),
      );
      return;
    }

    await _controller.checkBalance();
    // Every outcome — reply, SMS redirect, direct pop-up, error — is
    // explained in the inline balance panel on the Home screen.
  }

  // ------------------------------------------------------------------
  // Stage content builders
  // ------------------------------------------------------------------

  /// Idle stage: camera preview first, gallery beneath it, then the
  /// two-column Type Code / Check Balance grid and the inline balance result.
  Widget _idleCard() {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ScanPreview(
          onScan: _controller.busy ? null : _controller.startLiveScan,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: light
                ? AppColors.gameBlue
                : const Color(0xFF1D5E86),
            foregroundColor: light ? AppColors.gameInkLight : Colors.white,
            side: BorderSide(
              color: light
                  ? AppColors.gameInkLight.withValues(alpha: 0.28)
                  : theme.colorScheme.outline,
              width: 1.6,
            ),
          ),
          onPressed: _controller.busy ? null : _controller.pickFromGallery,
          icon: const Icon(Icons.photo_library_rounded),
          label: Text(l10n.fromGallery),
        ),
        const SizedBox(height: 12),
        _actionGrid(),
        const SizedBox(height: 14),
        _BalancePanel(controller: _controller),
      ],
    );
  }

  /// Type Code / Check Balance — a clean two-column grid of large touch
  /// targets, side by side on every screen width.
  Widget _actionGrid() {
    final l10n = AppLocalizations.of(context);
    final tiles = <_ActionTile>[
      _ActionTile(
        icon: Icons.keyboard_rounded,
        label: l10n.typeCode,
        accent: AppColors.gamePurple,
        onTap: _controller.busy ? null : _onManualEntry,
      ),
      _ActionTile(
        icon: Icons.account_balance_wallet_rounded,
        busyLabel: l10n.checkingEllipsis,
        label: l10n.checkBalance,
        accent: AppColors.gameOrange,
        busy: _controller.balanceBusy,
        onTap: _controller.balanceBusy ? null : _checkBalance,
      ),
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: tiles[i]),
          ],
        ],
      ),
    );
  }

  /// Manual entry: empty code field in review mode.
  void _onManualEntry() {
    _controller.startManualEntry();
  }

  Widget _successFooter() {
    final app = widget.appController;
    final l10n = AppLocalizations.of(context);
    if (!app.historyEnabled) {
      return Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Text(
          l10n.offlinePrivacyFooter,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }
    final entries = app.history.take(3).toList();
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SectionCard(
        icon: Icons.history_rounded,
        title: l10n.recentScansTitle,
        child: Column(
          children: [
            for (final HistoryEntry entry in entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(entry.provider.icon, size: 20),
                title: Text(
                  entry.maskedCode,
                  style: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                subtitle: Text(
                  l10n.recentScanTime(
                    entry.at.toLocal().toString().substring(0, 16),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _controller.l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return ListenableBuilder(
              listenable: widget.appController,
              builder: (context, _) => _body(),
            );
          },
        ),
      ),
    );
  }

  Widget _body() {
    final media = MediaQuery.of(context);
    final wide = media.size.width >= 620;
    final contentWidth = wide ? 560.0 : double.infinity;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    Widget content = switch (_controller.stage) {
      HomeStage.idle => _idleCard(),
      HomeStage.scanning => ScanCameraPanel(
        controller: _controller,
        onShutter: _controller.takePhoto,
        onGallery: _controller.pickFromGallery,
        onTorch: () => _controller.setTorch(!_controller.torchOn),
        onManual: _onManualEntry,
        onStop: _controller.returnToIdle,
        onOpenCamera: _controller.startLiveScan,
      ),
      HomeStage.review => CodeReviewPanel(
        controller: _controller,
        onConfirm: _confirmAndRecharge,
        onRescan: _controller.retakePhoto,
        onGallery: _controller.pickFromGallery,
        onCancel: _controller.clearAll,
      ),
      HomeStage.ready => CodeConfirmedPanel(
        controller: _controller,
        ussdString: _safeUssdString(),
        onRecharge: _showRechargeDialog,
        onCheckBalance: _checkBalance,
        onEdit: _controller.editAgain,
        onDiscard: _controller.clearAll,
        onCopy: () => _copy(_safeUssdString()),
      ),
    };

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: contentWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBrandHeader(
                subtitle: l10n.appSubtitle,
                child: ProviderSelector(
                  selected: _controller.provider,
                  onSelected: _onProviderSelected,
                  statusOf: _simStatusFor,
                  activeOf: _simActiveFor,
                ),
              ),
              _simSelector(),
              const SizedBox(height: 14),
              if (_controller.status != null)
                StatusBanner(
                  status: _controller.status!,
                  onDismiss: _controller.dismissStatus,
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                child: KeyedSubtree(
                  key: ValueKey(_controller.stage),
                  child: content,
                ),
              ),
              _successFooter(),
              const SizedBox(height: 16),
              Text(
                l10n.independentDisclaimer(appName),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _safeUssdString() {
    try {
      return UssdBuilder.recharge(
        _controller.provider,
        _controller.codeField.text,
      );
    } on ArgumentError {
      return AppLocalizations.of(context).codeNeedsDigits(
        _controller.provider.label,
      );
    }
  }

  Future<void> _onProviderSelected(TelecomProvider provider) async {
    _controller.selectProvider(provider);
    // Keep the default in sync so the chosen provider survives restarts.
    final appController = widget.appController;
    if (appController.defaultProvider != provider) {
      await appController.setDefaultProvider(provider);
    }
  }

  /// Compact SIM status shown on each provider card. Uses the real slot
  /// when a matching SIM is available and the expected slot otherwise.
  String _simStatusFor(TelecomProvider provider) {
    final app = widget.appController;
    final l10n = AppLocalizations.of(context);
    final sim = app.simForProvider(provider);
    if (sim != null) return l10n.simActive(sim.slot + 1);

    final fallbackSlot = provider == TelecomProvider.ethioTelecom ? 1 : 2;
    return app.sims.isEmpty
        ? l10n.simActive(fallbackSlot)
        : l10n.simInactive(fallbackSlot);
  }

  bool _simActiveFor(TelecomProvider provider) {
    final app = widget.appController;
    return app.simForProvider(provider) != null || app.sims.isEmpty;
  }

  /// Compact SIM chooser shown under the provider cards — only when the
  /// phone actually has more than one SIM. The choice is stored per
  /// provider, so Ethio can run on SIM 1 while Safaricom runs on SIM 2.
  Widget _simSelector() {
    final app = widget.appController;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final sims = app.sims;
        if (sims.length <= 1) return const SizedBox.shrink();
        final provider = _controller.provider;
        var subId = app.simSubIdFor(provider);
        if (subId > 0 && !sims.any((s) => s.subId == subId)) subId = -1;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final l10n = AppLocalizations.of(context);
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Material(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.sim_card_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      l10n.simFor(provider.shortLabel),
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  DropdownButton<int>(
                    value: subId,
                    underline: const SizedBox.shrink(),
                    isDense: true,
                    items: [
                      DropdownMenuItem(
                        value: -1,
                        child: Text(l10n.defaultValue),
                      ),
                      for (final sim in sims)
                        DropdownMenuItem(
                          value: sim.subId,
                          child: Text(
                            l10n.simName(sim.slot + 1, sim.displayName),
                          ),
                        ),
                    ],
                    onChanged: (value) =>
                        app.setSimSubId(provider, value ?? -1),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Interactive scanner preview shown above the Home actions. In idle it
/// previews the scan frame and opens the live camera on tap; once the
/// camera stage starts, the real live preview replaces it.
class _ScanPreview extends StatelessWidget {
  const _ScanPreview({required this.onScan});

  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C130E),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color: light
              ? AppColors.gameInkLight.withValues(alpha: 0.5)
              : AppColors.borderDark,
          width: 2.4,
        ),
        boxShadow: AppShadows.of(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radius - 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
              color: const Color(0xFF08100B),
              child: Row(
                children: [
                  Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      color: AppColors.scanAccent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: AppColors.scanAccent.withValues(alpha: 0.38),
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.center_focus_strong_rounded,
                      size: 16,
                      color: AppColors.scanAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.scanningCamera,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFE2F1E8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.scanAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.scanAccent.withValues(alpha: 0.32),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _LiveDot(),
                        const SizedBox(width: 5),
                        Text(
                          l10n.autoReadBadge,
                          style: const TextStyle(
                            color: AppColors.scanAccent,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                ScanGuideBox(caption: l10n.tapOpenLivePreview),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onScan,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                if (onScan != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 12,
                    child: Center(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.gameYellow,
                          foregroundColor: AppColors.gameInkLight,
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          side: BorderSide(
                            color: AppColors.gameInkLight.withValues(
                              alpha: 0.5,
                            ),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        onPressed: onScan,
                        icon: const Icon(Icons.photo_camera_rounded, size: 18),
                        label: Text(l10n.scanRechargeCard),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: AppColors.scanAccent,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// One of the two secondary Home actions (type / balance).
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
    this.busy = false,
    this.busyLabel,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final String? busyLabel;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final light = theme.brightness == Brightness.light;
    final enabled = onTap != null;
    final shownLabel = busy && busyLabel != null ? busyLabel! : label;
    final accentInk = light ? AppColors.gameInkLight : accent;

    return Semantics(
      button: true,
      enabled: enabled,
      label: shownLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            constraints: const BoxConstraints(minHeight: 104),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  enabled
                      ? accent.withValues(alpha: light ? 0.14 : 0.2)
                      : colorScheme.surface.withValues(alpha: 0.62),
                  colorScheme.surface.withValues(alpha: enabled ? 1 : 0.62),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: enabled
                    ? (light
                          ? AppColors.gameInkLight.withValues(alpha: 0.16)
                          : colorScheme.outline)
                    : colorScheme.outline,
                width: 1.8,
              ),
              boxShadow: enabled ? AppShadows.of(context) : const [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: enabled
                        ? accent.withValues(alpha: light ? 0.2 : 0.24)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: enabled
                          ? accent.withValues(alpha: 0.45)
                          : colorScheme.outline,
                      width: 1.4,
                    ),
                  ),
                  child: busy
                      ? Padding(
                          padding: const EdgeInsets.all(11),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: accentInk,
                          ),
                        )
                      : Icon(
                          icon,
                          size: 23,
                          color: enabled
                              ? accentInk
                              : colorScheme.onSurfaceVariant,
                        ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 34),
                  child: Center(
                    child: Text(
                      shownLabel,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: enabled
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline balance result (loading / live reply / honest error). Shown on the
/// Home screen so the balance never leaves the app.
class _BalancePanel extends StatelessWidget {
  const _BalancePanel({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.balanceBusy &&
        controller.balanceReply == null &&
        controller.balanceError == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final light = theme.brightness == Brightness.light;
    final l10n = AppLocalizations.of(context);

    if (controller.balanceBusy) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: SectionCard(
          icon: Icons.hourglass_top_rounded,
          title: l10n.balanceCheckingTitle(controller.provider.label),
          child: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.balanceCheckingBody,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final reply = controller.balanceReply;
    final error = controller.balanceError;
    final checkedAt = controller.balanceCheckedAt;
    final isError = reply == null;
    final parsed = reply == null ? null : parseBalanceReply(reply);
    final hasAmount = !isError && parsed != null && parsed.hasAmount;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: SectionCard(
        icon: isError
            ? Icons.error_outline_rounded
            : Icons.account_balance_wallet_rounded,
        title: l10n.balanceTitle(controller.provider.label),
        trailing: _StatusChip(
          isError: isError,
          label: isError
              ? l10n.chipNoBalance
              : (hasAmount ? l10n.chipLiveReply : l10n.chipCarrierReply),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasAmount) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: light
                      ? AppColors.lightGreen
                      : AppColors.darkGreenSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: light
                        ? AppColors.primaryLight.withValues(alpha: 0.35)
                        : AppColors.primaryDark.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${parsed.amount} ${parsed.currency}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: light
                            ? AppColors.primaryDarkGreen
                            : AppColors.primaryDark,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.parsedFromCarrier,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            (light
                                    ? AppColors.primaryDarkGreen
                                    : AppColors.primaryDark)
                                .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.carrierReplyVerbatim,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: isError
                    ? colorScheme.errorContainer.withValues(alpha: 0.5)
                    : colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.65,
                      ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isError
                      ? colorScheme.error.withValues(alpha: 0.35)
                      : colorScheme.outline,
                ),
              ),
              child: SelectableText(
                reply ?? error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isError
                      ? colorScheme.onErrorContainer
                      : colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
            if (!isError && (parsed == null || !parsed.hasAmount)) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.noRecognizableAmount,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ],
            if (checkedAt != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      isError
                          ? l10n.noBalanceRead
                          : l10n.liveReplyAt(
                              checkedAt.toLocal().toString().substring(11, 16),
                            ),
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small status pill used on result cards.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isError, required this.label});

  final bool isError;
  final String label;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final Color bg;
    final Color fg;
    if (isError) {
      bg = light ? const Color(0xFFFDECEB) : const Color(0xFF3A1512);
      fg = light ? const Color(0xFFB3261E) : const Color(0xFFFFB4AB);
    } else {
      bg = light ? AppColors.lightGreen : AppColors.darkGreenSurface;
      fg = light ? AppColors.primaryDarkGreen : AppColors.primaryDark;
    }
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 6, left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isError ? Icons.error_rounded : Icons.check_circle_rounded,
            size: 13,
            color: fg,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: fg, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
