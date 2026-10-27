import '../models/telecom_provider.dart';

/// Builds validated USSD strings for each provider.
class UssdBuilder {
  UssdBuilder._();

  static final RegExp _validPattern = RegExp(r'^\*[0-9]{3}\*[0-9]{6,24}#$');

  /// Builds the recharge USSD string, e.g. `*805*1234567890123#`.
  ///
  /// [digits] are sanitized (non-digits removed). Throws [ArgumentError]
  /// when fewer than 6 digits remain so obviously wrong input never
  /// reaches the dialer.
  static String recharge(TelecomProvider provider, String digits) {
    final clean = sanitizeDigits(digits);
    if (clean.length < 6) {
      throw ArgumentError.value(
        digits,
        'digits',
        'Voucher code must contain at least 6 digits',
      );
    }
    switch (provider) {
      case TelecomProvider.ethioTelecom:
        return '*805*$clean#';
      case TelecomProvider.safaricomEthiopia:
        return '*705*$clean#';
    }
  }

  /// Builds the balance USSD string, e.g. `*804#`.
  static String balance(TelecomProvider provider) => switch (provider) {
    TelecomProvider.ethioTelecom => '*804#',
    TelecomProvider.safaricomEthiopia => '*704#',
  };

  /// Removes every character that is not 0-9.
  static String sanitizeDigits(String input) {
    final buffer = StringBuffer();
    for (final code in input.runes) {
      if (code >= 0x30 && code <= 0x39) {
        buffer.writeCharCode(code);
      }
    }
    return buffer.toString();
  }

  /// True when [code] is a syntactically valid USSD recharge string.
  ///
  /// Only the verified shapes are accepted, so an arbitrary string is
  /// never handed to the native dialer intent.
  static bool isValidUssdString(String code) => _validPattern.hasMatch(code);
}
