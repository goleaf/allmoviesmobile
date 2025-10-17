import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/utils/media_image_helper.dart';
import '../../data/models/image_model.dart';
import 'media_image.dart';
import 'zoomable_image.dart';

class ImageGallery extends StatelessWidget {
  const ImageGallery({
    super.key,
    required this.title,
    required this.sections,
    this.padding = EdgeInsets.zero,
    this.thumbnailOverlayGradient,
    this.thumbnailBlurSigma = 0,
    this.dialogOverlayGradient,
    this.dialogBlurSigma = 0,
    this.itemSpacing = 12,
    this.onImageTap,
    this.showSectionItemCount = true,
  });

  final String title;
  final List<ImageGallerySectionConfig> sections;
  final EdgeInsetsGeometry padding;
  final Gradient? thumbnailOverlayGradient;
  final double thumbnailBlurSigma;
  final Gradient? dialogOverlayGradient;
  final double dialogBlurSigma;
  final double itemSpacing;
  final Future<void> Function(
    BuildContext context,
    ImageModel image,
    ImageGallerySectionConfig section,
  )?
      onImageTap;
  final bool showSectionItemCount;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...sections
              .where((section) => section.images.isNotEmpty)
              .map((section) => _Section(
                    section: section,
                    showCount: showSectionItemCount,
                    itemSpacing: itemSpacing,
                    thumbnailOverlayGradient: thumbnailOverlayGradient,
                    thumbnailBlurSigma: thumbnailBlurSigma,
                    dialogOverlayGradient: dialogOverlayGradient,
                    dialogBlurSigma: dialogBlurSigma,
                    onImageTap: onImageTap,
                  ))
              .intersperse(const SizedBox(height: 16)),
        ],
      ),
    );
  }
}

class ImageGallerySectionConfig {
  const ImageGallerySectionConfig({
    required this.title,
    required this.images,
    required this.type,
    required this.itemHeight,
    this.aspectRatio,
    this.thumbnailSize,
    this.previewSize,
    this.fullscreenSize,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.displayLimit,
  });

  final String title;
  final List<ImageModel> images;
  final MediaImageType type;
  final double itemHeight;
  final double? aspectRatio;
  final MediaImageSize? thumbnailSize;
  final MediaImageSize? previewSize;
  final MediaImageSize? fullscreenSize;
  final BorderRadius borderRadius;
  final int? displayLimit;

  double get resolvedAspectRatio {
    if (aspectRatio != null) {
      return aspectRatio!;
    }

    switch (type) {
      case MediaImageType.poster:
        return 2 / 3;
      case MediaImageType.backdrop:
      case MediaImageType.still:
        return 16 / 9;
      case MediaImageType.profile:
        return 2 / 3;
      case MediaImageType.logo:
        return 3 / 1;
    }
  }
}

extension<T> on Iterable<T> {
  Iterable<T> intersperse(T separator) sync* {
    var isFirst = true;
    for (final element in this) {
      if (!isFirst) {
        yield separator;
      }
      isFirst = false;
      yield element;
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.section,
    required this.showCount,
    required this.itemSpacing,
    required this.thumbnailOverlayGradient,
    required this.thumbnailBlurSigma,
    required this.dialogOverlayGradient,
    required this.dialogBlurSigma,
    required this.onImageTap,
  });

  final ImageGallerySectionConfig section;
  final bool showCount;
  final double itemSpacing;
  final Gradient? thumbnailOverlayGradient;
  final double thumbnailBlurSigma;
  final Gradient? dialogOverlayGradient;
  final double dialogBlurSigma;
  final Future<void> Function(
    BuildContext context,
    ImageModel image,
    ImageGallerySectionConfig section,
  )?
      onImageTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = section.displayLimit != null
        ? section.images.take(section.displayLimit!).toList()
        : section.images;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                section.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showCount)
              Text(
                '${section.images.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: section.itemHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => SizedBox(width: itemSpacing),
            itemBuilder: (context, index) {
              final image = images[index];
              final heroTag = '${section.type.name}_${image.filePath}_${index}';
              return AspectRatio(
                aspectRatio: section.resolvedAspectRatio,
                child: _GalleryThumbnail(
                  image: image,
                  section: section,
                  overlayGradient: thumbnailOverlayGradient,
                  blurSigma: thumbnailBlurSigma,
                  heroTag: heroTag,
                  onTap: () async {
                    if (onImageTap != null) {
                      await onImageTap!(context, image, section);
                      return;
                    }
                    await _openImageDialog(
                      context: context,
                      image: image,
                      section: section,
                      heroTag: heroTag,
                    );
                  },
                  dialogOverlayGradient: dialogOverlayGradient,
                  dialogBlurSigma: dialogBlurSigma,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openImageDialog({
    required BuildContext context,
    required ImageModel image,
    required ImageGallerySectionConfig section,
    required String heroTag,
  }) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.85),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          child: Stack(
            children: [
              if (dialogBlurSigma > 0)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: dialogBlurSigma,
                      sigmaY: dialogBlurSigma,
                    ),
                    child: const SizedBox(),
                  ),
                ),
              Positioned.fill(
                child: ZoomableImage(
                  path: image.filePath,
                  type: section.type,
                  size: section.fullscreenSize,
                  overlayGradient: dialogOverlayGradient,
                  blurSigma: dialogBlurSigma,
                  heroTag: heroTag,
                  onClose: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GalleryThumbnail extends StatelessWidget {
  const _GalleryThumbnail({
    required this.image,
    required this.section,
    required this.overlayGradient,
    required this.blurSigma,
    required this.heroTag,
    required this.onTap,
    required this.dialogOverlayGradient,
    required this.dialogBlurSigma,
  });

  final ImageModel image;
  final ImageGallerySectionConfig section;
  final Gradient? overlayGradient;
  final double blurSigma;
  final String heroTag;
  final VoidCallback onTap;
  final Gradient? dialogOverlayGradient;
  final double dialogBlurSigma;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: section.borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              MediaImage(
                path: image.filePath,
                type: section.type,
                size: section.thumbnailSize,
                previewSize: section.previewSize,
                fit: BoxFit.cover,
              ),
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
              if (dialogOverlayGradient != null || dialogBlurSigma > 0)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.fullscreen,
                        size: 18,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
