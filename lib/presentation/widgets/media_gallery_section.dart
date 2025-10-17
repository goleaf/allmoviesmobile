import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/models/image_model.dart';
import '../../providers/media_gallery_provider.dart';
import 'image_gallery.dart';
import 'zoomable_image.dart';

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
                ImageGallery(
                  title: loc.t('movie.posters'),
                  images: images.posters,
                  type: GalleryImageType.poster,
                  onImageTap: (context, image, index) => _openImage(
                    context,
                    image: image,
                    type: GalleryImageType.poster,
                    index: index,
                  ),
                  heroTagBuilder: (index, image) =>
                      _heroTagFor(GalleryImageType.poster, image, index),
                ),
              if (images.posters.isNotEmpty &&
                  (images.backdrops.isNotEmpty || images.stills.isNotEmpty))
                const SizedBox(height: 16),
              if (images.backdrops.isNotEmpty)
                ImageGallery(
                  title: loc.t('movie.backdrops'),
                  images: images.backdrops,
                  type: GalleryImageType.backdrop,
                  onImageTap: (context, image, index) => _openImage(
                    context,
                    image: image,
                    type: GalleryImageType.backdrop,
                    index: index,
                  ),
                  heroTagBuilder: (index, image) =>
                      _heroTagFor(GalleryImageType.backdrop, image, index),
                ),
              if (images.backdrops.isNotEmpty && images.stills.isNotEmpty)
                const SizedBox(height: 16),
              if (images.stills.isNotEmpty)
                ImageGallery(
                  title: loc.t('movie.stills'),
                  images: images.stills,
                  type: GalleryImageType.still,
                  onImageTap: (context, image, index) => _openImage(
                    context,
                    image: image,
                    type: GalleryImageType.still,
                    index: index,
                  ),
                  heroTagBuilder: (index, image) =>
                      _heroTagFor(GalleryImageType.still, image, index),
                ),
            ],
          ),
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

Future<void> _openImage(
  BuildContext context, {
  required ImageModel image,
  required GalleryImageType type,
  required int index,
}) {
  return ZoomableImage.show(
    context,
    image: image,
    type: type,
    heroTag: _heroTagFor(type, image, index),
  );
}

String _heroTagFor(
  GalleryImageType type,
  ImageModel image,
  int index,
) => 'gallery-${type.name}-${image.filePath}-$index';
