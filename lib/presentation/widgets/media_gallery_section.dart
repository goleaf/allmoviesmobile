import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/media_image_helper.dart';
import '../../providers/media_gallery_provider.dart';
import 'image_gallery.dart';

class MediaGallerySection extends StatelessWidget {
  const MediaGallerySection({
    super.key,
    this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.posterStyle,
    this.backdropStyle,
    this.stillStyle,
    this.thumbnailOverlayGradient,
    this.thumbnailBlurSigma = 0,
    this.dialogOverlayGradient,
    this.dialogBlurSigma = 0,
  });

  final String? title;
  final EdgeInsetsGeometry padding;
  final MediaGalleryRowStyle? posterStyle;
  final MediaGalleryRowStyle? backdropStyle;
  final MediaGalleryRowStyle? stillStyle;
  final Gradient? thumbnailOverlayGradient;
  final double thumbnailBlurSigma;
  final Gradient? dialogOverlayGradient;
  final double dialogBlurSigma;

  static const Gradient _defaultThumbnailGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color.fromARGB(180, 0, 0, 0),
      Color.fromARGB(40, 0, 0, 0),
      Color.fromARGB(0, 0, 0, 0),
    ],
  );

  static const Gradient _defaultDialogGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color.fromARGB(200, 0, 0, 0),
      Color.fromARGB(50, 0, 0, 0),
      Color.fromARGB(0, 0, 0, 0),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Consumer<MediaGalleryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? loc.t('movie.images'),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
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
            title: title ?? loc.t('movie.images'),
            padding: padding,
          );
        }

        final images = provider.images;
        if (images == null || !images.hasAny) {
          return const SizedBox.shrink();
        }

        final sections = <ImageGallerySectionConfig>[];
        if (images.posters.isNotEmpty) {
          final style = posterStyle ?? MediaGalleryRowStyle.posterDefaults;
          sections.add(
            ImageGallerySectionConfig(
              title: loc.t('movie.posters'),
              images: images.posters,
              type: MediaImageType.poster,
              itemHeight: style.height,
              aspectRatio: style.aspectRatio,
              thumbnailSize: style.thumbnailSize,
              previewSize: style.previewSize,
              fullscreenSize: style.fullscreenSize,
              borderRadius: style.borderRadius,
              displayLimit: style.displayLimit,
            ),
          );
        }
        if (images.backdrops.isNotEmpty) {
          final style = backdropStyle ?? MediaGalleryRowStyle.backdropDefaults;
          sections.add(
            ImageGallerySectionConfig(
              title: loc.t('movie.backdrops'),
              images: images.backdrops,
              type: MediaImageType.backdrop,
              itemHeight: style.height,
              aspectRatio: style.aspectRatio,
              thumbnailSize: style.thumbnailSize,
              previewSize: style.previewSize,
              fullscreenSize: style.fullscreenSize,
              borderRadius: style.borderRadius,
              displayLimit: style.displayLimit,
            ),
          );
        }
        if (images.stills.isNotEmpty) {
          final style = stillStyle ?? MediaGalleryRowStyle.stillDefaults;
          sections.add(
            ImageGallerySectionConfig(
              title: loc.t('movie.stills'),
              images: images.stills,
              type: MediaImageType.still,
              itemHeight: style.height,
              aspectRatio: style.aspectRatio,
              thumbnailSize: style.thumbnailSize,
              previewSize: style.previewSize,
              fullscreenSize: style.fullscreenSize,
              borderRadius: style.borderRadius,
              displayLimit: style.displayLimit,
            ),
          );
        }

        return ImageGallery(
          title: title ?? loc.t('movie.images'),
          sections: sections,
          padding: padding,
          thumbnailOverlayGradient:
              thumbnailOverlayGradient ?? _defaultThumbnailGradient,
          thumbnailBlurSigma: thumbnailBlurSigma,
          dialogOverlayGradient:
              dialogOverlayGradient ?? _defaultDialogGradient,
          dialogBlurSigma: dialogBlurSigma,
        );
      },
    );
  }
}

class MediaGalleryRowStyle {
  const MediaGalleryRowStyle({
    required this.height,
    this.aspectRatio,
    this.thumbnailSize,
    this.previewSize,
    this.fullscreenSize,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.displayLimit,
  });

  final double height;
  final double? aspectRatio;
  final MediaImageSize? thumbnailSize;
  final MediaImageSize? previewSize;
  final MediaImageSize? fullscreenSize;
  final BorderRadius borderRadius;
  final int? displayLimit;

  static const MediaGalleryRowStyle posterDefaults = MediaGalleryRowStyle(
    height: 220,
    aspectRatio: 2 / 3,
    thumbnailSize: MediaImageSize.w342,
    previewSize: MediaImageSize.w154,
    fullscreenSize: MediaImageSize.original,
  );

  static const MediaGalleryRowStyle backdropDefaults = MediaGalleryRowStyle(
    height: 150,
    aspectRatio: 16 / 9,
    thumbnailSize: MediaImageSize.w780,
    previewSize: MediaImageSize.w300,
    fullscreenSize: MediaImageSize.original,
  );

  static const MediaGalleryRowStyle stillDefaults = MediaGalleryRowStyle(
    height: 150,
    aspectRatio: 16 / 9,
    thumbnailSize: MediaImageSize.w300,
    previewSize: MediaImageSize.w92,
    fullscreenSize: MediaImageSize.original,
  );
}

class _GalleryErrorMessage extends StatelessWidget {
  const _GalleryErrorMessage({
    required this.message,
    required this.onRetry,
    required this.title,
    required this.padding,
  });

  final String message;
  final Future<void> Function() onRetry;
  final String title;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
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
                  AppLocalizations.of(context).t('errors.load_failed'),
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
                    child: Text(AppLocalizations.of(context).t('common.retry')),
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
