import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/navigation/deep_link_parser.dart';
import '../../../data/models/episode_model.dart';
import '../../../data/models/image_model.dart';
import '../../../data/models/media_images.dart';
import '../../../data/models/season_model.dart';
import '../../../data/models/video_model.dart';
import '../../../data/tmdb_repository.dart';
import '../../../presentation/widgets/error_widget.dart';
import '../../../presentation/widgets/loading_indicator.dart';
import '../../navigation/season_detail_args.dart';
import '../../widgets/fullscreen_modal_scaffold.dart';
import '../../widgets/image_gallery.dart';
import '../../widgets/media_image.dart';
import '../../widgets/share/deep_link_share_sheet.dart';
import '../episode_detail/episode_detail_screen.dart';
import '../../../providers/season_detail_provider.dart';

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

    final title = season.name.isNotEmpty
        ? season.name
        : '${loc.t('tv.season')} ${season.seasonNumber}';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => provider.load(forceRefresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _SeasonAppBar(
              season: season,
              tvId: provider.tvId,
              title: title,
            ),
            SliverToBoxAdapter(
              child: _SeasonMetadata(season: season),
            ),
            if ((season.overview ?? '').trim().isNotEmpty)
              SliverToBoxAdapter(
                child: _SeasonOverview(overview: season.overview!),
              ),
            if (season.episodes.isNotEmpty)
              _SeasonEpisodesSection(
                episodes: season.episodes,
                seasonNumber: season.seasonNumber,
                tvId: provider.tvId,
              ),
            if (season.cast.isNotEmpty)
              SliverToBoxAdapter(
                child: _SeasonCastSection(cast: season.cast),
              ),
            if (season.crew.isNotEmpty)
              SliverToBoxAdapter(
                child: _SeasonCrewSection(crew: season.crew),
              ),
            if (season.videos.isNotEmpty)
              SliverToBoxAdapter(
                child: _SeasonVideosSection(videos: season.videos),
              ),
            SliverToBoxAdapter(
              child: _SeasonImagesSection(
                tvId: provider.tvId,
                seasonNumber: season.seasonNumber,
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}

class _SeasonAppBar extends StatelessWidget {
  const _SeasonAppBar({
    required this.season,
    required this.tvId,
    required this.title,
  });

  final Season season;
  final int tvId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final backdropUrl = season.backdropUrl ?? season.posterUrl;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 260,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: loc.movie['share'] ?? loc.t('movie.share'),
          onPressed: () {
            final httpLink = DeepLinkBuilder.season(tvId, season.seasonNumber);
            showDeepLinkShareSheet(
              context,
              title: title,
              httpLink: httpLink,
              customSchemeLink: DeepLinkBuilder.asCustomScheme(httpLink),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        background: backdropUrl == null
            ? Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                alignment: Alignment.center,
                child: Icon(
                  Icons.tv,
                  size: 96,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  MediaImage(
                    path: backdropUrl,
                    type: MediaImageType.backdrop,
                    size: MediaImageSize.w780,
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SeasonMetadata extends StatelessWidget {
  const _SeasonMetadata({required this.season});

  final Season season;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final chips = <Widget>[];

    if ((season.airDate ?? '').isNotEmpty) {
      chips.add(_MetadataChip(
        icon: Icons.event,
        label: season.airDate!,
      ));
    }
    if (season.episodeCount != null) {
      chips.add(_MetadataChip(
        icon: Icons.confirmation_number,
        label: '${season.episodeCount} ${loc.tv['episodes'] ?? 'episodes'}',
      ));
    }

    final runtimes = season.episodes
        .where((episode) => episode.runtime != null && episode.runtime! > 0)
        .map((episode) => episode.runtime!)
        .toList(growable: false);
    if (runtimes.isNotEmpty) {
      final average = (runtimes.reduce((a, b) => a + b) / runtimes.length).round();
      chips.add(_MetadataChip(
        icon: Icons.schedule,
        label: '$average min ${loc.movie['runtime'] ?? 'avg.'}',
      ));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            season.name,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips,
          ),
        ],
      ),
    );
  }
}

class _SeasonOverview extends StatelessWidget {
  const _SeasonOverview({required this.overview});

  final String overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.t('tv.overview'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                overview,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lists episode cards using the data returned alongside
/// `GET /3/tv/{id}/season/{season_number}?append_to_response=credits,videos`.
class _SeasonEpisodesSection extends StatelessWidget {
  const _SeasonEpisodesSection({
    required this.episodes,
    required this.seasonNumber,
    required this.tvId,
  });

  final List<Episode> episodes;
  final int seasonNumber;
  final int tvId;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  loc.t('tv.episodes'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              );
            }
            final episode = episodes[index - 1];
            return _EpisodeTile(
              episode: episode,
              seasonNumber: seasonNumber,
              tvId: tvId,
              isLast: index == episodes.length,
            );
          },
          childCount: episodes.length + 1,
        ),
      ),
    );
  }
}

class _SeasonCastSection extends StatelessWidget {
  const _SeasonCastSection({required this.cast});

