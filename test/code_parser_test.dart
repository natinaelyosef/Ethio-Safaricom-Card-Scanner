import 'package:flutter_test/flutter_test.dart';
import 'package:saricom/logic/code_parser.dart';

void main() {
  group('segmentsFromLine', () {
    test('splits voucher groups into clean segments', () {
      final segments = segmentsFromLine('1234 5678 9012 345');
      expect(segments.map((s) => s.digits), ['1234', '5678', '9012', '345']);
      expect(segments.every((s) => !s.hasAlias), isTrue);
    });

    test('ignores short numbers like denominations', () {
      final segments = segmentsFromLine('Card 50 Br 1234567890123');
      expect(segments.map((s) => s.digits), ['1234567890123']);
    });

    test('substitutes obvious OCR letter confusions in near-digit tokens', () {
      final segments = segmentsFromLine('OI0O1OIOI0O1');
      expect(segments, hasLength(1));
      expect(segments.single.digits, '010010101001');
      expect(segments.single.hasAlias, isTrue);
    });

    test('never turns words like Card or Birr into digits', () {
      expect(segmentsFromLine('Card Birr airtime voucher'), isEmpty);
    });

    test('remote words keep their digits only in pure-digit tokens', () {
      final segments = segmentsFromLine('PIN 50091234561234#');
      expect(segments.map((s) => s.digits), ['50091234561234']);
    });

    test('aggressive disabled keeps raw digits', () {
      final segments = segmentsFromLine('1234567', aggressive: false);
      expect(segments.map((s) => s.digits), ['1234567']);
    });
  });

  group('buildCandidates', () {
    test('merges same-line groups into one candidate', () {
      final candidates = buildCandidates(
        ['1234 5678 9012 345'],
        minLength: 10,
        maxLength: 20,
      );
      expect(candidates, isNotEmpty);
      expect(candidates.first.code, '123456789012345');
      expect(candidates.first.rank, 2);
    });

    test('prefers a clean long run over merged noise', () {
      final candidates = buildCandidates(
        ['Card No. 99 · 4567890123456'],
        minLength: 10,
        maxLength: 20,
      );
      expect(candidates.first.code, '4567890123456');
      expect(candidates.first.rank, 1);
    });

    test('drops leading short groups when merging', () {
      final candidates = buildCandidates(
        ['50 1234 5678 9012 340'],
        minLength: 10,
        maxLength: 20,
      );
      expect(candidates.first.code, '123456789012340');
    });

    test('rejects candidates outside the length window', () {
      final candidates = buildCandidates(
        ['123456789012345678901234567890'],
        minLength: 10,
        maxLength: 20,
      );
      expect(candidates, isEmpty);
    });
  });

  group('bestCandidate', () {
    test('returns the longest clean code across lines', () {
      final best = bestCandidate(
        'PIN 50091234561234\n09 8765 4321\n1234567890123',
        minLength: 10,
      );
      // Both clean rank-1 runs are candidates; the longer wins.
      expect(best?.code, '50091234561234');
      expect(best?.sourceLine, 'PIN 50091234561234');
    });

    test('falls back to alias segments only when nothing clean', () {
      final best = bestCandidate('voucher\nOI0O1OIOI0O1OIO', minLength: 10);
      expect(best?.code, '010010101001010');
      expect(best?.rank, 3);
    });

    test('returns null when nothing readable', () {
      expect(bestCandidate('Scratch here ✋ Иь{} ', minLength: 10), isNull);
    });
  });

  group('largestNumberCandidate', () {
    test('picks the numerically largest eligible number', () {
      final best = largestNumberCandidate(
        'Card no 123456789012\nBackup 987654321098',
      );
      expect(best?.code, '987654321098');
    });

    test('merges grouped voucher digits and beats short card numbers', () {
      final best = largestNumberCandidate(
        '50 Birr\nPIN 1234 5678 9012 345\nCall 8040',
      );
      expect(best?.code, '123456789012345');
    });

    test('respects the digit bounds', () {
      expect(
        largestNumberCandidate('12345', minLength: 10, maxLength: 20),
        isNull,
      );
      expect(
        largestNumberCandidate(
          '1234567890123456789012345',
          minLength: 10,
          maxLength: 20,
        ),
        isNull,
      );
    });

    test('ignores leading zeros when comparing values', () {
      final best = largestNumberCandidate(
        '000000000000000123\n456789012345',
        minLength: 10,
        maxLength: 20,
      );
      expect(best?.code, '456789012345');
    });

    test('prefers an exact 14-digit candidate over a larger one', () {
      // 16-digit serial is numerically larger, but the real PIN is 14.
      final best = largestNumberCandidate(
        'Serial 998877665544332211\nPIN 12345678901234',
        minLength: 10,
        maxLength: 20,
        preferredLength: 14,
      );
      expect(best?.code, '12345678901234');
    });

    test('falls back to largest when no 14-digit candidate exists', () {
      final best = largestNumberCandidate(
        'Card 9988776655443322\nBackup 1111111111111111',
        minLength: 10,
        maxLength: 20,
        preferredLength: 14,
      );
      // No candidate is exactly 14 digits; the largest overall wins.
      expect(best?.code, '9988776655443322');
    });

    test('preferredLength ignored when nothing matches it', () {
      final best = largestNumberCandidate(
        '123456789012345678\n999999999999',
        minLength: 10,
        maxLength: 20,
        preferredLength: 14,
      );
      expect(best?.code, '123456789012345678');
    });
  });

  group('formatCode', () {
    test('groups digits in fours', () {
      expect(formatCode('1234567890123'), '1234 5678 9012 3');
      expect(formatCode('12345678'), '1234 5678');
    });

    test('strips non-digits along the way', () {
      expect(formatCode('12-34'), '1234');
    });
  });

  group('tidyRecognizedText', () {
    test('collapses whitespace and joins lines', () {
      expect(
        tidyRecognizedText('Ethio   50 Birr\n\n1234 5678   9012'),
        'Ethio 50 Birr · 1234 5678 9012',
      );
    });
  });
}
