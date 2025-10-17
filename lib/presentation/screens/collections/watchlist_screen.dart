import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/movie.dart';
import '../../../data/models/movie_mappers.dart';
import '../../../data/services/api_config.dart';
import '../../widgets/media_image.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../../core/utils/media_image_helper.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: Consumer2<WatchlistProvider, FavoritesProvider>(
        builder: (context, watchlistProvider, favoritesProvider, _) {
          final watchlistIds = watchlistProvider.watchlist;

          if (watchlistIds.isEmpty) {
            return const _EmptyCollectionMessage(
              icon: Icons.bookmark_border,
              message:
                  'Start building your watchlist by tapping the bookmark icon on a movie.',
            );
          }

          final sortedIds = watchlistIds.toList()
            ..sort((a, b) => b.compareTo(a));

          return _CollectionMoviesList(
            movieIds: sortedIds,
            watchlistProvider: watchlistProvider,
            favoritesProvider: favoritesProvider,
            emptyFallback: const _EmptyCollectionMessage(
              icon: Icons.bookmark_border,
              message: 'We were unable to load your watchlist right now.',
            ),
          );
        },
      ),
    );
  }
}

class _CollectionMoviesList extends StatefulWidget {
  const _CollectionMoviesList({
    required this.movieIds,
    required this.watchlistProvider,
    required this.favoritesProvider,
    required this.emptyFallback,
  });

  final List<int> movieIds;
  final WatchlistProvider watchlistProvider;
  final FavoritesProvider favoritesProvider;
  final Widget emptyFallback;

  @override
  State<_CollectionMoviesList> createState() => _CollectionMoviesListState();
}

class _CollectionMoviesListState extends State<_CollectionMoviesList> {
  late Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _loadMovies();
  }

  @override
  void didUpdateWidget(covariant _CollectionMoviesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.movieIds, oldWidget.movieIds)) {
      setState(() {
        _moviesFuture = _loadMovies();
      });
    }
  }

  Future<List<Movie>> _loadMovies() async {
    final repository = context.read<TmdbRepository>();
    final movies = <Movie>[];

    for (final id in widget.movieIds) {
      try {
        final details = await repository.fetchMovieDetails(id);
        movies.add(details.toMovieSummary());
      } on TmdbException {
        rethrow;
      } catch (error) {
        debugPrint('Failed to load movie $id: $error');
      }
    }

    return movies;
  }

  Future<void> _refresh() async {
    setState(() {
      _moviesFuture = _loadMovies();
    });
    await _moviesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: _moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          return _CollectionErrorMessage(error: error);
        }

        final movies = snapshot.data ?? const <Movie>[];
        if (movies.isEmpty) {
          return widget.emptyFallback;
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: movies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final movie = movies[index];
              final isInWatchlist = widget.watchlistProvider.isInWatchlist(
                movie.id,
              );
              final isFavorite = widget.favoritesProvider.isFavorite(movie.id);

              return _CollectionMovieTile(
                movie: movie,
                isInWatchlist: isInWatchlist,
                isFavorite: isFavorite,
                onToggleWatchlist: () =>
                    widget.watchlistProvider.toggleWatchlist(movie.id),
                onToggleFavorite: () =>
                    widget.favoritesProvider.toggleFavorite(movie.id),
              );
            },
          ),
        );
      },
    );
  }
}

class _CollectionMovieTile extends StatelessWidget {
  const _CollectionMovieTile({
    required this.movie,
    required this.isInWatchlist,
    required this.isFavorite,
    required this.onToggleWatchlist,
    required this.onToggleFavorite,
  });

  final Movie movie;
  final bool isInWatchlist;
  final bool isFavorite;
  final VoidCallback onToggleWatchlist;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _PosterImage(path: movie.posterPath),
        title: Text(movie.title),
        subtitle: Text(_buildSubtitle()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isInWatchlist ? Icons.bookmark : Icons.bookmark_add_outlined,
                color: isInWatchlist
                    ? Theme.of(context).colorScheme.secondary
                    : null,
              ),
              tooltip: isInWatchlist
                  ? 'Remove from watchlist'
                  : 'Add to watchlist',
              onPressed: onToggleWatchlist,
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              tooltip: isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              onPressed: onToggleFavorite,
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    final releaseYear = movie.releaseYear;
    if (releaseYear != null && releaseYear.isNotEmpty) {
      parts.add(releaseYear);
    }
    final genres = movie.genresText;
    if (genres.isNotEmpty) {
      parts.add(genres);
    }
    final showing = movie.showingLabel;
    if (showing != null && showing.isNotEmpty) {
      parts.add(showing);
    }
    return parts.isEmpty
        ? 'No additional details available.'
        : parts.join(' • ');
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return const _PosterPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: MediaImage(
        path: path,
        type: MediaImageType.poster,
        size: MediaImageSize.w92,
        width: 56,
        fit: BoxFit.cover,
        errorWidget: const _PosterPlaceholder(),
        placeholder: const _PosterPlaceholder(),
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.movie, color: Colors.grey),
    );
  }
}

class _CollectionErrorMessage extends StatelessWidget {
  const _CollectionErrorMessage({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = error is TmdbException
        ? 'We could not load your watchlist. Please check your TMDB API key configuration.'
        : 'Something went wrong while loading your watchlist.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCollectionMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyCollectionMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
