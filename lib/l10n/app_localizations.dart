import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
  ];

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recharge Card Scanner'**
  String get appSubtitle;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @selectProvider.
  ///
  /// In en, this message translates to:
  /// **'Select {provider}'**
  String selectProvider(String provider);

  /// No description provided for @scanRechargeCard.
  ///
  /// In en, this message translates to:
  /// **'Scan Recharge Card'**
  String get scanRechargeCard;

  /// No description provided for @scanningCamera.
  ///
  /// In en, this message translates to:
  /// **'Scanning camera'**
  String get scanningCamera;

  /// No description provided for @autoReadBadge.
  ///
  /// In en, this message translates to:
  /// **'AUTO READ'**
  String get autoReadBadge;

  /// No description provided for @tapOpenLivePreview.
  ///
  /// In en, this message translates to:
  /// **'Tap to open the live camera preview'**
  String get tapOpenLivePreview;

  /// No description provided for @cameraPreviewCaption.
  ///
  /// In en, this message translates to:
  /// **'Camera preview opens here when you start scanning'**
  String get cameraPreviewCaption;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get fromGallery;

  /// No description provided for @typeCode.
  ///
  /// In en, this message translates to:
  /// **'Type Code'**
  String get typeCode;

  /// No description provided for @checkBalance.
  ///
  /// In en, this message translates to:
  /// **'Check Balance'**
  String get checkBalance;

  /// No description provided for @checkingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checkingEllipsis;

  /// No description provided for @offlinePrivacyFooter.
  ///
  /// In en, this message translates to:
  /// **'Offline & private: scanning, OCR, and manual entry work without internet. Nothing is uploaded. Scan history is off unless you turn it on in Settings.'**
  String get offlinePrivacyFooter;

  /// No description provided for @recentScansTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent scans (this device only)'**
  String get recentScansTitle;

  /// No description provided for @recentScanTime.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String recentScanTime(String time);

  /// No description provided for @simFor.
  ///
  /// In en, this message translates to:
  /// **'SIM for {provider}'**
  String simFor(String provider);

  /// No description provided for @simActive.
  ///
  /// In en, this message translates to:
  /// **'SIM {slot} · Active'**
  String simActive(int slot);

  /// No description provided for @simInactive.
  ///
  /// In en, this message translates to:
  /// **'SIM {slot} · Inactive'**
  String simInactive(int slot);

  /// No description provided for @simName.
  ///
  /// In en, this message translates to:
  /// **'SIM {slot} · {name}'**
  String simName(int slot, String name);

  /// No description provided for @defaultValue.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultValue;

  /// No description provided for @independentDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'{appName} is an independent scanner app — not affiliated with Ethio telecom or Safaricom. USSD codes verified from public carrier guidance.'**
  String independentDisclaimer(String appName);

  /// No description provided for @cameraPaused.
  ///
  /// In en, this message translates to:
  /// **'Camera paused'**
  String get cameraPaused;

  /// No description provided for @reopenCameraOrTypePin.
  ///
  /// In en, this message translates to:
  /// **'Reopen the camera or type the PIN'**
  String get reopenCameraOrTypePin;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Open camera'**
  String get openCamera;

  /// No description provided for @autoReadingCard.
  ///
  /// In en, this message translates to:
  /// **'Auto-reading the card…'**
  String get autoReadingCard;

  /// No description provided for @analyzingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Analyzing photo…'**
  String get analyzingPhoto;

  /// No description provided for @autoScanningHint.
  ///
  /// In en, this message translates to:
  /// **'Auto-scanning — just hold the card inside the frame'**
  String get autoScanningHint;

  /// No description provided for @scanAutoReadHint.
  ///
  /// In en, this message translates to:
  /// **'Fill the frame with the printed digits — the app reads them automatically.'**
  String get scanAutoReadHint;

  /// No description provided for @readingLive.
  ///
  /// In en, this message translates to:
  /// **'Reading: {text}'**
  String readingLive(String text);

  /// No description provided for @torchOn.
  ///
  /// In en, this message translates to:
  /// **'Torch on'**
  String get torchOn;

  /// No description provided for @torchOff.
  ///
  /// In en, this message translates to:
  /// **'Torch off'**
  String get torchOff;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @captureNowOptional.
  ///
  /// In en, this message translates to:
  /// **'Capture now (optional, auto-scan is on)'**
  String get captureNowOptional;

  /// No description provided for @typePinManually.
  ///
  /// In en, this message translates to:
  /// **'Type PIN manually'**
  String get typePinManually;

  /// No description provided for @stopCamera.
  ///
  /// In en, this message translates to:
  /// **'Stop camera'**
  String get stopCamera;

  /// No description provided for @checkRecognizedPin.
  ///
  /// In en, this message translates to:
  /// **'Check the recognized PIN'**
  String get checkRecognizedPin;

  /// No description provided for @capturedPhotoNote.
  ///
  /// In en, this message translates to:
  /// **'Captured photo — kept on this device only, never uploaded.'**
  String get capturedPhotoNote;

  /// No description provided for @digitCount.
  ///
  /// In en, this message translates to:
  /// **'{count} digits'**
  String digitCount(int count);

  /// No description provided for @compareDigitsHelp.
  ///
  /// In en, this message translates to:
  /// **'Compare with the printed card digit by digit — OCR can mistake similar-looking numbers. You can fix any digit here before continuing.'**
  String get compareDigitsHelp;

  /// No description provided for @confirmAndRecharge.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Recharge'**
  String get confirmAndRecharge;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @photoPreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Photo preview unavailable'**
  String get photoPreviewUnavailable;

  /// No description provided for @readyToRecharge.
  ///
  /// In en, this message translates to:
  /// **'Ready to recharge'**
  String get readyToRecharge;

  /// No description provided for @ussdThatWillDial.
  ///
  /// In en, this message translates to:
  /// **'USSD that will dial'**
  String get ussdThatWillDial;

  /// No description provided for @openingUssd.
  ///
  /// In en, this message translates to:
  /// **'Opening USSD…'**
  String get openingUssd;

  /// No description provided for @rechargeProvider.
  ///
  /// In en, this message translates to:
  /// **'Recharge {provider}'**
  String rechargeProvider(String provider);

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @editCode.
  ///
  /// In en, this message translates to:
  /// **'Edit code'**
  String get editCode;

  /// No description provided for @scanNextCard.
  ///
  /// In en, this message translates to:
  /// **'Scan the next card'**
  String get scanNextCard;

  /// No description provided for @codeNeedsDigits.
  ///
  /// In en, this message translates to:
  /// **'{provider} code needs at least 6 digits'**
  String codeNeedsDigits(String provider);

  /// No description provided for @dialCodeYourself.
  ///
  /// In en, this message translates to:
  /// **'Dial this code yourself'**
  String get dialCodeYourself;

  /// No description provided for @dialSteps.
  ///
  /// In en, this message translates to:
  /// **'1. Open your Phone  2. Type or paste the code  3. Press Call  4. The carrier pop-up shows the result.'**
  String get dialSteps;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @networkReply.
  ///
  /// In en, this message translates to:
  /// **'Network reply'**
  String get networkReply;

  /// No description provided for @rechargeRequestSentTo.
  ///
  /// In en, this message translates to:
  /// **'Recharge request sent to {provider}.'**
  String rechargeRequestSentTo(String provider);

  /// No description provided for @confirmRecharge.
  ///
  /// In en, this message translates to:
  /// **'Confirm recharge'**
  String get confirmRecharge;

  /// No description provided for @providerDigits.
  ///
  /// In en, this message translates to:
  /// **'{provider} · {count} digits'**
  String providerDigits(String provider, int count);

  /// No description provided for @confirmRechargeBody.
  ///
  /// In en, this message translates to:
  /// **'The app sends this request straight to the network — when your phone supports in-app USSD the network\'s own reply appears right here inside the app. On devices that refuse in-app sessions the carrier pop-up shows over this screen instead. Results are never invented.'**
  String get confirmRechargeBody;

  /// No description provided for @duplicateWarning.
  ///
  /// In en, this message translates to:
  /// **'You already submitted this same PIN less than 3 minutes ago. Submitting it again will not add credit twice — only continue if the first attempt definitely failed.'**
  String get duplicateWarning;

  /// No description provided for @dualSimNote.
  ///
  /// In en, this message translates to:
  /// **'On phones with two SIMs the system may ask which SIM to dial with — pick the one you want charged.'**
  String get dualSimNote;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @runUssd.
  ///
  /// In en, this message translates to:
  /// **'Run USSD'**
  String get runUssd;

  /// No description provided for @blockedManualHint.
  ///
  /// In en, this message translates to:
  /// **'The in-app session could not complete on this phone. Allow the \"Phone\" permission (Settings → Apps → {appName} → Permissions) and try again — or copy the code below.'**
  String blockedManualHint(String appName);

  /// No description provided for @iosRechargeManualHint.
  ///
  /// In en, this message translates to:
  /// **'Apple does not allow apps to start USSD sessions, so please dial the code shown below yourself. Your {provider} balance updates in their pop-up.'**
  String iosRechargeManualHint(String provider);

  /// No description provided for @iosBalanceManualHint.
  ///
  /// In en, this message translates to:
  /// **'iOS does not allow apps to run USSD codes, so the balance cannot be retrieved inside the app on this platform. Dial the code below in the Phone app to see your {provider} balance.'**
  String iosBalanceManualHint(String provider);

  /// No description provided for @networkNoTextReply.
  ///
  /// In en, this message translates to:
  /// **'(The network replied, but with no text.)'**
  String get networkNoTextReply;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used in the app.'**
  String get languageDescription;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @amharic.
  ///
  /// In en, this message translates to:
  /// **'አማርኛ'**
  String get amharic;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @appearanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick the theme the app uses on this device.'**
  String get appearanceDescription;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @defaultProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'Default provider'**
  String get defaultProviderTitle;

  /// No description provided for @defaultProviderDescription.
  ///
  /// In en, this message translates to:
  /// **'The network the app selects first when you open it.'**
  String get defaultProviderDescription;

  /// No description provided for @providerRechargeBalance.
  ///
  /// In en, this message translates to:
  /// **'Recharge: {recharge} · Balance: {balance}'**
  String providerRechargeBalance(String recharge, String balance);

  /// No description provided for @simTitle.
  ///
  /// In en, this message translates to:
  /// **'SIM for recharge & balance'**
  String get simTitle;

  /// No description provided for @simDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose which SIM card sends each network\'s USSD request.'**
  String get simDescription;

  /// No description provided for @simExplanation.
  ///
  /// In en, this message translates to:
  /// **'On a dual-SIM phone, choose which SIM runs each provider\'s USSD session. When no SIM is chosen, the app auto-matches by carrier name, or uses the device default.'**
  String get simExplanation;

  /// No description provided for @noSimDetected.
  ///
  /// In en, this message translates to:
  /// **'No SIM detected (or the Phone permission was denied).'**
  String get noSimDetected;

  /// No description provided for @oneSimDetected.
  ///
  /// In en, this message translates to:
  /// **'One SIM detected — it will be used automatically.'**
  String get oneSimDetected;

  /// No description provided for @refreshSimList.
  ///
  /// In en, this message translates to:
  /// **'Refresh SIM list'**
  String get refreshSimList;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Local scan history'**
  String get historyTitle;

  /// No description provided for @historyDescription.
  ///
  /// In en, this message translates to:
  /// **'Stored on this device only — never uploaded.'**
  String get historyDescription;

  /// No description provided for @saveRecentScans.
  ///
  /// In en, this message translates to:
  /// **'Save recent scans'**
  String get saveRecentScans;

  /// No description provided for @saveRecentScansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Off by default. When on, only a masked code (first 4 digits + length), provider and time are stored on this device — never the full code.'**
  String get saveRecentScansSubtitle;

  /// No description provided for @clearHistoryCount.
  ///
  /// In en, this message translates to:
  /// **'Clear history ({count})'**
  String clearHistoryCount(int count);

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear scan history?'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Every entry stored on this device will be deleted. This restores the initial privacy state of the app.'**
  String get clearHistoryBody;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @scanHistoryCleared.
  ///
  /// In en, this message translates to:
  /// **'Scan history cleared'**
  String get scanHistoryCleared;

  /// No description provided for @ussdReaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Carrier USSD reader'**
  String get ussdReaderTitle;

  /// No description provided for @ussdReaderDescription.
  ///
  /// In en, this message translates to:
  /// **'Lets the app read the network\'s own pop-up reply.'**
  String get ussdReaderDescription;

  /// No description provided for @ussdReaderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled — carrier replies are read inside the app.'**
  String get ussdReaderEnabled;

  /// No description provided for @ussdReaderDisabled.
  ///
  /// In en, this message translates to:
  /// **'Off — the carrier pop-up cannot be read by the app.'**
  String get ussdReaderDisabled;

  /// No description provided for @ussdReaderExplanation.
  ///
  /// In en, this message translates to:
  /// **'Some phones refuse the in-app USSD API, so the carrier shows its own pop-up. To parse your balance or recharge reply and display it under the Home screen, the app needs the Android accessibility service. It only observes phone/dialer windows for a few seconds while an app request is running; nothing is stored or uploaded, and you can turn it off at any time.'**
  String get ussdReaderExplanation;

  /// No description provided for @reviewAccessibilitySetting.
  ///
  /// In en, this message translates to:
  /// **'Review accessibility setting'**
  String get reviewAccessibilitySetting;

  /// No description provided for @enableInAccessibilitySettings.
  ///
  /// In en, this message translates to:
  /// **'Enable in accessibility settings'**
  String get enableInAccessibilitySettings;

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get refreshStatus;

  /// No description provided for @scanningHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Scanning help'**
  String get scanningHelpTitle;

  /// No description provided for @scanningHelpDescription.
  ///
  /// In en, this message translates to:
  /// **'Short tips for a clean first-time read.'**
  String get scanningHelpDescription;

  /// No description provided for @scanningTip1.
  ///
  /// In en, this message translates to:
  /// **'Hold the card flat and steady; the frame guides the voucher area.'**
  String get scanningTip1;

  /// No description provided for @scanningTip2.
  ///
  /// In en, this message translates to:
  /// **'Use good lighting. Tap the torch icon in dim rooms.'**
  String get scanningTip2;

  /// No description provided for @scanningTip3.
  ///
  /// In en, this message translates to:
  /// **'Scratch the silver layer fully so every digit is clear.'**
  String get scanningTip3;

  /// No description provided for @scanningTip4.
  ///
  /// In en, this message translates to:
  /// **'The camera scans automatically — no shutter tap needed.'**
  String get scanningTip4;

  /// No description provided for @scanningTip5.
  ///
  /// In en, this message translates to:
  /// **'The largest number on the card is selected as the PIN; always check it against the paper before confirming.'**
  String get scanningTip5;

  /// No description provided for @scanningTip6.
  ///
  /// In en, this message translates to:
  /// **'After you confirm the PIN, the app recharges automatically and shows the carrier reply in the app.'**
  String get scanningTip6;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Offline, on-device, and account-free.'**
  String get privacyDescription;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'• OCR runs on-device (Google ML Kit). No card image or digit ever leaves the phone.\n• No accounts, no ads, no analytics, no telemetry of any kind.\n• Card photos stay on this device; originals picked from the gallery are never modified or deleted.\n• Full voucher codes are never written to storage.\n• The optional USSD reader only sees phone/dialer windows during an app request and stores nothing.\n• Recharge and balance USSD sessions run inside the carrier network, which needs mobile signal — that session belongs to your carrier.'**
  String get privacyBody;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About {appName}'**
  String aboutTitle(String appName);

  /// No description provided for @versionLine.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String versionLine(String version, String build);

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'{appName} scans paper recharge vouchers for Ethio telecom and Safaricom Ethiopia, corrects the recognized digits with you, and starts the carrier-approved USSD recharge sessions on Android. It is an independent utility and is not officially endorsed by, affiliated with, or a substitute for either operator\'s own apps.'**
  String aboutBody(String appName);

  /// No description provided for @developerLabel.
  ///
  /// In en, this message translates to:
  /// **'DEVELOPER'**
  String get developerLabel;

  /// No description provided for @openDeveloperPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Open {developer} portfolio in browser'**
  String openDeveloperPortfolio(String developer);

  /// No description provided for @offlineBadge.
  ///
  /// In en, this message translates to:
  /// **'Offline • No account • No ads'**
  String get offlineBadge;

  /// No description provided for @couldNotOpenPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Could not open the portfolio link.'**
  String get couldNotOpenPortfolio;

  /// No description provided for @statusCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is needed to photograph the card. Grant it in system settings, or type the PIN manually.'**
  String get statusCameraPermission;

  /// No description provided for @statusNoCamera.
  ///
  /// In en, this message translates to:
  /// **'No camera was found on this device. Type the PIN manually.'**
  String get statusNoCamera;

  /// No description provided for @statusCameraStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Camera could not start ({reason}). You can still pick a photo from the gallery or type the PIN.'**
  String statusCameraStartFailed(String reason);

  /// No description provided for @statusCameraNotOpen.
  ///
  /// In en, this message translates to:
  /// **'The camera is not open. Tap \"Open camera\" first, or choose a photo from the gallery.'**
  String get statusCameraNotOpen;

  /// No description provided for @statusPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be taken ({reason}). Try again, or type the PIN manually.'**
  String statusPhotoFailed(String reason);

  /// No description provided for @statusGalleryFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the gallery ({reason}). You can take a photo instead.'**
  String statusGalleryFailed(String reason);

  /// No description provided for @statusNoPinAuto.
  ///
  /// In en, this message translates to:
  /// **'No PIN yet — move closer, keep the digits sharp and inside the frame. More light helps.'**
  String get statusNoPinAuto;

  /// No description provided for @statusNoPinFromPhoto.
  ///
  /// In en, this message translates to:
  /// **'No recharge PIN could be read from this photo — {seen} Move closer so the digits fill the frame, avoid glare, and try again — or type the PIN manually.'**
  String statusNoPinFromPhoto(String seen);

  /// No description provided for @statusNothingReadable.
  ///
  /// In en, this message translates to:
  /// **'nothing readable was found.'**
  String get statusNothingReadable;

  /// No description provided for @statusReadThis.
  ///
  /// In en, this message translates to:
  /// **'this was read: \"{text}\".'**
  String statusReadThis(String text);

  /// No description provided for @statusScanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scanning failed ({reason}). Try again or type the PIN.'**
  String statusScanFailed(String reason);

  /// No description provided for @statusPinRecognized.
  ///
  /// In en, this message translates to:
  /// **'PIN recognized. Compare it with the paper card and fix any wrong digit before continuing — the printed card is the reference.'**
  String get statusPinRecognized;

  /// No description provided for @validationEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter or scan a voucher PIN first.'**
  String get validationEnterPin;

  /// No description provided for @validationTooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short to be a voucher PIN (needs at least 6 digits).'**
  String get validationTooShort;

  /// No description provided for @validationTooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long for a voucher PIN (max 24 digits).'**
  String get validationTooLong;

  /// No description provided for @validationUnusualLength.
  ///
  /// In en, this message translates to:
  /// **'Unusual length: a typical PIN has {min}–{max} digits. Check the card again, or continue if you are sure.'**
  String validationUnusualLength(int min, int max);

  /// No description provided for @statusPinTooShortForRecharge.
  ///
  /// In en, this message translates to:
  /// **'That PIN is not long enough for a recharge. Fix the digits and confirm again.'**
  String get statusPinTooShortForRecharge;

  /// No description provided for @statusNetworkAnswered.
  ///
  /// In en, this message translates to:
  /// **'The network answered below.'**
  String get statusNetworkAnswered;

  /// No description provided for @statusDirectRecharge.
  ///
  /// In en, this message translates to:
  /// **'{provider} received your recharge request — finish it in the carrier pop-up shown over this screen and wait for their confirmation SMS. The app cannot see whether it succeeded.'**
  String statusDirectRecharge(String provider);

  /// No description provided for @statusRechargeBlocked.
  ///
  /// In en, this message translates to:
  /// **'The USSD session could not complete in-app. Allow the \"Phone\" permission (Android Settings → Apps → {appName} → Permissions) and try again, or use the copy option.'**
  String statusRechargeBlocked(String appName);

  /// No description provided for @statusRechargeManual.
  ///
  /// In en, this message translates to:
  /// **'Apple does not allow apps to launch USSD codes. Copy the code shown below and dial it yourself in the Phone app.'**
  String get statusRechargeManual;

  /// No description provided for @statusRechargeFailed.
  ///
  /// In en, this message translates to:
  /// **'The USSD session failed on the network side. Try again, or use the copy option.'**
  String get statusRechargeFailed;

  /// No description provided for @balanceNoText.
  ///
  /// In en, this message translates to:
  /// **'The network replied but sent no balance text. Try again.'**
  String get balanceNoText;

  /// No description provided for @balanceViaSms.
  ///
  /// In en, this message translates to:
  /// **'{provider} answered via SMS — check your messages for the balance. You can also try the query again.'**
  String balanceViaSms(String provider);

  /// No description provided for @balanceDirect.
  ///
  /// In en, this message translates to:
  /// **'{provider} opened its balance prompt in a system pop-up over this screen — the app cannot read that dialog. The number shown there is the real balance.'**
  String balanceDirect(String provider);

  /// No description provided for @balanceBlocked.
  ///
  /// In en, this message translates to:
  /// **'The balance query could not run inside the app. Allow the \"Phone\" permission (Android Settings → Apps → {appName} → Permissions) and try again.'**
  String balanceBlocked(String appName);

  /// No description provided for @balanceManual.
  ///
  /// In en, this message translates to:
  /// **'iOS does not allow apps to run USSD codes. The app cannot retrieve the balance in-app on this platform.'**
  String get balanceManual;

  /// No description provided for @balanceFailed.
  ///
  /// In en, this message translates to:
  /// **'The balance query failed on the network side. Check your connection and try again.'**
  String get balanceFailed;

  /// No description provided for @balanceCheckingTitle.
  ///
  /// In en, this message translates to:
  /// **'Checking balance · {provider}'**
  String balanceCheckingTitle(String provider);

  /// No description provided for @balanceCheckingBody.
  ///
  /// In en, this message translates to:
  /// **'Sending the balance request to the network. The reply appears here without leaving the app.'**
  String get balanceCheckingBody;

  /// No description provided for @balanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Balance · {provider}'**
  String balanceTitle(String provider);

  /// No description provided for @chipNoBalance.
  ///
  /// In en, this message translates to:
  /// **'No balance read'**
  String get chipNoBalance;

  /// No description provided for @chipLiveReply.
  ///
  /// In en, this message translates to:
  /// **'Live reply'**
  String get chipLiveReply;

  /// No description provided for @chipCarrierReply.
  ///
  /// In en, this message translates to:
  /// **'Carrier reply'**
  String get chipCarrierReply;

  /// No description provided for @parsedFromCarrier.
  ///
  /// In en, this message translates to:
  /// **'Parsed from the carrier reply'**
  String get parsedFromCarrier;

  /// No description provided for @carrierReplyVerbatim.
  ///
  /// In en, this message translates to:
  /// **'Carrier reply (verbatim)'**
  String get carrierReplyVerbatim;

  /// No description provided for @noRecognizableAmount.
  ///
  /// In en, this message translates to:
  /// **'The reply contained no recognizable balance amount, so only the raw carrier text is shown. Nothing was guessed.'**
  String get noRecognizableAmount;

  /// No description provided for @noBalanceRead.
  ///
  /// In en, this message translates to:
  /// **'No balance was read. Nothing was guessed or stored.'**
  String get noBalanceRead;

  /// No description provided for @liveReplyAt.
  ///
  /// In en, this message translates to:
  /// **'Live reply received at {time}. The app displays the network text verbatim.'**
  String liveReplyAt(String time);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
