import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saricom/models/telecom_provider.dart';
import 'package:saricom/services/history_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<HistoryService> service() async {
    return HistoryService(await SharedPreferences.getInstance());
  }

  test('history is opt-in: addScan is a no-op while disabled', () async {
    final h = await service();
    await h.addScan(
      TelecomProvider.ethioTelecom,
      '1234567890123',
      DateTime(2026),
    );
    expect(h.entries(), isEmpty);
  });

  test('addScan stores masked code only', () async {
    final h = await service();
    await h.setEnabled(true);
    await h.addScan(
      TelecomProvider.safaricomEthiopia,
      '987654321012345',
      DateTime(2026),
    );

    final entries = h.entries();
    expect(entries, hasLength(1));
    final entry = entries.single;
    expect(entry.provider, TelecomProvider.safaricomEthiopia);
    expect(entry.maskedCode, contains('9876'));
    expect(entry.maskedCode, isNot(contains('54321012345')));
    expect(entry.digitCount, 15);
  });

  test('maskCode keeps the first four digits and hides the rest', () {
    expect(HistoryEntry.maskCode('987'), '•••(3)');
    expect(HistoryEntry.maskCode('987654321012345'), '9876•••••••••••(15)');
  });

  test('short codes below 6 digits are not stored', () async {
    final h = await service();
    await h.setEnabled(true);
    await h.addScan(TelecomProvider.ethioTelecom, '12345', DateTime(2026));
    expect(h.entries(), isEmpty);
  });

  test('history trims to the newest 30 entries', () async {
    final h = await service();
    await h.setEnabled(true);
    for (var i = 0; i < 40; i++) {
      await h.addScan(
        TelecomProvider.ethioTelecom,
        '9000${i}000000000',
        DateTime(2026, 1, 1, 0, 0, i),
      );
    }
    expect(h.entries(), hasLength(HistoryService.maxEntries));
    // Newest first.
    expect(h.entries().first.at.isAfter(h.entries().last.at), isTrue);
  });

  test('clear removes every entry', () async {
    final h = await service();
    await h.setEnabled(true);
    await h.addScan(
      TelecomProvider.ethioTelecom,
      '1234567890123',
      DateTime(2026),
    );
    await h.clear();
    expect(h.entries(), isEmpty);
  });

  test('entries() tolerates malformed JSON', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saricom.history.entries.v1', 'not-json');
    final h = HistoryService(prefs);
    expect(h.entries(), isEmpty);
  });
}
