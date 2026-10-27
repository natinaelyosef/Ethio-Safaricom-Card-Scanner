import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// One installed SIM on a dual-SIM Android phone.
class SimInfo {
  const SimInfo({
    required this.subId,
    required this.slot,
    required this.carrierName,
    required this.displayName,
  });

  /// Android subscription id; pass to [UssdService.dial] to run a
  /// session on this SIM. Never negative.
  final int subId;

  /// Physical slot index (0-based).
  final int slot;

  /// Carrier name from the SIM (e.g. "Ethio telecom", "Safaricom").
  final String carrierName;

  /// User-facing label ("Ethio telecom" or the SIM's custom name).
  final String displayName;

  bool get hasCarrier => carrierName.isNotEmpty;

  factory SimInfo.fromJson(Map<String, dynamic> json) {
    final carrier = (json['carrierName'] as String? ?? '').trim();
    var display = (json['displayName'] as String? ?? '').trim();
    if (display.isEmpty) {
      display = carrier.isEmpty ? 'SIM ${json['slot']}' : carrier;
    }
    return SimInfo(
      subId: (json['subId'] as num?)?.toInt() ?? -1,
      slot: (json['slot'] as num?)?.toInt() ?? 0,
      carrierName: carrier,
      displayName: display,
    );
  }
}

/// What happened when a USSD session was requested.
enum UssdLaunch {
  /// The network answered *in this app*: either TelephonyManager's
  /// sendUssdRequest returned the carrier's message, or the opt-in USSD
  /// pop-up reader captured the carrier dialog. Saricom shows the reply
  /// verbatim — no other app.
  ussdResponse,

  /// The carrier's own system pop-up is showing over this app and the
  /// opt-in reader is disabled or did not capture it.
  direct,

  /// Not possible on this platform (iOS blocks launching USSD).
  /// The UI shows copy-and-dial instructions instead.
  manual,

  /// Everything was attempted and the session could not be completed
  /// inside the app — and the direct-dial fallback is unavailable
  /// (CALL_PHONE denied). No other application is ever opened; the UI
  /// explains the permission and offers the copy option.
  blocked,

  /// The platform channel failed entirely, or the native call never
  /// returned (device stuck in sendUssdRequest).
  failed,
}

/// Outcome of one dial attempt.
class UssdOutcome {
  const UssdOutcome(this.launch, {this.response, this.details});

  final UssdLaunch launch;

  /// The network's own USSD answer text (only for UssdLaunch.ussdResponse).
  final String? response;

  /// Extra context for diagnostics (exception message etc.).
  final String? details;
}

/// Platform channel that runs USSD sessions on Android directly from
/// `MainActivity`:
///
/// 1. primary: `TelephonyManager.sendUssdRequest` — the network's reply
///    flows back here, so the whole session completes inside Saricom.
/// 2. fallback: `ACTION_CALL` — starts the session so the carrier's
///    regular pop-up appears over this app (requires CALL_PHONE; the
///    Dart layer requests it first).
/// 3. when the carrier pop-up is used and the user enabled the optional
///    USSD reader in Settings, `UssdAccessibilityService` captures the
///    dialog text and it is returned as a normal reply here.
///
/// The dialer app is *never* opened. iOS never allows apps to initiate
/// USSD codes, so dial returns [UssdLaunch.manual] there and the UI falls
/// back to copy-and-dial instructions.
class UssdService {
  UssdService() {
    _channel.setMethodCallHandler(_handlePlatformCall);
  }

  static const MethodChannel _channel = MethodChannel('saricom/platform');

  /// Completes when the accessibility reader captures the carrier pop-up.
  Completer<String>? _popupCompleter;

  /// How long to wait for the opt-in reader after the carrier pop-up was
  /// launched. USSD replies usually appear within a few seconds.
  static const Duration _captureWindow = Duration(seconds: 30);

  /// Hard cap on one dial. Emulator experiments proved some devices
  /// never invoke the native sendUssdRequest callback; without this
  /// timeout the Dart spinner spins forever.
  static const Duration _dialTimeout = Duration(seconds: 20);

  Future<dynamic> _handlePlatformCall(MethodCall call) async {
    if (call.method == 'ussdPopup') {
      final text = (call.arguments as String?)?.trim();
      final pending = _popupCompleter;
      if (text != null &&
          text.isNotEmpty &&
          pending != null &&
          !pending.isCompleted) {
        pending.complete(text);
      }
    }
    return null;
  }

