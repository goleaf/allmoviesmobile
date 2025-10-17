import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/tmdb_repository.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/episode_model.dart';
import '../../../data/models/season_model.dart';
import '../../../presentation/widgets/media_image.dart';
import '../../../data/models/media_images.dart';
import '../../../data/models/image_model.dart';
import '../../../core/utils/media_image_helper.dart';
import '../../../presentation/widgets/error_widget.dart';
import '../../../presentation/widgets/loading_indicator.dart';
import '../../../presentation/widgets/fullscreen_modal_scaffold.dart';
import '../../widgets/image_gallery.dart';
import '../../navigation/season_detail_args.dart';
import '../episode_detail/episode_detail_screen.dart';
import '../../../providers/season_detail_provider.dart';
import '../../../core/navigation/deep_link_handler.dart';
import '../../widgets/deep_link_share_sheet.dart';

class SeasonDetailScreen extends StatelessWidget {
  static const routeName = '/season';

  final SeasonDetailArgs args;

  const SeasonDetailScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<TmdbRepository>();
    return ChangeNotifierProvider(
      create: (_) => SeasonDetailProvider(
        repository,
        tvId: args.tvId,
        seasonNumber: args.seasonNumber,
      )..load(),
      child: const _SeasonDetailView(),
    );
  }
}

class _SeasonDetailView extends StatelessWidget {
  const _SeasonDetailView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SeasonDetailProvider>();
    final loc = AppLocalizations.of(context);

    if (provider.isLoading && provider.season == null) {
      return const FullscreenModalScaffold(
        title: Text('Season'),
        body: Center(child: LoadingIndicator()),
      );
    }

    if (provider.errorMessage != null && provider.season == null) {
      return FullscreenModalScaffold(
        title: const Text('Season'),
        body: Center(
          child: ErrorDisplay(
            message: provider.errorMessage!,
            onRetry: () => provider.load(forceRefresh: true),
          ),
        ),
      );
    }

