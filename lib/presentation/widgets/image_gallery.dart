import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/image_model.dart';
import '../../data/models/media_images.dart';
import '../../providers/media_gallery_provider.dart';
import '../../core/utils/media_image_helper.dart';
import 'media_image.dart';
import 'zoomable_image.dart';

/// Defines a single section to render inside the [ImageGallery].
class ImageGallerySectionConfig {
  const ImageGallerySectionConfig({
    required this.title,
    required this.images,
    required this.imageType,
    this.imageSize,
    this.previewSize,
    this.rowHeight,
    this.fallbackAspectRatio,
    this.imageBorderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  /// Section title displayed above the carousel.
  final String title;

  /// Collection of images to render in the carousel.
  final List<ImageModel> images;

  /// Media image type used to resolve CDN URLs.
  final MediaImageType imageType;

  /// Preferred high-resolution size for list thumbnails.
  final MediaImageSize? imageSize;

  /// Optional low-resolution preview size.
  final MediaImageSize? previewSize;

  /// Fixed row height. Defaults depend on [imageType] if omitted.
  final double? rowHeight;

  /// Aspect ratio fallback when metadata is missing.
  final double? fallbackAspectRatio;

  /// Border radius applied to each thumbnail.
  final BorderRadius imageBorderRadius;
}

/// A reusable gallery widget that consumes a [MediaGalleryProvider].
class ImageGallery extends StatelessWidget {
  const ImageGallery({
    super.key,
    required this.title,
    required this.errorFallbackMessage,
    required this.retryLabel,
    required this.buildSections,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.sectionSpacing = 16,
  });

  /// Main gallery title.
  final String title;

  /// Message displayed when loading fails and no provider message is available.
  final String errorFallbackMessage;

  /// Label for the retry button on error state.
  final String retryLabel;

  /// Builds the sections shown when images are successfully loaded.
  final List<ImageGallerySectionConfig> Function(
    BuildContext context,
    MediaImages images,
  ) buildSections;

  /// Outer padding for the gallery container.
  final EdgeInsets padding;

  /// Spacing between gallery sections.
  final double sectionSpacing;

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaGalleryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _GalleryContainer(
            padding: padding,
            title: title,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.hasError) {
          return _GalleryErrorMessage(
            title: title,
            message: provider.errorMessage ?? errorFallbackMessage,
            retryLabel: retryLabel,
            onRetry: provider.refresh,
            padding: padding,
          );
        }

        final images = provider.images;
        if (images == null || !images.hasAny) {
          return const SizedBox.shrink();
        }

        final sections = buildSections(context, images)
            .where((section) => section.images.isNotEmpty)
            .toList();
        if (sections.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GalleryTitle(title: title),
              const SizedBox(height: 12),
              for (int index = 0; index < sections.length; index++) ...[
                _GalleryRow(config: sections[index]),
                if (index < sections.length - 1)
                  SizedBox(height: sectionSpacing),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _GalleryRow extends StatelessWidget {
  const _GalleryRow({required this.config});

  final ImageGallerySectionConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rowHeight = config.rowHeight ?? _defaultRowHeight(config.imageType);
    final fallbackAspectRatio =
        config.fallbackAspectRatio ?? _defaultAspectRatio(config.imageType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                config.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${config.images.length}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: rowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final image = config.images[index];
              final aspectRatio = image.aspectRatio > 0
                  ? image.aspectRatio
                  : fallbackAspectRatio;

              return GestureDetector(
                onTap: () => ZoomableImageDialog.show(
                  context,
                  imagePath: image.filePath,
                  type: config.imageType,
                ),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: ClipRRect(
                    borderRadius: config.imageBorderRadius,
                    child: MediaImage(
                      path: image.filePath,
                      type: config.imageType,
                      size: config.imageSize,
                      previewSize: config.previewSize,
                      fit: BoxFit.cover,
                      placeholder: Container(color: Colors.grey[300]),
                      errorWidget: Container(
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: config.images.length,
          ),
        ),
      ],
    );
  }
}

class _GalleryContainer extends StatelessWidget {
  const _GalleryContainer({
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final String title;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GalleryTitle(title: title),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _GalleryTitle extends StatelessWidget {
  const _GalleryTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _GalleryErrorMessage extends StatelessWidget {
  const _GalleryErrorMessage({
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final String title;
  final String message;
  final String retryLabel;
  final Future<void> Function() onRetry;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GalleryTitle(title: title),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onRetry,
                    child: Text(retryLabel),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

double _defaultRowHeight(MediaImageType type) {
  switch (type) {
    case MediaImageType.poster:
      return 220;
    case MediaImageType.backdrop:
    case MediaImageType.still:
      return 150;
    case MediaImageType.profile:
    case MediaImageType.logo:
      return 160;
  }
}

double _defaultAspectRatio(MediaImageType type) {
  switch (type) {
    case MediaImageType.poster:
      return 0.67;
    case MediaImageType.backdrop:
    case MediaImageType.still:
      return 16 / 9;
    case MediaImageType.profile:
      return 2 / 3;
    case MediaImageType.logo:
      return 2.5;
  }
}
