// Generates Saricom's brand assets (app icon, adaptive-icon foreground,
// splash logo) with the pure-Dart `image` package — no design tool needed.
//
//   dart run tool/generate_assets.dart
import 'dart:io';

import 'package:image/image.dart' as img;

// Brand colors (ARGB ints from the app palette).
const int _bgTop = 0xFF00813F; // bright emerald top
const int _bgBottom = 0xFF005A33; // deep green bottom
const int _phoneBody = 0xFF053A22; // phone silhouette
const int _phoneBezel = 0xFF0A4C30; // thin bezel highlight
const int _cardBorder = 0xFFDDE5DF; // voucher border
const int _white = 0xFFFFFFFF;
const int _digitBar = 0xFF008C45; // primary green digits
const int _scanAccent = 0xFF7BE3AE; // scan-bracket green

img.Color _c(int argb) {
  final r = (argb >> 16) & 0xFF;
  final g = (argb >> 8) & 0xFF;
  final b = argb & 0xFF;
  final a = (argb >> 24) & 0xFF;
  return img.ColorUint8.rgba(r, g, b, a);
}

void main() {
  Directory('assets/branding').createSync(recursive: true);

  final icon = drawScene(1024, margin: 0.16, withPhone: true);
  File('assets/branding/app_icon.png').writeAsBytesSync(img.encodePng(icon));

  // Adaptive-icon foreground keeps content inside the ~66% safe area,
  // transparent elsewhere (the launcher paints the green background).
  final foreground = drawScene(1024, margin: 0.34, withPhone: false);
  File('assets/branding/app_icon_foreground.png')
      .writeAsBytesSync(img.encodePng(foreground));

  // Splash logo: brand motif on a transparent background.
  final splash = drawScene(768, margin: 0.24, withPhone: false);
  File('assets/branding/splash_logo.png').writeAsBytesSync(img.encodePng(splash));

  stdout.writeln('brand assets written to assets/branding/');
}

/// Draws the motif: (phone silhouette) + white voucher + digit bars +
/// light-green scan brackets, centered with [margin] of breathing room.
///
/// [withPhone] paints the full square badge (app icon); otherwise the motif
/// floats on transparent pixels (adaptive foreground / splash).
img.Image drawScene(
  int size, {
  required double margin,
  required bool withPhone,
}) {
  final c = img.Image(width: size, height: size, numChannels: 4);

  if (withPhone) {
    _verticalGradient(c, _bgTop, _bgBottom);

    final m = (size * margin).round();
    img.fillRect(
      c,
      x1: m,
      y1: m,
      x2: m + (size - 2 * m),
      y2: m + (size - 2 * m),
      radius: size * 0.16,
      color: _c(_phoneBody),
    );
    final inset = (size * 0.025).round();
    img.fillRect(
      c,
      x1: m + inset,
      y1: m + inset,
      x2: m + inset + (size - 2 * m - 2 * inset),
      y2: m + inset + (size - 2 * m - 2 * inset),
      radius: size * 0.13,
      color: _c(_phoneBezel),
    );
  }

  // White voucher card (landscape) centered slightly low.
  final cardW = (size * (withPhone ? 0.62 : 0.70)).round();
  final cardH = (cardW * 0.42).round();
  final cardX = (size - cardW) ~/ 2;
  final cardY =
      (size - cardH) ~/ 2 + (size * (withPhone ? 0.01 : 0.03)).round();

  // Border pass, then fill inset by 2px so the border reads at all sizes.
  img.fillRect(
    c,
    x1: cardX,
    y1: cardY,
    x2: cardX + cardW,
    y2: cardY + cardH,
    radius: cardH * 0.19,
    color: _c(_cardBorder),
  );
  img.fillRect(
    c,
    x1: cardX + 2,
    y1: cardY + 2,
    x2: cardX + cardW - 2,
    y2: cardY + cardH - 2,
    radius: cardH * 0.17,
    color: _c(_white),
  );

  // Digit groups: three equal bars + one short bar (a counting voucher).
  final barH = (cardH * 0.17).round();
  final barY = (cardH - barH) ~/ 2 + cardY;
  final groupW = (cardW * 0.155).round();
  final gap = (cardW * 0.04).round();
  var barX = cardX + (cardW * 0.075).round();
  for (var i = 0; i < 3; i++) {
    img.fillRect(
      c,
      x1: barX,
      y1: barY,
      x2: barX + groupW,
      y2: barY + barH,
      radius: barH / 2,
      color: _c(_digitBar),
    );
    barX += groupW + gap;
  }
  img.fillRect(
    c,
    x1: barX,
    y1: barY,
    x2: barX + (groupW * 0.55).round(),
    y2: barY + barH,
    radius: barH / 2,
    color: _c(_scanAccent),
  );

  final space = (size * (withPhone ? 0.055 : 0.07)).round();
  _drawScanBrackets(
    c,
    left: cardX - space,
    top: cardY - space,
    width: cardW + 2 * space,
    height: cardH + 2 * space,
  );

  return c;
}

/// Four L-shaped corner brackets around the given rectangle.
void _drawScanBrackets(
  img.Image c, {
  required int left,
  required int top,
  required int width,
  required int height,
}) {
  final right = left + width - 1;
  final bottom = top + height - 1;
  final arm = (height * 0.24).round();
  final t = (arm / 3.5).round().clamp(4, 18);

  // Top-left
  img.fillRect(
    c,
    x1: left,
    y1: top,
    x2: left + arm,
    y2: top + t,
    color: _c(_scanAccent),
  );
  img.fillRect(
    c,
    x1: left,
    y1: top,
    x2: left + t,
    y2: top + arm,
    color: _c(_scanAccent),
  );
  // Top-right
  img.fillRect(
    c,
    x1: right - arm,
    y1: top,
    x2: right,
    y2: top + t,
    color: _c(_scanAccent),
  );
  img.fillRect(
    c,
    x1: right - t,
    y1: top,
    x2: right,
    y2: top + arm,
    color: _c(_scanAccent),
  );
  // Bottom-left
  img.fillRect(
    c,
    x1: left,
    y1: bottom - t,
    x2: left + arm,
    y2: bottom,
    color: _c(_scanAccent),
  );
  img.fillRect(
    c,
    x1: left,
    y1: bottom - arm,
    x2: left + t,
    y2: bottom,
    color: _c(_scanAccent),
  );
  // Bottom-right
  img.fillRect(
    c,
    x1: right - arm,
    y1: bottom - t,
    x2: right,
    y2: bottom,
    color: _c(_scanAccent),
  );
  img.fillRect(
    c,
    x1: right - t,
    y1: bottom - arm,
    x2: right,
    y2: bottom,
    color: _c(_scanAccent),
  );
}

void _verticalGradient(img.Image c, int topColor, int bottomColor) {
  for (var y = 0; y < c.height; y++) {
    final t = y / (c.height - 1);
    img.fillRect(
      c,
      x1: 0,
      y1: y,
      x2: c.width - 1,
      y2: y,
      color: _c(_lerp(topColor, bottomColor, t)),
    );
  }
}

int _lerp(int a, int b, double t) {
  final ar = (a >> 16) & 0xFF, ag = (a >> 8) & 0xFF, ab = a & 0xFF;
  final br = (b >> 16) & 0xFF, bg = (b >> 8) & 0xFF, bb = b & 0xFF;
  final r = (ar + ((br - ar) * t)).round();
  final g = (ag + ((bg - ag) * t)).round();
  final bl = (ab + ((bb - ab) * t)).round();
  return (a & 0xFF000000) | (r << 16) | (g << 8) | bl;
}
