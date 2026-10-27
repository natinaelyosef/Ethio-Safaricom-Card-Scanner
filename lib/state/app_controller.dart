import 'package:flutter/material.dart';

import '../models/telecom_provider.dart';
import '../services/history_service.dart';
import '../services/settings_service.dart';
import '../services/ussd_service.dart';

/// Global app settings state (theme, default provider, history opt-in,
/// dual-SIM selection).
///
/// Deliberately kept tiny — no DI framework, one [ChangeNotifier] the two
/// screens observe with [ListenableBuilder].
class AppController extends ChangeNotifier {
  AppController(this._settings, this._history, {UssdService? ussd})
    : _ussd = ussd ?? UssdService();

  final SettingsService _settings;
  final HistoryService _history;
  final UssdService _ussd;

  /// Cached SIM list; fetched once per session (lazily).
  List<SimInfo>? _sims;

  /// True while [refreshSims] is in flight.
  bool simsLoading = false;

  /// Last error from the SIM list query (shown in Settings).
  String? simsError;

  AppThemeMode get themeMode => _settings.themeMode;

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _settings.setThemeMode(mode);
    notifyListeners();
  }

  /// Active interface locale (`en` or `am`).
  Locale get locale => Locale(_settings.languageCode);

  String get languageCode => _settings.languageCode;

  Future<void> setLanguageCode(String code) async {
    await _settings.setLanguageCode(code);
    notifyListeners();
  }

  TelecomProvider get defaultProvider => _settings.defaultProvider;

  Future<void> setDefaultProvider(TelecomProvider provider) async {
    await _settings.setDefaultProvider(provider);
    notifyListeners();
  }

  bool get historyEnabled => _history.isEnabled();

  Future<void> setHistoryEnabled(bool enabled) async {
    await _history.setEnabled(enabled);
    notifyListeners();
  }

  List<HistoryEntry> get history => _history.entries();

  Future<void> clearHistory() async {
    await _history.clear();
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Dual-SIM support
  // ------------------------------------------------------------------

  /// The cached SIM list (empty until [refreshSims] succeeds).
  List<SimInfo> get sims => _sims ?? const [];

  /// Fetches the active SIMs once per session. Safe to call repeatedly —
  /// the list is only re-queried when it was never loaded.
  Future<void> refreshSims({bool force = false}) async {
    if (simsLoading) return;
    if (!force && _sims != null) return;
    simsLoading = true;
    simsError = null;
    notifyListeners();
    try {
      final list = await _ussd.listSims();
      _sims = list;
      if (list.isEmpty) {
        simsError = null; // Not an error — single-SIM or permission denied.
      }
    } catch (_) {
      simsError = 'Could not read the SIM list.';
    } finally {
      simsLoading = false;
      notifyListeners();
    }
  }

  /// Subscription id the user chose for [provider] (-1 = default).
  int simSubIdFor(TelecomProvider provider) => _settings.simSubId(provider);

  /// The installed SIM that [provider] will dial, when it can be resolved
  /// from the cached list (explicit choice first, then carrier match).
  SimInfo? simForProvider(TelecomProvider provider) {
    final chosen = simSubIdFor(provider);
    if (chosen > 0) {
      for (final sim in sims) {
        if (sim.subId == chosen) return sim;
      }
    }

    final needle = provider.simCarrierNeedle;
    if (needle == null) return null;
    final matches = sims
        .where(
          (sim) =>
              sim.carrierName.toLowerCase().contains(needle) ||
              sim.displayName.toLowerCase().contains(needle),
        )
        .toList();
    return matches.length == 1 ? matches.first : null;
  }

  /// Chooses (or clears with -1) the SIM for [provider].
  Future<void> setSimSubId(TelecomProvider provider, int subId) async {
    await _settings.setSimSubId(provider, subId);
    notifyListeners();
  }

  /// Resolves the subscription id to dial for [provider], used by
  /// [HomeController] before every recharge/balance USSD session.
  ///
  /// Auto-matches when the user has not chosen a SIM but the list is
  /// available and contains the provider's carrier (e.g. "Ethio telecom"
  /// for [TelecomProvider.ethioTelecom]) — so dual-SIM phones work
  /// out-of-the-box without a manual choice.
  Future<int?> resolveSubscriptionId(TelecomProvider provider) async {
    final chosen = _settings.simSubId(provider);
    if (chosen > 0) return chosen;

    final list = _sims ?? await _refreshQuietly();
    if (list.isEmpty) return null;

    final needle = provider.simCarrierNeedle;
    if (needle == null) return null;
    final match = list.where(
      (sim) =>
          sim.carrierName.toLowerCase().contains(needle) ||
          sim.displayName.toLowerCase().contains(needle),
    );
    if (match.isEmpty) return null;
    // Single matching SIM: auto-use it. Multiple: leave to the device
    // default so we never guess between two cards of the same carrier.
    return match.length == 1 ? match.first.subId : null;
  }

  Future<List<SimInfo>> _refreshQuietly() async {
    try {
      final list = await _ussd.listSims();
      _sims = list;
      return list;
    } catch (_) {
      return const [];
    }
  }

  /// Home screen reads the saved provider for each new session.
  HistoryService get historyService => _history;

  /// Shared settings service (same loaded SharedPreferences instance).
  SettingsService get settingsService => _settings;
}
