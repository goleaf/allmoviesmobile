import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/utils/media_image_helper.dart';
import 'media_image.dart';

class ZoomableImage extends StatelessWidget {
  const ZoomableImage({
    super.key,
    required this.path,
    required this.type,
    this.size,
    this.overlayGradient,
    this.blurSigma = 0,
    this.onClose,
    this.heroTag,
    this.backgroundColor = Colors.transparent,
  });

  final String? path;
  final MediaImageType type;
  final MediaImageSize? size;
  final Gradient? overlayGradient;
  final double blurSigma;
  final VoidCallback? onClose;
  final String? heroTag;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final closeTooltip = MaterialLocalizations.of(context).closeButtonTooltip;

    Widget content = InteractiveViewer(
      panEnabled: true,
      minScale: 1,
      maxScale: 5,
      child: Center(
        child: MediaImage(
          path: path,
          type: type,
          size: size ??
              MediaImageHelper.resolvePreferredSize(
                context,
                type: type,
                fallback: MediaImageSize.original,
              ),
          fit: BoxFit.contain,
          placeholder: Container(
            color: Colors.black.withOpacity(0.2),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: const Icon(
            Icons.broken_image,
            color: Colors.white70,
            size: 48,
          ),
        ),
      ),
    );

    if (heroTag != null) {
      content = Hero(tag: heroTag!, child: content);
    }

    return Material(
      color: backgroundColor,
      child: Stack(
        children: [
          Positioned.fill(child: content),
          if (blurSigma > 0)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurSigma,
                    sigmaY: blurSigma,
                  ),
                  child: const SizedBox(),
                ),
              ),
            ),
          if (overlayGradient != null)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: overlayGradient),
              ),
            ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Tooltip(
                message: closeTooltip,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
