import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/models/image_model.dart';
import '../../data/services/api_config.dart';
import '../../core/utils/media_image_helper.dart';
import 'media_image.dart';
import '../../providers/media_gallery_provider.dart';
import 'image_gallery.dart';

class MediaGallerySection extends StatelessWidget {
  const MediaGallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Consumer<MediaGalleryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.t('movie.images'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }

        if (provider.hasError) {
          return _GalleryErrorMessage(
            message: provider.errorMessage ?? loc.t('errors.load_failed'),
            onRetry: provider.refresh,
          );
        }

        final images = provider.images;
        if (images == null || !images.hasAny) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.t('movie.images'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (images.posters.isNotEmpty)
                _GalleryRow(
                  title: loc.t('movie.posters'),
                  images: images.posters,
                  type: _GalleryImageType.poster,
                ),
              if (images.posters.isNotEmpty &&
                  (images.backdrops.isNotEmpty || images.stills.isNotEmpty))
                const SizedBox(height: 16),
              if (images.backdrops.isNotEmpty)
                _GalleryRow(
                  title: loc.t('movie.backdrops'),
                  images: images.backdrops,
                  type: _GalleryImageType.backdrop,
                ),
              if (images.backdrops.isNotEmpty && images.stills.isNotEmpty)
                const SizedBox(height: 16),
              if (images.stills.isNotEmpty)
                _GalleryRow(
                  title: loc.t('movie.stills'),
                  images: images.stills,
                  type: _GalleryImageType.still,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GalleryRow extends StatelessWidget {
  const _GalleryRow({
    required this.title,
    required this.images,
    required this.type,
  });

  final String title;
  final List<ImageModel> images;
  final _GalleryImageType type;

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
              final heroTag = _heroTagFor(type, index, image);

              return GestureDetector(
                onTap: () =>
                    _openFullScreenImage(context, images, index, type),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: heroTag,
                          child: MediaImage(
                            path: image.filePath,
                            type: switch (type) {
                              _GalleryImageType.poster =>
                                  MediaImageType.poster,
                              _GalleryImageType.backdrop =>
                                  MediaImageType.backdrop,
                              _GalleryImageType.still =>
                                  MediaImageType.still,
                            },
                            size: switch (type) {
                              _GalleryImageType.poster =>
                                  MediaImageSize.w342,
                              _GalleryImageType.backdrop =>
                                  MediaImageSize.w780,
                              _GalleryImageType.still =>
                                  MediaImageSize.w300,
                            },
                            fit: BoxFit.cover,
                            placeholder:
                                Container(color: Colors.grey.shade300),
                            errorWidget: Container(
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.55),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Icon(
                                Icons.open_in_full,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: images.length,
          ),
        ),
      ],
    );
  }

  static double _rowHeightForType(_GalleryImageType type) {
    switch (type) {
      case _GalleryImageType.poster:
        return 220;
      case _GalleryImageType.backdrop:
      case _GalleryImageType.still:
        return 150;
    }
  }

  static double _defaultAspectRatio(_GalleryImageType type) {
    switch (type) {
      case _GalleryImageType.poster:
        return 0.67;
      case _GalleryImageType.backdrop:
      case _GalleryImageType.still:
        return 16 / 9;
    }
  }

  static String _thumbnailUrlFor(ImageModel image, _GalleryImageType type) {
    switch (type) {
      case _GalleryImageType.poster:
        return ApiConfig.getPosterUrl(
          image.filePath,
          size: ApiConfig.posterSizeMedium,
        );
      case _GalleryImageType.backdrop:
      case _GalleryImageType.still:
        return ApiConfig.getBackdropUrl(
          image.filePath,
          size: ApiConfig.backdropSizeMedium,
        );
    }
  }

  static String _fullImageUrlFor(ImageModel image, _GalleryImageType type) {
    switch (type) {
      case _GalleryImageType.poster:
        return ApiConfig.getPosterUrl(
          image.filePath,
          size: ApiConfig.posterSizeOriginal,
        );
      case _GalleryImageType.backdrop:
      case _GalleryImageType.still:
        return ApiConfig.getBackdropUrl(
          image.filePath,
          size: ApiConfig.backdropSizeOriginal,
        );
    }
  }

  static Future<void> _openFullScreenImage(
    BuildContext context,
    List<ImageModel> images,
    int initialIndex,
    _GalleryImageType type,
  ) async {
    final mediaType = _mapToMediaType(type);

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: ImageGallery(
            images: images,
            mediaType: mediaType,
            initialIndex: initialIndex,
            heroTagBuilder: (index, image) =>
                _heroTagFor(type, index, image),
          ),
        );
      },
    );
  }

  static String _heroTagFor(
    _GalleryImageType type,
    int index,
    ImageModel image,
  ) {
    return '${type.name}-${image.filePath}-$index';
  }

  static MediaImageType _mapToMediaType(_GalleryImageType type) {
    switch (type) {
      case _GalleryImageType.poster:
        return MediaImageType.poster;
      case _GalleryImageType.backdrop:
        return MediaImageType.backdrop;
      case _GalleryImageType.still:
        return MediaImageType.still;
    }
  }
}

class _GalleryErrorMessage extends StatelessWidget {
  const _GalleryErrorMessage({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('movie.images'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.t('errors.load_failed'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onRetry,
                    child: Text(loc.t('common.retry')),
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

enum _GalleryImageType { poster, backdrop, still }
