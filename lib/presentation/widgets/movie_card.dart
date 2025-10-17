import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/favorites_provider.dart';
// Removed erroneous barrel imports; use direct imports instead
import '../../core/utils/media_image_helper.dart';
import 'loading_indicator.dart';
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
  final String heroTag;

  const MovieCard({
    super.key,
    required this.id,
    required this.title,
    this.posterPath,
    this.voteAverage,
    this.releaseDate,
    this.showingLabel,
    this.onTap,
    String? heroTag,
  }) : heroTag = heroTag ?? 'mediaPoster-$id';

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(id);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster Image
                Expanded(child: _buildPoster()),
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
    final resolvedHeroTag = heroTag;
    if (posterPath == null || posterPath!.isEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = _resolveDimension(constraints.maxWidth, 150);
              final height = _resolveDimension(constraints.maxHeight, 225);
              return ShimmerLoading(
                width: width,
                height: height,
                borderRadius: BorderRadius.circular(0),
              );
            },
          ),
          const Center(
            child: Icon(Icons.movie, size: 48, color: Colors.grey),
          ),
        ],
      );
    }

    final imageWidget = MediaImage(
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
      placeholder: LayoutBuilder(
        builder: (context, constraints) {
          final width = _resolveDimension(constraints.maxWidth, 150);
          final height = _resolveDimension(constraints.maxHeight, 225);
          return ShimmerLoading(
            width: width,
            height: height,
            borderRadius: BorderRadius.circular(0),
          );
        },
      ),
      errorWidget: Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
        ),
      ),
    );

    return Hero(
      tag: resolvedHeroTag,
      child: imageWidget,
    );
  }

  double _resolveDimension(double value, double fallback) {
    if (value.isFinite && value > 0) {
      return value;
    }
    return fallback;
  }
}