  /// True when the user enabled Saricom's USSD pop-up reader in Android
  /// accessibility settings.
  Future<bool> isUssdReaderEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isUssdReaderEnabled') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Opens the system accessibility settings so the user can enable the
  /// reader (Android restricts toggling it programmatically).
  Future<void> openUssdReaderSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openUssdReaderSettings');
    } on PlatformException {
      // Nothing else we can do; the Settings card explains the path.
    } on MissingPluginException {
      // Older build without the native method.
    }
  }

  /// Arms the native side to accept a popup capture for the next request.
  Future<void> _armCapture() async {
    try {
      await _channel.invokeMethod('armUssdCapture', {
        'seconds': _captureWindow.inSeconds + 5,
      });
    } on PlatformException {
      // Optional feature.
    } on MissingPluginException {
      // Optional feature.
    }
  }

  /// Waits for the accessibility service to hand over the carrier dialog
  /// text. Returns [UssdLaunch.direct] when nothing arrives in time.
  Future<UssdOutcome> _awaitCapturedPopup(Completer<String> completer) async {
    try {
      final text = await completer.future.timeout(_captureWindow);
      return UssdOutcome(UssdLaunch.ussdResponse, response: text);
    } on TimeoutException {
      return const UssdOutcome(UssdLaunch.direct);
    } finally {
      if (identical(_popupCompleter, completer)) {
        _popupCompleter = null;
      }
    }
  }

  /// Lists the active SIMs (dual-SIM support). Android only; returns an
  /// empty list when READ_PHONE_STATE is denied or on other platforms.
  Future<List<SimInfo>> listSims() async {
    if (!Platform.isAndroid) return const [];
    try {
      final raw = await _channel.invokeMethod<String>('listSims');
      if (raw == null || raw.isEmpty) return const [];
      if (raw == 'noPermission') {
        // Ask once; if denied the UI falls back to the default SIM.
        final status = await Permission.phone.status;
        if (!status.isGranted) await Permission.phone.request();
        final retry = await _channel.invokeMethod<String>('listSims');
        if (retry == null || retry.isEmpty || retry == 'noPermission') {
          return const [];
        }
        return _parseSims(retry);
      }
      return _parseSims(raw);
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  List<SimInfo> _parseSims(String raw) {
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(SimInfo.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Runs the USSD session for [code] (like `*805*1234...#`).
  ///
  /// On Android the CALL_PHONE runtime permission is requested before the
  /// first attempt so the direct-dial fallback stays available if the
  /// device's sendUssdRequest refuses.
  ///
  /// [subscriptionId] pins the session to a specific SIM on dual-SIM
  /// phones (see [listSims]); pass null to use the device default.
  Future<UssdOutcome> dial(String code, {int? subscriptionId}) async {
    if (code.isEmpty) return const UssdOutcome(UssdLaunch.failed);
    if (!Platform.isAndroid) return const UssdOutcome(UssdLaunch.manual);

    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
    }
    // Denied is not fatal: sendUssdRequest needs no permission. Only the
    // rare fallback needs CALL_PHONE — with it denied the channel answers
    // "noPermission" and the UI explains, without opening any other app.

    await _armCapture();

    // Register the popup listener *before* dialing so a carrier dialog
    // that appears very quickly cannot be missed.
    final readerEnabled = await isUssdReaderEnabled();
    final popup = Completer<String>();
    if (readerEnabled) _popupCompleter = popup;

    String? res;
    try {
      res = await _invokeOpenUssd(
        code,
        subscriptionId: subscriptionId,
      ).timeout(_dialTimeout);
    } on TimeoutException {
      if (identical(_popupCompleter, popup)) _popupCompleter = null;
      return const UssdOutcome(UssdLaunch.failed, details: 'ussd timed out');
    } finally {
      if (!readerEnabled && identical(_popupCompleter, popup)) {
        _popupCompleter = null;
      }
    }
    if (res == null) {
      if (identical(_popupCompleter, popup)) _popupCompleter = null;
      return const UssdOutcome(UssdLaunch.failed);
    }

    if (res.startsWith('ussdResponse:')) {
      if (identical(_popupCompleter, popup)) _popupCompleter = null;
      final text = res.substring('ussdResponse:'.length).trim();
      return UssdOutcome(
        UssdLaunch.ussdResponse,
        response: text.isEmpty ? null : text,
      );
    }
    if (res.startsWith('direct|') || res == 'direct') {
      // The carrier pop-up is now over the app. If the user enabled the
      // pop-up reader, wait for its text and treat it as a normal reply.
      if (readerEnabled) {
        return _awaitCapturedPopup(popup);
      }
      return const UssdOutcome(UssdLaunch.direct);
    }
    if (identical(_popupCompleter, popup)) _popupCompleter = null;
    switch (res) {
      case 'noPermission':
        return const UssdOutcome(
          UssdLaunch.blocked,
          details: 'call permission denied',
        );
      default:
        return const UssdOutcome(UssdLaunch.failed);
    }
  }

  Future<String?> _invokeOpenUssd(String code, {int? subscriptionId}) async {
    try {
      return await _channel.invokeMethod<String>('openUssd', {
        'code': code,
        if (subscriptionId != null && subscriptionId > 0)
          'subscriptionId': subscriptionId,
      });
    } on PlatformException catch (e) {
      return 'failed:${e.message}';
    } on MissingPluginException {
      return null;
    }
  }
}
