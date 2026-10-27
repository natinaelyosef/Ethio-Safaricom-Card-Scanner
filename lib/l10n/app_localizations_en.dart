// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appSubtitle => 'Recharge Card Scanner';

  @override
  String get homeTab => 'Home';

  @override
  String get settingsTab => 'Settings';

  @override
  String selectProvider(String provider) {
    return 'Select $provider';
  }

  @override
  String get scanRechargeCard => 'Scan Recharge Card';

  @override
  String get scanningCamera => 'Scanning camera';

  @override
  String get autoReadBadge => 'AUTO READ';

  @override
  String get tapOpenLivePreview => 'Tap to open the live camera preview';

  @override
  String get cameraPreviewCaption =>
      'Camera preview opens here when you start scanning';

  @override
  String get fromGallery => 'From Gallery';

  @override
  String get typeCode => 'Type Code';

  @override
  String get checkBalance => 'Check Balance';

  @override
  String get checkingEllipsis => 'Checking…';

  @override
  String get offlinePrivacyFooter =>
      'Offline & private: scanning, OCR, and manual entry work without internet. Nothing is uploaded. Scan history is off unless you turn it on in Settings.';

  @override
  String get recentScansTitle => 'Recent scans (this device only)';

  @override
  String recentScanTime(String time) {
    return 'Time: $time';
  }

  @override
  String simFor(String provider) {
    return 'SIM for $provider';
  }

  @override
  String simActive(int slot) {
    return 'SIM $slot · Active';
  }

  @override
  String simInactive(int slot) {
    return 'SIM $slot · Inactive';
  }

  @override
  String simName(int slot, String name) {
    return 'SIM $slot · $name';
  }

  @override
  String get defaultValue => 'Default';

  @override
  String independentDisclaimer(String appName) {
    return '$appName is an independent scanner app — not affiliated with Ethio telecom or Safaricom. USSD codes verified from public carrier guidance.';
  }

  @override
  String get cameraPaused => 'Camera paused';

  @override
  String get reopenCameraOrTypePin => 'Reopen the camera or type the PIN';

  @override
  String get openCamera => 'Open camera';

  @override
  String get autoReadingCard => 'Auto-reading the card…';

  @override
  String get analyzingPhoto => 'Analyzing photo…';

  @override
  String get autoScanningHint =>
      'Auto-scanning — just hold the card inside the frame';

  @override
  String get scanAutoReadHint =>
      'Fill the frame with the printed digits — the app reads them automatically.';

  @override
  String readingLive(String text) {
    return 'Reading: $text';
  }

  @override
  String get torchOn => 'Torch on';

  @override
  String get torchOff => 'Torch off';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get captureNowOptional => 'Capture now (optional, auto-scan is on)';

  @override
  String get typePinManually => 'Type PIN manually';

  @override
  String get stopCamera => 'Stop camera';

  @override
  String get checkRecognizedPin => 'Check the recognized PIN';

  @override
  String get capturedPhotoNote =>
      'Captured photo — kept on this device only, never uploaded.';

  @override
  String digitCount(int count) {
    return '$count digits';
  }

  @override
  String get compareDigitsHelp =>
      'Compare with the printed card digit by digit — OCR can mistake similar-looking numbers. You can fix any digit here before continuing.';

  @override
  String get confirmAndRecharge => 'Confirm & Recharge';

  @override
  String get retake => 'Retake';

  @override
  String get gallery => 'Gallery';

  @override
  String get discard => 'Discard';

  @override
  String get photoPreviewUnavailable => 'Photo preview unavailable';

  @override
  String get readyToRecharge => 'Ready to recharge';

  @override
  String get ussdThatWillDial => 'USSD that will dial';

  @override
  String get openingUssd => 'Opening USSD…';

  @override
  String rechargeProvider(String provider) {
    return 'Recharge $provider';
  }

  @override
  String get balance => 'Balance';

  @override
  String get editCode => 'Edit code';

  @override
  String get scanNextCard => 'Scan the next card';

  @override
  String codeNeedsDigits(String provider) {
    return '$provider code needs at least 6 digits';
  }

  @override
  String get dialCodeYourself => 'Dial this code yourself';

  @override
  String get dialSteps =>
      '1. Open your Phone  2. Type or paste the code  3. Press Call  4. The carrier pop-up shows the result.';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get done => 'Done';

  @override
  String get networkReply => 'Network reply';

  @override
  String rechargeRequestSentTo(String provider) {
    return 'Recharge request sent to $provider.';
  }

  @override
  String get confirmRecharge => 'Confirm recharge';

  @override
  String providerDigits(String provider, int count) {
    return '$provider · $count digits';
  }

  @override
  String get confirmRechargeBody =>
      'The app sends this request straight to the network — when your phone supports in-app USSD the network\'s own reply appears right here inside the app. On devices that refuse in-app sessions the carrier pop-up shows over this screen instead. Results are never invented.';

  @override
  String get duplicateWarning =>
      'You already submitted this same PIN less than 3 minutes ago. Submitting it again will not add credit twice — only continue if the first attempt definitely failed.';

  @override
  String get dualSimNote =>
      'On phones with two SIMs the system may ask which SIM to dial with — pick the one you want charged.';

  @override
  String get cancel => 'Cancel';

  @override
  String get runUssd => 'Run USSD';

  @override
  String blockedManualHint(String appName) {
    return 'The in-app session could not complete on this phone. Allow the \"Phone\" permission (Settings → Apps → $appName → Permissions) and try again — or copy the code below.';
  }

  @override
  String iosRechargeManualHint(String provider) {
    return 'Apple does not allow apps to start USSD sessions, so please dial the code shown below yourself. Your $provider balance updates in their pop-up.';
  }

  @override
  String iosBalanceManualHint(String provider) {
    return 'iOS does not allow apps to run USSD codes, so the balance cannot be retrieved inside the app on this platform. Dial the code below in the Phone app to see your $provider balance.';
  }

  @override
  String get networkNoTextReply => '(The network replied, but with no text.)';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageDescription => 'Choose the language used in the app.';

  @override
  String get english => 'English';

  @override
  String get amharic => 'አማርኛ';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceDescription =>
      'Pick the theme the app uses on this device.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get defaultProviderTitle => 'Default provider';

  @override
  String get defaultProviderDescription =>
      'The network the app selects first when you open it.';

  @override
  String providerRechargeBalance(String recharge, String balance) {
    return 'Recharge: $recharge · Balance: $balance';
  }

  @override
  String get simTitle => 'SIM for recharge & balance';

  @override
  String get simDescription =>
      'Choose which SIM card sends each network\'s USSD request.';

  @override
  String get simExplanation =>
      'On a dual-SIM phone, choose which SIM runs each provider\'s USSD session. When no SIM is chosen, the app auto-matches by carrier name, or uses the device default.';

  @override
  String get noSimDetected =>
      'No SIM detected (or the Phone permission was denied).';

  @override
  String get oneSimDetected =>
      'One SIM detected — it will be used automatically.';

  @override
  String get refreshSimList => 'Refresh SIM list';

  @override
  String get historyTitle => 'Local scan history';

  @override
  String get historyDescription =>
      'Stored on this device only — never uploaded.';

  @override
  String get saveRecentScans => 'Save recent scans';

  @override
  String get saveRecentScansSubtitle =>
      'Off by default. When on, only a masked code (first 4 digits + length), provider and time are stored on this device — never the full code.';

  @override
  String clearHistoryCount(int count) {
    return 'Clear history ($count)';
  }

  @override
  String get clearHistoryTitle => 'Clear scan history?';

  @override
  String get clearHistoryBody =>
      'Every entry stored on this device will be deleted. This restores the initial privacy state of the app.';

  @override
  String get delete => 'Delete';

  @override
  String get scanHistoryCleared => 'Scan history cleared';

  @override
  String get ussdReaderTitle => 'Carrier USSD reader';

  @override
  String get ussdReaderDescription =>
      'Lets the app read the network\'s own pop-up reply.';

  @override
  String get ussdReaderEnabled =>
      'Enabled — carrier replies are read inside the app.';

  @override
  String get ussdReaderDisabled =>
      'Off — the carrier pop-up cannot be read by the app.';

  @override
  String get ussdReaderExplanation =>
      'Some phones refuse the in-app USSD API, so the carrier shows its own pop-up. To parse your balance or recharge reply and display it under the Home screen, the app needs the Android accessibility service. It only observes phone/dialer windows for a few seconds while an app request is running; nothing is stored or uploaded, and you can turn it off at any time.';

  @override
  String get reviewAccessibilitySetting => 'Review accessibility setting';

  @override
  String get enableInAccessibilitySettings =>
      'Enable in accessibility settings';

  @override
  String get refreshStatus => 'Refresh status';

  @override
  String get scanningHelpTitle => 'Scanning help';

  @override
  String get scanningHelpDescription =>
      'Short tips for a clean first-time read.';

  @override
  String get scanningTip1 =>
      'Hold the card flat and steady; the frame guides the voucher area.';

  @override
  String get scanningTip2 =>
      'Use good lighting. Tap the torch icon in dim rooms.';

  @override
  String get scanningTip3 =>
      'Scratch the silver layer fully so every digit is clear.';

  @override
  String get scanningTip4 =>
      'The camera scans automatically — no shutter tap needed.';

  @override
  String get scanningTip5 =>
      'The largest number on the card is selected as the PIN; always check it against the paper before confirming.';

  @override
  String get scanningTip6 =>
      'After you confirm the PIN, the app recharges automatically and shows the carrier reply in the app.';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyDescription => 'Offline, on-device, and account-free.';

  @override
  String get privacyBody =>
      '• OCR runs on-device (Google ML Kit). No card image or digit ever leaves the phone.\n• No accounts, no ads, no analytics, no telemetry of any kind.\n• Card photos stay on this device; originals picked from the gallery are never modified or deleted.\n• Full voucher codes are never written to storage.\n• The optional USSD reader only sees phone/dialer windows during an app request and stores nothing.\n• Recharge and balance USSD sessions run inside the carrier network, which needs mobile signal — that session belongs to your carrier.';

  @override
  String aboutTitle(String appName) {
    return 'About $appName';
  }

  @override
  String versionLine(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String aboutBody(String appName) {
    return '$appName scans paper recharge vouchers for Ethio telecom and Safaricom Ethiopia, corrects the recognized digits with you, and starts the carrier-approved USSD recharge sessions on Android. It is an independent utility and is not officially endorsed by, affiliated with, or a substitute for either operator\'s own apps.';
  }

  @override
  String get developerLabel => 'DEVELOPER';

  @override
  String openDeveloperPortfolio(String developer) {
    return 'Open $developer portfolio in browser';
  }

  @override
  String get offlineBadge => 'Offline • No account • No ads';

  @override
  String get couldNotOpenPortfolio => 'Could not open the portfolio link.';

  @override
  String get statusCameraPermission =>
      'Camera permission is needed to photograph the card. Grant it in system settings, or type the PIN manually.';

  @override
  String get statusNoCamera =>
      'No camera was found on this device. Type the PIN manually.';

  @override
  String statusCameraStartFailed(String reason) {
    return 'Camera could not start ($reason). You can still pick a photo from the gallery or type the PIN.';
  }

  @override
  String get statusCameraNotOpen =>
      'The camera is not open. Tap \"Open camera\" first, or choose a photo from the gallery.';

  @override
  String statusPhotoFailed(String reason) {
    return 'The photo could not be taken ($reason). Try again, or type the PIN manually.';
  }

  @override
  String statusGalleryFailed(String reason) {
    return 'Could not open the gallery ($reason). You can take a photo instead.';
  }

  @override
  String get statusNoPinAuto =>
      'No PIN yet — move closer, keep the digits sharp and inside the frame. More light helps.';

  @override
  String statusNoPinFromPhoto(String seen) {
    return 'No recharge PIN could be read from this photo — $seen Move closer so the digits fill the frame, avoid glare, and try again — or type the PIN manually.';
  }

  @override
  String get statusNothingReadable => 'nothing readable was found.';

  @override
  String statusReadThis(String text) {
    return 'this was read: \"$text\".';
  }

  @override
  String statusScanFailed(String reason) {
    return 'Scanning failed ($reason). Try again or type the PIN.';
  }

  @override
  String get statusPinRecognized =>
      'PIN recognized. Compare it with the paper card and fix any wrong digit before continuing — the printed card is the reference.';

  @override
  String get validationEnterPin => 'Enter or scan a voucher PIN first.';

  @override
  String get validationTooShort =>
      'Too short to be a voucher PIN (needs at least 6 digits).';

  @override
  String get validationTooLong => 'Too long for a voucher PIN (max 24 digits).';

  @override
  String validationUnusualLength(int min, int max) {
    return 'Unusual length: a typical PIN has $min–$max digits. Check the card again, or continue if you are sure.';
  }

  @override
  String get statusPinTooShortForRecharge =>
      'That PIN is not long enough for a recharge. Fix the digits and confirm again.';

  @override
  String get statusNetworkAnswered => 'The network answered below.';

  @override
  String statusDirectRecharge(String provider) {
    return '$provider received your recharge request — finish it in the carrier pop-up shown over this screen and wait for their confirmation SMS. The app cannot see whether it succeeded.';
  }

  @override
  String statusRechargeBlocked(String appName) {
    return 'The USSD session could not complete in-app. Allow the \"Phone\" permission (Android Settings → Apps → $appName → Permissions) and try again, or use the copy option.';
  }

  @override
  String get statusRechargeManual =>
      'Apple does not allow apps to launch USSD codes. Copy the code shown below and dial it yourself in the Phone app.';

  @override
  String get statusRechargeFailed =>
      'The USSD session failed on the network side. Try again, or use the copy option.';

  @override
  String get balanceNoText =>
      'The network replied but sent no balance text. Try again.';

  @override
  String balanceViaSms(String provider) {
    return '$provider answered via SMS — check your messages for the balance. You can also try the query again.';
  }

  @override
  String balanceDirect(String provider) {
    return '$provider opened its balance prompt in a system pop-up over this screen — the app cannot read that dialog. The number shown there is the real balance.';
  }

  @override
  String balanceBlocked(String appName) {
    return 'The balance query could not run inside the app. Allow the \"Phone\" permission (Android Settings → Apps → $appName → Permissions) and try again.';
  }

  @override
  String get balanceManual =>
      'iOS does not allow apps to run USSD codes. The app cannot retrieve the balance in-app on this platform.';

  @override
  String get balanceFailed =>
      'The balance query failed on the network side. Check your connection and try again.';

  @override
  String balanceCheckingTitle(String provider) {
    return 'Checking balance · $provider';
  }

  @override
  String get balanceCheckingBody =>
      'Sending the balance request to the network. The reply appears here without leaving the app.';

  @override
  String balanceTitle(String provider) {
    return 'Balance · $provider';
  }

  @override
  String get chipNoBalance => 'No balance read';

  @override
  String get chipLiveReply => 'Live reply';

  @override
  String get chipCarrierReply => 'Carrier reply';

  @override
  String get parsedFromCarrier => 'Parsed from the carrier reply';

  @override
  String get carrierReplyVerbatim => 'Carrier reply (verbatim)';

  @override
  String get noRecognizableAmount =>
      'The reply contained no recognizable balance amount, so only the raw carrier text is shown. Nothing was guessed.';

  @override
  String get noBalanceRead =>
      'No balance was read. Nothing was guessed or stored.';

  @override
  String liveReplyAt(String time) {
    return 'Live reply received at $time. The app displays the network text verbatim.';
  }
}
