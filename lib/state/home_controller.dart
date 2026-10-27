import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/app_info.dart';
import '../logic/code_parser.dart';
import '../logic/ussd_builder.dart';
import '../l10n/app_localizations.dart';
import '../models/telecom_provider.dart';
import '../services/history_service.dart';
import '../services/ocr_service.dart';
import '../services/ussd_service.dart';

/// The states the Home screen shows inside its single page.
enum HomeStage { idle, scanning, review, ready }

/// Severity for the in-page status banner.
enum StatusKind { info, success, warning, error }

/// One status banner entry.
class HomeStatus {
  const HomeStatus(this.message, this.kind);
  final String message;
  final StatusKind kind;
}

/// Drives everything on the Home screen: camera capture, OCR, PIN review,
/// confirmation, recharge, and balance checks — all in one screen.
///
/// # Scanning pipeline
///
/// `takePhoto()` (the shutter) or the auto-capture assist takes a real
/// still photo with the platform camera, stops the preview, and hands the
/// file to [OcrService], which runs ML Kit on device with rotation /
/// contrast / center-crop probes. The captured photo is kept in
/// [capturedPhotoPath] so the review panel can show it next to the
/// editable PIN. A gallery image can be analyzed through the same path.
///
/// # Recharge / balance
///
/// Both run through [UssdService], which talks to `MainActivity`'s
/// `openUssd`: Android's `TelephonyManager.sendUssdRequest` returns the
/// network's own reply inside the app (displayed here in a dialog or the
/// balance panel). The phone dialer is never opened.
class HomeController extends ChangeNotifier {
  HomeController(
    this.provider,
    this._ocr,
    this._ussd,
    this._history, {
    this.resolveSubscriptionId,
  });

  final OcrService _ocr;
  final UssdService _ussd;
  final HistoryService _history;
  final ImagePicker _picker = ImagePicker();

  /// Resolves the user's chosen SIM subscription id for [provider]
  /// (from Settings). Returns null to use the device default SIM.
  final Future<int?> Function(TelecomProvider provider)? resolveSubscriptionId;

  /// Current interface strings. The Home screen refreshes this on every
  /// build, so status messages follow the language chosen in Settings.
  AppLocalizations? _l10n;

  set l10n(AppLocalizations value) {
    if (identical(_l10n, value)) return;
    _l10n = value;
    // A visible status was written in the previous language; clear it so
    // the UI never mixes two languages (the screen is rebuilding anyway).
    status = null;
  }

  AppLocalizations get l10n =>
      _l10n ?? lookupAppLocalizations(const Locale('en'));

  CameraController? camera;
  List<CameraDescription> _cameras = const [];

  HomeStage stage = HomeStage.idle;

  /// Currently selected provider.
  TelecomProvider provider;

  /// Best digit-run recognized on the latest photo.
  String candidate = '';

  /// What the editor shows while reviewing / confirming.
  final TextEditingController codeField = TextEditingController();

  /// Path of the photo the PIN came from (null for manual entry). Shown in
  /// the review panel — the image never leaves the device.
  String? capturedPhotoPath;

  bool get hasCapturedPhoto => capturedPhotoPath != null;

  bool confirmed = false;
  bool busy = false;
  bool dialInFlight = false;
  bool _disposed = false;

  /// Live OCR preview text (tidied) while scanning.
  String liveText = '';

  /// Status banner shown at the top of the Home screen content.
  HomeStatus? status;

  // ---- balance state (inline panel on Home) ----
  bool balanceBusy = false;

  /// The network's own balance reply text, shown verbatim.
  String? balanceReply;
  String? balanceError;
  DateTime? balanceCheckedAt;

  // ---- duplicate-recharge guard ----
  DateTime? _lastRechargeAt;
  String? _lastRechargePin;

  /// True when the same PIN was submitted less than 3 minutes ago.
  bool get isRecentDuplicate {
    final at = _lastRechargeAt;
    final pin = _lastRechargePin;
    if (at == null || pin == null) return false;
    final clean = UssdBuilder.sanitizeDigits(codeField.text);
    return clean == pin && DateTime.now().difference(at).inMinutes < 3;
  }