    final season = provider.season;
    if (season == null) {
      return const FullscreenModalScaffold(
        title: Text('Season'),
        body: Center(child: Text('No details available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${loc.t('tv.season')} ${season.seasonNumber}'),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: () {
              final displayTitle = season.name.isNotEmpty
                  ? season.name
                  : '${loc.t('tv.season')} ${season.seasonNumber}';
              showDeepLinkShareSheet(
                context,
                title: displayTitle,
                deepLink: DeepLinkHandler.buildSeasonUri(
                  provider.tvId,
                  season.seasonNumber,
                  universal: true,
                ),
                fallbackUrl:
                    'https://www.themoviedb.org/tv/${provider.tvId}/season/${season.seasonNumber}',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, season),
            _buildOverview(context, season, loc),
            _buildEpisodes(context, season),
            _buildCast(context, season),
            _buildCrew(context, season),
            _buildVideos(context, season),
            _buildImages(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Season season) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: MediaImage(
              path: season.posterPath,
              type: MediaImageType.poster,
              size: MediaImageSize.w500,
              width: 120,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (season.airDate != null)
                  Text(
                    season.airDate!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (season.episodeCount != null) ...[
                  const SizedBox(height: 8),
                  Text('${season.episodeCount} episodes'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(
    BuildContext context,
    Season season,
    AppLocalizations loc,
  ) {
    if (season.overview == null || season.overview!.isEmpty) {
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
          Text(season.overview!),
        ],
      ),
    );
  }

  Widget _buildEpisodes(BuildContext context, Season season) {
    final loc = AppLocalizations.of(context);
    if (season.episodes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).t('tv.episodes'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...season.episodes.map(
            (e) => _EpisodeTile(episode: e, seasonNumber: season.seasonNumber),
          ),
        ],
      ),
    );
  }

  Widget _buildCast(BuildContext context, Season season) {
    final loc = AppLocalizations.of(context);
    if (season.cast.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).t('movie.cast'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: season.cast.length,
              itemBuilder: (context, index) {
                final cast = season.cast[index];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: MediaImage(
                          path: cast.profilePath,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (cast.character != null)
                        Text(
                          cast.character!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
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

  Widget _buildCrew(BuildContext context, Season season) {
    final loc = AppLocalizations.of(context);
    if (season.crew.isEmpty) return const SizedBox.shrink();
    final crew = season.crew.take(12).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).t('movie.crew'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: crew
                .map(
                  (c) => Chip(
                    label: Text(
                      '${c.name}${c.job != null ? ' • ${c.job}' : ''}',
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideos(BuildContext context, Season season) {
    final loc = AppLocalizations.of(context);
    if (season.videos.isEmpty) return const SizedBox.shrink();
    final trailers = season.videos
        .where(
          (v) =>
              v.site == 'YouTube' &&
              (v.type == 'Trailer' || v.type == 'Teaser'),
        )
        .toList();
    if (trailers.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).t('movie.videos'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trailers.length,
              itemBuilder: (context, index) {
                final video = trailers[index];
                final thumbnailUrl =
                    'https://img.youtube.com/vi/${video.key}/mqdefault.jpg';
                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        thumbnailUrl,
                        width: 240,
                        height: 140,
                        fit: BoxFit.cover,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImages(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final repository = context.read<TmdbRepository>();
    final args =
        (ModalRoute.of(context)?.settings.arguments) as SeasonDetailArgs?;
    if (args == null) return const SizedBox.shrink();
    return FutureBuilder<MediaImages>(
      future: repository.fetchTvSeasonImages(args.tvId, args.seasonNumber),
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
        if (!snapshot.hasData || !snapshot.data!.hasAny) {
          return Text(
            AppLocalizations.of(context).t('tv.no_images'),
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }

        final images = snapshot.data!;
        final posters = images.posters.take(10).toList();
        final backdrops = images.backdrops.take(10).toList();

        void openGallery(
          List<ImageModel> items,
          int initialIndex,
          MediaImageType type,
        ) {
          showGeneralDialog<void>(
            context: context,
            barrierDismissible: true,
            barrierLabel:
                MaterialLocalizations.of(context).modalBarrierDismissLabel,
            barrierColor: Colors.black.withOpacity(0.9),
            transitionDuration: const Duration(milliseconds: 220),
            pageBuilder: (context, animation, secondaryAnimation) {
              return FadeTransition(
                opacity: animation,
                child: ImageGallery(
                  images: items,
                  mediaType: type,
                  initialIndex: initialIndex,
                  heroTagBuilder: (index, image) =>
                      'season-${args.seasonNumber}-${type.name}-$index',
                ),
              );
            },
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).t('movie.images'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (posters.isNotEmpty) ...[
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: posters.length,
                    itemBuilder: (context, index) {
                      final img = posters[index];
                      final heroTag =
                          'season-${args.seasonNumber}-poster-$index';
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => openGallery(
                            posters,
                            index,
                            MediaImageType.poster,
                          ),
                          child: Hero(
                            tag: heroTag,
                            child: MediaImage(
                              path: img.filePath,
                              type: MediaImageType.poster,
                              size: MediaImageSize.w342,
                              width: 140,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (backdrops.isNotEmpty)
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: backdrops.length,
                    itemBuilder: (context, index) {
                      final img = backdrops[index];
                      final heroTag =
                          'season-${args.seasonNumber}-backdrop-$index';
                      return Container(
                        width: 240,
                        margin: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => openGallery(
                            backdrops,
                            index,
                            MediaImageType.backdrop,
                          ),
                          child: Hero(
                            tag: heroTag,
                            child: MediaImage(
                              path: img.filePath,
                              type: MediaImageType.backdrop,
                              size: MediaImageSize.w780,
                              width: 240,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final Episode episode;
  final int seasonNumber;

  const _EpisodeTile({required this.episode, required this.seasonNumber});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: episode.stillPath != null
          ? ClipRRect(
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
          : const SizedBox(width: 120, height: 68),
      title: Text(
        'E${episode.episodeNumber}: ${episode.name}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: episode.overview != null && episode.overview!.isNotEmpty
          ? Text(
              episode.overview!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EpisodeDetailScreen(
              episode: episode,
              tvId: provider.tvId,
            ),
          ),
        );
      },
    );
  }
}
