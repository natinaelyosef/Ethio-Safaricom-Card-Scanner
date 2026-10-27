import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../state/home_controller.dart';
import 'scan_frame_overlay.dart';

/// The camera panel shown while the Home stage is `scanning`.
///
/// Layout: live preview with the scan frame overlay, a status strip, and a
/// toolbar with torch, gallery, a large shutter, manual entry and stop.
/// An auto-capture assist runs behind the scenes, so the strip explains
/// that tapping the shutter is optional.
class ScanCameraPanel extends StatelessWidget {
  const ScanCameraPanel({
    super.key,
    required this.controller,
    required this.onShutter,
    required this.onGallery,
    required this.onTorch,
    required this.onManual,
    required this.onStop,
    required this.onOpenCamera,
  });

  final HomeController controller;
  final VoidCallback onShutter;
  final VoidCallback onGallery;
  final VoidCallback onTorch;
  final VoidCallback onManual;
  final VoidCallback onStop;
  final VoidCallback onOpenCamera;

  @override
  Widget build(BuildContext context) {
    final camera = controller.camera;
    final light = Theme.of(context).brightness == Brightness.light;

    final Widget body;
    if (camera != null && camera.value.isInitialized) {
      body = _LivePreview(controller: controller, camera: camera);
    } else {
      body = _Placeholder(onManual: onManual, onOpenCamera: onOpenCamera);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color: light
              ? AppColors.gameInkLight.withValues(alpha: 0.5)
              : AppColors.borderDark,
          width: 2.4,
        ),
        boxShadow: AppShadows.of(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radius - 2),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Color(0xFF0C130E)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              body,
              _Toolbar(
                controller: controller,
                onShutter: onShutter,
                onGallery: onGallery,
                onTorch: onTorch,
                onManual: onManual,
                onStop: onStop,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.onManual, required this.onOpenCamera});

  final VoidCallback onManual;
  final VoidCallback onOpenCamera;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AspectRatio(
      aspectRatio: 3 / 2.4,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFF0C130E)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.document_scanner_rounded,
                size: 40,
                color: Color(0xFF7BE3AE),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.cameraPaused,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.reopenCameraOrTypePin,
                style: const TextStyle(
                  color: Color(0xFF9AA8A0),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5ED39B),
                      foregroundColor: const Color(0xFF04301C),
                    ),
                    onPressed: onOpenCamera,
                    icon: const Icon(Icons.photo_camera_rounded, size: 18),
                    label: Text(l10n.openCamera),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7BE3AE),
                      side: const BorderSide(color: Color(0xFF3A5245)),
                      backgroundColor: Colors.transparent,
                    ),
                    onPressed: onManual,
                    child: Text(
                      l10n.typeCode,
                      style: const TextStyle(color: Color(0xFFDCEDE3)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.controller, required this.camera});

  final HomeController controller;
  final CameraController camera;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return AspectRatio(
              aspectRatio: camera.value.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(camera),
                  const IgnorePointer(child: ScanFrameOverlay()),
                  if (controller.busy || controller.isAutoAnalyzing)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.55),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF7BE3AE),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.isAutoAnalyzing
                                  ? l10n.autoReadingCard
                                  : l10n.analyzingPhoto,
                              style: const TextStyle(
                                color: Color(0xFFDCEDE3),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        Container(
          width: double.infinity,
          color: Colors.black.withValues(alpha: 0.55),
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          child: Row(
            children: [
              const Icon(
                Icons.center_focus_strong_rounded,
                size: 16,
                color: Color(0xFF7BE3AE),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.liveText.isNotEmpty
                      ? l10n.readingLive(controller.liveText)
                      : controller.autoCaptureActive
                      ? l10n.autoScanningHint
                      : l10n.scanAutoReadHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFDCEDE3),
                    fontSize: 12.5,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.onShutter,
    required this.onGallery,
    required this.onTorch,
    required this.onManual,
    required this.onStop,
  });

  final HomeController controller;
  final VoidCallback onShutter;
  final VoidCallback onGallery;
  final VoidCallback onTorch;
  final VoidCallback onManual;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final camera = controller.camera;
    final live = camera != null && camera.value.isInitialized;
    final shutterEnabled = live && !controller.busy;
    final l10n = AppLocalizations.of(context);

    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: controller.torchOn ? l10n.torchOff : l10n.torchOn,
            icon: Icon(
              controller.torchOn
                  ? Icons.flashlight_on_rounded
                  : Icons.flashlight_off_rounded,
              color: Colors.white,
            ),
            onPressed: live ? onTorch : null,
          ),
          IconButton(
            tooltip: l10n.chooseFromGallery,
            icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
            onPressed: controller.busy ? null : onGallery,
          ),
          // Large shutter (optional — the camera captures automatically).
          Semantics(
            button: true,
            label: l10n.captureNowOptional,
            child: InkWell(
              onTap: shutterEnabled ? onShutter : null,
              customBorder: const CircleBorder(),
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: shutterEnabled
                          ? const Color(0xFF5ED39B)
                          : const Color(0xFF2E4A3B),
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.typePinManually,
            icon: const Icon(Icons.keyboard_rounded, color: Colors.white),
            onPressed: controller.busy ? null : onManual,
          ),
          IconButton(
            tooltip: l10n.stopCamera,
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: controller.busy ? null : onStop,
          ),
        ],
      ),
    );
  }
}