  // ---- automatic scanning plumbing ----
  Timer? _captureTimer;
  Timer? _kickoffTimer;
  static const _captureInterval = Duration(milliseconds: 1200);
  static const _firstCaptureDelay = Duration(milliseconds: 700);
  int _captureFailures = 0;
  static const _autoHintAfterFailures = 4;

  /// Guards only the auto-capture tick; the shutter and gallery use
  /// [busy]. Auto-capture must never freeze the UI — a slow OCR pass
  /// simply skips the next tick.
  bool _autoBusy = false;

  /// True while the live camera keeps re-shooting the card automatically.
  bool get autoCaptureActive =>
      stage == HomeStage.scanning && (_captureTimer?.isActive ?? false);

  /// True while an automatic shot is being captured / read.
  bool get isAutoAnalyzing => _autoBusy;

  // ------------------------------------------------------------------
  // Provider / status
  // ------------------------------------------------------------------

  void selectProvider(TelecomProvider value) {
    provider = value;
    balanceReply = null;
    balanceError = null;
    balanceCheckedAt = null;
    notifyListeners();
  }

  void _setStatus(HomeStatus? s) {
    status = s;
    notifyListeners();
  }

  void dismissStatus() => _setStatus(null);

  // ------------------------------------------------------------------
  // Camera + photo scanning
  // ------------------------------------------------------------------

  /// Requests camera permission and opens the live preview with auto-assist.
  Future<void> startLiveScan() async {
    if (busy) return;
    _setStatus(null);

    var permission = await Permission.camera.status;
    if (!permission.isGranted) {
      permission = await Permission.camera.request();
    }
    if (!permission.isGranted) {
      stage = HomeStage.idle;
      _setStatus(
        HomeStatus(l10n.statusCameraPermission, StatusKind.warning),
      );
      notifyListeners();
      return;
    }

    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isEmpty) {
        _setStatus(HomeStatus(l10n.statusNoCamera, StatusKind.error));
        return;
      }
      final backs = _cameras
          .where((c) => c.lensDirection == CameraLensDirection.back)
          .toList();
      final cam = backs.isNotEmpty ? backs.first : _cameras.first;

      capturedPhotoPath = null;
      candidate = '';
      codeField.clear();
      liveText = '';
      _captureFailures = 0;
      _autoBusy = false;
      _captureTimer?.cancel();
      _kickoffTimer?.cancel();

      final controller = CameraController(
        cam,
        // ultraHigh is plenty for voucher digits and takes noticeably
        // less time to capture+encode than ResolutionPreset.max on
        // modern phones (the still is downscaled to 1600px for OCR
        // anyway).
        ResolutionPreset.ultraHigh,
        enableAudio: false,
      );
      camera = controller;
      stage = HomeStage.scanning;
      notifyListeners();

