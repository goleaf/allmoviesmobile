import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/services/api_config.dart';
import '../../providers/favorites_provider.dart';

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

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster Image
                Expanded(
                  child: _buildPoster(),
                ),
                // Movie Info
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
                          if (releaseDate != null && releaseDate!.isNotEmpty)
                            Text(
                              releaseDate!.substring(0, 4),
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
            // Favorite Button
            Positioned(
              top: 4,
              right: 4,
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
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster() {
    if (posterPath == null || posterPath!.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.movie,
            size: 48,
            color: Colors.grey,
          ),
        ),
      );
    }

    final posterUrl = ApiConfig.getPosterUrl(posterPath, size: ApiConfig.posterSizeMedium);

    return CachedNetworkImage(
      imageUrl: posterUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

