/// Pure-Dart helpers that turn raw OCR text into plausible recharge codes.
///
/// Recharge cards print the hidden voucher number as one long digit run,
/// often grouped by spaces or across two lines (e.g. `1234 5678 9012 345`).
/// OCR commonly splits such runs with stray spaces, interleaves them with
/// card text ("airtime", "50 Birr", "Card No.") and occasionally prints
/// digits as similar letters (O→0, I→1, S→5, B→8 …).
///
/// The parser therefore:
///  1. reads each line into digit segments (words with 2+ consecutive
///     non-alias letters are treated as text, never as digits),
///  2. emits candidate codes in a clearly ranked order:
///     priority 1 = longest clean digit segment of the line,
///     priority 2 = merge of consecutive clean groups on one line,
///     priority 3 = alias-substituted segments (only when nothing better),
///  3. never merges across lines.
library;

/// Conservative OCR letter→digit substitutions.
///
/// Only common glyph confusions are mapped; ambiguous ones are excluded.
/// `(O o D) → 0`, `(I i l |) → 1`, `Z z → 2`, `E → 3`, `A → 4`,
/// `(S s) → 5`, `G b → 6`, `T → 7`, `B → 8`, `g q → 9`.
const Map<String, String> ocrDigitAliases = {
  'O': '0',
  'o': '0',
  'D': '0',
  'I': '1',
  'i': '1',
  'l': '1',
  '|': '1',
  'Z': '2',
  'z': '2',
  'E': '3',
  'A': '4',
  'S': '5',
  's': '5',
  'G': '6',
  'b': '6',
  'T': '7',
  'B': '8',
  'g': '9',
  'q': '9',
};

/// Maximum digits a plausible voucher code can have.
const int maxVoucherDigits = 24;

/// One digit segment read from a line.
class OcrSegment {
  OcrSegment({
    required this.digits,
    required this.hasAlias,
    required this.sourceLine,
  });

  /// Digit characters only.
  final String digits;

  /// True when letter→digit substitutions were applied.
  final bool hasAlias;
  final String? sourceLine;
}

/// A candidate voucher code extracted from one OCR line.
class CodeCandidate {
  const CodeCandidate({
    required this.code,
    required this.sourceLine,
    required this.rank,
    required this.confidenceHint,
  });

  /// Digits only (no spaces or line breaks).
  final String code;

  /// The original OCR line the code came from.
  final String? sourceLine;

  /// 1 = clean long run, 2 = merged groups, 3 = alias-substituted.
  final int rank;

  /// Informal correctness hint, 0..1 (rank based).
  final double confidenceHint;
}

/// Splits one OCR line into digit segments using whitespace as the
/// tokenizer boundary and handling alias substitutions per segment.
List<OcrSegment> segmentsFromLine(String line, {bool aggressive = true}) {
  final segments = <OcrSegment>[];

  for (final token in line.trim().split(RegExp(r'\s+'))) {
    if (token.isEmpty) continue;

    // Veto heavy text tokens: two consecutive non-alias letters mean the
    // token is a word ('Card', 'Birr') whose letters must not leak into
    // digit form ('Card' would otherwise become '…40…').
    var consecutiveNonAlias = 0;
    var isText = false;
    for (final ch in token.runes) {
      final c = String.fromCharCode(ch);
      final alias = c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;
      if (!alias && !(aggressive && ocrDigitAliases.containsKey(c))) {
        consecutiveNonAlias++;
        if (consecutiveNonAlias >= 2) {
          isText = true;
          break;
        }
      } else {
        consecutiveNonAlias = 0;
      }
    }
    if (isText) continue;

    // Collect maximal digit runs inside the (possibly substituted) token.
    final out = StringBuffer();
    var usedAlias = false;
    void flush() {
      if (out.length >= 3) {
        segments.add(
          OcrSegment(
            digits: out.toString(),
            hasAlias: usedAlias,
            sourceLine: line,
          ),
        );
      }
      out.clear();
      usedAlias = false;
    }

    for (final ch in token.runes) {
      final c = String.fromCharCode(ch);
      final isDigit = c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;
      if (isDigit) {
        out.write(c);
      } else if (aggressive && ocrDigitAliases.containsKey(c)) {
        out.write(ocrDigitAliases[c]!);
        usedAlias = true;
      } else {
        flush();
      }
    }
    flush();
  }

  return segments;
}

