import 'package:flutter/material.dart';

/// Painter for the scanning guide: darkened edges, corner brackets and an
/// animated scan line. Purely cosmetic — OCR reads the whole preview.
class ScanFrameOverlay extends StatefulWidget {
  const ScanFrameOverlay({
    super.key,
    this.darkening = const Color(0x66061208),
    this.accentColor = const Color(0xFF7BE3AE),
    this.lineWidth = 3.5,
  });

  final Color darkening;
  final Color accentColor;
  final double lineWidth;

  @override
  State<ScanFrameOverlay> createState() => _ScanFrameOverlayState();
}

class _ScanFrameOverlayState extends State<ScanFrameOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _scanController,
        builder: (context, _) {
          return CustomPaint(
            painter: _FramePainter(
              progress: _scanController.value,
              darkening: widget.darkening,
              accent: widget.accentColor,
              lineWidth: widget.lineWidth,
            ),
          );
        },
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter({
    required this.progress,
    required this.darkening,
    required this.accent,
    required this.lineWidth,
  });

  final double progress;
  final Color darkening;
  final Color accent;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Frame geometry: a wide rounded rect (voucher-like proportions).
    final frame = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.46),
      width: size.width * 0.86,
      height: size.width * 0.86 * 0.42,
    ).deflate(4);

    // Dark scrim around the frame: four bands.
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(frame, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = darkening);

    // Corner brackets.
    final bracket = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..color = accent;

    const arm = 26.0;
    const r = 16.0;
    final points = <Offset, ({bool right, bool down})>{
      Offset(frame.left, frame.top): (right: false, down: false),
      Offset(frame.right, frame.top): (right: true, down: false),
      Offset(frame.left, frame.bottom): (right: false, down: true),
      Offset(frame.right, frame.bottom): (right: true, down: true),
    };
    points.forEach((corner, flags) {
      final dx = flags.right ? -1 : 1;
      final dy = flags.down ? -1 : 1;
      final alongX = Offset(corner.dx + dx * arm, corner.dy);
      final alongY = Offset(corner.dx, corner.dy + dy * arm);
      final midX = Offset(corner.dx + dx * arm, corner.dy + dy * r);
      final midY = Offset(corner.dx + dx * r, corner.dy + dy * arm);
      final pathX = Path()
        ..moveTo(alongX.dx, alongX.dy)
        ..lineTo(midX.dx, midX.dy)
        ..quadraticBezierTo(corner.dx, corner.dy, midY.dx, midY.dy)
        ..lineTo(alongY.dx, alongY.dy);
      canvas.drawPath(pathX, bracket);
    });

    // Animated scan line inside the frame.
    final t = 0.15 + 0.7 * progress;
    final y = frame.top + frame.height * t;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = accent.withValues(alpha: 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(frame.left + 14, y, frame.right - 14, y + 2.2),
        const Radius.circular(2),
      ),
      line,
    );

    // Hint text baseline under the frame.
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Align the voucher number inside the frame',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.92),
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(size.width / 2 - textPainter.width / 2, frame.bottom + 10),
    );
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
