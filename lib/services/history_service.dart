import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/telecom_provider.dart';

/// One local (device-only) scan-history entry.
///
/// Full voucher codes are never stored. Only a masked preview of the first
/// four digits is kept so the user can recognise a card they already used.
class HistoryEntry {
  HistoryEntry({
    required this.provider,
    required this.maskedCode,
    required this.digitCount,
    required this.at,
  });

  final TelecomProvider provider;

  /// Masked voucher, e.g. `4821••••••(13)` — first four digits + length.
  final String maskedCode;
  final int digitCount;
  final DateTime at;

  /// Builds the masked representation for a full voucher code.
  static String maskCode(String digits) {
    final clean = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length <= 4) {
      return '${'•' * clean.length}(${clean.length})';
    }
    final head = clean.substring(0, 4);
    return '$head${'•' * (clean.length - 4)}(${clean.length})';
  }

  Map<String, dynamic> toMap() => {
    'p': provider.name,
    'c': maskedCode,
    'n': digitCount,
    'd': at.toIso8601String(),
  };

  static HistoryEntry fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      provider: TelecomProvider.values.firstWhere(
        (p) => p.name == (map['p'] as String?),
        orElse: () => TelecomProvider.ethioTelecom,
      ),
      maskedCode: (map['c'] as String?) ?? '•••••',
      digitCount: (map['n'] as num?)?.toInt() ?? 0,
      at: DateTime.tryParse((map['d'] as String?) ?? '') ?? DateTime.now(),
    );
  }
}

/// Optional, opt-in scan history kept in local storage only.
class HistoryService {
  HistoryService(this._prefs);

  static const _keyEntries = 'saricom.history.entries.v1';
  static const int maxEntries = 30;

  final SharedPreferences _prefs;

  bool isEnabled() => _prefs.getBool('saricom.history.enabled') ?? false;

  Future<void> setEnabled(bool enabled) =>
      _prefs.setBool('saricom.history.enabled', enabled);

  List<HistoryEntry> entries() {
    final raw = _prefs.getString(_keyEntries);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => HistoryEntry.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      return list;
    } on FormatException {
      return const [];
    }
  }

  /// Records a scan. No-op when history is disabled. Codes are masked and
  /// the list is trimmed so storage stays minimal.
  Future<void> addScan(
    TelecomProvider provider,
    String digits,
    DateTime at,
  ) async {
    if (!isEnabled()) return;
    final clean = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 6) return;

    final current = List.of(entries())
      ..insert(
        0,
        HistoryEntry(
          provider: provider,
          maskedCode: HistoryEntry.maskCode(clean),
          digitCount: clean.length,
          at: at,
        ),
      );
    final trimmed = current.length > maxEntries
        ? current.sublist(0, maxEntries)
        : current;
    await _prefs.setString(
      _keyEntries,
      jsonEncode(trimmed.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> clear() => _prefs.remove(_keyEntries);
}