/// Builds ranked [CodeCandidate]s from recognized lines.
List<CodeCandidate> buildCandidates(
  List<String> lines, {
  int minLength = 10,
  int maxLength = maxVoucherDigits,
}) {
  final candidates = <CodeCandidate>[];

  void consider(String merged, String? line, int rank) {
    if (merged.length >= minLength &&
        merged.length <= maxLength &&
        !candidates.any((c) => c.code == merged)) {
      candidates.add(
        CodeCandidate(
          code: merged,
          sourceLine: line,
          rank: rank,
          confidenceHint: (1 - (rank - 1) * 0.25).clamp(0.0, 1.0),
        ),
      );
    }
  }

  for (final line in lines) {
    final segments = segmentsFromLine(line);
    if (segments.isEmpty) continue;

    // Priority 1: the longest clean segment in the line.
    final clean = segments
        .where((s) => !s.hasAlias && s.digits.length >= 3)
        .toList();
    if (clean.isNotEmpty) {
      final longest = clean.reduce(
        (a, b) => a.digits.length >= b.digits.length ? a : b,
      );
      consider(longest.digits, line, 1);

      // Priority 2: merges of consecutive clean groups (e.g. the voucher
      // printed as `1234 5678 9012 345`).
      var run = <String>[];
      void flushRun() {
        // Leading 1–2 digit groups are usually denominations or page
        // numbers glued onto the voucher line; drop them from merges.
        while (run.isNotEmpty && run.first.length <= 2) {
          run.removeAt(0);
        }
        if (run.length >= 2) {
          // Individual group sizes stay visible in the audit trail here:
          // groups of '0'/'00'/'000' indicate a stray separator too, and
          // trailing single digits belong to the voucher itself.
          if (run.any((g) => g == '000' || g == '00' || g == '0')) {
            // All-zero group looks like OCR noise — skip this merge.
          } else {
            consider(run.join(), line, 2);
          }
        }
      }

      for (final s in segments) {
        if (!s.hasAlias && s.digits.length >= 3) {
          run.add(s.digits);
        } else {
          flushRun();
        }
      }
      if (run.length >= 2) {
        flushRun();
      } else {
        run.clear();
      }
    }

    // Priority 3: alias-substituted segments (whole digits can appear as
    // letters when the print is faint).
    for (final s in segments.where((s) => s.hasAlias && s.digits.length >= 3)) {
      consider(s.digits, line, 3);
    }
  }

  candidates.sort((a, b) {
    final byRank = a.rank.compareTo(b.rank);
    if (byRank != 0) return byRank;
    return b.code.length.compareTo(a.code.length);
  });
  return candidates;
}

/// Best single code candidate for a whole OCR text, or `null`.
CodeCandidate? bestCandidate(
  String rawText, {
  int minLength = 10,
  int maxLength = maxVoucherDigits,
}) {
  final candidates = buildCandidates(
    rawText.split(RegExp(r'\r?\n')),
    minLength: minLength,
    maxLength: maxLength,
  );
  return candidates.isEmpty ? null : candidates.first;
}

/// Numeric comparison of two digit strings (leading zeros ignored).
///
/// Returns a positive number when [a] is numerically larger than [b].
int compareDigitValue(String a, String b) {
  final sa = a.replaceFirst(RegExp(r'^0+'), '');
  final sb = b.replaceFirst(RegExp(r'^0+'), '');
  if (sa.length != sb.length) return sa.length.compareTo(sb.length);
  return sa.compareTo(sb);
}

/// The **largest number** printed in the OCR text within the allowed digit
/// bounds, optionally biased toward the typical voucher PIN length.
///
/// Recharge card PINs are the longest printed numbers on the card (grouped
/// as `1234 5678 9012 34`). Serial numbers, SMS short codes and
/// denominations are normally shorter. This helper therefore ranks all
/// parser candidates by their numeric value, not by the parser's textual
/// rank, which makes the scan deterministic for the user's requirement:
/// “pick the largest number as the PIN”.
///
/// Ethio telecom and Safaricom Ethiopia vouchers print a **14-digit**
/// hidden PIN. When [preferredLength] is given and any candidate has
/// exactly that length, only those candidates are considered — so a
/// genuine 14-digit PIN beats a longer misread serial, while cards whose
/// PIN was only partially read still fall back to the overall largest.
CodeCandidate? largestNumberCandidate(
  String rawText, {
  int minLength = 10,
  int maxLength = maxVoucherDigits,
  int? preferredLength,
}) {
  final candidates = buildCandidates(
    rawText.split(RegExp(r'\r?\n')),
    minLength: minLength,
    maxLength: maxLength,
  );
  if (candidates.isEmpty) return null;

  var pool = candidates;
  if (preferredLength != null) {
    final exact = candidates
        .where((c) => c.code.length == preferredLength)
        .toList();
    if (exact.isNotEmpty) pool = exact;
  }

  CodeCandidate largest = pool.first;
  for (final candidate in pool.skip(1)) {
    if (compareDigitValue(candidate.code, largest.code) > 0) {
      largest = candidate;
    }
  }
  return largest;
}

/// Formats a digit string into display groups, e.g. `1234 5678 9012`.
String formatCode(String digits, {int groupSize = 4}) {
  final clean = digits.replaceAll(RegExp(r'[^0-9]'), '');
  final buffer = StringBuffer();
  for (var i = 0; i < clean.length; i++) {
    if (i > 0 && i % groupSize == 0) buffer.write(' ');
    buffer.write(clean[i]);
  }
  return buffer.toString();
}

/// Whitespace-cleaned version of [text] that keeps single spaces between
/// digit groups (used for the "raw recognized" preview).
String tidyRecognizedText(String text) {
  return text
      .split(RegExp(r'\r?\n'))
      .map((l) => l.trim().replaceAll(RegExp(r'\s{2,}'), ' '))
      .where((l) => l.isNotEmpty)
      .join(' · ');
}
