import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/movie_detail_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/rating_display.dart';

class MovieDetailScreen extends StatelessWidget {
  static const routeName = '/movie-detail';
  
  final Movie movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MovieDetailProvider(
        context.read<TmdbRepository>(),
        movie.id,
      ),
      child: _MovieDetailView(movie: movie),
    );
  }


}

class _MovieDetailView extends StatelessWidget {
  const _MovieDetailView({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final detailProvider = context.watch<MovieDetailProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, loc, detailProvider),
                _buildActions(context, loc),
                if (detailProvider.isLoading)
                  const LinearProgressIndicator(minHeight: 2),
                _buildOverview(context, loc, detailProvider),
                _buildMetadata(context, loc, detailProvider),
                _buildGenres(context, loc, detailProvider),
                _buildKeywords(context, loc, detailProvider),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
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

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailProvider detailProvider,
  ) {
    final posterUrl = movie.posterUrl;
    final detailed = detailProvider.movie;
    final releaseYear = detailed?.releaseDate?.isNotEmpty == true
        ? detailed!.releaseDate!.split('-').first
        : movie.releaseYear;
    final tagline = detailed?.tagline;
    final voteAverage = detailed?.voteAverage ?? movie.voteAverage;
    final voteCount = detailed?.voteCount ?? movie.voteCount;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                if (tagline != null && tagline.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '“$tagline”',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
                if (releaseYear != null && releaseYear.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    releaseYear,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
                if (voteAverage != null && voteAverage > 0) ...[
                  const SizedBox(height: 8),
                  RatingDisplay(
                    rating: voteAverage,
                    voteCount: voteCount,
                    size: 18,
                  ),
                ],
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

  Widget _buildOverview(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailProvider detailProvider,
  ) {
    final overview =
        detailProvider.movie?.overview?.trim().isNotEmpty == true
            ? detailProvider.movie!.overview
            : movie.overview;

    if (overview == null || overview.isEmpty) {
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
            overview,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailProvider detailProvider,
  ) {
    final metadata = <MapEntry<String, String>>[];
    final detailed = detailProvider.movie;

    final releaseDate = detailed?.releaseDate?.isNotEmpty == true
        ? detailed!.releaseDate!
        : movie.releaseDate;
    if (releaseDate != null && releaseDate.isNotEmpty) {
      metadata.add(MapEntry(loc.t('movie.release_date'), releaseDate));
    }

    final runtime = detailed?.runtime;
    if (runtime != null && runtime > 0) {
      metadata.add(MapEntry(
        loc.t('movie.runtime'),
        '$runtime ${loc.t('movie.minutes')}',
      ));
    }

    final voteCount = detailed?.voteCount ?? movie.voteCount;
    if (voteCount != null && voteCount > 0) {
      metadata.add(MapEntry(loc.t('movie.votes'), '$voteCount'));
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
            loc.t('movie.details'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...metadata.map(
            (entry) => Padding(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenres(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailProvider detailProvider,
  ) {
    final detailedGenres = detailProvider.genres
        .map((genre) => genre.name.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    final fallbackGenres = movie.genreIds
        ?.map((genreId) => Movie.genreMap[genreId])
        .whereType<String>()
        .toList();

    final genres = detailedGenres.isNotEmpty
        ? detailedGenres
        : fallbackGenres ?? const <String>[];

    if (genres.isEmpty) {
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
            children: genres
                .map(
                  (genre) => Chip(
                    label: Text(genre),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywords(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailProvider detailProvider,
  ) {
    final keywords = detailProvider.keywords;

    if (detailProvider.isLoading && keywords.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.t('movie.keywords'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(6, (index) {
                return Container(
                  width: 80,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    }

    if (keywords.isEmpty) {
      if (detailProvider.errorMessage != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.t('movie.keywords'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                detailProvider.errorMessage!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
              TextButton(
                onPressed: detailProvider.refresh,
                child: Text(loc.t('common.retry')),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('movie.keywords'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: keywords
                .map(
                  (keyword) => Chip(
                    label: Text(keyword.name),
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
