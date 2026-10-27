import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

import '../logic/code_parser.dart';

/// Result of one recognition pass over a photo.
class ScanRecognition {
  const ScanRecognition({
    required this.rawText,
    required this.lines,
    required this.extraRotation,
    required this.enhanced,
  });

  /// Raw text exactly as recognized (may hold spaces and line breaks).
  final String rawText;

  /// Individual recognized lines (trimmed, non-empty) in reading order.
  final List<String> lines;

  /// Additional rotation (0/90/180/270, on top of EXIF correction) that
  /// produced the best digits, cached for the next photo.
  final int extraRotation;

  /// True when a contrast-normalized copy recognized better than the raw
  /// photo (dim cards, shadows).
  final bool enhanced;

  bool get foundText => lines.isNotEmpty;

  /// Crude confidence proxy: how many digit characters were read.
  int get digitScore => _digitCount(rawText);

  static int _digitCount(String text) {
    var count = 0;
    for (final unit in text.codeUnits) {
      if (unit >= 0x30 && unit <= 0x39) count++;
    }
    return count;
  }
}

/// Runs on-device ML Kit text recognition over card photos.
///
/// Design notes (why this is fast *and* reliable):
///
/// * The scanner uses real still photos, not camera frame streams. Frame
///   streams need device-specific NV21 conversion and orientation
///   guesses that fail silently on a range of phones; photos carry
///   correct rotation metadata and are what this workflow actually needs.
/// * Every photo is decoded once, EXIF-rotated in memory, then **downscaled
///   to 1600 px** before any recognition pass. Modern phones capture
///   12–48 MP stills; feeding those to ML Kit as-is is what made scans
///   slow. 1600 px keeps voucher digits well above the recognizer's
///   resolution floor while cutting each pass to a fraction of the time.
/// * The common case is a **single pass**: upright, downscaled. Probes
///   stop as soon as a convincing digit run (≥ 10 digits) appears, so a
///   well-aimed photo is recognized in one go.
/// * Only when the first pass is weak do up to three extra probes run:
///   the preferred orientation, and contrast-normalized center crops
///   that kill busy backgrounds.
///
/// No image or text ever leaves the device — the recognizer is the
/// bundled on-device Google ML Kit model, and probe files are deleted
/// immediately after they are read.
class OcrService {
  OcrService() {
    _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  late final TextRecognizer _recognizer;

  /// The in-flight recognition, if any (used to queue or drop captures).
  Future<ScanRecognition?>? _active;

  /// Rotation (0/90/180/270) that worked last time.
  int _preferredRotation = 0;

  /// A *single* recognized digit run this long means the PIN was read:
  /// voucher PINs are 14–15 digits, so a clean run of 10+ digits is a
  /// real PIN. Counting digits across the whole text is not enough —
  /// denominations, dates and serial fragments easily add up to 10
  /// digits while the actual PIN line was misread.
  static const int _convincingPinDigits = 10;

  /// Downscale target. Voucher digits fill the frame (the scan overlay
  /// says so), so 1600 px is far more than enough for ML Kit.
  static const int _maxProbeWidth = 1600;

  /// Maximum derived probes after the fast first pass.
  static const int _maxExtraProbes = 3;

  /// Recognizes one card photo.
  ///
  /// With [dropIfBusy] (auto-capture) the call returns `null` while a
  /// previous pass is still running, so automatic attempts are dropped
  /// rather than queued. The manual shutter and gallery pass
  /// [dropIfBusy] = false and simply wait for the running pass.
  Future<ScanRecognition?> processPhoto(
    String path, {
    bool dropIfBusy = false,
  }) {
    final previous = _active;
    if (dropIfBusy && previous != null) return Future.value(null);
    final run = (previous ?? Future<ScanRecognition?>.value())
        .catchError((_) => null)
        .then((_) => _runProbes(path));
    _active = run;
    return run;
  }

  Future<ScanRecognition?> _runProbes(String path) async {
    // Decode once; all probes derive from this upright, downscaled bitmap.
    img.Image? work;
    try {
      final raw = await img.decodeJpgFile(path);
      final upright = raw == null ? null : img.bakeOrientation(raw);
      work = upright == null ? null : _downscale(upright, _maxProbeWidth);
      // ignore: avoid_print
      print('OCR: decoded=${raw != null} size=${work?.width}x${work?.height}');
    } catch (e) {
      // ignore: avoid_print
      print('OCR: decode failed: $e');
      work = null;
    }

    if (work == null) {
      // Undecodable file — try ML Kit directly on the path as a last
      // resort (it handles formats the `image` package may not).
      final direct = await _readProbe(
        _Probe(path, rotation: 0, enhanced: false, temporary: false),
      );
      // ignore: avoid_print
      print(
        'OCR: direct fallback result=${direct?.digitScore} '
        'lines=${direct?.lines.length}',
      );
      return direct ?? _empty();
    }

    ScanRecognition? best;

    // Fast path: one upright pass. A clear, well-aimed photo finishes
    // here in ~200–400 ms on a mid-range phone.
    final first = await _derivedProbe(
      path,
      work,
      0,
      enhanced: false,
      centerCrop: false,
    );
    best = await _readProbe(first);
    if (best != null && _pinLength(best.rawText) >= _convincingPinDigits) {
      _preferredRotation = 0;
      return best;
    }

    // Slow path: only when the first pass found no PIN-sized run —
    // blurry, dim or skewed cards.
    final rotations = _rotationOrder();
    final extra = <Future<_Probe>>[
      // Preferred rotation (sideways/upside-down cards).
      _derivedProbe(
        path,
        work,
        rotations.first,
        enhanced: false,
        centerCrop: false,
      ),
      // Contrast-normalized center crops (dim cards, busy backgrounds).
      _derivedProbe(
        path,
        work,
        rotations.first,
        enhanced: true,
        centerCrop: true,
      ),
      _derivedProbe(path, work, rotations[1], enhanced: true, centerCrop: true),
    ];

    for (var i = 0; i < _maxExtraProbes && i < extra.length; i++) {
      final probe = await extra[i];
      final result = await _readProbe(probe);
      if (result == null) continue;
      if (_better(result, best)) best = result;
      final current = best;
      if (current != null &&
          _pinLength(current.rawText) >= _convincingPinDigits) {
        break;
      }
    }

    if (best != null) {
      _preferredRotation = best.extraRotation;
      return best;
    }
    return _empty();
  }

  /// True when [candidate] is a better read than [current]: a longer
  /// single digit run (the PIN) wins first; total digit count only
  /// breaks ties.
  static bool _better(ScanRecognition candidate, ScanRecognition? current) {
    if (current == null) return true;
    final c = _pinLength(candidate.rawText);
    final p = _pinLength(current.rawText);
    if (c != p) return c > p;
    return candidate.digitScore > current.digitScore;
  }

  /// Length of the best voucher-shaped digit run the parser would pick
  /// from [rawText]; 0 when none exists. Mirrors the app's selection
  /// rule (largest number, 14-digit preference) so probe scoring agrees
  /// with what the user will finally see.
  static int _pinLength(String rawText) {
    final candidate = largestNumberCandidate(
      rawText,
      minLength: 6,
      maxLength: 24,
      preferredLength: 14,
    );
    return candidate?.code.length ?? 0;
  }

  static ScanRecognition _empty() => const ScanRecognition(
    rawText: '',
    lines: [],
    extraRotation: 0,
    enhanced: false,
  );

  /// Preferred rotation first, then the rest.
  List<int> _rotationOrder() {
    final all = <int>[0, 90, 180, 270];
    final preferred = _preferredRotation;
    if (preferred == 0) return all;
    return [preferred, ...all.where((d) => d != preferred)];
  }

  /// Longest-side downscale that keeps memory and ML Kit input small.
  static img.Image _downscale(img.Image source, int maxSide) {
    if (source.width <= maxSide && source.height <= maxSide) return source;
    final scale =
        maxSide / (source.width > source.height ? source.width : source.height);
    return img.copyResize(
      source,
      width: (source.width * scale).round(),
      interpolation: img.Interpolation.linear,
    );
  }

  /// Encodes one derived probe (rotated / enhanced / cropped) to a temp
  /// file next to the original. Returns a non-sendable probe when the
  /// transform fails, and the loop simply skips it.
  Future<_Probe> _derivedProbe(
    String originalPath,
    img.Image base,
    int degrees, {
    required bool enhanced,
    required bool centerCrop,
  }) async {
    try {
      var work = degrees == 0 ? base : img.copyRotate(base, angle: degrees);

      if (centerCrop) {
        final w = (work.width * 0.72).round();
        final h = (work.height * 0.55).round();
        work = img.copyCrop(
          work,
          x: ((work.width - w) / 2).round(),
          y: ((work.height - h) / 2).round(),
          width: w,
          height: h,
        );
      }

      if (enhanced) {
        work = img.grayscale(work);
        work = img.adjustColor(work, contrast: 125, gamma: 0.9);
      }

      final original = File(originalPath);
      final name = original.uri.pathSegments.last;
      final target =
          '${original.parent.path}${Platform.pathSeparator}ocr_probe_'
          '${degrees}_${enhanced ? 'e' : 'r'}${centerCrop ? 'c' : ''}_$name';
      // 1600 px probes at q85 are small enough to encode in ~20–50 ms.
      await img.encodeJpgFile(target, work, quality: 85);

      return _Probe(
        target,
        rotation: degrees,
        enhanced: enhanced,
        temporary: true,
      );
    } catch (e) {
      // ignore: avoid_print
      print('OCR: derived probe failed: $e');
      return const _Probe(null, rotation: 0, enhanced: false, temporary: false);
    }
  }

  Future<ScanRecognition?> _readProbe(_Probe probe) async {
    if (probe.file == null) return null;
    try {
      final inputImage = InputImage.fromFilePath(probe.file!);
      final found = await _recognizer.processImage(inputImage);
      final lines = _linesOf(found.text);
      if (lines.isEmpty) return null;
      return ScanRecognition(
        rawText: found.text,
        lines: lines,
        extraRotation: probe.rotation,
        enhanced: probe.enhanced,
      );
    } catch (e) {
      // ignore: avoid_print
      print('OCR: MLKit failed: $e');
      return null;
    } finally {
      if (probe.temporary) {
        try {
          await File(probe.file!).delete();
        } catch (_) {
          // Temp files also die with the OS cache.
        }
      }
    }
  }

  List<String> _linesOf(String text) {
    final lines = <String>[];
    for (final line in text.split(RegExp(r'\r?\n'))) {
      final t = line.trim();
      if (t.isNotEmpty) lines.add(t);
    }
    return lines;
  }

  void dispose() {
    try {
      _recognizer.close();
    } catch (_) {
      // In tests or hot restarts the channel may be missing; safe to ignore.
    }
  }
}

/// One recognition attempt: a file plus the transform that produced it.
class _Probe {
  const _Probe(
    this.file, {
    required this.rotation,
    required this.enhanced,
    required this.temporary,
  });

  final String? file;
  final int rotation;
  final bool enhanced;
  final bool temporary;
}