  final List<Cast> cast;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.movie['cast'] ?? 'Cast',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final member = cast[index];
                return SizedBox(
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: MediaImage(
                          path: member.profilePath,
                          type: MediaImageType.profile,
                          size: MediaImageSize.w185,
                          width: 140,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        member.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if ((member.character ?? '').isNotEmpty)
                        Text(
                          member.character!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Theme.of(context).hintColor),
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
}

class _SeasonCrewSection extends StatelessWidget {
  const _SeasonCrewSection({required this.crew});

  final List<Crew> crew;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final topCrew = crew.take(12).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.movie['crew'] ?? 'Crew',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topCrew
                .map(
                  (member) => Chip(
                    label: Text(
                      member.job == null
                          ? member.name
                          : '${member.name} • ${member.job}',
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

/// Displays video thumbnails sourced from TMDB's appended `videos` payload.
class _SeasonVideosSection extends StatelessWidget {
  const _SeasonVideosSection({required this.videos});

  final List<Video> videos;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final youtubeVideos = videos
        .where((video) =>
            video.site?.toLowerCase() == 'youtube' &&
            (video.type == 'Trailer' || video.type == 'Teaser'))
        .toList(growable: false);

    if (youtubeVideos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.movie['videos'] ?? 'Videos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: youtubeVideos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final video = youtubeVideos[index];
                final thumb = 'https://img.youtube.com/vi/${video.key}/mqdefault.jpg';
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        thumb,
                        width: 280,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      right: 16,
                      child: Text(
                        video.name ?? 'YouTube',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.play_arrow, color: Colors.white, size: 32),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Lazy loads gallery images via `GET /3/tv/{id}/season/{season_number}/images`.
class _SeasonImagesSection extends StatelessWidget {
  const _SeasonImagesSection({
    required this.tvId,
    required this.seasonNumber,
  });

  final int tvId;
  final int seasonNumber;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<TmdbRepository>();
    final loc = AppLocalizations.of(context);

    return FutureBuilder<MediaImages>(
      future: repository.fetchTvSeasonImages(tvId, seasonNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.hasAny) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              loc.t('tv.no_images'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        final images = snapshot.data!;
        final posters = images.posters.take(10).toList(growable: false);
        final backdrops = images.backdrops.take(10).toList(growable: false);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.movie['images'] ?? 'Images',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              if (posters.isNotEmpty)
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: posters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final image = posters[index];
                      return _SeasonImageThumbnail(
                        image: image,
                        heroTag: 'season-$seasonNumber-poster-$index',
                        mediaType: MediaImageType.poster,
                        onTap: () => _openGallery(
                          context,
                          posters,
                          index,
                          MediaImageType.poster,
                          seasonNumber,
                        ),
                      );
                    },
                  ),
                ),
              if (backdrops.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: backdrops.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final image = backdrops[index];
                      return _SeasonImageThumbnail(
                        image: image,
                        heroTag: 'season-$seasonNumber-backdrop-$index',
                        mediaType: MediaImageType.backdrop,
                        onTap: () => _openGallery(
                          context,
                          backdrops,
                          index,
                          MediaImageType.backdrop,
                          seasonNumber,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openGallery(
    BuildContext context,
    List<ImageModel> images,
    int initialIndex,
    MediaImageType mediaType,
    int seasonNumber,
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
            mediaType: mediaType,
            initialIndex: initialIndex,
            heroTagBuilder: (index, image) =>
                'season-$seasonNumber-${mediaType.name}-$index',
          ),
        );
      },
    );
  }
}

class _SeasonImageThumbnail extends StatelessWidget {
  const _SeasonImageThumbnail({
    required this.image,
    required this.heroTag,
    required this.mediaType,
    required this.onTap,
  });

  final ImageModel image;
  final String heroTag;
  final MediaImageType mediaType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = mediaType == MediaImageType.poster
        ? MediaImageSize.w342
        : MediaImageSize.w780;

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: MediaImage(
            path: image.filePath,
            type: mediaType,
            size: size,
            width: mediaType == MediaImageType.poster ? 150 : 240,
            height: mediaType == MediaImageType.poster ? 220 : 160,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    required this.episode,
    required this.seasonNumber,
    required this.tvId,
    required this.isLast,
  });

  final Episode episode;
  final int seasonNumber;
  final int tvId;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final airDate = episode.airDate?.isNotEmpty == true ? episode.airDate : null;
    final runtime =
        episode.runtime != null && episode.runtime! > 0 ? '${episode.runtime} min' : null;
    final rating =
        episode.voteAverage != null && episode.voteAverage! > 0 ? episode.voteAverage!.toStringAsFixed(1) : null;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: episode.stillPath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: MediaImage(
                    path: episode.stillPath,
                    type: MediaImageType.still,
                    size: MediaImageSize.w300,
                    width: 140,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 140,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.tv, color: theme.colorScheme.onSurfaceVariant),
                ),
          title: Text(
            'E${episode.episodeNumber}: ${episode.name}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (airDate != null || runtime != null)
                Text(
                  [airDate, runtime].where((value) => value != null).join(' • '),
                  style: theme.textTheme.bodySmall,
                ),
              if (rating != null)
                Text(
                  '${AppLocalizations.of(context).movie['rating'] ?? 'Rating'} $rating',
                  style: theme.textTheme.bodySmall,
                ),
              if ((episode.overview ?? '').isNotEmpty)
                Text(
                  episode.overview!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EpisodeDetailScreen(
                  episode: episode,
                  tvId: tvId,
                ),
              ),
            );
          },
        ),
        if (!isLast) const Divider(height: 0),
      ],
    );
  }
}
