import 'package:flutter/material.dart';

import 'app.dart';
import 'services/history_service.dart';
import 'services/ocr_service.dart';
import 'services/settings_service.dart';
import 'services/ussd_service.dart';
import 'state/app_controller.dart';

/// Application entry point.
///
/// Loads the local stores first (no network, no accounts), builds the
/// singleton services, then hands control to [SaricomApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = await SettingsService.load();
  final history = HistoryService(settings.prefs);
  final appController = AppController(settings, history);
  final services = AppServices(
    settings: settings,
    history: history,
    ocr: OcrService(),
    ussd: UssdService(),
  );

  runApp(SaricomApp(appController: appController, services: services));
}
