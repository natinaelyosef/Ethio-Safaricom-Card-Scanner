// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appSubtitle => 'የሪቻርጅ ካርድ ስካነር';

  @override
  String get homeTab => 'መነሻ';

  @override
  String get settingsTab => 'ቅንብሮች';

  @override
  String selectProvider(String provider) {
    return '$provider ይምረጡ';
  }

  @override
  String get scanRechargeCard => 'የሪቻርጅ ካርድ ስካን ያድርጉ';

  @override
  String get scanningCamera => 'ካሜራ በመቃኘት ላይ';

  @override
  String get autoReadBadge => 'ራስ-ሰር ንባብ';

  @override
  String get tapOpenLivePreview => 'የቀጥታ የካሜራ ቅድመ-እይታን ለመክፈት ይንኩ';

  @override
  String get cameraPreviewCaption => 'ስካን ማድረግ ሲጀምሩ የካሜራ ቅድመ-እይታ እዚህ ይታያል';

  @override
  String get fromGallery => 'ከጋለሪ';

  @override
  String get typeCode => 'ኮድ ያስገቡ';

  @override
  String get checkBalance => 'ቀሪ ሂሳብ ይመልከቱ';

  @override
  String get checkingEllipsis => 'በመፈተሽ ላይ…';

  @override
  String get offlinePrivacyFooter =>
      'ከመስመር ውጭ እና ግላዊ፦ ስካን፣ OCR እና በእጅ ማስገባት ኢንተርኔት ሳይኖር ይሰራሉ። ምንም ነገር አይላክም። በቅንብሮች ውስጥ እስኪያበሩት ድረስ የስካን ታሪክ ጠፍቷል።';

  @override
  String get recentScansTitle => 'የቅርብ ጊዜ ስካኖች (በዚህ መሣሪያ ላይ ብቻ)';

  @override
  String recentScanTime(String time) {
    return 'ጊዜ፦ $time';
  }

  @override
  String simFor(String provider) {
    return 'ለ$provider የሚሆን SIM';
  }

  @override
  String simActive(int slot) {
    return 'SIM $slot · ንቁ';
  }

  @override
  String simInactive(int slot) {
    return 'SIM $slot · ንቁ አይደለም';
  }

  @override
  String simName(int slot, String name) {
    return 'SIM $slot · $name';
  }

  @override
  String get defaultValue => 'ነባሪ';

  @override
  String independentDisclaimer(String appName) {
    return '$appName ገለልተኛ የስካን መተግበሪያ ነው — ከኢትዮ ቴሌኮም ወይም ከሳፋሪኮም ጋር ትስስር የለውም። የUSSD ኮዶች ከሕዝባዊ የአገልግሎት አቅራቢ መመሪያዎች የተረጋገጡ ናቸው።';
  }

  @override
  String get cameraPaused => 'ካሜራ ቆሟል';

  @override
  String get reopenCameraOrTypePin => 'ካሜራውን እንደገና ይክፈቱ ወይም PIN ያስገቡ';

  @override
  String get openCamera => 'ካሜራ ይክፈቱ';

  @override
  String get autoReadingCard => 'ካርዱ በራስ-ሰር በመነበብ ላይ…';

  @override
  String get analyzingPhoto => 'ፎቶው በመተንተን ላይ…';

  @override
  String get autoScanningHint => 'በራስ-ሰር በመቃኘት ላይ — ካርዱን በፍሬሙ ውስጥ ብቻ ይያዙት';

  @override
  String get scanAutoReadHint =>
      'ፍሬሙን በታተሙት አሃዞች ይሙሉ — መተግበሪያው በራስ-ሰር ይነብባቸዋል።';

  @override
  String readingLive(String text) {
    return 'በመነበብ ላይ፦ $text';
  }

  @override
  String get torchOn => 'ቶርች በርቷል';

  @override
  String get torchOff => 'ቶርች ጠፍቷል';

  @override
  String get chooseFromGallery => 'ከጋለሪ ይምረጡ';

  @override
  String get captureNowOptional => 'አሁን ያንሱ (አማራጭ፣ ራስ-ሰር ስካን በርቷል)';

  @override
  String get typePinManually => 'PIN በእጅ ያስገቡ';

  @override
  String get stopCamera => 'ካሜራ አቁም';

  @override
  String get checkRecognizedPin => 'የተለየውን PIN ያረጋግጡ';

  @override
  String get capturedPhotoNote =>
      'የተነሳው ፎቶ — በዚህ መሣሪያ ላይ ብቻ ይቀመጣል፣ በጭራሽ አይላክም።';

  @override
  String digitCount(int count) {
    return '$count አሃዞች';
  }

  @override
  String get compareDigitsHelp =>
      'ከታተመው ካርድ ጋር አሃድ በአሃድ ያወዳድሩ — OCR ተመሳሳይ የሚመስሉ ቁጥሮችን ሊሳሳት ይችላል። ከመቀጠልዎ በፊት ማንኛውንም አሃድ እዚህ ማስተካከል ይችላሉ።';

  @override
  String get confirmAndRecharge => 'አረጋግጥ እና ሪቻርጅ አድርግ';

  @override
  String get retake => 'እንደገና ያንሱ';

  @override
  String get gallery => 'ጋለሪ';

  @override
  String get discard => 'ሰርዝ';

  @override
  String get photoPreviewUnavailable => 'የፎቶ ቅድመ-እይታ አይገኝም';

  @override
  String get readyToRecharge => 'ለሪቻርጅ ዝግ';

  @override
  String get ussdThatWillDial => 'የሚደወለው USSD';

  @override
  String get openingUssd => 'USSD በመክፈት ላይ…';

  @override
  String rechargeProvider(String provider) {
    return '$provider ሪቻርጅ ያድርጉ';
  }

  @override
  String get balance => 'ቀሪ ሂሳብ';

  @override
  String get editCode => 'ኮድ ያስተካክሉ';

  @override
  String get scanNextCard => 'ቀጣዩን ካርድ ስካን ያድርጉ';

  @override
  String codeNeedsDigits(String provider) {
    return 'የ$provider ኮድ ቢያንስ 6 አሃዞች ያስፈልገዋል';
  }

  @override
  String get dialCodeYourself => 'ይህን ኮድ ራስዎ ይደውሉ';

  @override
  String get dialSteps =>
      '1. ስልክዎን ይክፈቱ  2. ኮዱን ይተይቡ ወይም ይለጥፉ  3. Call ይጫኑ  4. የአገልግሎት አቅራቢው ፖፕ-አፕ ውጤቱን ያሳያል።';

  @override
  String get copiedToClipboard => 'ወደ ቅንጥብ ሰሌዳ ተቀድቷል';

  @override
  String get copy => 'ቅዳ';

  @override
  String get done => 'ጨርስ';

  @override
  String get networkReply => 'የኔትወርክ ምላሽ';

  @override
  String rechargeRequestSentTo(String provider) {
    return 'የሪቻርጅ ጥያቄ ወደ $provider ተልኳል።';
  }

  @override
  String get confirmRecharge => 'ሪቻርጅን ያረጋግጡ';

  @override
  String providerDigits(String provider, int count) {
    return '$provider · $count አሃዞች';
  }

  @override
  String get confirmRechargeBody =>
      'መተግበሪያው ይህን ጥያቄ በቀጥታ ወደ ኔትወርኩ ይልካል — ስልክዎ በመተግበሪያው ውስጥ USSD ከሚደግፍ የኔትወርኩ የራሱ ምላሽ እዚህ መተግበሪያ ውስጥ ይታያል። በመተግበሪያ ውስጥ የማይሰሩ መሣሪያዎች ላይ የአገልግሎት አቅራቢው ፖፕ-አፕ በዚህ ማያ ገጽ ላይ ይታያል። ውጤቶች በጭራሽ አይፈጠሩም።';

  @override
  String get duplicateWarning =>
      'ይህን ተመሳሳይ PIN ከ3 ደቂቃ በፊት አስገብተዋል። እንደገና ማስገባት ክሬዲት በእጥፍ አይጨምርም — የመጀመሪያው ሙከራ በእርግጥ ካልተሳካ ብቻ ይቀጥሉ።';

  @override
  String get dualSimNote =>
      'ሁለት SIM ባላቸው ስልኮች ስርዓቱ በየትኛው SIM እንዲደውል ሊጠይቅ ይችላል — ሪቻርጅ የሚፈልጉትን ይምረጡ።';

  @override
  String get cancel => 'ይቅር';

  @override
  String get runUssd => 'USSD አስጀምር';

  @override
  String blockedManualHint(String appName) {
    return 'በመተግበሪያው ውስጥ ያለው ክፍለ-ጊዜ በዚህ ስልክ ላይ ሊጠናቀቅ አልቻለም። የ“Phone” ፈቃድን ይፍቀዱ (ቅንብሮች → መተግበሪያዎች → $appName → ፈቃዶች) እና እንደገና ይሞክሩ — ወይም ከታች ያለውን ኮድ ይቅዱ።';
  }

  @override
  String iosRechargeManualHint(String provider) {
    return 'Apple መተግበሪያዎች USSD እንዲያስጀምሩ አይፈቅድም፣ ስለዚህ ከታች የሚታየውን ኮድ ራስዎ ይደውሉ። የ$provider ቀሪ ሂሳብዎ በእነሱ ፖፕ-አፕ ውስጥ ይታያል።';
  }

  @override
  String iosBalanceManualHint(String provider) {
    return 'iOS መተግበሪያዎች USSD ኮዶችን እንዲያስጀምሩ አይፈቅድም፣ ስለዚህ ቀሪ ሂሳብን በመተግበሪያው ውስጥ ማግኘት አይቻልም። የ$provider ቀሪ ሂሳብዎን ለማየት ከታች ያለውን ኮድ በስልክ መተግበሪያው ይደውሉ።';
  }

  @override
  String get networkNoTextReply => '(ኔትወርኩ ምላሽ ሰጥቷል፣ ግን ጽሑፍ የለም።)';

  @override
  String get settingsTitle => 'ቅንብሮች';

  @override
  String get languageTitle => 'ቋንቋ';

  @override
  String get languageDescription => 'በመተግበሪያው ውስጥ የሚጠቀምበትን ቋንቋ ይምረጡ።';

  @override
  String get english => 'English';

  @override
  String get amharic => 'አማርኛ';

  @override
  String get appearanceTitle => 'መልክ';

  @override
  String get appearanceDescription => 'በዚህ መሣሪያ ላይ መተግበሪያው የሚጠቀምበትን ገጽታ ይምረጡ።';

  @override
  String get themeSystem => 'ስርዓት';

  @override
  String get themeLight => 'ብርሃን';

  @override
  String get themeDark => 'ጨለማ';

  @override
  String get defaultProviderTitle => 'ነባሪ አገልግሎት አቅራቢ';

  @override
  String get defaultProviderDescription => 'መተግበሪያው ሲከፈት በመጀመሪያ የሚመርጠው ኔትወርክ።';

  @override
  String providerRechargeBalance(String recharge, String balance) {
    return 'ሪቻርጅ፦ $recharge · ቀሪ ሂሳብ፦ $balance';
  }

  @override
  String get simTitle => 'ለሪቻርጅ እና ቀሪ ሂሳብ የሚሆን SIM';

  @override
  String get simDescription => 'የእያንዳንዱን ኔትወርክ USSD ጥያቄ የሚልከውን SIM ካርድ ይምረጡ።';

  @override
  String get simExplanation =>
      'በሁለት-SIM ስልክ ላይ ለእያንዳንዱ አገልግሎት አቅራቢ USSD ክፍለ-ጊዜ የሚያስፈጽመውን SIM ይምረጡ። SIM ካልተመረጠ መተግበሪያው በአገልግሎት አቅራቢው ስም በራስ-ሰር ያገናኛል ወይም የመሣሪያውን ነባሪ ይጠቀማል።';

  @override
  String get noSimDetected => 'SIM አልተገኘም (ወይም የስልክ ፈቃድ ተከልክሏል)።';

  @override
  String get oneSimDetected => 'አንድ SIM ተገኝቷል — በራስ-ሰር ይጠቀምበታል።';

  @override
  String get refreshSimList => 'የSIM ዝርዝር አድስ';

  @override
  String get historyTitle => 'የአካባቢ የስካን ታሪክ';

  @override
  String get historyDescription => 'በዚህ መሣሪያ ላይ ብቻ ይቀመጣል — በጭራሽ አይላክም።';

  @override
  String get saveRecentScans => 'የቅርብ ጊዜ ስካኖችን አስቀምጥ';

  @override
  String get saveRecentScansSubtitle =>
      'በነባሪ ጠፍቷል። ሲበራ የተደበቀ ኮድ (የመጀመሪያዎቹ 4 አሃዞች + ርዝመት)፣ አገልግሎት አቅራቢ እና ጊዜ ብቻ በዚህ መሣሪያ ላይ ይቀመጣሉ — ሙሉ ኮድ ፈጽሞ አይቀመጥም።';

  @override
  String clearHistoryCount(int count) {
    return 'ታሪክ አጥፋ ($count)';
  }

  @override
  String get clearHistoryTitle => 'የስካን ታሪክን ያጥፉ?';

  @override
  String get clearHistoryBody =>
      'በዚህ መሣሪያ ላይ የተቀመጠው እያንዳንዱ መዝገብ ይሰረዛል። ይህ የመተግበሪያውን የመጀመሪያ የግላዊነት ሁኔታ ይመልሳል።';

  @override
  String get delete => 'አጥፋ';

  @override
  String get scanHistoryCleared => 'የስካን ታሪክ ጠፍቷል';

  @override
  String get ussdReaderTitle => 'የአገልግሎት አቅራቢ USSD አንባቢ';

  @override
  String get ussdReaderDescription =>
      'መተግበሪያው የኔትወርኩን የራሱ ፖፕ-አፕ ምላሽ እንዲያነብ ይፈቅዳል።';

  @override
  String get ussdReaderEnabled =>
      'ነቅቷል — የአገልግሎት አቅራቢ ምላሾች በመተግበሪያው ውስጥ ይነበባሉ።';

  @override
  String get ussdReaderDisabled =>
      'ጠፍቷል — የአገልግሎት አቅራቢው ፖፕ-አፕ በመተግበሪያው ሊነበብ አይችልም።';

  @override
  String get ussdReaderExplanation =>
      'አንዳንድ ስልኮች በመተግበሪያ ውስጥ USSD API አይቀበሉም፣ ስለዚህ አገልግሎት አቅራቢው የራሱን ፖፕ-አፕ ያሳያል። የቀሪ ሂሳብ ወይም የሪቻርጅ ምላሽዎን በመተግበሪያው ውስጥ ለማሳየት መተግበሪያው የAndroid ተደራሽነት አገልግሎት ያስፈልገዋል። በመተግበሪያ ጥያቄ በሚሄድበት ጊዜ ለጥቂት ሰከንዶች የስልክ/መደወያ መስኮቶችን ብቻ ይከታተላል፤ ምንም አይቀመጥም ወይም አይላክም፣ እና በማንኛውም ጊዜ ማጥፋት ይችላሉ።';

  @override
  String get reviewAccessibilitySetting => 'የተደራሽነት ቅንብርን ይገምግሙ';

  @override
  String get enableInAccessibilitySettings => 'በተደራሽነት ቅንብሮች ውስጥ አብራ';

  @override
  String get refreshStatus => 'ሁኔታ አድስ';

  @override
  String get scanningHelpTitle => 'የስካን እርዳታ';

  @override
  String get scanningHelpDescription => 'ለንጹህ የመጀመሪያ ንባብ አጭር ምክሮች።';

  @override
  String get scanningTip1 => 'ካርዱን ጠፍጣፋ እና አንድ ቦታ ይያዙት፤ ፍሬሙ የቫውቸር ቦታውን ይመራል።';

  @override
  String get scanningTip2 => 'ጥሩ ብርሃን ይጠቀሙ። በጨለማ ክፍሎች ውስጥ የቶርች አዶን ይንኩ።';

  @override
  String get scanningTip3 => 'እያንዳንዱ አሃድ ግልጽ እንዲሆን የብር ንብርብሩን ሙሉ በሙሉ ይቧጭሩ።';

  @override
  String get scanningTip4 => 'ካሜራው በራስ-ሰር ይቃኛል — መተጫን አያስፈልግም።';

  @override
  String get scanningTip5 =>
      'በካርዱ ላይ ያለው ትልቁ ቁጥር PIN ተብሎ ይመረጣል፤ ከማረጋገጥዎ በፊት ሁልጊዜ ከወረቀቱ ጋር ያወዳድሩት።';

  @override
  String get scanningTip6 =>
      'PIN ካረጋገጡ በኋላ መተግበሪያው በራስ-ሰር ሪቻርጅ ያደርጋል እና የአገልግሎት አቅራቢውን ምላሽ በመተግበሪያው ውስጥ ያሳያል።';

  @override
  String get privacyTitle => 'ግላዊነት';

  @override
  String get privacyDescription => 'ከመስመር ውጭ፣ በመሣሪያ ላይ ብቻ፣ እና ያለመለያ።';

  @override
  String get privacyBody =>
      '• OCR በመሣሪያው ላይ ይሰራል (Google ML Kit)። ምንም የካርድ ምስል ወይም አሃድ ስልኩን ለቆ አይወጣም።\n• መለያዎች የሉም፣ ማስታወቂያ የለም፣ ትንተና የለም፣ ምንም ዓይነት ቴሌሜትሪ የለም።\n• የካርድ ፎቶዎች በዚህ መሣሪያ ላይ ይቆያሉ፤ ከጋለሪ የተመረጡ ዋና ፋይሎች በጭራሽ አይቀየሩም ወይም አይሰረዙም።\n• ሙሉ የቫውቸር ኮዶች በማከማቻ ውስጥ ፈጽሞ አይጻፉም።\n• አማራጭ የሆነው USSD አንባቢ በመተግበሪያ ጥያቄ ጊዜ የስልክ/መደወያ መስኮቶችን ብቻ ይመለከታል እና ምንም አያከማችም።\n• የሪቻርጅ እና የቀሪ ሂሳብ USSD ክፍለ-ጊዜዎች በአገልግሎት አቅራቢው ኔትወርክ ውስጥ ይሰራሉ፤ ይህም የሞባይል ሲግናል ይፈልጋል — ይህ ክፍለ-ጊዜ የአገልግሎት አቅራቢዎ ነው።';

  @override
  String aboutTitle(String appName) {
    return 'ስለ $appName';
  }

  @override
  String versionLine(String version, String build) {
    return 'ስሪት $version ($build)';
  }

  @override
  String aboutBody(String appName) {
    return '$appName ለኢትዮ ቴሌኮም እና ለሳፋሪኮም ኢትዮጵያ የወረቀት የሪቻርጅ ቫውቸሮችን ይቃኛል፣ የተለዩትን አሃዞች ከእርስዎ ጋር ያስተካክላል፣ እና በAndroid ላይ በአገልግሎት አቅራቢው የተፈቀዱ የUSSD ሪቻርጅ ክፍለ-ጊዜዎችን ይጀምራል። ገለልተኛ መሣሪያ ነው እና በኦፊሴላዊነት በሁለቱም አገልግሎት አቅራቢዎች አልተደገፈም፣ ከእነሱ ጋር ትስስር የለውም፣ እንዲሁም የእነሱ መተግበሪያዎች ምትክ አይደለም።';
  }

  @override
  String get developerLabel => 'ገንቢ';

  @override
  String openDeveloperPortfolio(String developer) {
    return 'የ$developer ፖርትፎሊዮን በአሳሽ ክፈት';
  }

  @override
  String get offlineBadge => 'ከመስመር ውጭ • መለያ የለም • ማስታወቂያ የለም';

  @override
  String get couldNotOpenPortfolio => 'የፖርትፎሊዮ አገናኙን መክፈት አልተቻለም።';

  @override
  String get statusCameraPermission =>
      'ካርዱን ፎቶ ለማንሳት የካሜራ ፈቃድ ያስፈልጋል። በስርዓት ቅንብሮች ውስጥ ይፍቀዱ፣ ወይም PIN በእጅ ያስገቡ።';

  @override
  String get statusNoCamera => 'በዚህ መሣሪያ ላይ ካሜራ አልተገኘም። PIN በእጅ ያስገቡ።';

  @override
  String statusCameraStartFailed(String reason) {
    return 'ካሜራው ሊጀምር አልቻለም ($reason)። አሁንም ከጋለሪ ፎቶ መምረጥ ወይም PIN በእጅ ማስገባት ይችላሉ።';
  }

  @override
  String get statusCameraNotOpen =>
      'ካሜራው አልተከፈተም። መጀመሪያ “ካሜራ ይክፈቱ” ን ይንኩ፣ ወይም ከጋለሪ ፎቶ ይምረጡ።';

  @override
  String statusPhotoFailed(String reason) {
    return 'ፎቶው ሊነሳ አልቻለም ($reason)። እንደገና ይሞክሩ፣ ወይም PIN በእጅ ያስገቡ።';
  }

  @override
  String statusGalleryFailed(String reason) {
    return 'ጋለሪውን መክፈት አልተቻለም ($reason)። በምትኩ ፎቶ ማንሳት ይችላሉ።';
  }

  @override
  String get statusNoPinAuto =>
      'እስካሁን PIN የለም — ይቅርበት፣ አሃዞቹ ግልጽ ሆነው በፍሬሙ ውስጥ እንዲሆኑ ያድርጉ። ተጨማሪ ብርሃን ይረዳል።';

  @override
  String statusNoPinFromPhoto(String seen) {
    return 'ከዚህ ፎቶ የሪቻርጅ PIN ሊነበብ አልቻለም — $seen አሃዞቹ ፍሬሙን እንዲሞሉ ይቅርቡ፣ ነጸብራቅን ያስወግዱ፣ እና እንደገና ይሞክሩ — ወይም PIN በእጅ ያስገቡ።';
  }

  @override
  String get statusNothingReadable => 'ምንም የሚነበብ ነገር አልተገኘም።';

  @override
  String statusReadThis(String text) {
    return 'ይህ ተነብቧል፦ “$text”።';
  }

  @override
  String statusScanFailed(String reason) {
    return 'ስካን አልተሳካም ($reason)። እንደገና ይሞክሩ ወይም PIN ያስገቡ።';
  }

  @override
  String get statusPinRecognized =>
      'PIN ተለይቷል። ከወረቀቱ ካርድ ጋር ያወዳድሩ እና ማንኛውንም የተሳሳተ አሃድ ከመቀጠልዎ በፊት ያስተካክሉ — የታተመው ካርድ መለኪያው ነው።';

  @override
  String get validationEnterPin => 'መጀመሪያ የቫውቸር PIN ያስገቡ ወይም ይቃኙ።';

  @override
  String get validationTooShort => 'ለቫውቸር PIN በጣም አጭር ነው (ቢያንስ 6 አሃዞች ያስፈልጋሉ)።';

  @override
  String get validationTooLong => 'ለቫውቸር PIN በጣም ረጅም ነው (ከፍተኛ 24 አሃዞች)።';

  @override
  String validationUnusualLength(int min, int max) {
    return 'ያልተለመደ ርዝመት፦ የተለመደ PIN $min–$max አሃዞች አለው። ካርዱን እንደገና ያረጋግጡ፣ ወይም እርግጠኛ ከሆኑ ይቀጥሉ።';
  }

  @override
  String get statusPinTooShortForRecharge =>
      'ይህ PIN ለሪቻርጅ በቂ ርዝመት የለውም። አሃዞቹን ያስተካክሉ እና እንደገና ያረጋግጡ።';

  @override
  String get statusNetworkAnswered => 'ኔትወርኩ ከታች መልሷል።';

  @override
  String statusDirectRecharge(String provider) {
    return '$provider የሪቻርጅ ጥያቄዎን ተቀብሏል — በዚህ ማያ ገጽ ላይ በሚታየው የአገልግሎት አቅራቢ ፖፕ-አፕ ውስጥ ጨርሱት እና የማረጋገጫ SMS ይጠብቁ። መተግበሪያው መሳካቱን ማየት አይችልም።';
  }

  @override
  String statusRechargeBlocked(String appName) {
    return 'USSD ክፍለ-ጊዜው በመተግበሪያው ውስጥ ሊጠናቀቅ አልቻለም። የ“Phone” ፈቃድን ይፍቀዱ (የAndroid ቅንብሮች → መተግበሪያዎች → $appName → ፈቃዶች) እና እንደገና ይሞክሩ፣ ወይም የመቅዳት አማራጩን ይጠቀሙ።';
  }

  @override
  String get statusRechargeManual =>
      'Apple መተግበሪያዎች USSD ኮዶችን እንዲያስጀምሩ አይፈቅድም። ከታች የሚታየውን ኮድ ይቅዱ እና በስልክ መተግበሪያው ውስጥ ራስዎ ይደውሉ።';

  @override
  String get statusRechargeFailed =>
      'USSD ክፍለ-ጊዜው በኔትወርኩ በኩል አልተሳካም። እንደገና ይሞክሩ፣ ወይም የመቅዳት አማራጩን ይጠቀሙ።';

  @override
  String get balanceNoText =>
      'ኔትወርኩ ምላሽ ሰጥቷል ግን የቀሪ ሂሳብ ጽሑፍ አልላከም። እንደገና ይሞክሩ።';

  @override
  String balanceViaSms(String provider) {
    return '$provider በSMS መልሷል — ቀሪ ሂሳቡን በመልዕክቶችዎ ውስጥ ይመልከቱ። ጥያቄውን እንደገና መሞከርም ይችላሉ።';
  }

  @override
  String balanceDirect(String provider) {
    return '$provider የቀሪ ሂሳብ ጥያቄውን በዚህ ማያ ገጽ ላይ ባለ የስርዓት ፖፕ-አፕ ውስጥ ከፍቷል — መተግበሪያው ያንን መገኛ ማንበብ አይችልም። እዚያ የሚታየው ቁጥር ትክክለኛው ቀሪ ሂሳብ ነው።';
  }

  @override
  String balanceBlocked(String appName) {
    return 'የቀሪ ሂሳብ ጥያቄው በመተግበሪያው ውስጥ ሊሰራ አልቻለም። የ“Phone” ፈቃድን ይፍቀዱ (የAndroid ቅንብሮች → መተግበሪያዎች → $appName → ፈቃዶች) እና እንደገና ይሞክሩ።';
  }

  @override
  String get balanceManual =>
      'iOS መተግበሪያዎች USSD ኮዶችን እንዲያስጀምሩ አይፈቅድም። መተግበሪያው በዚህ መድረክ ላይ ቀሪ ሂሳብን በመተግበሪያ ውስጥ ማግኘት አይችልም።';

  @override
  String get balanceFailed =>
      'የቀሪ ሂሳብ ጥያቄው በኔትወርኩ በኩል አልተሳካም። ግንኙነትዎን ያረጋግጡ እና እንደገና ይሞክሩ።';

  @override
  String balanceCheckingTitle(String provider) {
    return 'ቀሪ ሂሳብ በመፈተሽ ላይ · $provider';
  }

  @override
  String get balanceCheckingBody =>
      'የቀሪ ሂሳብ ጥያቄ ወደ ኔትወርኩ በመላክ ላይ። ምላሹ ከመተግበሪያው ሳይወጣ እዚህ ይታያል።';

  @override
  String balanceTitle(String provider) {
    return 'ቀሪ ሂሳብ · $provider';
  }

  @override
  String get chipNoBalance => 'ቀሪ ሂሳብ አልተነበበም';

  @override
  String get chipLiveReply => 'የቀጥታ ምላሽ';

  @override
  String get chipCarrierReply => 'የአገልግሎት አቅራቢ ምላሽ';

  @override
  String get parsedFromCarrier => 'ከአገልግሎት አቅራቢው ምላሽ የተለየ';

  @override
  String get carrierReplyVerbatim => 'የአገልግሎት አቅራቢ ምላሽ (በቃል በቃል)';

  @override
  String get noRecognizableAmount =>
      'ምላሹ የሚታወቅ የቀሪ ሂሳብ መጠን አልያዘም፣ ስለዚህ የአገልግሎት አቅራቢው ጥሬ ጽሑፍ ብቻ ታይቷል። ምንም አልተገመተም።';

  @override
  String get noBalanceRead => 'ቀሪ ሂሳብ አልተነበበም። ምንም አልተገመተም ወይም አልተቀመጠም።';

  @override
  String liveReplyAt(String time) {
    return 'የቀጥታ ምላሽ በ$time ተቀብሏል። መተግበሪያው የኔትወርኩን ጽሑፍ በቃል በቃል ያሳያል።';
  }
}
