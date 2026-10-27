You can found apk to install im you phone in  https://github.com/natinaelyosef/Ethio-Safaricom-Card-Scanner/tree/main/apk 
# Ethio & Safaricom Card Scanner

Photograph a paper recharge card for **Ethio telecom** or **Safaricom
Ethiopia**, review the PIN the app read on-device, then recharge and check
your balance **inside the app** — no dialer, browser, or other app is
opened. One Flutter codebase for Android and iOS (Android is fully
featured; iOS cannot launch USSD by platform rule).

**Offline-first and private:** camera, gallery, OCR, PIN editing and
validation all work with no connection. OCR runs fully on device (Google
ML Kit); no card photo or voucher code ever leaves the phone, no photos
are uploaded, and no code appears in logs. History is opt-in (off by
default) and stores only *masked* codes — the first 4 digits, digit
count, provider and time.

## Verified USSD flows

| Carrier | Recharge | Balance |
| --- | --- | --- |
| Ethio telecom | `*805*<voucherDigits>#` | `*804#` |
| Safaricom Ethiopia | `*705*<voucherDigits>#` | `*704#` |

**Everything runs inside the app on Android — the phone dialer is never
opened.** “Check balance” on the Home screen sends the balance query
directly and shows the network's own reply in an inline panel on the same
screen; the parsed amount is displayed first, with the raw carrier text
below it.

When a device refuses the in-app USSD API, the carrier's own pop-up is
shown instead. Android normally hides that dialog from apps; the app can
read it through its **opt-in accessibility service** (Settings → Carrier
USSD reader). The service only watches phone/dialer windows for a few
seconds around an app request, stores nothing, and can be disabled in
Android accessibility settings at any time.

1. Primary: `TelephonyManager.sendUssdRequest` sends the code straight to
   the network from inside the app and **the network's own reply is shown
   in an in-app dialog** (your balance text, the recharge confirmation,
   even multi-step USSD prompts).
2. Fallback (device refuses in-app USSD): a direct dial starts the
   session so the carrier's own pop-up appears *over* this screen.
   Requires the "Phone" permission, which is requested only when needed.
3. If both are blocked, the app explains inside its own UI and offers the
   copy option — no other application is ever opened.

The app never claims the recharge succeeded: the carrier's reply or
confirmation SMS is the authority.

## Architecture

```text
lib/
  main.dart            entry point; builds settings/history services and the app
  app.dart             MaterialApp: light/dark themes, home + settings routes
  core/
    app_info.dart      app identity + privacy copy helpers
    theme/app_theme.dart  bespoke light/dark color system (see palette below)
  models/
    telecom_provider.dart  enum with per-carrier labels, hints and icons
  logic/
    code_parser.dart   OCR-token -> voucher-candidate rewrite engine
    ussd_builder.dart  builds *805*<digits># etc., validates shapes
    ussd_reply.dart    parses balance amounts out of carrier USSD replies
  services/
    ocr_service.dart   ML Kit on photos: rotation, contrast and center-crop probes
    ussd_service.dart  Android platform channel (in-app USSD) + manual path
    settings_service.dart  SharedPreferences-backed user settings
    history_service.dart   opt-in, 30-entry, masked history store
  state/
    app_controller.dart    theme + default provider + historyEnabled
    home_controller.dart   stage machine: idle → scanning → review → ready
  screens/
    home_screen.dart       scan/confirm-flow UI, inline balance, recharge dialogs
    settings_screen.dart   theme, default provider, history + privacy tips
  widgets/
    ...                    scan overlay, code panels, provider selector, etc.
```

### The scan flow

1. **Open the camera and hold the card in the frame** — scanning starts
   automatically: a still photo (`takePicture`, so rotation is correct) is
   captured about 0.7 s after the camera opens and retried every ~1.2 s
   until a PIN is read. An optional shutter and the gallery button remain
   available.
2. **Choose an existing image** — the gallery button opens the system
   photo picker; the image is analyzed through the same pipeline.
3. **Rotation, contrast and crop probes** — ML Kit's on-device latin
   recognizer first reads the file as captured, then retries upright
   rotations (the last successful rotation is tried first), then a
   grayscale/contrast-normalized version, then a contrast-normalized
   center crop (72% × 55%) to kill busy backgrounds. The first
   convincing digit run wins; temporary probe files are deleted
   immediately after reading.
