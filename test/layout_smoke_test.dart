import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saricom/app.dart';
import 'package:saricom/services/history_service.dart';
import 'package:saricom/services/ocr_service.dart';
import 'package:saricom/services/settings_service.dart';
import 'package:saricom/services/ussd_service.dart';
import 'package:saricom/state/app_controller.dart';

Future<void> pumpApp(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final settings = await SettingsService.load();
  final history = HistoryService(settings.prefs);
  final controller = AppController(settings, history);
  final services = AppServices(
    settings: settings,
    history: history,
    ocr: OcrService(),
    ussd: UssdService(),
  );
  await tester.pumpWidget(
    SaricomApp(appController: controller, services: services),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('320x640 home renders without layout errors', (tester) async {
    await pumpApp(tester, const Size(320, 640));

    expect(find.text('Ethio & Safaricom Card Scanner'), findsOneWidget);
    expect(find.text('Ethio telecom'), findsOneWidget);
    expect(find.text('Safaricom'), findsOneWidget);
    expect(find.text('Scan Recharge Card'), findsOneWidget);
    expect(find.text('From Gallery'), findsOneWidget);
    expect(find.text('Type Code'), findsOneWidget);
    expect(find.text('Check Balance'), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('320x640 manual entry -> ready -> discard', (tester) async {
    await pumpApp(tester, const Size(320, 640));

    await tester.ensureVisible(find.text('Type Code'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Type Code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '832411651675');
    await tester.pump();
    await tester.ensureVisible(find.text('Confirm & Recharge'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm & Recharge'));
    await tester.pumpAndSettle();
    expect(find.text('Ready to recharge'), findsOneWidget);

    await tester.ensureVisible(find.text('Scan the next card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan the next card'));
    await tester.pumpAndSettle();
    expect(find.text('Scan Recharge Card'), findsOneWidget);
  });

  testWidgets('360x740 settings scrolls to the last card', (tester) async {
    await pumpApp(tester, const Size(360, 740));

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Default provider'), findsOneWidget);
    expect(find.text('Local scan history'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('About Ethio & Safaricom Card Scanner'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('About Ethio & Safaricom Card Scanner'), findsOneWidget);
    expect(find.text('Natinael Yosef'), findsOneWidget);
    expect(
      find.text('https://natinaelyosef.github.io/natinael-yosef-portfolio/'),
      findsOneWidget,
    );

    // Back home keeps the two-page shell intact.
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Scan Recharge Card'), findsOneWidget);
  });

  testWidgets('wide screen keeps the two-column action grid', (tester) async {
    await pumpApp(tester, const Size(620, 1000));
    expect(find.text('From Gallery'), findsOneWidget);
    expect(find.text('Type Code'), findsOneWidget);
    expect(find.text('Check Balance'), findsOneWidget);
  });

  testWidgets('all three appearance modes apply from Settings', (tester) async {
    await pumpApp(tester, const Size(360, 800));
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    Brightness brightness() =>
        Theme.of(tester.element(find.text('Appearance'))).brightness;

    await tester.ensureVisible(find.text('Light'));
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.light);

    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.light);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.dark);
  });

  testWidgets('bottom navigation keeps exactly two destinations', (
    tester,
  ) async {
    await pumpApp(tester, const Size(360, 800));

    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.text('Scan Recharge Card'), findsOneWidget);
  });
}
