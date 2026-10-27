import 'package:flutter_test/flutter_test.dart';
import 'package:saricom/logic/ussd_builder.dart';
import 'package:saricom/models/telecom_provider.dart';

void main() {
  group('recharge strings', () {
    test('Ethio telecom uses *805', () {
      expect(
        UssdBuilder.recharge(TelecomProvider.ethioTelecom, '50910-5526 22905'),
        '*805*50910552622905#',
      );
    });

    test('Safaricom Ethiopia uses *705', () {
      expect(
        UssdBuilder.recharge(
          TelecomProvider.safaricomEthiopia,
          '40 1234 5678 9012',
        ),
        '*705*40123456789012#',
      );
    });

    test('throws when fewer than 6 digits remain', () {
      expect(
        () => UssdBuilder.recharge(TelecomProvider.ethioTelecom, '12345'),
        throwsArgumentError,
      );
    });
  });

  group('balance strings', () {
    test('verified codes', () {
      expect(UssdBuilder.balance(TelecomProvider.ethioTelecom), '*804#');
      expect(UssdBuilder.balance(TelecomProvider.safaricomEthiopia), '*704#');
    });
  });

  group('sanitizeDigits', () {
    test('strips everything but 0-9', () {
      expect(UssdBuilder.sanitizeDigits('*804# a1b2 3.4!'), '8041234');
      expect(UssdBuilder.sanitizeDigits(''), '');
    });
  });

  group('isValidUssdString', () {
    test('accepts valid recharge strings of both providers', () {
      expect(UssdBuilder.isValidUssdString('*805*1234567890123#'), isTrue);
      expect(UssdBuilder.isValidUssdString('*705*1234567890123#'), isTrue);
    });

    test('rejects arbitrary or malformed strings', () {
      expect(UssdBuilder.isValidUssdString(''), isFalse);
      expect(UssdBuilder.isValidUssdString('*805#'), isFalse);
      expect(UssdBuilder.isValidUssdString('*1234#'), isFalse);
      expect(UssdBuilder.isValidUssdString('*805*123abc#'), isFalse);
      expect(UssdBuilder.isValidUssdString('tel:*805*123456#'), isFalse);
      // Too many digits (max 24 enforced by the pattern).
      expect(UssdBuilder.isValidUssdString('*805*${'1' * 25}#'), isFalse);
    });
  });
}
