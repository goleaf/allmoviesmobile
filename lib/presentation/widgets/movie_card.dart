import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../providers/favorites_provider.dart';
import 'media_image.dart';

class MovieCard extends StatelessWidget {
  final int id;
  final String title;
  final String? posterPath;
  final double? voteAverage;
  final String? releaseDate;
  final String? showingLabel;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.id,
    required this.title,
    this.posterPath,
    this.voteAverage,
    this.releaseDate,
    this.showingLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(id);

    final releaseYear =
        releaseDate != null && releaseDate!.isNotEmpty ? releaseDate!.substring(0, 4) : null;
    final semanticsParts = <String>[
      title,
      if (releaseYear != null) releaseYear,
      if (voteAverage != null)
        '${voteAverage!.toStringAsFixed(1)} / 10',
      if (showingLabel != null && showingLabel!.isNotEmpty) showingLabel!,
    ];

    final semanticsLabel = semanticsParts.join(', ');
    final hint = loc.t('common.viewDetailsHint');

    return Semantics(
      label: semanticsLabel,
      button: onTap != null,
      hint: hint,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildPoster(loc)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                            const Spacer(),
                            if (releaseYear != null)
                              Text(
                                releaseYear,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        if (showingLabel != null && showingLabel!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            showingLabel!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Tooltip(
                  message: isFavorite
                      ? loc.t('common.removeFromFavorites')
                      : loc.t('common.addToFavorites'),
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: IconButton(
                      iconSize: 20,
                      padding: const EdgeInsets.all(4.0),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        favoritesProvider.toggleFavorite(id);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster(AppLocalizations loc) {
    if (posterPath == null || posterPath!.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.movie, size: 48, color: Colors.grey),
        ),
      );
    }

    return MediaImage(
      path: posterPath,
      type: MediaImageType.poster,
      size: MediaImageSize.w342,
      fit: BoxFit.cover,
      semanticsLabel:
          '${loc.t('common.posterLabelPrefix')} $title',
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
    );
  }
}
