import 'package:flutter/material.dart';

import '../logic/ussd_builder.dart';

/// The two telecom providers supported by Ethio & Safaricom Card Scanner.
enum TelecomProvider { ethioTelecom, safaricomEthiopia }

/// Verified provider information and USSD helpers.
///
/// The USSD short codes below were verified against public/caregiver
/// documentation in 2025:
///
/// * Ethio telecom: recharge voucher via `*805*<hidden number>#`,
///   balance via `*804#` (source: ethiotelecom.et FAQ).
/// * Safaricom Ethiopia: recharge voucher via `*705*<hidden number>#`,
///   balance via `*704#` (sources: safaricom.et care guides).
///
/// Dialing these strings is carried out by the phone itself in its own
/// USSD session; Saricom only pre-fills the string.
extension TelecomProviderX on TelecomProvider {
  String get label {
    switch (this) {
      case TelecomProvider.ethioTelecom:
        return 'Ethio telecom';
      case TelecomProvider.safaricomEthiopia:
        return 'Safaricom Ethiopia';
    }
  }

  /// Short tag used on compact chips.
  String get shortLabel {
    switch (this) {
      case TelecomProvider.ethioTelecom:
        return 'Ethio';
      case TelecomProvider.safaricomEthiopia:
        return 'Safaricom';
    }
  }

  /// Compact label used on the Home provider selector.
  String get selectorLabel {
    switch (this) {
      case TelecomProvider.ethioTelecom:
        return 'Ethio telecom';
      case TelecomProvider.safaricomEthiopia:
        return 'Safaricom';
    }
  }

  /// One-line action summary, e.g. "*805*····#" for Ethio telecom.
  String get rechargeHint {
    switch (this) {
      case TelecomProvider.ethioTelecom:
        return 'Dial *805*CODE#';
      case TelecomProvider.safaricomEthiopia:
        return 'Dial *705*CODE#';
    }
  }

  String get balanceHint {
    switch (this) {
      case TelecomProvider.ethioTelecom:
        return 'Dial *804#';
      case TelecomProvider.safaricomEthiopia:
        return 'Dial *704#';
    }
  }

  /// Recharge USSD shape with a `CODE` placeholder, for display only.
  String get rechargeUssdExample {
    switch (this) {
      case TelecomProvider.ethioTelecom:
        return '*805*CODE#';
      case TelecomProvider.safaricomEthiopia:
        return '*705*CODE#';
    }
  }

  /// The provider's balance USSD code.
  String get balanceUssdCode => UssdBuilder.balance(this);

  /// How many digits the USSD recharge voucher is expected to carry.
  ///
  /// Digit counts differ by card batch and denomination and are **not**
  /// officially documented, so this is used only as a soft display hint.
  ({int min, int max}) get voucherLengthHint => (min: 10, max: 20);

  /// Lowercase substring used to auto-match a physical SIM to this
  /// provider when the user has not chosen one explicitly (dual-SIM).
  /// Returns null when no reliable needle exists.
  String? get simCarrierNeedle {
    switch (this) {
      case TelecomProvider.ethioTelecom:
        return 'ethio';
      case TelecomProvider.safaricomEthiopia:
        return 'safaricom';
    }
  }

  /// Icon used across the app for this provider.
  IconData get icon {
    switch (this) {
      case TelecomProvider.ethioTelecom:
        return Icons.signal_cellular_alt_rounded;
      case TelecomProvider.safaricomEthiopia:
        return Icons.near_me_rounded;
    }
  }

  /// Builds the exact recharge USSD string for a voucher code.
  String rechargeUssd(String digits) => UssdBuilder.recharge(this, digits);

  /// Builds the exact balance-check USSD string.
  String get balanceUssd => UssdBuilder.balance(this);
}
