import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/media_image_helper.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/navigation/deep_link_handler.dart';
import '../../../data/models/credit_model.dart';
import '../../../data/models/episode_group_model.dart';
import '../../../data/models/episode_model.dart';
import '../../../data/models/episode_group_model.dart';
import '../../../data/models/image_model.dart';
import '../../../data/models/keyword_model.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/network_model.dart';
import '../../../data/models/saved_media_item.dart';
import '../../../data/models/season_model.dart';
import '../../../data/models/tv_detailed_model.dart';
import '../../../data/models/video_model.dart';
import '../../../data/models/media_images.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/tv_detail_provider.dart';
import '../../../providers/watch_region_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../../providers/offline_provider.dart';
import '../../widgets/error_widget.dart';
import '../../../data/models/watch_provider_model.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/rating_display.dart';
import '../../widgets/media_image.dart';
import '../../widgets/fullscreen_modal_scaffold.dart';
import '../../navigation/season_detail_args.dart';
import '../season_detail/season_detail_screen.dart';
import '../../widgets/watch_providers_section.dart';
import '../../widgets/share_link_sheet.dart';
import '../../../core/navigation/deep_link_parser.dart';

class TVDetailScreen extends StatelessWidget {
  static const routeName = '/tv-detail';

  final Movie tvShow;

  const TVDetailScreen({super.key, required this.tvShow});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<TmdbRepository>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TvDetailProvider(repository, tvId: tvShow.id)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              MediaGalleryProvider(repository)..loadTvImages(tvShow.id),
        ),
      ],
      child: const _TVDetailView(),
    );
  }
}

class _TVDetailView extends StatelessWidget {
  const _TVDetailView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TvDetailProvider>();
    final loc = AppLocalizations.of(context);

    if (provider.isLoading && provider.details == null) {
      return const FullscreenModalScaffold(
        title: Text('Loading...'),
        body: Center(child: LoadingIndicator()),
      );
    }

    if (provider.errorMessage != null && provider.details == null) {
      return FullscreenModalScaffold(
        title: const Text('Error'),
        body: Center(
          child: ErrorDisplay(
            message: provider.errorMessage!,
            onRetry: () => provider.load(forceRefresh: true),
          ),
        ),
      );
    }

