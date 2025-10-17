import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/models/image_model.dart';
import 'image_gallery.dart';
import 'media_image.dart';

class ZoomableImage extends StatelessWidget {
  const ZoomableImage({
    super.key,
    required this.image,
    required this.type,
    this.heroTag,
    this.backgroundColor = Colors.black,
    this.overlayGradient,
    this.overlayBlurSigmaX,
    this.overlayBlurSigmaY,
    this.additionalOverlayBuilder,
  });

  final ImageModel image;
  final GalleryImageType type;
  final String? heroTag;
  final Color backgroundColor;
  final Gradient? overlayGradient;
  final double? overlayBlurSigmaX;
  final double? overlayBlurSigmaY;
  final WidgetBuilder? additionalOverlayBuilder;

  static Future<void> show(
    BuildContext context, {
    required ImageModel image,
    required GalleryImageType type,
    String? heroTag,
    Color backgroundColor = Colors.black,
    Gradient? overlayGradient,
    double? overlayBlurSigmaX,
    double? overlayBlurSigmaY,
    WidgetBuilder? additionalOverlayBuilder,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return ZoomableImage(
          image: image,
          type: type,
          heroTag: heroTag,
          backgroundColor: backgroundColor,
          overlayGradient: overlayGradient,
          overlayBlurSigmaX: overlayBlurSigmaX,
          overlayBlurSigmaY: overlayBlurSigmaY,
          additionalOverlayBuilder: additionalOverlayBuilder,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: backgroundColor)),
          if (overlayBlurSigmaX != null || overlayBlurSigmaY != null)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: overlayBlurSigmaX ?? 0,
                  sigmaY: overlayBlurSigmaY ?? 0,
                ),
                child: const SizedBox.shrink(),
              ),
            ),
          if (overlayGradient != null)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: overlayGradient),
              ),
            ),
          Positioned.fill(
            child: InteractiveViewer(
              child: Center(
                child: _buildHeroWrapper(
                  MediaImage(
                    path: image.filePath,
                    type: _mediaImageTypeFor(type),
                    size: MediaImageSize.original,
                    fit: BoxFit.contain,
                    placeholder: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (additionalOverlayBuilder != null)
            Positioned.fill(child: additionalOverlayBuilder!(context)),
        ],
      ),
    );
  }

  Widget _buildHeroWrapper(Widget child) {
    if (heroTag == null || heroTag!.isEmpty) {
      return child;
    }

    return Hero(tag: heroTag!, child: child);
  }

  static MediaImageType _mediaImageTypeFor(GalleryImageType type) {
    switch (type) {
      case GalleryImageType.poster:
        return MediaImageType.poster;
      case GalleryImageType.backdrop:
        return MediaImageType.backdrop;
      case GalleryImageType.still:
        return MediaImageType.still;
    }
  }
}
