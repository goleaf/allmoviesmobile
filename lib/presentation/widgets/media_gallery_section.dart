import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/media_image_helper.dart';
import '../../data/models/media_images.dart';
import 'image_gallery.dart';

class MediaGallerySection extends StatelessWidget {
  const MediaGallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return ImageGallery(
      title: loc.t('movie.images'),
      errorFallbackMessage: loc.t('errors.load_failed'),
      retryLabel: loc.t('common.retry'),
      buildSections: (context, images) => _buildSections(loc, images),
    );
  }

  List<ImageGallerySectionConfig> _buildSections(
    AppLocalizations loc,
    MediaImages images,
  ) {
    return [
      ImageGallerySectionConfig(
        title: loc.t('movie.posters'),
        images: images.posters,
        imageType: MediaImageType.poster,
        imageSize: MediaImageSize.w342,
        previewSize: MediaImageSize.w154,
        rowHeight: 220,
        fallbackAspectRatio: 0.67,
      ),
      ImageGallerySectionConfig(
        title: loc.t('movie.backdrops'),
        images: images.backdrops,
        imageType: MediaImageType.backdrop,
        imageSize: MediaImageSize.w780,
        previewSize: MediaImageSize.w300,
        rowHeight: 150,
        fallbackAspectRatio: 16 / 9,
      ),
      ImageGallerySectionConfig(
        title: loc.t('movie.stills'),
        images: images.stills,
        imageType: MediaImageType.still,
        imageSize: MediaImageSize.w300,
        previewSize: MediaImageSize.w92,
        rowHeight: 150,
        fallbackAspectRatio: 16 / 9,
      ),
    ];
  }
}
