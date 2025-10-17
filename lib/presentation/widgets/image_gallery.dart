import 'package:flutter/material.dart';

import '../../data/models/image_model.dart';
import 'media_image.dart';

/// Enum describing the type of gallery image being displayed.
enum GalleryImageType { poster, backdrop, still }

typedef GalleryImageTapCallback = void Function(
  BuildContext context,
  ImageModel image,
  int index,
);

typedef GalleryOverlayBuilder = Widget? Function(
  BuildContext context,
  ImageModel image,
  int index,
);

typedef GalleryHeroTagBuilder = String? Function(
  int index,
  ImageModel image,
);

class ImageGallery extends StatelessWidget {
  const ImageGallery({
    super.key,
    required this.title,
    required this.images,
    required this.type,
    this.onImageTap,
    this.overlayBuilder,
    this.heroTagBuilder,
    this.itemSpacing = 12,
  });

  final String title;
  final List<ImageModel> images;
  final GalleryImageType type;
  final GalleryImageTapCallback? onImageTap;
  final GalleryOverlayBuilder? overlayBuilder;
  final GalleryHeroTagBuilder? heroTagBuilder;
  final double itemSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${images.length}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: _rowHeightForType(type),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final image = images[index];
              final aspectRatio = image.aspectRatio > 0
                  ? image.aspectRatio
                  : _defaultAspectRatio(type);

              return GestureDetector(
                onTap: () => onImageTap?.call(context, image, index),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: _buildImageItem(context, image, index),
                ),
              );
            },
            separatorBuilder: (_, __) => SizedBox(width: itemSpacing),
            itemCount: images.length,
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem(
    BuildContext context,
    ImageModel image,
    int index,
  ) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MediaImage(
            path: image.filePath,
            type: _mediaImageTypeFor(type),
            size: _mediaImageSizeFor(type),
            fit: BoxFit.cover,
            placeholder: Container(color: Colors.grey[300]),
            errorWidget: Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image),
            ),
          ),
          if (overlayBuilder != null)
            Positioned.fill(
              child: overlayBuilder!(context, image, index) ?? const SizedBox(),
            ),
        ],
      ),
    );

    final heroTag = heroTagBuilder?.call(index, image);
    if (heroTag != null && heroTag.isNotEmpty) {
      content = Hero(tag: heroTag, child: content);
    }

    return content;
  }

  static double _rowHeightForType(GalleryImageType type) {
    switch (type) {
      case GalleryImageType.poster:
        return 220;
      case GalleryImageType.backdrop:
      case GalleryImageType.still:
        return 150;
    }
  }

  static double _defaultAspectRatio(GalleryImageType type) {
    switch (type) {
      case GalleryImageType.poster:
        return 0.67;
      case GalleryImageType.backdrop:
      case GalleryImageType.still:
        return 16 / 9;
    }
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

  static MediaImageSize _mediaImageSizeFor(GalleryImageType type) {
    switch (type) {
      case GalleryImageType.poster:
        return MediaImageSize.w342;
      case GalleryImageType.backdrop:
        return MediaImageSize.w780;
      case GalleryImageType.still:
        return MediaImageSize.w300;
    }
  }
}
