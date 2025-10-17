import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/models/image_model.dart';
import '../../data/models/media_images.dart';
import 'image_gallery.dart';
import 'media_image.dart';

class SeasonImageGallery extends StatelessWidget {
  const SeasonImageGallery({
    super.key,
    required this.seasonNumber,
    required this.images,
  });

  final int seasonNumber;
  final MediaImages images;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final rows = <Widget>[];

    void addRow(
      String title,
      List<ImageModel> entries,
      _SeasonGalleryType type,
    ) {
      if (entries.isEmpty) {
        return;
      }

      rows.add(
        _SeasonGalleryRow(
          title: title,
          images: entries,
          type: type,
          seasonNumber: seasonNumber,
        ),
      );
      rows.add(const SizedBox(height: 16));
    }

    addRow(loc.t('tv.season_posters'), images.posters, _SeasonGalleryType.poster);
    addRow(
      loc.t('tv.season_backdrops'),
      images.backdrops,
      _SeasonGalleryType.backdrop,
    );
    addRow(loc.t('tv.season_stills'), images.stills, _SeasonGalleryType.still);

    if (rows.isNotEmpty && rows.last is SizedBox) {
      rows.removeLast();
    }

    if (rows.isEmpty) {
      return Text(
        loc.t('tv.season_images_empty'),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('tv.season_images'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...rows,
      ],
    );
  }

  static Future<void> _openFullScreenImage(
    BuildContext context,
    List<ImageModel> images,
    int initialIndex,
    _SeasonGalleryType type,
    int seasonNumber,
  ) async {
    final mediaType = switch (type) {
      _SeasonGalleryType.poster => MediaImageType.poster,
      _SeasonGalleryType.backdrop => MediaImageType.backdrop,
      _SeasonGalleryType.still => MediaImageType.still,
    };

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
            heroTagBuilder: (index, image) => _heroTag(
              seasonNumber: seasonNumber,
              type: type,
              index: index,
              image: image,
            ),
          ),
        );
      },
    );
  }

  static String _heroTag({
    required int seasonNumber,
    required _SeasonGalleryType type,
    required int index,
    required ImageModel image,
  }) {
    return 'season-$seasonNumber-${type.name}-${image.filePath}-$index';
  }
}

class _SeasonGalleryRow extends StatelessWidget {
  const _SeasonGalleryRow({
    required this.title,
    required this.images,
    required this.type,
    required this.seasonNumber,
  });

  final String title;
  final List<ImageModel> images;
  final _SeasonGalleryType type;
  final int seasonNumber;

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
                style: theme.textTheme.titleSmall?.copyWith(
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
              final heroTag = SeasonImageGallery._heroTag(
                seasonNumber: seasonNumber,
                type: type,
                index: index,
                image: image,
              );

              return GestureDetector(
                onTap: () => SeasonImageGallery._openFullScreenImage(
                  context,
                  images,
                  index,
                  type,
                  seasonNumber,
                ),
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
                              _SeasonGalleryType.poster => MediaImageType.poster,
                              _SeasonGalleryType.backdrop =>
                                  MediaImageType.backdrop,
                              _SeasonGalleryType.still => MediaImageType.still,
                            },
                            size: switch (type) {
                              _SeasonGalleryType.poster => MediaImageSize.w342,
                              _SeasonGalleryType.backdrop => MediaImageSize.w780,
                              _SeasonGalleryType.still => MediaImageSize.w300,
                            },
                            fit: BoxFit.cover,
                            placeholder: Container(
                              color: Colors.grey.shade300,
                            ),
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

  static double _rowHeightForType(_SeasonGalleryType type) {
    switch (type) {
      case _SeasonGalleryType.poster:
        return 220;
      case _SeasonGalleryType.backdrop:
      case _SeasonGalleryType.still:
        return 150;
    }
  }

  static double _defaultAspectRatio(_SeasonGalleryType type) {
    switch (type) {
      case _SeasonGalleryType.poster:
        return 0.67;
      case _SeasonGalleryType.backdrop:
      case _SeasonGalleryType.still:
        return 16 / 9;
    }
  }
}

enum _SeasonGalleryType { poster, backdrop, still }
