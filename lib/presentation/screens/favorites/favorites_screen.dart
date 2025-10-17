import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/movie_detailed_model.dart';
import '../../../data/models/genre_model.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/stored_movie_tile.dart';
import '../movie_detail/movie_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  static const routeName = '/favorites';

  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Set<int> _cachedIds = const {};
  late FavoritesProvider _favoritesProvider;
  late WatchlistProvider _watchlistProvider;
  Future<List<Movie>>? _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = Future.value(const []);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _favoritesProvider = Provider.of<FavoritesProvider>(context);
    _watchlistProvider = Provider.of<WatchlistProvider>(context);

    final favoriteIds = _favoritesProvider.favorites;
    if (!setEquals(favoriteIds, _cachedIds)) {
      _cachedIds = Set<int>.from(favoriteIds);
      _favoritesFuture = _loadFavorites(favoriteIds);
    }
  }

  Future<List<Movie>> _loadFavorites(Set<int> favoriteIds) async {
    if (favoriteIds.isEmpty) return const [];

    final repository = context.read<TmdbRepository>();
    final ids = favoriteIds.toList()..sort((a, b) => b.compareTo(a));
    final movies = <Movie>[];

    for (final id in ids) {
      try {
        final details = await repository.fetchMovieDetails(id);
        movies.add(_mapDetailsToMovie(details));
      } on TmdbException {
        rethrow;
      } catch (error) {
        debugPrint('Failed to load favorite movie $id: $error');
      }
    }

    return movies;
  }

  Movie _mapDetailsToMovie(MovieDetailed details) {
    final genreIds = details.genres.map((Genre genre) => genre.id).toList();

    return Movie(
      id: details.id,
      title: details.title,
      overview: details.overview,
      posterPath: details.posterPath,
      backdropPath: details.backdropPath,
      mediaType: 'movie',
      releaseDate: details.releaseDate,
      voteAverage: details.voteAverage,
      voteCount: details.voteCount,
      popularity: details.popularity,
      originalTitle: details.originalTitle,
      originalLanguage:
          details.spokenLanguages.isNotEmpty ? details.spokenLanguages.first.iso6391 : null,
      adult: false,
      genreIds: genreIds,
    );
  }

  Future<void> _refreshFavorites() async {
    final favoriteIds = _favoritesProvider.favorites;
    setState(() {
      _favoritesFuture = _loadFavorites(favoriteIds);
    });
    final future = _favoritesFuture;
    if (future != null) {
      await future;
    }
  }

  Future<void> _toggleFavorite(Movie movie) async {
    final wasFavorite = _favoritesProvider.isFavorite(movie.id);
    await _favoritesProvider.toggleFavorite(movie.id);
    if (!mounted) return;

    final loc = AppLocalizations.of(context);
    final message =
        wasFavorite ? loc.t('favorites.removed') : loc.t('favorites.added');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _toggleWatchlist(Movie movie) async {
    final wasInWatchlist = _watchlistProvider.isInWatchlist(movie.id);
    await _watchlistProvider.toggleWatchlist(movie.id);
    if (!mounted) return;

    final loc = AppLocalizations.of(context);
    final message = wasInWatchlist
        ? loc.t('watchlist.removed')
        : loc.t('watchlist.added');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _showClearDialog(AppLocalizations loc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.t('favorites.title')),
        content: const Text('Are you sure you want to clear all favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.t('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(loc.t('common.clear')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _favoritesProvider.clearFavorites();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favorites cleared')),
      );
    }
  }

  void _openMovieDetail(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final favorites = _favoritesProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('favorites.title')),
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: loc.t('common.clear'),
              onPressed: () => _showClearDialog(loc),
            ),
        ],
      ),
      body: favorites.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border,
              title: loc.t('favorites.empty'),
              message: loc.t('favorites.empty_message'),
            )
          : FutureBuilder<List<Movie>>(
              future: _favoritesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                }

                if (snapshot.hasError) {
                  final error = snapshot.error;
                  final message = error is TmdbException
                      ? error.message
                      : loc.t('errors.load_failed');
                  return ErrorDisplay(
                    message: message,
                    onRetry: _refreshFavorites,
                  );
                }

                final movies = snapshot.data ?? const <Movie>[];
                if (movies.isEmpty) {
                  return EmptyState(
                    icon: Icons.favorite_border,
                    title: loc.t('favorites.empty'),
                    message: loc.t('favorites.empty_message'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshFavorites,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: movies.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      final isFavorite = _favoritesProvider.isFavorite(movie.id);
                      final isInWatchlist =
                          _watchlistProvider.isInWatchlist(movie.id);

                      return StoredMovieTile(
                        movie: movie,
                        isFavorite: isFavorite,
                        isInWatchlist: isInWatchlist,
                        onTap: () => _openMovieDetail(movie),
                        onToggleFavorite: () => _toggleFavorite(movie),
                        onToggleWatchlist: () => _toggleWatchlist(movie),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
