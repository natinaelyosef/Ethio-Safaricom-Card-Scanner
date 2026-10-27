import 'package:flutter_test/flutter_test.dart';
import 'package:saricom/logic/ussd_reply.dart';

void main() {
  group('parseBalanceReply', () {
    test('parses currency after amount (Ethio telecom style)', () {
      final parsed = parseBalanceReply(
        'Your balance is 12.50 Birr. Thank you.',
      );
      expect(parsed.hasAmount, isTrue);
      expect(parsed.amount, '12.50');
      expect(parsed.currency, 'ETB');
      expect(parsed.rawReply, contains('12.50 Birr'));
    });

    test('parses currency before amount with thousands separator', () {
      final parsed = parseBalanceReply('Balance: ETB 1,234.56');
      expect(parsed.amount, '1234.56');
      expect(parsed.currency, 'ETB');
    });

    test('parses Amharic currency and balance wording', () {
      final parsed = parseBalanceReply('ቀሪ ሂሳብዎ 45.00 ብር ነው።');
      expect(parsed.amount, '45.00');
      expect(parsed.currency, 'ETB');
    });

    test('parses an explicit balance phrase without a currency', () {
      final parsed = parseBalanceReply('Dear customer, your balance is 8.4');
      expect(parsed.amount, '8.4');
    });

    test('does not invent an amount from a recharge confirmation', () {
      final parsed = parseBalanceReply(
        'Dear customer, your recharge is successful.',
      );
      expect(parsed.hasAmount, isFalse);
      expect(parsed.rawReply, isNotEmpty);
    });

    test('rejects a bare phone number in a balance phrase', () {
      final parsed = parseBalanceReply('Your balance was sent to 0911223344');
      expect(parsed.hasAmount, isFalse);
    });

    test('always keeps the raw reply verbatim', () {
      const raw = 'Your balance is 3.00 Birr';
      expect(parseBalanceReply(raw).rawReply, raw);
    });
  });
}
