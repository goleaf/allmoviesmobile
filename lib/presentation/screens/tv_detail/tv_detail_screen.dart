import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/episode_model.dart';
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
  Future<TVDetailed>? _detailsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detailsFuture ??= _loadDetails();
  }

  @override
  void didUpdateWidget(covariant TVDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tvShow.id != widget.tvShow.id) {
      setState(() {
        _detailsFuture = _loadDetails();
      });
    }
  }

  Future<TVDetailed> _loadDetails() {
    final repository = context.read<TmdbRepository>();
    return repository.fetchTvDetails(widget.tvShow.id);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: FutureBuilder<TVDetailed>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      loc.t('errors.unknown_error'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          final details = snapshot.data;

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, loc, details),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, loc),
                    _buildActions(context, loc),
                    _buildOverview(context, loc),
                    _buildMetadata(context, loc),
                    _buildGenres(context, loc),
                    if (details != null) _buildSeasons(context, loc, details),
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

  Widget _buildAppBar(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed? details,
  ) {
    final backdropUrl = details?.backdropPath != null
        ? ApiConfig.getBackdropUrl(details!.backdropPath)
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

  Widget _buildHeader(BuildContext context, AppLocalizations loc) {
    final posterUrl = widget.tvShow.posterUrl;

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
                        widget.tvShow.title,
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
                if (widget.tvShow.releaseYear != null &&
                    widget.tvShow.releaseYear!.isNotEmpty)
                  Text(
                    '${loc.t('tv.first_aired')}: ${widget.tvShow.releaseYear}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                const SizedBox(height: 8),
                if (widget.tvShow.voteAverage != null &&
                    widget.tvShow.voteAverage! > 0)
                  RatingDisplay(
                    rating: widget.tvShow.voteAverage!,
                    voteCount: widget.tvShow.voteCount,
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

  Widget _buildOverview(BuildContext context, AppLocalizations loc) {
    if (widget.tvShow.overview == null || widget.tvShow.overview!.isEmpty) {
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
            widget.tvShow.overview!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, AppLocalizations loc) {
    final metadata = <MapEntry<String, String>>[];

    if (widget.tvShow.releaseDate != null &&
        widget.tvShow.releaseDate!.isNotEmpty) {
      metadata.add(MapEntry(
        loc.t('tv.first_air_date'),
        widget.tvShow.releaseDate!,
      ));
    }

    if (widget.tvShow.voteCount != null && widget.tvShow.voteCount! > 0) {
      metadata.add(MapEntry(
        loc.t('tv.votes'),
        widget.tvShow.voteCount.toString(),
      ));
    }

    if (widget.tvShow.popularity != null) {
      metadata.add(MapEntry(
        loc.t('tv.popularity'),
        widget.tvShow.popularity!.toStringAsFixed(0),
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
    final genreIds = widget.tvShow.genreIds ?? const <int>[];

    if (genreIds.isEmpty) {
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
            children: genreIds.map((genreId) {
              // Get genre name from Movie.genreMap
              final genreName = Movie.genreMap[genreId] ?? 'Genre $genreId';
              return Chip(
                label: Text(genreName),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasons(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed details,
  ) {
    if (details.seasons.isEmpty) {
      return const SizedBox.shrink();
    }

    final seasonsWithEpisodes = details.seasons
        .where((season) => season.episodes.isNotEmpty)
        .toList();

    if (seasonsWithEpisodes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          ...seasonsWithEpisodes.map(
            (season) => _SeasonEpisodesSection(season: season),
          ),
        ],
      ),
    );
  }
}

class _SeasonEpisodesSection extends StatelessWidget {
  const _SeasonEpisodesSection({required this.season});

  final Season season;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final episodes = season.episodes;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            '${season.name} (${season.seasonNumber})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (season.airDate != null && season.airDate!.isNotEmpty)
                Text(season.airDate!),
              if (season.episodeCount != null)
                Text('${season.episodeCount} ${loc.t('tv.episodes').toLowerCase()}'),
            ],
          ),
          children: [
            const Divider(height: 1),
            ...List.generate(episodes.length, (index) {
              final episode = episodes[index];
              return _EpisodeTile(
                episode: episode,
                isLast: index == episodes.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    required this.episode,
    required this.isLast,
  });

  final Episode episode;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final stillUrl = ApiConfig.getBackdropUrl(
      episode.stillPath,
      size: ApiConfig.backdropSizeSmall,
    );

    final guestStars = episode.cast.take(5).map((cast) => cast.name).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, isLast ? 16 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: stillUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: stillUrl,
                        width: 140,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 140,
                          height: 80,
                          color: Colors.grey[300],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 140,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        ),
                      )
                    : Container(
                        width: 140,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.tv),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${episode.episodeNumber}. ${episode.name}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        if (episode.airDate != null &&
                            episode.airDate!.isNotEmpty)
                          _EpisodeMetaChip(
                            icon: Icons.event,
                            label: episode.airDate!,
                          ),
                        if (episode.runtime != null && episode.runtime! > 0)
                          _EpisodeMetaChip(
                            icon: Icons.schedule,
                            label:
                                '${episode.runtime} ${loc.t('movie.minutes')}',
                          ),
                        if (episode.voteAverage != null &&
                            episode.voteAverage! > 0)
                          _EpisodeMetaChip(
                            icon: Icons.star_rate_rounded,
                            label: episode.voteAverage!.toStringAsFixed(1),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (episode.overview != null && episode.overview!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                episode.overview!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          if (guestStars.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: '${loc.t('tv.guest_stars')}: ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: guestStars.join(', ')),
                  ],
                ),
              ),
            ),
          if (!isLast) const Divider(height: 24),
        ],
      ),
    );
  }
}

class _EpisodeMetaChip extends StatelessWidget {
  const _EpisodeMetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

