import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/favorites_provider.dart';
// Removed erroneous barrel imports; use direct imports instead
import '../../core/utils/media_image_helper.dart';
import '../../core/localization/app_localizations.dart';
import 'media_image.dart';

/// Movie/TV card with poster, metadata, hero transition and favorite toggle.
class MovieCard extends StatelessWidget {
  final int id;
  final String title;
  final String? posterPath;
  final double? voteAverage;
  final String? releaseDate;
  final String? showingLabel;
  final VoidCallback? onTap;
  final String? heroTag;

  const MovieCard({
    super.key,
    required this.id,
    required this.title,
    this.posterPath,
    this.voteAverage,
    this.releaseDate,
    this.showingLabel,
    this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(id);
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final accessibilityStrings = loc.accessibility;

    final year = (releaseDate != null && releaseDate!.length >= 4)
        ? releaseDate!.substring(0, 4)
        : null;
    final semanticsParts = <String>[title];
    if (year != null) {
      semanticsParts.add(
        '${(loc.movie['release_date'] as String?) ?? 'Release date'} $year',
      );
    }
    if (voteAverage != null) {
      semanticsParts.add(
        '${(loc.movie['rating'] as String?) ?? 'Rating'} ${voteAverage!.toStringAsFixed(1)}',
      );
    }
    final semanticsLabel = semanticsParts.join(', ');
    final semanticsHint =
        (accessibilityStrings['open_details'] as String?) ?? 'Open details';
    final posterLabelTemplate =
        (accessibilityStrings['poster_label'] as String?) ?? 'Poster for {title}';
    final posterSemanticLabel =
        posterLabelTemplate.replaceAll('{title}', title);
    final favoriteAddLabel =
        (accessibilityStrings['favorite_add'] as String?) ?? 'Add to favorites';
    final favoriteRemoveLabel =
        (accessibilityStrings['favorite_remove'] as String?) ??
            'Remove from favorites';

    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticsLabel,
      hint: semanticsHint,
      child: Focus(
        canRequestFocus: onTap != null,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: onTap,
            focusColor: theme.focusColor,
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildPoster(posterSemanticLabel),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (voteAverage != null) ...[
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  voteAverage!.toStringAsFixed(1),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                              const Spacer(),
                              if (year != null)
                                Text(
                                  year,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                          if (showingLabel != null && showingLabel!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                showingLabel!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Semantics(
                    button: true,
                    toggled: isFavorite,
                    label: isFavorite ? favoriteRemoveLabel : favoriteAddLabel,
                    child: Tooltip(
                      message:
                          isFavorite ? favoriteRemoveLabel : favoriteAddLabel,
                      child: Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            favoritesProvider.toggleFavorite(id);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? theme.colorScheme.error
                                  : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoster(String semanticLabel) {
    final tag = heroTag ?? 'movie-poster-$id';
    if (posterPath == null || posterPath!.isEmpty) {
      return Hero(
        tag: tag,
        flightShuttleBuilder: _buildFlightShuttle,
        child: Semantics(
          label: semanticLabel,
          image: true,
          child: Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.movie, size: 48, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Hero(
      tag: tag,
      flightShuttleBuilder: _buildFlightShuttle,
      child: Semantics(
        label: semanticLabel,
        image: true,
        child: MediaImage(
          path: posterPath,
          type: MediaImageType.poster,
          size: MediaImageSize.w342,
          fit: BoxFit.cover,
          overlay: MediaImageOverlay(
            gradientResolvers: [
              (theme, _) {
                final isDark = theme.brightness == Brightness.dark;
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(isDark ? 0.4 : 0.6),
                    Colors.black.withOpacity(0),
                  ],
                );
              },
            ],
          ),
          placeholder: Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
            ),
          ),
        ),
      ),
    );

  }

  double _resolveDimension(double value, double fallback) {
    if (value.isFinite && value > 0) {
      return value;
    }
    return fallback;
  }

  static Widget _buildFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return FadeTransition(
      opacity: animation.drive(
        CurveTween(curve: Curves.easeInOut),
      ),
      child: toHeroContext.widget,
    );
  }
}
