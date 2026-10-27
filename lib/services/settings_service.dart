import 'package:shared_preferences/shared_preferences.dart';

import '../models/telecom_provider.dart';

/// Typed wrapper around SharedPreferences holding every local preference.
///
/// All keys live here so nothing else touches the raw store. Nothing in
/// these settings is sensitive — vouchers are **never** stored here.
class SettingsService {
  SettingsService(this._prefs);

  static const _keyThemeMode = 'saricom.theme.mode'; // system|light|dark
  static const _keyLanguageCode = 'saricom.language.code'; // en|am
  static const _keyDefaultProvider = 'saricom.provider.default';
  static const _keyHistoryEnabled = 'saricom.history.enabled';

  /// Interface languages the app ships with.
  static const supportedLanguageCodes = <String>{'en', 'am'};

  /// Per-provider SIM subscription id (-1 = device default). Keyed by
  /// the provider enum name so dual-SIM users can pin Ethio telecom to
  /// SIM 1 and Safaricom to SIM 2.
  static String _keySimSubId(TelecomProvider provider) =>
      'saricom.sim.subId.${provider.name}';

  final SharedPreferences _prefs;

  /// The loaded SharedPreferences instance, shared with HistoryService.
  SharedPreferences get prefs => _prefs;

  /// Creates a service from freshly loaded prefs.
  static Future<SettingsService> load() async =>
      SettingsService(await SharedPreferences.getInstance());

  AppThemeMode get themeMode {
    final raw = _prefs.getString(_keyThemeMode) ?? AppThemeMode.light.name;
    return AppThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => AppThemeMode.light,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async =>
      await _prefs.setString(_keyThemeMode, mode.name);

  /// Interface language code. Defaults to English; Amharic is `am`.
  String get languageCode {
    final raw = _prefs.getString(_keyLanguageCode);
    return supportedLanguageCodes.contains(raw) ? raw! : 'en';
  }

  Future<void> setLanguageCode(String code) async {
    if (!supportedLanguageCodes.contains(code)) return;
    await _prefs.setString(_keyLanguageCode, code);
  }

  TelecomProvider get defaultProvider {
    final raw = _prefs.getString(_keyDefaultProvider);
    if (raw == TelecomProvider.safaricomEthiopia.name) {
      return TelecomProvider.safaricomEthiopia;
    }
    return TelecomProvider.ethioTelecom;
  }

  Future<void> setDefaultProvider(TelecomProvider provider) =>
      _prefs.setString(_keyDefaultProvider, provider.name);

  bool get historyEnabled => _prefs.getBool(_keyHistoryEnabled) ?? false;

  Future<void> setHistoryEnabled(bool enabled) =>
      _prefs.setBool(_keyHistoryEnabled, enabled);

  /// Subscription id of the SIM chosen for [provider], or -1 for the
  /// device default (or when no choice has been made).
  int simSubId(TelecomProvider provider) =>
      _prefs.getInt(_keySimSubId(provider)) ?? -1;

  Future<void> setSimSubId(TelecomProvider provider, int subId) =>
      _prefs.setInt(_keySimSubId(provider), subId);
}

/// Theme preference.
enum AppThemeMode { system, light, dark }
