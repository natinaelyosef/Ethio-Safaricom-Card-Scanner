/// Parsing helpers for carrier USSD replies (balance checks, recharge
/// confirmations).
///
/// The raw network text is always preserved verbatim. A balance amount is
/// extracted only when the reply itself contains a number next to a known
/// currency marker (ETB, Birr, Br, ብር) or an explicit balance phrase such
/// as "your balance is …". Saricom never invents a figure: when nothing
/// matches, [ParsedBalance.amount] is `null` and only the raw reply is
/// shown.
library;

/// A balance reply from the network with an optional parsed amount.
class ParsedBalance {
  const ParsedBalance({
    required this.rawReply,
    this.amount,
    this.currency = 'ETB',
  });

  /// The carrier's reply, exactly as received.
  final String rawReply;

  /// Normalized amount (no thousands separators), e.g. `12.50`.
  final String? amount;

  /// Currency label derived from the reply; defaults to `ETB`.
  final String currency;

  bool get hasAmount => amount != null;
}

/// Matches the three currency spellings used by Ethio telecom and
/// Safaricom Ethiopia (English and Amharic) plus common abbreviations.
const String _currency = r'(ETB|Birr|BR|Br\.?|ብር)';

final RegExp _currencyThenAmount = RegExp(
  '$_currency\\s*[:=]?\\s*([0-9][0-9,]*(?:\\.[0-9]{1,2})?)',
  caseSensitive: false,
);

final RegExp _amountThenCurrency = RegExp(
  '([0-9][0-9,]*(?:\\.[0-9]{1,2})?)\\s*$_currency',
  caseSensitive: false,
);

final RegExp _balancePhrase = RegExp(
  r'(?:balance|ቀሪ(?:\s*ሂሳብ)?|ሂሳብዎ)[^0-9\n]{0,48}'
  r'([0-9][0-9,]*(?:\.[0-9]{1,2})?)',
  caseSensitive: false,
);

String _normalizeAmount(String raw) => raw.replaceAll(',', '');

/// All supported markers map to ETB (Ethio telecom / Safaricom Ethiopia).
String _currencyLabel(String raw) => 'ETB';

/// Extracts a balance amount from a carrier reply, if present.
ParsedBalance parseBalanceReply(String rawReply) {
  // 1. Currency adjacent to a number is the strongest signal
  //    ("Your balance is 12.50 Birr", "ETB 12.50", "ቀሪ ሂሳብ 12.50 ብር").
  final currencyFirst = _currencyThenAmount.firstMatch(rawReply);
  if (currencyFirst != null) {
    return ParsedBalance(
      rawReply: rawReply,
      amount: _normalizeAmount(currencyFirst.group(2)!),
      currency: _currencyLabel(currencyFirst.group(1)!),
    );
  }

  final amountFirst = _amountThenCurrency.firstMatch(rawReply);
  if (amountFirst != null) {
    return ParsedBalance(
      rawReply: rawReply,
      amount: _normalizeAmount(amountFirst.group(1)!),
      currency: _currencyLabel(amountFirst.group(2)!),
    );
  }

  // 2. An explicit balance phrase followed by a number
  //    ("Your current balance is 12.50").
  final phrase = _balancePhrase.firstMatch(rawReply);
  if (phrase != null) {
    final amount = _normalizeAmount(phrase.group(1)!);
    // A bare 8+ digit run in a balance phrase is almost certainly a phone
    // number or an account id, not money.
    final bareDigits = amount.replaceAll('.', '');
    if (!(bareDigits.length >= 8 && !amount.contains('.'))) {
      return ParsedBalance(rawReply: rawReply, amount: amount);
    }
  }

  return ParsedBalance(rawReply: rawReply);
}
