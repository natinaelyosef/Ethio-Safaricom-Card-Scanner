import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saricom/models/telecom_provider.dart';
import 'package:saricom/services/settings_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults: light theme, English, Ethio telecom, history off', () async {
    final settings = await SettingsService.load();
    expect(settings.themeMode, AppThemeMode.light);
    expect(settings.languageCode, 'en');
    expect(settings.defaultProvider, TelecomProvider.ethioTelecom);
    expect(settings.historyEnabled, isFalse);
  });

  test('roundtrip every preference', () async {
    final settings = await SettingsService.load();
    await settings.setThemeMode(AppThemeMode.dark);
    await settings.setLanguageCode('am');
    await settings.setDefaultProvider(TelecomProvider.safaricomEthiopia);
    await settings.setHistoryEnabled(true);

    final reloaded = await SettingsService.load();
    expect(reloaded.themeMode, AppThemeMode.dark);
    expect(reloaded.languageCode, 'am');
    expect(reloaded.defaultProvider, TelecomProvider.safaricomEthiopia);
    expect(reloaded.historyEnabled, isTrue);
  });

  test('unknown stored enum falls back to defaults', () async {
    SharedPreferences.setMockInitialValues({
      'saricom.theme.mode': 'neither',
      'saricom.provider.default': 'unknown-net',
      'saricom.language.code': 'fr',
    });
    final settings = await SettingsService.load();
    expect(settings.themeMode, AppThemeMode.light);
    expect(settings.languageCode, 'en');
    expect(settings.defaultProvider, TelecomProvider.ethioTelecom);
  });

  test('sim subId defaults to -1 and roundtrips per provider', () async {
    final settings = await SettingsService.load();
    expect(settings.simSubId(TelecomProvider.ethioTelecom), -1);
    expect(settings.simSubId(TelecomProvider.safaricomEthiopia), -1);

    await settings.setSimSubId(TelecomProvider.ethioTelecom, 2);
    await settings.setSimSubId(TelecomProvider.safaricomEthiopia, 3);

    final reloaded = await SettingsService.load();
    expect(reloaded.simSubId(TelecomProvider.ethioTelecom), 2);
    expect(reloaded.simSubId(TelecomProvider.safaricomEthiopia), 3);
  });
}
