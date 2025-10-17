import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/credit_model.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/movie_detailed_model.dart';
import '../../../data/services/api_config.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/rating_display.dart';

class MovieDetailScreen extends StatefulWidget {
  static const routeName = '/movie-detail';

  final Movie movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<_MovieDetailsData> _movieDetailsFuture;

  @override
  void initState() {
    super.initState();
    _movieDetailsFuture = _loadDetails();
  }

  Future<_MovieDetailsData> _loadDetails() async {
    final repository = context.read<TmdbRepository>();
    final creditsFuture = repository.fetchMovieCredits(widget.movie.id);
    final details = await repository.fetchMovieDetails(widget.movie.id);
    List<Crew> crew = const <Crew>[];
    try {
      final credits = await creditsFuture;
      crew = credits.crew;
    } catch (error) {
      debugPrint('Failed to load crew for movie ${widget.movie.id}: $error');
    }

    return _MovieDetailsData(details: details, crew: crew);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: FutureBuilder<_MovieDetailsData>(
        future: _movieDetailsFuture,
        builder: (context, snapshot) {
          final details = snapshot.data?.details;
          final crew = snapshot.data?.crew ?? const <Crew>[];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, loc),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, loc),
                    _buildActions(context, loc),
                    _buildOverview(context, loc, details),
                    _buildMetadata(context, loc, details),
                    _buildGenres(context, loc),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (snapshot.hasError)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          loc.t('errors.load_failed'),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      )
                    else
                      _buildCrew(context, loc, crew),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations loc) {
    final backdropUrl = widget.movie.backdropUrl;
    
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
    final posterUrl = widget.movie.posterUrl;
    
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
                  widget.movie.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (widget.movie.releaseYear != null &&
                    widget.movie.releaseYear!.isNotEmpty)
                  Text(
                    widget.movie.releaseYear!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                const SizedBox(height: 8),
                if (widget.movie.voteAverage != null &&
                    widget.movie.voteAverage! > 0)
                  RatingDisplay(
                    rating: widget.movie.voteAverage!,
                    voteCount: widget.movie.voteCount,
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

    final isFavorite = favoritesProvider.isFavorite(widget.movie.id);
    final isInWatchlist = watchlistProvider.isInWatchlist(widget.movie.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                favoritesProvider.toggleFavorite(widget.movie.id);
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
                watchlistProvider.toggleWatchlist(widget.movie.id);
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
    MovieDetailed? details,
  ) {
    final overviewText = details?.overview ?? widget.movie.overview;

    if (overviewText == null || overviewText.isEmpty) {
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
            overviewText,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailed? details,
  ) {
    final metadata = <MapEntry<String, String>>[];

    final releaseDate =
        details?.releaseDate?.isNotEmpty == true ? details!.releaseDate : widget.movie.releaseDate;
    if (releaseDate != null && releaseDate.isNotEmpty) {
      metadata.add(MapEntry(loc.t('movie.release_date'), releaseDate));
    }

    final runtime = details?.runtime;
    if (runtime != null && runtime > 0) {
      metadata.add(MapEntry(
        loc.t('movie.runtime'),
        '$runtime ${loc.t('movie.minutes')}',
      ));
    }

    final voteCount = details?.voteCount ?? widget.movie.voteCount;
    if (voteCount != null && voteCount > 0) {
      metadata.add(MapEntry(loc.t('movie.votes'), voteCount.toString()));
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

  Widget _buildCrew(
    BuildContext context,
    AppLocalizations loc,
    List<Crew> crew,
  ) {
    if (crew.isEmpty) {
      return const SizedBox.shrink();
    }

    final crewMembers = _selectCrewMembers(crew);
    if (crewMembers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('movie.crew'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...crewMembers.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.job,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                  if (member.department.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      member.department,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Crew> _selectCrewMembers(List<Crew> crew) {
    const prioritizedJobs = [
      'Director',
      'Screenplay',
      'Writer',
      'Story',
      'Characters',
      'Producer',
      'Executive Producer',
    ];

    final selected = <Crew>[];
    final seenIds = <int>{};

    for (final job in prioritizedJobs) {
      for (final member in crew) {
        if (member.job.toLowerCase() == job.toLowerCase() && seenIds.add(member.id)) {
          selected.add(member);
          break;
        }
      }
      if (selected.length >= 8) {
        return selected;
      }
    }

    for (final member in crew) {
      if (selected.length >= 8) {
        break;
      }
      if (seenIds.add(member.id)) {
        selected.add(member);
      }
    }

    return selected;
  }

  Widget _buildGenres(BuildContext context, AppLocalizations loc) {
    if (widget.movie.genreIds == null || widget.movie.genreIds!.isEmpty) {
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
            children: widget.movie.genreIds!.map((genreId) {
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

class _MovieDetailsData {
  const _MovieDetailsData({
    required this.details,
    required this.crew,
  });

  final MovieDetailed details;
  final List<Crew> crew;
}
