import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../data/services/api_config.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/media_gallery_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/rating_display.dart';
import '../../widgets/media_gallery_section.dart';

class MovieDetailScreen extends StatelessWidget {
  static const routeName = '/movie-detail';
  
  final Movie movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final repository = context.read<TmdbRepository>();

    return ChangeNotifierProvider(
      create: (_) => MediaGalleryProvider(repository)..loadMovieImages(movie.id),
      child: Builder(
        builder: (context) {
          final loc = AppLocalizations.of(context);

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                _buildAppBar(context, loc),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, loc),
                      _buildActions(context, loc),
                      _buildOverview(context, loc),
                      _buildMetadata(context, loc),
                      _buildGenres(context, loc),
                      const MediaGallerySection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations loc) {
    final backdropUrl = movie.backdropUrl;
    
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: backdropUrl != null && backdropUrl.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: backdropUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 64),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.movie, size: 64),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations loc) {
    final posterUrl = movie.posterUrl;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: posterUrl != null && posterUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: posterUrl,
                    width: 120,
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 120,
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 120,
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  )
                : Container(
                    width: 120,
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.movie),
                  ),
          ),
          const SizedBox(width: 16),
          // Title and basic info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (movie.releaseYear != null && movie.releaseYear!.isNotEmpty)
                  Text(
                    movie.releaseYear!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                const SizedBox(height: 8),
                if (movie.voteAverage != null && movie.voteAverage! > 0)
                  RatingDisplay(
                    rating: movie.voteAverage!,
                    voteCount: movie.voteCount,
                    size: 18,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations loc) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final watchlistProvider = context.watch<WatchlistProvider>();
    
    final isFavorite = favoritesProvider.isFavorite(movie.id);
    final isInWatchlist = watchlistProvider.isInWatchlist(movie.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                favoritesProvider.toggleFavorite(movie.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFavorite
                          ? loc.t('favorites.removed')
                          : loc.t('favorites.added'),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              label: Text(
                isFavorite
                    ? loc.t('movie.remove_from_favorites')
                    : loc.t('movie.add_to_favorites'),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                watchlistProvider.toggleWatchlist(movie.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isInWatchlist
                          ? loc.t('watchlist.removed')
                          : loc.t('watchlist.added'),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                color: isInWatchlist ? Colors.blue : null,
              ),
              label: Text(
                isInWatchlist
                    ? loc.t('movie.remove_from_watchlist')
                    : loc.t('movie.add_to_watchlist'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(BuildContext context, AppLocalizations loc) {
    if (movie.overview == null || movie.overview!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('movie.overview'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.overview!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, AppLocalizations loc) {
    final metadata = <MapEntry<String, String>>[];

    if (movie.releaseDate != null && movie.releaseDate!.isNotEmpty) {
      metadata.add(MapEntry(
        loc.t('movie.release_date'),
        movie.releaseDate!,
      ));
    }

    if (movie.runtime != null && movie.runtime! > 0) {
      metadata.add(MapEntry(
        loc.t('movie.runtime'),
        '${movie.runtime} ${loc.t('movie.minutes')}',
      ));
    }

    if (movie.voteCount != null && movie.voteCount! > 0) {
      metadata.add(MapEntry(
        loc.t('movie.votes'),
        movie.voteCount.toString(),
      ));
    }

    if (metadata.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...metadata.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(entry.value),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGenres(BuildContext context, AppLocalizations loc) {
    if (movie.genreIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('movie.genres'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: movie.genreIds.map((genreId) {
              // TODO: Get genre name from GenresProvider
              return Chip(
                label: Text('Genre $genreId'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
