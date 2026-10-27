import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Full-screen playful backdrop shared by both tabs: a soft gradient,
/// pastel glow blobs, and a faint dot grid that reads like a game board.
class GameBackdrop extends StatelessWidget {
  const GameBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final dotColor = light
        ? AppColors.gameInkLight.withValues(alpha: 0.045)
        : Colors.white.withValues(alpha: 0.035);
    final blobAlpha = light ? 0.2 : 0.1;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: light
                  ? const [
                      AppColors.backdropTopLight,
                      AppColors.backdropBottomLight,
                    ]
                  : const [
                      AppColors.backdropTopDark,
                      AppColors.backdropBottomDark,
                    ],
            ),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(painter: _DotGridPainter(color: dotColor)),
        ),
        Positioned(
          top: -76,
          right: -46,
          child: _GameBlob(
            color: AppColors.gameYellow.withValues(alpha: blobAlpha),
            size: 210,
          ),
        ),
        Positioned(
          top: 285,
          left: -74,
          child: _GameBlob(
            color: AppColors.gameBlue.withValues(alpha: blobAlpha * 0.9),
            size: 185,
          ),
        ),
        Positioned(
          bottom: 80,
          right: -64,
          child: _GameBlob(
            color: AppColors.gamePurple.withValues(alpha: blobAlpha * 0.75),
            size: 170,
          ),
        ),
        child,
      ],
    );
  }
}

class _GameBlob extends StatelessWidget {
  const _GameBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = 26.0;
    for (var x = 0.0; x <= size.width; x += step) {
      for (var y = 0.0; y <= size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => oldDelegate.color != color;
}