    final details = provider.details;
    if (details == null) {
      return const FullscreenModalScaffold(
        title: Text('TV Show'),
        body: Center(child: Text('No details available')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, details, loc),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(
                  context,
                  provider.tvId,
                  details,
                  loc,
                ),
                _buildActions(context, details, loc),
                _buildOverview(context, details, loc),
                _buildMetadata(context, details, loc),
                // Content ratings not available on TVDetailed model currently
                _buildGenres(context, details, loc),
                _buildNetworks(context, details, loc),
                _buildSeasons(context, details, loc, provider),
                _buildEpisodeGroups(context, provider, loc),
                _buildCast(context, details, loc),
                _buildVideos(context, details, loc),
                _buildKeywords(context, details, loc),
                _buildWatchProviders(context, details),
                const MediaGallerySection(),
                _buildExternalLinks(context, details, loc),
                _buildRecommendations(context, details, loc),
                _buildSimilar(context, details, loc),
                _buildProductionInfo(context, details, loc),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    final backdropPath = details.backdropPath;

    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      actions: [
        IconButton(
          tooltip: loc.t('movie.share'),
          icon: const Icon(Icons.share),
          onPressed: () {
            showShareLinkSheet(
              context,
              title: details.name,
              link: DeepLinkBuilder.tvShow(details.id),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          details.name,
          style: const TextStyle(
            shadows: [Shadow(color: Colors.black, blurRadius: 8)],
          ),
        ),
        background: backdropPath != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  MediaImage(
                    path: backdropPath,
                    type: MediaImageType.backdrop,
                    size: MediaImageSize.w780,
                    fit: BoxFit.cover,
                    enableBlur: true,
                    blurSigmaX: 24,
                    blurSigmaY: 24,
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
    int tvId,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    final posterPath = details.posterPath;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'tv-poster-$tvId',
            flightShuttleBuilder: (context, animation, direction, from, to) {
              return FadeTransition(
                opacity: animation.drive(
                  CurveTween(curve: Curves.easeInOut),
                ),
                child: to.widget,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: MediaImage(
                path: posterPath,
                type: MediaImageType.poster,
                size: MediaImageSize.w500,
                width: 120,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (details.tagline != null && details.tagline!.isNotEmpty) ...[
                  Text(
                    details.tagline!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      details.firstAirDate ?? 'Unknown',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (details.numberOfSeasons != null &&
                    details.numberOfEpisodes != null) ...[
                  Text(
                    '${details.numberOfSeasons} ${details.numberOfSeasons == 1 ? 'Season' : 'Seasons'} • ${details.numberOfEpisodes} Episodes',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (details.voteAverage > 0)
                  RatingDisplay(
                    rating: details.voteAverage,
                    voteCount: details.voteCount,
                    size: 18,
                  ),
                const SizedBox(height: 8),
                if (details.status != null)
                  Chip(
                    label: Text(details.status!),
                    avatar: Icon(_getStatusIcon(details.status!), size: 16),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final watchlistProvider = context.watch<WatchlistProvider>();
    final offlineProvider = context.watch<OfflineProvider>();

    final isFavorite = favoritesProvider.isFavorite(details.id);
    final isInWatchlist = watchlistProvider.isInWatchlist(details.id);
    final isDownloaded = offlineProvider.downloadedItems.any(
      (item) => item.id == details.id && item.type == SavedMediaType.tv,
    );
    final episodeRuntime =
        details.episodeRunTime.isNotEmpty ? details.episodeRunTime.first : null;
    final offlineItem = SavedMediaItem(
      id: details.id,
      type: SavedMediaType.tv,
      title: details.name,
      originalTitle: details.originalName,
      posterPath: details.posterPath,
      backdropPath: details.backdropPath,
      overview: details.overview,
      releaseDate: details.firstAirDate,
      voteAverage: details.voteAverage,
      voteCount: details.voteCount,
      episodeRuntimeMinutes: episodeRuntime,
      episodeCount: details.numberOfEpisodes,
      seasonCount: details.numberOfSeasons,
      genreIds: details.genres.map((genre) => genre.id).toList(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    favoritesProvider.toggleFavorite(details.id);
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
                  icon:
                      Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                  label: Text(
                    isFavorite
                        ? loc.t('tv.remove_from_favorites')
                        : loc.t('tv.add_to_favorites'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFavorite
                        ? Colors.red.withOpacity(0.1)
                        : null,
                    foregroundColor: isFavorite ? Colors.red : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    watchlistProvider.toggleWatchlist(details.id);
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
                  ),
                  label: Text(
                    isInWatchlist
                        ? loc.t('tv.remove_from_watchlist')
                        : loc.t('tv.add_to_watchlist'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInWatchlist
                        ? Colors.blue.withOpacity(0.1)
                        : null,
                    foregroundColor: isInWatchlist ? Colors.blue : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final nowDownloaded =
                        await offlineProvider.toggleDownload(offlineItem);
                    final message = nowDownloaded
                        ? loc.t('offline.download_saved')
                        : loc.t('offline.download_removed');
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(
                    isDownloaded
                        ? Icons.offline_pin
                        : Icons.download_for_offline,
                  ),
                  label: Text(
                    isDownloaded
                        ? loc.t('offline.remove_download')
                        : loc.t('offline.download'),
                  ),
                ),
              ),
            ],
          ),
          if (isDownloaded) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.offline_pin, size: 16),
                label: Text(loc.t('offline.downloaded')),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverview(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    if (details.overview == null || details.overview!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('tv.overview'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(details.overview!, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildMetadata(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    final metadata = <MapEntry<String, String>>[];

    if (details.firstAirDate != null && details.firstAirDate!.isNotEmpty) {
      metadata.add(MapEntry('First Air Date', details.firstAirDate!));
    }

    if (details.lastAirDate != null && details.lastAirDate!.isNotEmpty) {
      metadata.add(MapEntry('Last Air Date', details.lastAirDate!));
    }

    if (details.episodeRunTime.isNotEmpty) {
      metadata.add(
        MapEntry('Episode Runtime', '${details.episodeRunTime.first} min'),
      );
    }

    if (details.popularity != null) {
      metadata.add(
        MapEntry('Popularity', details.popularity!.toStringAsFixed(1)),
      );
    }

    if (metadata.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Details',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...metadata.map(
                (entry) => Padding(
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
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // _buildContentRatings removed: the current TVDetailed model doesn't expose ratings

  Widget _buildContentRatings(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    final repository = context.read<TmdbRepository>();
    return FutureBuilder<Map<String, String>>(
      future: repository.fetchTvContentRatings(details.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        final map = snapshot.data;
        if (map == null || map.isEmpty) return const SizedBox.shrink();
        final entries = map.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content Ratings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entries.map((e) {
                      return Chip(
                        label: Text('${e.key}: ${e.value}'),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenres(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    if (details.genres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('tv.genres'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: details.genres.map((genre) {
              return Chip(
                label: Text(genre.name),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworks(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    if (details.networks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Networks',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: details.networks.length,
              itemBuilder: (context, index) {
                final network = details.networks[index];
                return _NetworkLogo(network: network);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasons(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
    TvDetailProvider provider,
  ) {
    if (details.seasons.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter out specials (season 0) for main list
    final mainSeasons = details.seasons
        .where((s) => s.seasonNumber > 0)
        .toList();

    if (mainSeasons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Seasons',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: mainSeasons.length,
            itemBuilder: (context, index) {
              final season = mainSeasons[index];
              return _SeasonCard(
                season: season,
                onTap: () => Navigator.of(context).pushNamed(
                  SeasonDetailScreen.routeName,
                  arguments: SeasonDetailArgs(
                    tvId: details.id,
                    seasonNumber: season.seasonNumber,
                  ),
                ),
              );
            },
          ),
        ),
        if (provider.selectedSeasonNumber != null)
          _buildSelectedSeasonDetails(context, details, loc, provider),
      ],
    );
  }

  Widget _buildEpisodeGroups(
    BuildContext context,
    TvDetailProvider provider,
    AppLocalizations loc,
  ) {
    final groups = provider.episodeGroups;
    final isLoading = provider.isEpisodeGroupsLoading;
    final error = provider.episodeGroupsError;
    final selectedGroup = provider.selectedEpisodeGroup;

    if (groups.isEmpty) {
      if (error != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ErrorDisplay(
            message: error,
            onRetry: () => provider.retryEpisodeGroups(),
          ),
        );
      }

      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                loc.t('tv.episode_groups'),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (isLoading) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final group in groups)
                ChoiceChip(
                  label: Text(group.name),
                  selected: provider.selectedEpisodeGroupId == group.id ||
                      (provider.selectedEpisodeGroupId == null &&
                          group == groups.first),
                  onSelected: (_) => provider.selectEpisodeGroup(group.id),
                ),
            ],
          ),
          if (selectedGroup != null &&
              selectedGroup.description != null &&
              selectedGroup.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              selectedGroup.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          if (selectedGroup == null || selectedGroup.groups.isEmpty)
            Text(
              loc.t('tv.episode_group_no_episodes'),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            )
          else
            Column(
              children: [
                for (final node in selectedGroup.groups)
                  _EpisodeGroupNodeCard(node: node, loc: loc),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedSeasonDetails(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
    TvDetailProvider provider,
  ) {
    final seasonNumber = provider.selectedSeasonNumber!;
    final season = provider.seasonForNumber(seasonNumber);
    final isLoading = provider.isSeasonLoading(seasonNumber);
    final error = provider.seasonError(seasonNumber);
    final images = provider.seasonImagesForNumber(seasonNumber);
    final imagesLoading = provider.isSeasonImagesLoading(seasonNumber);
    final imagesError = provider.seasonImagesError(seasonNumber);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Season $seasonNumber',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _SeasonImageGallery(
                provider: provider,
                seasonNumber: seasonNumber,
                images: images,
                isLoading: imagesLoading,
                error: imagesError,
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (error != null)
                ErrorDisplay(
                  message: error,
                  onRetry: () => provider.retrySeason(seasonNumber),
                )
              else if (season != null && season.episodes.isNotEmpty)
                ...season.episodes.map(
                  (episode) => _EpisodeCard(
                        episode: episode,
                        tvId: details.id,
                        seasonNumber: seasonNumber,
                      ),
                )
              else
                Center(child: Text(loc.t('tv.no_episodes'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCast(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    if (details.cast.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayCast = details.cast.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Cast',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayCast.length,
            itemBuilder: (context, index) {
              final castMember = displayCast[index];
              return _CastCard(cast: castMember);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideos(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    if (details.videos.isEmpty) {
      return const SizedBox.shrink();
    }

    final trailers = details.videos
        .where((video) => video.type == 'Trailer' || video.type == 'Teaser')
        .take(5)
        .toList();

    if (trailers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Videos & Trailers',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: trailers.length,
            itemBuilder: (context, index) {
              final video = trailers[index];
              return _VideoCard(video: video);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKeywords(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    if (details.keywords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Keywords',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: details.keywords.take(20).map((keyword) {
              return Chip(
                label: Text(keyword.name),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchProviders(BuildContext context, TVDetailed details) {
    final region = context.watch<WatchRegionProvider>().region;
    final repository = context.read<TmdbRepository>();

    return FutureBuilder<Map<String, WatchProviderResults>>(
      future: repository.fetchTvWatchProviders(details.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 48,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final map = snapshot.data!;
        final providers = map[region] ?? map['US'];
        if (providers == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: WatchProvidersSection(region: region, providers: providers),
        );
      },
    );
  }

  Widget _buildExternalLinks(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    final links = <MapEntry<String, String>>[];

    if (details.homepage != null && details.homepage!.isNotEmpty) {
      links.add(MapEntry('Homepage', details.homepage!));
    }

    if (details.externalIds.imdbId != null) {
      links.add(
        MapEntry(
          'IMDb',
          'https://www.imdb.com/title/${details.externalIds.imdbId}',
        ),
      );
    }

    if (details.externalIds.facebookId != null) {
      links.add(
        MapEntry(
          'Facebook',
          'https://www.facebook.com/${details.externalIds.facebookId}',
        ),
      );
    }

    if (details.externalIds.twitterId != null) {
      links.add(
        MapEntry(
          'Twitter',
          'https://twitter.com/${details.externalIds.twitterId}',
        ),
      );
    }

    if (details.externalIds.instagramId != null) {
      links.add(
        MapEntry(
          'Instagram',
          'https://www.instagram.com/${details.externalIds.instagramId}',
        ),
      );
    }

    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'External Links',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: links.map((link) {
                  return OutlinedButton.icon(
                    onPressed: () => _launchURL(link.value, context),
                    icon: Icon(_getIconForLink(link.key)),
                    label: Text(link.key),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendations(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    if (details.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recommended TV Shows',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: details.recommendations.take(10).length,
            itemBuilder: (context, index) {
              final show = details.recommendations[index];
              return SizedBox(
                width: 140,
                child: MovieCard(
                  id: show.id,
                  title: show.name,
                  posterPath: show.posterPath,
                  voteAverage: show.voteAverage,
                  releaseDate: show.firstAirDate,
                  heroTag: 'tv-poster-${show.id}',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TVDetailScreen(
                          tvShow: Movie(
                            id: show.id,
                            title: show.name,
                            posterPath: show.posterPath,
                            backdropPath: show.backdropPath,
                            voteAverage: show.voteAverage,
                            voteCount: 0,
                            releaseDate: show.firstAirDate,
                            genreIds: [],
                          ),
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSimilar(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    if (details.similar.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Similar TV Shows',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: details.similar.take(10).length,
            itemBuilder: (context, index) {
              final show = details.similar[index];
              return SizedBox(
                width: 140,
                child: MovieCard(
                  id: show.id,
                  title: show.name,
                  posterPath: show.posterPath,
                  voteAverage: show.voteAverage,
                  releaseDate: show.firstAirDate,
                  heroTag: 'tv-poster-${show.id}',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TVDetailScreen(
                          tvShow: Movie(
                            id: show.id,
                            title: show.name,
                            posterPath: show.posterPath,
                            backdropPath: show.backdropPath,
                            voteAverage: show.voteAverage,
                            voteCount: 0,
                            releaseDate: show.firstAirDate,
                            genreIds: [],
                          ),
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductionInfo(
    BuildContext context,
    TVDetailed details,
    AppLocalizations loc,
  ) {
    if (details.productionCompanies.isEmpty &&
        details.productionCountries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Production',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (details.productionCompanies.isNotEmpty) ...[
                Text(
                  'Companies:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: details.productionCompanies
                      .map((company) => Chip(label: Text(company.name)))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              if (details.productionCountries.isNotEmpty) ...[
                Text(
                  'Countries:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(details.productionCountries.map((c) => c.name).join(', ')),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'returning series':
        return Icons.replay;
      case 'ended':
        return Icons.check_circle;
      case 'canceled':
        return Icons.cancel;
      case 'in production':
        return Icons.videocam;
      default:
        return Icons.info;
    }
  }

  void _launchURL(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot open this link')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to open link: $e')));
      }
    }
  }

  IconData _getIconForLink(String linkName) {
    switch (linkName.toLowerCase()) {
      case 'homepage':
        return Icons.language;
      case 'imdb':
        return Icons.movie;
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
        return Icons.tag;
      case 'instagram':
        return Icons.photo_camera;
      default:
        return Icons.link;
    }
  }
}

class _NetworkLogo extends StatelessWidget {
  final Network network;

  const _NetworkLogo({required this.network});

  @override
  Widget build(BuildContext context) {
    final logoPath = network.logoPath;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: logoPath != null
          ? MediaImage(
              path: logoPath,
              type: MediaImageType.logo,
              size: MediaImageSize.w92,
              height: 40,
              fit: BoxFit.contain,
            )
          : Container(
              width: 80,
              height: 40,
              alignment: Alignment.center,
              child: Text(
                network.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
  }

class _EpisodeGroupNodeCard extends StatelessWidget {
  const _EpisodeGroupNodeCard({required this.node, required this.loc});

  final EpisodeGroupNode node;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final episodes = node.episodes;

    final title = node.name.isNotEmpty
        ? node.name
        : loc
            .t('tv.episode_group_node_fallback')
            .replaceFirst('{order}', '${node.order ?? '?'}');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(title),
        subtitle: node.overview != null && node.overview!.isNotEmpty
            ? Text(node.overview!)
            : null,
        children: [
          if (episodes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                loc.t('tv.episode_group_no_episodes'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...episodes.map(
              (episode) => _EpisodeGroupEpisodeTile(
                episode: episode,
                loc: loc,
              ),
            ),
        ],
      ),
    );
  }
}

class _EpisodeGroupEpisodeTile extends StatelessWidget {
  const _EpisodeGroupEpisodeTile({required this.episode, required this.loc});

  final EpisodeGroupEpisode episode;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stillPath = episode.stillPath;
    final code =
        'S${episode.seasonNumber.toString().padLeft(2, '0')}E${episode.episodeNumber.toString().padLeft(2, '0')}';
    final metadata = <String>[code];
    if (episode.airDate != null && episode.airDate!.isNotEmpty) {
      metadata.add(episode.airDate!);
    }
    final votes = episode.voteAverage != null
        ? '${episode.voteAverage!.toStringAsFixed(1)} • '
            '${episode.voteCount ?? 0} ${loc.t('movie.votes')}'
        : null;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: stillPath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: MediaImage(
                path: stillPath,
                type: MediaImageType.still,
                size: MediaImageSize.w300,
                width: 100,
                height: 56,
                fit: BoxFit.cover,
              ),
            )
          : CircleAvatar(
              radius: 24,
              child: Text(
                code,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
      title: Text(
        episode.name.isNotEmpty
            ? episode.name
            : '${loc.t('tv.episode')} ${episode.episodeNumber}',
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metadata.join(' • '),
            style: theme.textTheme.bodySmall,
          ),
          if (votes != null)
            Text(
              votes,
              style: theme.textTheme.bodySmall,
            ),
          if (episode.overview != null && episode.overview!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                episode.overview!,
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _SeasonCard extends StatelessWidget {
  final Season season;
  final VoidCallback onTap;

  const _SeasonCard({required this.season, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final posterPath = season.posterPath;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: MediaImage(
                path: posterPath,
                type: MediaImageType.poster,
                size: MediaImageSize.w342,
                width: 140,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              season.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (season.episodeCount != null)
              Text(
                '${season.episodeCount} episodes',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}

class _SeasonImageGallery extends StatelessWidget {
  const _SeasonImageGallery({
    required this.provider,
    required this.seasonNumber,
    required this.images,
    required this.isLoading,
    required this.error,
  });

  final TvDetailProvider provider;
  final int seasonNumber;
  final MediaImages? images;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (isLoading) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return ErrorDisplay(
        message: error!,
        onRetry: () => provider.retrySeasonImages(seasonNumber),
      );
    }

    if (images == null) {
      return const SizedBox.shrink();
    }

    if (!images!.hasAny) {
      return Text(loc.t('tv.no_images'));
    }

    final theme = Theme.of(context);
    final sections = <Widget>[
      Text(
        loc.t('tv.season_images_title')
            .replaceFirst('{seasonNumber}', '$seasonNumber'),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
    ];

    void addSection(
      String title,
      List<ImageModel> items,
      MediaImageType type,
      MediaImageSize size,
      double height, {
      double? width,
    }) {
      if (items.isEmpty) {
        return;
      }
      sections.add(Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ));
      sections.add(const SizedBox(height: 8));
      sections.add(
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final image = items[index];
              final heroTag = 'tv-season-$seasonNumber-${type.name}-$index';
              return GestureDetector(
                onTap: () => _openGallery(
                  context,
                  items,
                  index,
                  type,
                ),
                child: Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: MediaImage(
                      path: image.filePath,
                      type: type,
                      size: size,
                      width: width,
                      height: height,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: items.length,
          ),
        ),
      );
      sections.add(const SizedBox(height: 16));
    }

    addSection(
      loc.t('movie.posters'),
      images!.posters,
      MediaImageType.poster,
      MediaImageSize.w342,
      200,
      width: 140,
    );
    addSection(
      loc.t('movie.backdrops'),
      images!.backdrops,
      MediaImageType.backdrop,
      MediaImageSize.w780,
      140,
      width: 240,
    );
    addSection(
      loc.t('movie.stills'),
      images!.stills,
      MediaImageType.still,
      MediaImageSize.w300,
      120,
      width: 200,
    );

    if (sections.isNotEmpty && sections.last is SizedBox) {
      sections.removeLast();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }

  void _openGallery(
    BuildContext context,
    List<ImageModel> images,
    int initialIndex,
    MediaImageType type,
  ) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: ImageGallery(
            images: images,
            mediaType: type,
            initialIndex: initialIndex,
            heroTagBuilder: (index, image) =>
                'tv-season-${seasonNumber}-${type.name}-$index',
          ),
        );
      },
    );
  }
}

class _EpisodeGroupNodeCard extends StatelessWidget {
  const _EpisodeGroupNodeCard({required this.node, required this.loc});

  final EpisodeGroupNode node;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overview = node.overview?.trim();
    final episodes = node.episodes;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              node.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (overview != null && overview.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                overview,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            if (episodes.isEmpty)
              Text(
                loc.t('tv.episode_group_no_episodes'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            else
              Column(
                children: [
                  for (final episode in episodes)
                    _EpisodeGroupEpisodeTile(
                      episode: episode,
                      loc: loc,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeGroupEpisodeTile extends StatelessWidget {
  const _EpisodeGroupEpisodeTile({required this.episode, required this.loc});

  final EpisodeGroupEpisode episode;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seasonNumber = episode.seasonNumber.toString().padLeft(2, '0');
    final episodeNumber = episode.episodeNumber.toString().padLeft(2, '0');
    final meta = <String>[];
    if (episode.airDate != null && episode.airDate!.isNotEmpty) {
      meta.add(episode.airDate!);
    }
    if (episode.voteAverage != null && episode.voteAverage! > 0) {
      meta.add('${episode.voteAverage!.toStringAsFixed(1)}/10');
    }
    if (episode.order != null) {
      meta.add(
        loc
            .t('tv.episode_group_order')
            .replaceFirst('{order}', '${episode.order}'),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (episode.stillPath != null && episode.stillPath!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: MediaImage(
                path: episode.stillPath,
                type: MediaImageType.still,
                size: MediaImageSize.w300,
                width: 120,
                height: 68,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 120,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.live_tv,
                color: Colors.grey[600],
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'S$seasonNumber · E$episodeNumber — ${episode.name}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    meta.join(' • '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (episode.overview != null && episode.overview!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    episode.overview!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  final Episode episode;
  final int tvId;
  final int seasonNumber;

  const _EpisodeCard({
    required this.episode,
    required this.tvId,
    required this.seasonNumber,
  });

  @override
  Widget build(BuildContext context) {
    final stillPath = episode.stillPath;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to episode details
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (stillPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: MediaImage(
                    path: stillPath,
                    type: MediaImageType.still,
                    size: MediaImageSize.w300,
                    width: 120,
                    height: 68,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'E${episode.episodeNumber}: ${episode.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (episode.airDate != null)
                      Text(
                        episode.airDate!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    if (episode.overview != null &&
                        episode.overview!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        episode.overview!,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CastCard extends StatelessWidget {
  final Cast cast;

  const _CastCard({required this.cast});

  @override
  Widget build(BuildContext context) {
    final profilePath = cast.profilePath;

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: MediaImage(
              path: profilePath,
              type: MediaImageType.profile,
              size: MediaImageSize.w185,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cast.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (cast.character != null)
            Text(
              cast.character!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final Video video;

  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = video.site == 'YouTube'
        ? 'https://img.youtube.com/vi/${video.key}/mqdefault.jpg'
        : null;

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _launchVideo(video),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (thumbnailUrl != null)
                    CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      width: 240,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      width: 240,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.play_circle_outline, size: 48),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              video.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _launchVideo(Video video) async {
    if (video.site == 'YouTube') {
      final url = 'https://www.youtube.com/watch?v=${video.key}';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}

class _ProviderLogo extends StatelessWidget {
  final String logoPath;

  const _ProviderLogo({required this.logoPath});

  @override
  Widget build(BuildContext context) {
    final logoUrl = logoPath.isNotEmpty ? logoPath : null;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: logoUrl != null
          ? MediaImage(
              path: logoUrl,
              type: MediaImageType.logo,
              size: MediaImageSize.w92,
              height: 30,
              fit: BoxFit.contain,
            )
          : Container(
              width: 40,
              height: 30,
              alignment: Alignment.center,
              child: Text(
                'N/A',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
    );
  }
}
