import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Alignment guide shown inside the idle "Scan a paper recharge card" card.
///
/// It previews the rounded scanning frame, corner brackets and sweep line
/// that the live camera overlay uses, and points the user at the Scan
/// button. Purely a guide — the real preview and OCR start only when the
/// camera is opened.
class ScanGuideBox extends StatefulWidget {
  const ScanGuideBox({super.key, this.caption});

  final String? caption;

  @override
  State<ScanGuideBox> createState() => _ScanGuideBoxState();
}

class _ScanGuideBoxState extends State<ScanGuideBox>
    with SingleTickerProviderStateMixin {
  /// One sweep per appearance of the card (the guide is rebuilt every time
  /// the Home screen returns to idle), so nothing keeps ticking while the
  /// screen is idle.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caption =
        widget.caption ?? AppLocalizations.of(context).cameraPreviewCaption;

    return AspectRatio(
      aspectRatio: 16 / 9.4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF101A13), Color(0xFF0A110C)],
            ),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _GuidePainter(
                  progress: _controller.value,
                  accent: AppColors.scanAccent,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 26),
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.scanAccent.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.scanAccent.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.photo_camera_rounded,
                          color: AppColors.scanAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        caption,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFDCEDE3),
                          fontSize: 11.5,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  _GuidePainter({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.5),
      width: size.width * 0.74,
      height: size.width * 0.74 * 0.46,
    ).deflate(3);

    // Soft darkening outside the frame keeps the guide readable.
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(frame, const Radius.circular(14)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = const Color(0x33000000));

    // Rounded frame outline.
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(14)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = accent.withValues(alpha: 0.55),
    );

    // Corner brackets.
    final bracket = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = accent;

    const arm = 20.0;
    const r = 14.0;
    final points = <Offset, ({bool right, bool down})>{
      Offset(frame.left, frame.top): (right: false, down: false),
      Offset(frame.right, frame.top): (right: true, down: false),
      Offset(frame.left, frame.bottom): (right: false, down: true),
      Offset(frame.right, frame.bottom): (right: true, down: true),
    };
    points.forEach((corner, flags) {
      final dx = flags.right ? -1.0 : 1.0;
      final dy = flags.down ? -1.0 : 1.0;
      final alongX = Offset(corner.dx + dx * arm, corner.dy);
      final alongY = Offset(corner.dx, corner.dy + dy * arm);
      final midX = Offset(corner.dx + dx * arm, corner.dy + dy * r);
      final midY = Offset(corner.dx + dx * r, corner.dy + dy * arm);
      final p = Path()
        ..moveTo(alongX.dx, alongX.dy)
        ..lineTo(midX.dx, midX.dy)
        ..quadraticBezierTo(corner.dx, corner.dy, midY.dx, midY.dy)
        ..lineTo(alongY.dx, alongY.dy);
      canvas.drawPath(p, bracket);
    });

    // Sweep line inside the frame.
    final t = 0.18 + 0.64 * progress;
    final y = frame.top + frame.height * t;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(frame.left + 12, y, frame.right - 12, y + 2),
        const Radius.circular(2),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(_GuidePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
