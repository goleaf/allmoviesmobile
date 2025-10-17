import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/tv_detailed_model.dart';
import '../../../data/services/api_config.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/rating_display.dart';

class TVDetailScreen extends StatefulWidget {
  static const routeName = '/tv-detail';

  final Movie tvShow;

  const TVDetailScreen({
    super.key,
    required this.tvShow,
  });

  @override
  State<TVDetailScreen> createState() => _TVDetailScreenState();
}

class _TVDetailScreenState extends State<TVDetailScreen> {
  TVDetailed? _details;
  bool _isLoadingDetails = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadDetails);
  }

  Future<void> _loadDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoadingDetails = true;
      _errorMessage = null;
    });

    try {
      final repository = context.read<TmdbRepository>();
      final details = await repository.fetchTvDetails(widget.tvShow.id);
      if (!mounted) return;
      setState(() {
        _details = details;
        _isLoadingDetails = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _buildSeasons(context, loc),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations loc) {
    final detailBackdropUrl = ApiConfig.getBackdropUrl(
      _details?.backdropPath,
      size: ApiConfig.backdropSizeLarge,
    );
    final fallbackBackdropUrl = widget.tvShow.backdropUrl ?? '';
    final backdropUrl = detailBackdropUrl.isNotEmpty
        ? detailBackdropUrl
        : fallbackBackdropUrl;

    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: backdropUrl.isNotEmpty
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
                child: const Icon(Icons.tv, size: 64),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations loc) {
    final detailPosterUrl = ApiConfig.getPosterUrl(
      _details?.posterPath,
      size: ApiConfig.posterSizeLarge,
    );
    final fallbackPosterUrl = widget.tvShow.posterUrl ?? '';
    final posterUrl = detailPosterUrl.isNotEmpty
        ? detailPosterUrl
        : fallbackPosterUrl;
    final title = _details?.name ?? widget.tvShow.title;
    final releaseYear = _extractYear(_details?.firstAirDate) ??
        widget.tvShow.releaseYear;
    final voteAverage = _details?.voteAverage ?? widget.tvShow.voteAverage;
    final voteCount = _details?.voteCount ?? widget.tvShow.voteCount;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: posterUrl.isNotEmpty
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
                    child: const Icon(Icons.tv),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tv,
                        size: 14,
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'TV Series',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                ),
                if (releaseYear != null && releaseYear.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${loc.t('tv.first_aired')}: $releaseYear',
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

    final isFavorite = favoritesProvider.isFavorite(widget.tvShow.id);
    final isInWatchlist = watchlistProvider.isInWatchlist(widget.tvShow.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                favoritesProvider.toggleFavorite(widget.tvShow.id);
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
                    ? loc.t('tv.remove_from_favorites')
                    : loc.t('tv.add_to_favorites'),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                watchlistProvider.toggleWatchlist(widget.tvShow.id);
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
                    ? loc.t('tv.remove_from_watchlist')
                    : loc.t('tv.add_to_watchlist'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(BuildContext context, AppLocalizations loc) {
    final detailOverview = _details?.overview?.trim();
    final fallbackOverview = widget.tvShow.overview?.trim();
    final overview =
        (detailOverview != null && detailOverview.isNotEmpty)
            ? detailOverview
            : fallbackOverview;

    if (overview == null || overview.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('tv.overview'),
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

  Widget _buildMetadata(BuildContext context, AppLocalizations loc) {
    final metadata = <MapEntry<String, String>>[];
    final details = _details;

    final firstAirDate = details?.firstAirDate ?? widget.tvShow.releaseDate;
    if (firstAirDate != null && firstAirDate.isNotEmpty) {
      metadata.add(MapEntry(
        loc.t('tv.first_air_date'),
        firstAirDate,
      ));
    }

    final lastAirDate = details?.lastAirDate;
    if (lastAirDate != null && lastAirDate.isNotEmpty) {
      metadata.add(MapEntry(
        loc.t('tv.last_air_date'),
        lastAirDate,
      ));
    }

    final numberOfSeasons = details?.numberOfSeasons;
    if (numberOfSeasons != null && numberOfSeasons > 0) {
      metadata.add(MapEntry(
        loc.t('tv.number_of_seasons'),
        numberOfSeasons.toString(),
      ));
    }

    final numberOfEpisodes = details?.numberOfEpisodes;
    if (numberOfEpisodes != null && numberOfEpisodes > 0) {
      metadata.add(MapEntry(
        loc.t('tv.number_of_episodes'),
        numberOfEpisodes.toString(),
      ));
    }

    final runtimes = details?.episodeRunTime ?? const <int>[];
    if (runtimes.isNotEmpty) {
      final runtimeText =
          runtimes.map((runtime) => '$runtime min').join(' / ');
      metadata.add(MapEntry(
        loc.t('tv.episode_runtime'),
        runtimeText,
      ));
    }

    final voteCount = details?.voteCount ?? widget.tvShow.voteCount;
    if (voteCount != null && voteCount > 0) {
      metadata.add(MapEntry(
        loc.t('movie.votes'),
        voteCount.toString(),
      ));
    }

    final popularity = details?.popularity ?? widget.tvShow.popularity;
    if (popularity != null) {
      metadata.add(MapEntry(
        loc.t('movie.popularity'),
        popularity.toStringAsFixed(0),
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
                      width: 140,
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
    final detailGenres = _details?.genres
            .map((genre) => genre.name.trim())
            .where((name) => name.isNotEmpty)
            .toList() ??
        const <String>[];

    final fallbackGenres = (widget.tvShow.genreIds ?? const <int>[]) 
        .map((id) => Movie.genreMap[id])
        .whereType<String>()
        .toList();

    final genres = detailGenres.isNotEmpty ? detailGenres : fallbackGenres;

    if (genres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('tv.genres'),
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
                  (genreName) => Chip(
                    label: Text(genreName),
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

  Widget _buildSeasons(BuildContext context, AppLocalizations loc) {
    if (_isLoadingDetails) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.t('tv.seasons'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.t('tv.seasons'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadDetails,
              child: Text(loc.t('common.retry')),
            ),
          ],
        ),
      );
    }

    final seasons = _details?.seasons ?? const [];
    if (seasons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('tv.seasons'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 270,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: seasons.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final season = seasons[index];
                final posterUrl = ApiConfig.getPosterUrl(
                  season.posterPath,
                  size: ApiConfig.posterSizeMedium,
                );
                final year = _extractYear(season.airDate);
                final episodeCount = season.episodeCount ?? season.episodes.length;
                final seasonName = season.name.trim().isNotEmpty
                    ? season.name
                    : '${loc.t('tv.season')} ${season.seasonNumber}';

                return SizedBox(
                  width: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: 2 / 3,
                          child: posterUrl.isNotEmpty
                              ? CachedNetworkImage(
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
                                    child: const Icon(Icons.broken_image),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.tv),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        seasonName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (year != null && year.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          year,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                      if (episodeCount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$episodeCount ${loc.t('tv.episodes')}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                      if (season.overview != null &&
                          season.overview!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          season.overview!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _extractYear(String? date) {
    if (date == null || date.isEmpty) {
      return null;
    }
    return date.split('-').first;
  }
}