4. **Largest number = PIN** — all candidate digit runs are compared
   numerically (length first, then value): the largest number printed on
   the card is selected as the PIN, within the provider's typical length
   window; the 6–24 hard bounds are the fallback. Spaces and separators
   are stripped; no digits are ever added or invented.
5. **Review with the photo on screen** — the recognized PIN appears in an
   editable field directly under the captured photo. The user compares
   against the paper card and can fix any digit.
6. **Retake or switch images** — “Retake” reopens the camera; “Gallery”
   picks another image; “Discard” clears everything.
7. **One confirmation, then automatic recharge** — “Confirm & Recharge”
   locks the edited PIN and immediately runs the USSD recharge on
   Android. The carrier's reply is shown in-app; the Ready panel stays
   available for a retry, and the same PIN cannot be submitted twice
   within 3 minutes without an explicit warning.
8. **Balance check** — “Check balance” runs in place: a spinner, then the
   carrier's live reply. When the reply contains a recognizable amount
   (ETB / Birr / ብር), the parsed figure is shown prominently with the raw
   text underneath; otherwise only the raw reply and an honest note are
   shown. A balance is never fabricated.
9. **History (opt-in)** — Settings → History to keep the last 30
   *masked* entries.

## Getting started

```bash
flutter pub get
flutter test          # parser, USSD building, replies, services, UI
flutter analyze
```

### iOS

```bash
cd ios && pod install && cd ..
flutter run --release
```

Camera and photo-library access are declared in `ios/Runner/Info.plist`
(`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`); the
bundle id is `com.saricom.app`. Sign with your own Apple team in Xcode
(`Runner.xcodeproj`). iOS cannot launch USSD codes, so recharge and
balance fall back to a copy-and-dial sheet — the UI says so explicitly.

### Android release APK

Debug-signed sideloadable APK (built with `flutter build apk --release`):

```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk (~82 MB; the ML Kit
#   latin model accounts for most of it)
```

For Play-store-grade signing, generate a keystore and add
`android/key.properties` — the Gradle file already wires it in and
falls back to debug signing when it is absent:

```properties
storeFile=C:/path/to/keystore.jks
storePassword=...
keyAlias=saricom
keyPassword=...
```

then rebuild. `key.properties` must never be committed.

### Brand assets

`tool/generate_assets.dart` draws the icon/motif with the pure-Dart
`image` package (no design tools). Regenerate everything with:

```bash
dart run tool/generate_assets.dart   # writes assets/branding/*.png
dart run flutter_launcher_icons      # Android/iOS launcher icons
dart run flutter_native_splash:create
```

## Known limits

- *iOS USSD*: apps cannot launch telephony codes remotely; iOS keeps the
  copy-and-dial sheet and does not auto-dial after confirmation.
- *In-app USSD support*: a few aggressive OEMs (some Samsung/Xiaomi
  builds) refuse `sendUssdRequest`; those devices fall back to the
  carrier's own pop-up over the app. Enable the opt-in USSD reader in
  Settings to capture and parse that dialog; without it, the app shows a
  clear “session started in the carrier pop-up” message instead of
  inventing a result.
- *Accessibility reader*: it is disabled until the user enables it in
  Android settings; the accessibility config is limited to phone/dialer
  packages and it only reads during an app request. If the OEM's USSD
  dialog is hosted by an unusual package, capture may not trigger — the
  raw session still works.
- *Balance parsing*: amounts are parsed only from currency-adjacent
  numbers (ETB, Birr, Br, ብር) or an explicit balance phrase. Replies
  without one show raw text only.
- *Digit length*: carriers do not publish exact voucher lengths, so
  validation stays generic (warn 10–20, hard reject <6 or >24).
- *OCR accuracy*: on-device recognition handles rotation, moderate
  shadow and low contrast, but the review step exists because errors are
  still possible — the printed card is always the authority, and the
  automatic recharge still requires the single “Confirm & Recharge” tap.
- *Scanner speed*: auto-scan reads roughly one photo every 1.2 s and
  needs no shutter tap; the manual shutter and gallery stay available.
"# Ethio-Safaricom-Card-Scanner" 
