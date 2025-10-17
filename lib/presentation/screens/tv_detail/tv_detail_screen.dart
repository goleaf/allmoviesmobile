import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/episode_model.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/season_model.dart';
import '../../../data/models/tv_detailed_model.dart';
import '../../../data/services/api_config.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/tv_detail_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/rating_display.dart';

class TVDetailScreen extends StatelessWidget {
  static const routeName = '/tv-detail';

  final Movie tvShow;

  const TVDetailScreen({
    super.key,
    required this.tvShow,
  });

  @override
  Widget build(BuildContext context) {
    final repository = context.read<TmdbRepository>();

    return ChangeNotifierProvider(
      create: (_) => TvDetailProvider(repository, tvId: tvShow.id)..load(),
      child: _TvDetailView(tvShow: tvShow),
    );
  }
}

class _TvDetailView extends StatelessWidget {
  const _TvDetailView({required this.tvShow});

  final Movie tvShow;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TvDetailProvider>();
    final loc = AppLocalizations.of(context);
    final details = provider.details;

    final backdropUrl = details != null
        ? _backdropUrl(details.backdropPath)
        : tvShow.backdropUrl;
    final posterUrl = details != null
        ? _posterUrl(details.posterPath)
        : tvShow.posterUrl;
    final title = details?.name ?? tvShow.title;
    final tagline = details?.tagline;
    final overview = details?.overview ?? tvShow.overview;
    final voteAverage = details?.voteAverage ?? tvShow.voteAverage;
    final voteCount = details?.voteCount ?? tvShow.voteCount;
    final firstAirDate = _formatDate(details?.firstAirDate ?? tvShow.releaseDate);

