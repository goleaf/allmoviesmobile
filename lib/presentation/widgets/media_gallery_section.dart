import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/models/image_model.dart';
import '../../data/services/api_config.dart';
import 'media_image.dart';
import '../../providers/media_gallery_provider.dart';

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
              final gradientOverlay = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              );
              return GestureDetector(
                onTap: () => _openFullScreenImage(context, image, type),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: MediaImage(
                      path: image.filePath,
                      type: switch (type) {
                        _GalleryImageType.poster => MediaImageType.poster,
                        _GalleryImageType.backdrop => MediaImageType.backdrop,
                        _GalleryImageType.still => MediaImageType.still,
                      },
                      size: switch (type) {
                        _GalleryImageType.poster => MediaImageSize.w342,
                        _GalleryImageType.backdrop => MediaImageSize.w780,
                        _GalleryImageType.still => MediaImageSize.w300,
                      },
                      fit: BoxFit.cover,
                      placeholder: Container(color: Colors.grey[300]),
                      errorWidget: Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                      gradientOverlay: gradientOverlay,
                      showOverlayWhenLoading: true,
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
    ImageModel image,
    _GalleryImageType type,
  ) async {
    final imageUrl = image.filePath;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final overlayGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.75),
            Colors.black.withOpacity(0.45),
          ],
        );

        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(gradient: overlayGradient),
                ),
              ),
            ),
            Dialog(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      child: Center(
                        child: MediaImage(
                          path: imageUrl,
                          type: switch (type) {
                            _GalleryImageType.poster => MediaImageType.poster,
                            _GalleryImageType.backdrop => MediaImageType.backdrop,
                            _GalleryImageType.still => MediaImageType.still,
                          },
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
                          gradientOverlay: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.65),
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                            stops: const [0, 0.5, 1],
                          ),
                          showOverlayWhenLoading: true,
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
                ],
              ),
            ),
          ],
        );
      },
    );
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
