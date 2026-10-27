import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saricom/app.dart';
import 'package:saricom/models/telecom_provider.dart';
import 'package:saricom/services/history_service.dart';
import 'package:saricom/services/ocr_service.dart';
import 'package:saricom/services/settings_service.dart';
import 'package:saricom/services/ussd_service.dart';
import 'package:saricom/state/app_controller.dart';

Future<(AppController, AppServices)> bootstrap() async {
  final settings = await SettingsService.load();
  final history = HistoryService(settings.prefs);
  final controller = AppController(settings, history);
  final services = AppServices(
    settings: settings,
    history: history,
    ocr: OcrService(),
    ussd: UssdService(),
  );
  return (controller, services);
}

/// Gives every widget test a tall portrait phone surface so all primary
/// actions are visible without scrolling.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(540, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final (controller, services) = await bootstrap();
  await tester.pumpWidget(
    SaricomApp(appController: controller, services: services),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home shows brand, provider selector and main actions', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Ethio & Safaricom Card Scanner'), findsOneWidget);
    expect(find.text('Recharge Card Scanner'), findsOneWidget);
    // Provider cards with their active SIM status.
    expect(find.text('Ethio telecom'), findsOneWidget);
    expect(find.text('Safaricom'), findsOneWidget);
    expect(find.textContaining('SIM 1'), findsOneWidget);
    expect(find.textContaining('SIM 2'), findsOneWidget);
    expect(find.text('Scan Recharge Card'), findsOneWidget);
    expect(find.text('From Gallery'), findsOneWidget);
    expect(find.text('Type Code'), findsOneWidget);
    expect(find.text('Check Balance'), findsOneWidget);
  });

  testWidgets('switching provider persists the default provider', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Safaricom'));
    await tester.pumpAndSettle();

    expect(
      (await SettingsService.load()).defaultProvider,
      TelecomProvider.safaricomEthiopia,
    );
  });

  testWidgets('manual entry validates, then confirms into ready panel', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Type Code'));
    await tester.pumpAndSettle();

    expect(find.text('Check the recognized PIN'), findsOneWidget);
    expect(find.text('Confirm & Recharge'), findsOneWidget);

    // A too-short code cannot be confirmed: stays on review.
    await tester.enterText(find.byType(TextField), '123');
    await tester.pump();
    expect(find.text('3 digits'), findsOneWidget);
    expect(find.text('123'), findsNWidgets(2));
    await tester.tap(find.text('Confirm & Recharge'));
    await tester.pumpAndSettle();
    expect(find.text('Ready to recharge'), findsNothing);
    expect(find.text('Check the recognized PIN'), findsOneWidget);

    // A plausible code confirms into the ready panel.
    await tester.enterText(find.byType(TextField), '832411651675');
    await tester.pump();
    expect(find.text('12 digits'), findsOneWidget);
    expect(find.text('8324 1165 1675'), findsOneWidget);
    await tester.tap(find.text('Confirm & Recharge'));
    await tester.pumpAndSettle();

    expect(find.text('Ready to recharge'), findsOneWidget);
    expect(find.textContaining('8324 1165 1675'), findsOneWidget);
    expect(find.textContaining('*805*832411651675#'), findsOneWidget);
  });

  testWidgets('discard returns from ready to the idle card', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Type Code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '832411651675');
    await tester.tap(find.text('Confirm & Recharge'));
    await tester.pumpAndSettle();
    expect(find.text('Ready to recharge'), findsOneWidget);

    await tester.ensureVisible(find.text('Scan the next card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan the next card'));
    await tester.pumpAndSettle();
    expect(find.text('Scan Recharge Card'), findsOneWidget);
  });

  testWidgets('settings switches the app to dark theme', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);

    await tester.ensureVisible(find.text('Dark'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Appearance'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('settings switches the app to Amharic', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);

    await tester.tap(find.text('አማርኛ'));
    await tester.pumpAndSettle();

    expect(find.text('መነሻ'), findsOneWidget);
    expect(find.text('ቅንብሮች'), findsNWidgets(2));
    expect((await SettingsService.load()).languageCode, 'am');
  });
}