    final slivers = <Widget>[
      _buildAppBar(context, backdropUrl),
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(
              context,
              loc,
              posterUrl,
              title,
              tagline,
              voteAverage,
              voteCount,
              firstAirDate,
            ),
            _buildActions(context, loc),
            if (provider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _ErrorNotice(
                  message: provider.errorMessage!,
                  onRetry: provider.refresh,
                ),
              ),
            if (provider.isLoading && details == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: LoadingIndicator()),
              )
            else ...[
              _buildOverview(context, loc, overview),
              _buildMetadata(context, loc, details),
              _buildGenres(context, loc, details),
              _buildSeasonsSection(context, loc, provider),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: slivers,
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, String? backdropUrl) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: (backdropUrl ?? '').isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: backdropUrl!,
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
    String? posterUrl,
    String title,
    String? tagline,
    double? voteAverage,
    int? voteCount,
    String? firstAirDate,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (posterUrl ?? '').isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: posterUrl!,
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if ((tagline ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    tagline!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                  ),
                ],
                const SizedBox(height: 8),
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
                        loc.t('tv.title'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                if ((firstAirDate ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${loc.t('tv.first_air_date')}: $firstAirDate',
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

    final isFavorite = favoritesProvider.isFavorite(tvShow.id);
    final isInWatchlist = watchlistProvider.isInWatchlist(tvShow.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                favoritesProvider.toggleFavorite(tvShow.id);
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
                watchlistProvider.toggleWatchlist(tvShow.id);
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
    String? overview,
  ) {
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
    TVDetailed? details,
  ) {
    if (details == null) {
      return const SizedBox.shrink();
    }

    final metadata = <MapEntry<String, String>>[];

    if ((details.firstAirDate ?? '').isNotEmpty) {
      metadata.add(MapEntry(
        loc.t('tv.first_air_date'),
        _formatDate(details.firstAirDate) ?? details.firstAirDate!,
      ));
    }

    if ((details.lastAirDate ?? '').isNotEmpty) {
      metadata.add(MapEntry(
        loc.t('tv.last_air_date'),
        _formatDate(details.lastAirDate) ?? details.lastAirDate!,
      ));
    }

    if (details.numberOfSeasons != null) {
      metadata.add(MapEntry(
        loc.t('tv.number_of_seasons'),
        details.numberOfSeasons.toString(),
      ));
    }

    if (details.numberOfEpisodes != null) {
      metadata.add(MapEntry(
        loc.t('tv.number_of_episodes'),
        details.numberOfEpisodes.toString(),
      ));
    }

    if (details.episodeRunTime.isNotEmpty) {
      final runtimes = details.episodeRunTime;
      final formatted = runtimes.length == 1
          ? '${runtimes.first} ${loc.t('movie.minutes')}'
          : '${runtimes.reduce((a, b) => a < b ? a : b)}-${runtimes.reduce((a, b) => a > b ? a : b)} ${loc.t('movie.minutes')}';
      metadata.add(MapEntry(
        loc.t('tv.episode_runtime'),
        formatted,
      ));
    }

    if ((details.status ?? '').isNotEmpty) {
      metadata.add(MapEntry('Status', details.status!));
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

  Widget _buildGenres(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed? details,
  ) {
    final chips = <String>[];

    if (details != null) {
      chips.addAll(details.genres.map((genre) => genre.name).whereType<String>());
    } else if (tvShow.genreIds != null) {
      chips.addAll(tvShow.genres);
    }

    if (chips.isEmpty) {
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
            children: chips
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

  Widget _buildSeasonsSection(
    BuildContext context,
    AppLocalizations loc,
    TvDetailProvider provider,
  ) {
    final seasons = provider.seasons;
    if (seasons.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedSeasonNumber =
        provider.selectedSeasonNumber ?? seasons.first.seasonNumber;
    final selectedSeason = provider.seasonForNumber(selectedSeasonNumber);
    final episodes = provider.episodesForSeason(selectedSeasonNumber);
    final isLoading = provider.isSeasonLoading(selectedSeasonNumber);
    final error = provider.seasonError(selectedSeasonNumber);

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: seasons.map((season) {
                final isSelected = season.seasonNumber == selectedSeasonNumber;
                final label = _seasonLabel(loc, season);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) =>
                        provider.selectSeason(season.seasonNumber),
                  ),
                );
              }).toList(),
            ),
          ),
          if (selectedSeason != null &&
              (selectedSeason.overview ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              selectedSeason.overview!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          if (isLoading && episodes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error != null)
            _SeasonErrorNotice(
              message: error,
              onRetry: () => provider.retrySeason(selectedSeasonNumber),
              loc: loc,
            )
          else if (episodes.isEmpty)
            Text(
              loc.t('tv.no_episodes'),
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: episodes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final episode = episodes[index];
                return _EpisodeCard(episode: episode, loc: loc);
              },
            ),
        ],
      ),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({required this.episode, required this.loc});

  final Episode episode;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final stillUrl = _stillUrl(episode.stillPath);
    final airDate = _formatDate(episode.airDate);
    final runtimeText = episode.runtime != null && episode.runtime! > 0
        ? '${episode.runtime} ${loc.t('movie.minutes')}'
        : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((stillUrl ?? '').isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: stillUrl!,
                      width: 120,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${loc.t('tv.episode')} ${episode.episodeNumber}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        episode.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if ((airDate ?? '').isNotEmpty || runtimeText != null) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            if ((airDate ?? '').isNotEmpty)
                              Text('${loc.t('tv.air_date')}: $airDate'),
                            if (runtimeText != null)
                              Text('${loc.t('movie.runtime')}: $runtimeText'),
                          ],
                        ),
                      ],
                      if (episode.voteAverage != null && episode.voteAverage! > 0) ...[
                        const SizedBox(height: 8),
                        RatingDisplay(
                          rating: episode.voteAverage!,
                          voteCount: episode.voteCount,
                          size: 14,
                          showLabel: false,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if ((episode.overview ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                episode.overview!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SeasonErrorNotice extends StatelessWidget {
  const _SeasonErrorNotice({
    required this.message,
    required this.onRetry,
    required this.loc,
  });

  final String message;
  final VoidCallback onRetry;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.onErrorContainer,
              ),
              child: Text(loc.t('tv.retry_loading_episodes')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.onErrorContainer,
              ),
              child: Text(loc.t('common.retry')),
            ),
          ],
        ),
      ),
    );
  }
}

String? _posterUrl(String? path) {
  if (path == null || path.isEmpty) {
    return null;
  }
  final url = ApiConfig.getPosterUrl(
    path,
    size: ApiConfig.posterSizeLarge,
  );
  return url.isEmpty ? null : url;
}

String? _backdropUrl(String? path) {
  if (path == null || path.isEmpty) {
    return null;
  }
  final url = ApiConfig.getBackdropUrl(
    path,
    size: ApiConfig.backdropSizeLarge,
  );
  return url.isEmpty ? null : url;
}

String? _stillUrl(String? path) {
  if (path == null || path.isEmpty) {
    return null;
  }
  return '${ApiConfig.tmdbImageBaseUrl}/w300$path';
}

String? _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    return raw;
  }
  return DateFormat.yMMMd().format(parsed);
}

String _seasonLabel(AppLocalizations loc, Season season) {
  final trimmedName = season.name.trim();
  final hasDefaultName =
      trimmedName.isEmpty || trimmedName.toLowerCase().startsWith('season');
  final baseLabel = hasDefaultName
      ? '${loc.t('tv.season')} ${season.seasonNumber}'
      : trimmedName;
  final episodeCount = season.episodeCount ?? season.episodes.length;
  if (episodeCount <= 0) {
    return baseLabel;
  }
  return '$baseLabel ($episodeCount)';
}
