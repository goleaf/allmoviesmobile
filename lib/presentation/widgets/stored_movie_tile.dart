import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/models/movie.dart';
import '../../data/services/api_config.dart';
import '../../core/utils/media_image_helper.dart';
import '../widgets/media_image.dart';

class StoredMovieTile extends StatelessWidget {
  const StoredMovieTile({
    super.key,
    required this.movie,
    required this.isFavorite,
    required this.isInWatchlist,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onToggleWatchlist,
  });

  final Movie movie;
  final bool isFavorite;
  final bool isInWatchlist;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleWatchlist;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          leading: _PosterImage(posterPath: movie.posterPath),
          title: Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: _buildSubtitle(context),
          isThreeLine: movie.genresText.isNotEmpty,
          trailing: Wrap(
            spacing: 4,
            children: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                tooltip: isFavorite
                    ? loc.t('movie.remove_from_favorites')
                    : loc.t('movie.add_to_favorites'),
                onPressed: onToggleFavorite,
              ),
              IconButton(
                icon: Icon(
                  isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                  color: isInWatchlist
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                tooltip: isInWatchlist
                    ? loc.t('movie.remove_from_watchlist')
                    : loc.t('movie.add_to_watchlist'),
                onPressed: onToggleWatchlist,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final details = <String>[];
    final releaseYear = movie.releaseYear;
    if (releaseYear != null && releaseYear.isNotEmpty) {
      details.add(releaseYear);
    }
    if (movie.voteAverage != null && movie.voteAverage! > 0) {
      details.add('${movie.voteAverage!.toStringAsFixed(1)} ★');
    }

    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final secondaryStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.primary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (details.isNotEmpty) Text(details.join(' • '), style: subtitleStyle),
        if (movie.genresText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              movie.genresText,
              style: secondaryStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.posterPath});

  final String? posterPath;

  @override
  Widget build(BuildContext context) {
    if (posterPath == null || posterPath!.isEmpty) {
      return Container(
        width: 60,
        height: 90,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.movie,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: MediaImage(
        path: posterPath,
        type: MediaImageType.poster,
        size: MediaImageSize.w92,
        width: 60,
        height: 90,
        fit: BoxFit.cover,
        placeholder: Container(
          width: 60,
          height: 90,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: Container(
          width: 60,
          height: 90,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.broken_image,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
