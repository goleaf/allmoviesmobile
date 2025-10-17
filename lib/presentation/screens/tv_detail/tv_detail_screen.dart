import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/season_model.dart';
import '../../../data/models/tv_detailed_model.dart';
import '../../../data/services/api_config.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/loading_indicator.dart';
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
  late Future<TVDetailed> _tvDetailsFuture;

  @override
  void initState() {
    super.initState();
    _tvDetailsFuture = _loadTvDetails();
  }

  Future<TVDetailed> _loadTvDetails({bool forceRefresh = false}) {
    final repository = context.read<TmdbRepository>();
    return repository.fetchTvDetails(
      widget.tvShow.id,
      forceRefresh: forceRefresh,
    );
  }

  void _retryLoading() {
    setState(() {
      _tvDetailsFuture = _loadTvDetails(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return FutureBuilder<TVDetailed>(
      future: _tvDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: LoadingIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.t('errors.load_failed'),
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _retryLoading,
                      child: Text(loc.t('common.retry')),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final tvDetails = snapshot.data;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, loc, tvDetails),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, loc, tvDetails),
                    _buildActions(context, loc),
                    _buildOverview(context, loc, tvDetails),
                    _buildMetadata(context, loc, tvDetails),
                    _buildGenres(context, loc, tvDetails),
                    _buildSeasons(context, loc, tvDetails),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed? tvDetails,
  ) {
    final detailedBackdrop =
        ApiConfig.getBackdropUrl(tvDetails?.backdropPath, size: ApiConfig.backdropSizeLarge);
    final backdropUrl = detailedBackdrop.isNotEmpty
        ? detailedBackdrop
        : widget.tvShow.backdropUrl;

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
                child: const Icon(Icons.tv, size: 64),
              ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed? tvDetails,
  ) {
    final detailedPoster =
        ApiConfig.getPosterUrl(tvDetails?.posterPath, size: ApiConfig.posterSizeLarge);
    final posterUrl = detailedPoster.isNotEmpty
        ? detailedPoster
        : widget.tvShow.posterUrl;

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
                    child: const Icon(Icons.tv),
                  ),
          ),
          const SizedBox(width: 16),
          // Title and basic info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tvDetails?.name ?? widget.tvShow.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'TV Series',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (_firstAirDate(tvDetails).isNotEmpty)
                  Text(
                    '${loc.t('tv.first_air_date')}: ${_firstAirDate(tvDetails)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                const SizedBox(height: 8),
                if ((tvDetails?.voteAverage ?? widget.tvShow.voteAverage) != null &&
                    (tvDetails?.voteAverage ?? widget.tvShow.voteAverage)! > 0)
                  RatingDisplay(
                    rating: (tvDetails?.voteAverage ?? widget.tvShow.voteAverage)!,
                    voteCount: tvDetails?.voteCount ?? widget.tvShow.voteCount,
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

  Widget _buildOverview(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed? tvDetails,
  ) {
    final overview = (tvDetails?.overview ?? widget.tvShow.overview)?.trim();
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

  Widget _buildMetadata(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed? tvDetails,
  ) {
    final metadata = <MapEntry<String, String>>[];

    final firstAirDate = tvDetails?.firstAirDate ?? widget.tvShow.releaseDate;
    if (firstAirDate != null && firstAirDate.isNotEmpty) {
      metadata.add(MapEntry(
        loc.t('tv.first_air_date'),
        _formatDate(firstAirDate),
      ));
    }

    final lastAirDate = tvDetails?.lastAirDate;
    if (lastAirDate != null && lastAirDate.isNotEmpty) {
      metadata.add(MapEntry(
        loc.t('tv.last_air_date'),
        _formatDate(lastAirDate),
      ));
    }

    final voteCount = tvDetails?.voteCount ?? widget.tvShow.voteCount;
    if (voteCount != null && voteCount > 0) {
      metadata.add(MapEntry(
        loc.t('tv.votes'),
        voteCount.toString(),
      ));
    }

    final popularity = tvDetails?.popularity ?? widget.tvShow.popularity;
    if (popularity != null) {
      metadata.add(MapEntry(
        loc.t('tv.popularity'),
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

  Widget _buildGenres(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed? tvDetails,
  ) {
    final detailedGenres = tvDetails?.genres.map((genre) => genre.name).toList();

    if ((detailedGenres == null || detailedGenres.isEmpty) &&
        (widget.tvShow.genreIds?.isEmpty ?? true)) {
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
            children: (detailedGenres ??
                    widget.tvShow.genreIds
                        ?.map((genreId) => Movie.genreMap[genreId] ?? 'Genre $genreId')
                        .toList() ??
                    [])
                .map((genreName) => Chip(
                      label: Text(genreName),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasons(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed? tvDetails,
  ) {
    final seasons = tvDetails?.seasons ?? [];
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
          ListView.separated(
            itemCount: seasons.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _SeasonCard(
              season: seasons[index],
              loc: loc,
            ),
          ),
        ],
      ),
    );
  }

  String _firstAirDate(TVDetailed? tvDetails) {
    final detailedDate = tvDetails?.firstAirDate;
    if (detailedDate != null && detailedDate.isNotEmpty) {
      return _formatDate(detailedDate);
    }

    final releaseYear = widget.tvShow.releaseYear;
    if (releaseYear != null && releaseYear.isNotEmpty) {
      return releaseYear;
    }

    return '';
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return '';
    }

    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat.yMMMd().format(parsed);
    } catch (_) {
      return rawDate;
    }
  }
}

class _SeasonCard extends StatelessWidget {
  final Season season;
  final AppLocalizations loc;

  const _SeasonCard({
    required this.season,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final posterUrl = ApiConfig.getPosterUrl(
      season.posterPath,
      size: ApiConfig.posterSizeSmall,
    );

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final airDate = _formatAirDate(season.airDate, loc, context);
    final episodeCount = season.episodeCount != null
        ? season.episodeCount.toString()
        : loc.t('common.not_available');

    final hasOverview = season.overview != null && season.overview!.trim().isNotEmpty;
    final seasonLabel = '${loc.t('tv.season')} ${season.seasonNumber}';
    final displayTitle = season.name.trim().isEmpty
        ? seasonLabel
        : '$seasonLabel • ${season.name}';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: posterUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: posterUrl,
                      width: 90,
                      height: 135,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 90,
                        height: 135,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 90,
                        height: 135,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    )
                  : Container(
                      width: 90,
                      height: 135,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.live_tv, size: 16),
                      const SizedBox(width: 6),
                      Text('${loc.t('tv.episodes')}: $episodeCount'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.event, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${loc.t('tv.first_air_date')}: $airDate',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (hasOverview) ...[
                    const SizedBox(height: 8),
                    Text(
                      season.overview!,
                      style: textTheme.bodyMedium,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatAirDate(
    String? rawDate,
    AppLocalizations loc,
    BuildContext context,
  ) {
    if (rawDate == null || rawDate.isEmpty) {
      return loc.t('common.unknown');
    }

    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat.yMMMd(Localizations.localeOf(context).toString())
          .format(parsed);
    } catch (_) {
      return rawDate;
    }
  }
}