      await controller.initialize();
      if (_disposed) {
        await controller.dispose();
        return;
      }
      _captureTimer?.cancel();
      _captureTimer = Timer.periodic(
        _captureInterval,
        (_) => _autoCaptureTick(),
      );
      // Start reading almost immediately instead of waiting for the first
      // periodic tick, so the user only has to point the camera at the card.
      _kickoffTimer?.cancel();
      _kickoffTimer = Timer(_firstCaptureDelay, _autoCaptureTick);
      notifyListeners();
    } on CameraException catch (e) {
      stage = HomeStage.idle;
      camera = null;
      _setStatus(
        HomeStatus(
          l10n.statusCameraStartFailed(e.description ?? e.code),
          StatusKind.error,
        ),
      );
      notifyListeners();
    }
  }

  /// The shutter: photograph the card, run OCR, and show the review panel.
  Future<void> takePhoto() async {
    if (busy) return;
    final controller = camera;
    if (controller == null || !controller.value.isInitialized) {
      _setStatus(
        HomeStatus(l10n.statusCameraNotOpen, StatusKind.warning),
      );
      return;
    }

    busy = true;
    notifyListeners();
    XFile? shot;
    try {
      shot = await controller.takePicture();
    } on CameraException catch (e) {
      busy = false;
      _setStatus(
        HomeStatus(
          l10n.statusPhotoFailed(e.description ?? e.code),
          StatusKind.error,
        ),
      );
      notifyListeners();
      return;
    }
    await _analyzePhoto(shot.path);
  }

  /// Picks an image from the gallery and analyzes it the same way.
  Future<void> pickFromGallery() async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      // Release the camera while the picker takes over the screen.
      await stopLiveScan(keepStage: true);
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
      );
      if (picked == null) {
        busy = false;
        if (stage == HomeStage.scanning) {
          // Reopen the preview so the user can continue scanning.
          await startLiveScan();
        }
        notifyListeners();
        return;
      }
      await _analyzePhoto(picked.path);
    } catch (err) {
      busy = false;
      _setStatus(
        HomeStatus(
          l10n.statusGalleryFailed(err.runtimeType.toString()),
          StatusKind.error,
        ),
      );
      notifyListeners();
    }
  }

  Future<void> _autoCaptureTick() async {
    if (stage != HomeStage.scanning || _disposed || busy || _autoBusy) {
      return;
    }
    final controller = camera;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture) return;

    _autoBusy = true;
    notifyListeners();
    try {
      final shot = await controller.takePicture();
      if (stage != HomeStage.scanning || _disposed) {
        _deleteQuietly(shot.path);
        return;
      }
      // dropIfBusy: if a previous auto pass is still running, this shot
      // is dropped — the preview never freezes.
      final recognition = await _ocr.processPhoto(shot.path, dropIfBusy: true);
      if (stage != HomeStage.scanning || _disposed) {
        _deleteQuietly(shot.path);
        return;
      }

      final best = _bestFrom(recognition);
      if (best == null) {
        _deleteQuietly(shot.path);
        _captureFailures++;
        if (_captureFailures >= _autoHintAfterFailures) {
          // Only add the hint when nothing else is being shown — never
          // overwrite a shutter/gallery error that explains what OCR saw.
          if (status == null) {
            _setStatus(
              HomeStatus(l10n.statusNoPinAuto, StatusKind.info),
            );
          }
          _captureFailures = 0;
        }
        return;
      }
      _adopt(best, shot.path);
    } catch (_) {
      // Next tick retries quietly; manual shutter remains available.
    } finally {
      _autoBusy = false;
      if (!_disposed && stage == HomeStage.scanning) notifyListeners();
    }
  }

  void _deleteQuietly(String path) {
    try {
      File(path).deleteSync();
    } catch (_) {
      // Best effort; OS cache will clean up.
    }
  }

  /// Shared analysis for shutter photos and gallery images.
  Future<void> _analyzePhoto(String path) async {
    busy = true;
    notifyListeners();
    try {
      final recognition = await _ocr.processPhoto(path);
      if (_disposed) return;

      liveText = recognition == null
          ? ''
          : tidyRecognizedText(recognition.rawText);
      final best = _bestFrom(recognition);
      if (best == null) {
        stage = HomeStage.scanning;
        final raw = liveText.length > 90
            ? '${liveText.substring(0, 90)}…'
            : liveText;
        final seen = liveText.isEmpty
            ? l10n.statusNothingReadable
            : l10n.statusReadThis(raw);
        _setStatus(
          HomeStatus(
            l10n.statusNoPinFromPhoto(seen),
            StatusKind.error,
          ),
        );
        return;
      }
      _adopt(best, path);
    } catch (err) {
      stage = HomeStage.scanning;
      _setStatus(
        HomeStatus(
          l10n.statusScanFailed(err.runtimeType.toString()),
          StatusKind.error,
        ),
      );
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void _adopt(CodeCandidate best, String photoPath) {
    capturedPhotoPath = photoPath;
    candidate = best.code;
    codeField.text = best.code;
    codeField.selection = TextSelection.collapsed(offset: best.code.length);
    unawaited(stopLiveScan(keepStage: true));
    stage = HomeStage.review;
    _setStatus(
      HomeStatus(l10n.statusPinRecognized, StatusKind.info),
    );
    notifyListeners();
  }

  CodeCandidate? _bestFrom(ScanRecognition? recognition) {
    if (recognition == null || !recognition.foundText) return null;
    // ignore: avoid_print
    print('OCR-C: lines=${recognition.lines}');
    final best = buildBestCandidate(recognition.lines);
    // ignore: avoid_print
    print('OCR-C: best=${best?.code} rank=${best?.rank}');
    return best;
  }

  /// Builds the best code candidate from recognized lines.
  ///
  /// Recharge PINs are printed as the largest number on the card, so every
  /// plausible digit run is compared numerically. Ethio telecom and
  /// Safaricom Ethiopia vouchers print a **14-digit** hidden PIN, so an
  /// exact 14-digit candidate always beats a longer misread serial. The
  /// provider's length window is tried first (fewer false positives from
  /// helpline numbers and serials); if nothing fits, the hard validation
  /// bounds 6–24 are used so an unusually short or long genuine PIN is
  /// still offered for review.
  CodeCandidate? buildBestCandidate(List<String> lines) {
    final text = lines.join('\n');
    final hint = provider.voucherLengthHint;
    return largestNumberCandidate(
          text,
          minLength: hint.min,
          maxLength: hint.max,
          preferredLength: 14,
        ) ??
        largestNumberCandidate(
          text,
          minLength: 6,
          maxLength: 24,
          preferredLength: 14,
        );
  }

  /// Retake: drop the photo result and reopen the camera.
  Future<void> retakePhoto() async {
    capturedPhotoPath = null;
    candidate = '';
    codeField.clear();
    liveText = '';
    await startLiveScan();
  }

  /// Stops the preview and releases the camera.
  Future<void> stopLiveScan({bool keepStage = false}) async {
    _captureTimer?.cancel();
    _captureTimer = null;
    _kickoffTimer?.cancel();
    _kickoffTimer = null;
    final controller = camera;
    camera = null;
    try {
      if (controller?.value.isInitialized ?? false) {
        await controller!.dispose();
      }
    } on CameraException {
      // Ignore teardown races.
    }
    if (!keepStage && stage == HomeStage.scanning) {
      stage = HomeStage.idle;
    }
    notifyListeners();
  }

  bool get torchOn => camera?.value.flashMode == FlashMode.torch;

  /// Enables/disables the torch while scanning.
  Future<void> setTorch(bool on) async {
    final c = camera;
    if (c == null || !c.value.isInitialized) return;
    try {
      final flash = on ? FlashMode.torch : FlashMode.off;
      if (c.value.flashMode != flash) {
        await c.setFlashMode(flash);
      }
      notifyListeners();
    } on CameraException {
      // Torch unsupported — silently ignore.
    }
  }

  // ------------------------------------------------------------------
  // Review / confirmation
  // ------------------------------------------------------------------

  /// Check before confirmation. Returns a message when the code is
  /// implausible.
  ///
  /// No provider-specific digit-count rules are officially documented
  /// (they vary by card batch/denomination), so validation stays generic:
  /// digits only; hard bounds 6–24 digits. A length outside the provider's
  /// typical window is a *warning*, not a block — the copy on the card
  /// says "or continue if you are sure".
  String? validateCode() {
    final clean = UssdBuilder.sanitizeDigits(codeField.text);
    if (clean.isEmpty) {
      return l10n.validationEnterPin;
    }
    if (clean.length < 6) {
      return l10n.validationTooShort;
    }
    if (clean.length > 24) {
      return l10n.validationTooLong;
    }
    return null;
  }

  /// Soft warning when [clean] is outside the provider's typical length
  /// window. Not a block — the user may continue if the card says so.
  String? unusualLengthWarning(String clean) {
    final hint = provider.voucherLengthHint;
    if (clean.length < hint.min || clean.length > hint.max) {
      return l10n.validationUnusualLength(hint.min, hint.max);
    }
    return null;
  }

  /// Requires the user's explicit confirmation before any recharge: press
  /// Confirm → the code locks and the Recharge button becomes available.
  ///
  /// Returns `true` when the code passed validation and the stage is now
  /// [HomeStage.ready]. The Home screen uses that to run the recharge
  /// automatically after the single confirmation.
  Future<bool> confirmCode() async {
    final message = validateCode();
    if (message != null) {
      _setStatus(HomeStatus(message, StatusKind.error));
      return false;
    }
    final clean = UssdBuilder.sanitizeDigits(codeField.text);
    codeField.text = clean;
    codeField.selection = TextSelection.collapsed(offset: clean.length);
    candidate = clean;
    confirmed = true;
    stage = HomeStage.ready;
    final warning = unusualLengthWarning(clean);
    _setStatus(
      warning == null ? null : HomeStatus(warning, StatusKind.warning),
    );
    await _history.addScan(provider, clean, DateTime.now());
    notifyListeners();
    return true;
  }

  /// Goes back to editing from the ready stage.
  void editAgain() {
    stage = HomeStage.review;
    confirmed = false;
    notifyListeners();
  }

  /// Starts manual code entry: empty field in the review stage.
  Future<void> startManualEntry() async {
    await stopLiveScan(keepStage: true);
    stage = HomeStage.review;
    confirmed = false;
    capturedPhotoPath = null;
    candidate = '';
    codeField.clear();
    liveText = '';
    _setStatus(null);
    notifyListeners();
  }

  /// Stops everything and shows the idle card again.
  Future<void> returnToIdle() async {
    await stopLiveScan(keepStage: true);
    stage = HomeStage.idle;
    _setStatus(null);
    notifyListeners();
  }

  /// Discards the current code and returns to the idle card.
  Future<void> clearAll() async {
    await stopLiveScan(keepStage: true);
    stage = HomeStage.idle;
    candidate = '';
    confirmed = false;
    capturedPhotoPath = null;
    codeField.clear();
    liveText = '';
    _setStatus(null);
    notifyListeners();
  }

  /// Resolves the chosen SIM subscription id for the current provider
  /// (null = device default).
  Future<int?> _resolveSubId() async {
    final resolve = resolveSubscriptionId;
    if (resolve == null) return null;
    try {
      return await resolve(provider);
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------------
  // Recharge (USSD)
  // ------------------------------------------------------------------

  /// Runs the recharge USSD session for the confirmed code.
  ///
  /// Android asks the network directly with `TelephonyManager
  /// .sendUssdRequest`: whenever the device supports it, the *network's own
  /// answer* comes back into this app (shown in a dialog); no other app is
  /// opened. If the device refuses, the carrier's system pop-up appears
  /// over this app (direct dial) — the phone dialer is never opened.
  /// Saricom never claims the recharge succeeded.
  Future<UssdOutcome> recharge() async {
    if (dialInFlight) {
      return const UssdOutcome(UssdLaunch.failed, details: 'in-flight');
    }
    dialInFlight = true;
    busy = true;
    notifyListeners();

    UssdOutcome outcome;
    try {
      final code = UssdBuilder.recharge(provider, codeField.text);
      final subId = await _resolveSubId();
      outcome = await _ussd.dial(code, subscriptionId: subId);
    } on ArgumentError {
      outcome = const UssdOutcome(UssdLaunch.failed, details: 'invalid code');
      _setStatus(
        HomeStatus(
          l10n.statusPinTooShortForRecharge,
          StatusKind.error,
        ),
      );
      dialInFlight = false;
      busy = false;
      notifyListeners();
      return outcome;
    }

    if (outcome.launch == UssdLaunch.ussdResponse ||
        outcome.launch == UssdLaunch.direct) {
      _lastRechargePin = UssdBuilder.sanitizeDigits(codeField.text);
      _lastRechargeAt = DateTime.now();
    }

    switch (outcome.launch) {
      case UssdLaunch.ussdResponse:
        _setStatus(
          HomeStatus(l10n.statusNetworkAnswered, StatusKind.success),
        );
        break;
      case UssdLaunch.direct:
        _setStatus(
          HomeStatus(
            l10n.statusDirectRecharge(provider.label),
            StatusKind.info,
          ),
        );
        break;
      case UssdLaunch.blocked:
        _setStatus(
          HomeStatus(
            l10n.statusRechargeBlocked(appName),
            StatusKind.error,
          ),
        );
        break;
      case UssdLaunch.manual:
        _setStatus(
          HomeStatus(l10n.statusRechargeManual, StatusKind.warning),
        );
        break;
      case UssdLaunch.failed:
        _setStatus(
          HomeStatus(l10n.statusRechargeFailed, StatusKind.error),
        );
        break;
    }

    dialInFlight = false;
    busy = false;
    notifyListeners();
    return outcome;
  }

  // ------------------------------------------------------------------
  // Balance (USSD, inline panel)
  // ------------------------------------------------------------------

  /// Runs the provider's balance USSD session and stores the network reply
  /// for the inline balance panel on the Home screen.
  ///
  /// Where the device supports in-app USSD the network's own text is shown
  /// verbatim; otherwise a clear explanation is stored ([balanceError]) —
  /// a balance is never invented, and no external app is opened. Errors
  /// stay inline — no pop-up dialog interrupts the user.
  Future<UssdOutcome> checkBalance() async {
    if (balanceBusy) {
      return const UssdOutcome(UssdLaunch.failed, details: 'in-flight');
    }
    balanceBusy = true;
    busy = true;
    balanceReply = null;
    balanceError = null;
    balanceCheckedAt = null;
    notifyListeners();

    UssdOutcome outcome;
    try {
      final subId = await _resolveSubId();
      outcome = await _ussd.dial(
        UssdBuilder.balance(provider),
        subscriptionId: subId,
      );
    } catch (_) {
      outcome = const UssdOutcome(UssdLaunch.failed);
    }

    balanceCheckedAt = DateTime.now();
    switch (outcome.launch) {
      case UssdLaunch.ussdResponse:
        final reply = outcome.response?.trim();
        if (reply == null || reply.isEmpty) {
          balanceError = l10n.balanceNoText;
        } else if (_looksLikeSmsInsteadOfUssd(reply)) {
          // Carrier replied with an SMS (balance sent to inbox) instead
          // of an in-session USSD answer. Tell the user where to look.
          balanceError = l10n.balanceViaSms(provider.label);
        } else {
          balanceReply = reply;
          _setStatus(null);
        }
        break;
      case UssdLaunch.direct:
        balanceError = l10n.balanceDirect(provider.label);
        break;
      case UssdLaunch.blocked:
        balanceError = l10n.balanceBlocked(appName);
        break;
      case UssdLaunch.manual:
        balanceError = l10n.balanceManual;
        break;
      case UssdLaunch.failed:
        balanceError = l10n.balanceFailed;
        break;
    }

    balanceBusy = false;
    busy = false;
    notifyListeners();
    return outcome;
  }

  /// True when the carrier reply looks like an SMS redirect rather than a
  /// live USSD answer (e.g. "You will receive an SMS with your balance").
  static bool _looksLikeSmsInsteadOfUssd(String reply) {
    final lower = reply.toLowerCase();
    return lower.contains('sms') ||
        lower.contains('text message') ||
        lower.contains('check your message') ||
        lower.contains('inbox');
  }

  // ------------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------------

  /// Release the camera whenever the app leaves the foreground.
  void onAppLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        if (stage == HomeStage.scanning && camera != null) {
          unawaited(stopLiveScan(keepStage: true));
          stage = HomeStage.idle;
          notifyListeners();
        }
        break;
      case AppLifecycleState.resumed:
        break;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _captureTimer?.cancel();
    _captureTimer = null;
    _kickoffTimer?.cancel();
    _kickoffTimer = null;
    final controller = camera;
    camera = null;
    if (controller != null) {
      try {
        if (controller.value.isInitialized) {
          controller.dispose();
        }
      } on CameraException {
        // Already gone.
      }
    }
    codeField.dispose();
    super.dispose();
  }
}
