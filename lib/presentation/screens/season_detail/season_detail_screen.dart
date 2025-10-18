import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/navigation/deep_link_parser.dart';
import '../../../data/models/episode_model.dart';
import '../../../data/models/image_model.dart';
import '../../../data/models/season_model.dart';
import '../../../data/models/video_model.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/season_detail_provider.dart';
import '../../navigation/episode_detail_args.dart';
import '../../navigation/season_detail_args.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/fullscreen_modal_scaffold.dart';
import '../../widgets/image_gallery.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/media_image.dart';
import '../../widgets/rating_display.dart';
import '../../widgets/share/deep_link_share_sheet.dart';
import '../episode_detail/episode_detail_screen.dart';
import '../person_detail/person_detail_screen.dart';
import '../video_player/video_player_screen.dart';

class SeasonDetailScreen extends StatelessWidget {
  static const routeName = '/season';

  const SeasonDetailScreen({super.key, required this.args});

  final SeasonDetailArgs args;

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

    if (provider.isPrimingSeason) {
      return FullscreenModalScaffold(
        title: Text(loc.t('tv.season')),
        body: const Center(child: LoadingIndicator()),
      );
    }

    if (provider.showSeasonError) {
      return FullscreenModalScaffold(
        title: Text(loc.t('tv.season')),
        body: Center(
          child: ErrorDisplay(
            message: provider.seasonError ?? loc.t('errors.generic'),
            onRetry: provider.retrySeason,
          ),
        ),
      );
    }

    final season = provider.season;
    if (season == null) {
      return FullscreenModalScaffold(
        title: Text(loc.t('tv.season')),
        body: const Center(child: Text('No details available')),
      );
    }

    return FullscreenModalScaffold(
      includeDefaultSliverAppBar: false,
      sliverScrollWrapper: (scrollView) => RefreshIndicator(
        onRefresh: () => context.read<SeasonDetailProvider>().refresh(),
        child: scrollView,
      ),
      slivers: [
        _SeasonArtworkAppBar(season: season),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: _SeasonDetailBody(season: season, provider: provider),
          ),
        ),
      ],
    );
  }
}

class _SeasonArtworkAppBar extends StatelessWidget {
  const _SeasonArtworkAppBar({required this.season});

  final Season season;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.read<SeasonDetailProvider>();
    final title = season.name.isNotEmpty
        ? season.name
        : '${loc.t('tv.season')} ${season.seasonNumber}';
    final backgroundPath =
        (season.backdropPath?.isNotEmpty ?? false) ? season.backdropPath : season.posterPath;
    final backgroundType =
        (season.backdropPath?.isNotEmpty ?? false) ? MediaImageType.backdrop : MediaImageType.poster;

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      leading: const CloseButton(),
      actions: [
        IconButton(
          tooltip: loc.movie['share'] ?? loc.t('movie.share'),
          icon: const Icon(Icons.share),
          onPressed: () {
            final httpLink = DeepLinkBuilder.season(provider.tvId, season.seasonNumber);
            final customLink = DeepLinkBuilder.asCustomScheme(httpLink);
            showDeepLinkShareSheet(
              context,
              title: title,
              httpLink: httpLink,
              customSchemeLink: customLink,
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: backgroundPath != null && backgroundPath.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  MediaImage(
                    path: backgroundPath,
                    type: backgroundType,
                    size: backgroundType == MediaImageType.backdrop
                        ? MediaImageSize.w1280
                        : MediaImageSize.w780,
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
              )
            : Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Icon(
                  Icons.image_outlined,
                  size: 72,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}

class _SeasonDetailBody extends StatelessWidget {
  const _SeasonDetailBody({required this.season, required this.provider});

  final Season season;
  final SeasonDetailProvider provider;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final children = <Widget>[
      _SeasonLoadingBanner(isLoading: provider.isSeasonRefreshing),
      _SeasonHeader(season: season),
    ];

    if (provider.seasonError != null && provider.hasLoadedSeason) {
      children.addAll([
        const SizedBox(height: 12),
        Text(
          provider.seasonError!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ]);
    }

    void addSection(Widget? widget) {
      if (widget == null) return;
      children.add(const SizedBox(height: 24));
      children.add(widget);
    }

    addSection(_buildMetadata(context, loc, season));
    addSection(_buildOverview(context, loc, season));
    addSection(_buildEpisodes(context, loc, season, provider.tvId));
    addSection(_buildCast(context, loc, season.cast));
    addSection(_buildCrew(context, loc, season.crew));
    addSection(_buildVideos(context, loc, season));
    addSection(_buildImages(context, loc, provider));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget? _buildMetadata(
    BuildContext context,
    AppLocalizations loc,
    Season season,
  ) {
    final chips = <Widget>[];
    final airDate = _formatAirDate(season.airDate);
    if (airDate != null) {
      chips.add(
        _SeasonMetadataChip(
          icon: Icons.event,
          label: '${loc.t('tv.first_air_date')}: $airDate',
        ),
      );
    }

    if (season.episodeCount != null && season.episodeCount! > 0) {
      final episodesLabel =
          '${season.episodeCount} ${loc.t('tv.episodes')}';
      chips.add(
        _SeasonMetadataChip(
          icon: Icons.tv,
          label: episodesLabel,
        ),
      );
    }

    if (chips.isEmpty) {
      return null;
    }

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget? _buildOverview(
    BuildContext context,
    AppLocalizations loc,
    Season season,
  ) {
    final overview = season.overview?.trim();
    if (overview == null || overview.isEmpty) {
      return null;
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('tv.overview'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          overview,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget? _buildEpisodes(
    BuildContext context,
    AppLocalizations loc,
    Season season,
    int tvId,
  ) {
    if (season.episodes.isEmpty) {
      return null;
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('tv.episodes'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: season.episodes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final episode = season.episodes[index];
            return _SeasonEpisodeCard(episode: episode, tvId: tvId);
          },
        ),
      ],
    );
  }

  Widget? _buildCast(
    BuildContext context,
    AppLocalizations loc,
    List<Cast> cast,
  ) {
    if (cast.isEmpty) {
      return null;
    }

    final theme = Theme.of(context);
    final visibleCast = cast.take(12).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.movie['cast'] ?? loc.t('movie.cast'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visibleCast.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _SeasonPersonCard(cast: visibleCast[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildCrew(
    BuildContext context,
    AppLocalizations loc,
    List<Crew> crew,
  ) {
    if (crew.isEmpty) {
      return null;
    }

    final theme = Theme.of(context);
    final display = crew.take(18).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.movie['crew'] ?? loc.t('movie.crew'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: display
              .map(
                (member) => ActionChip(
                  label: Text('${member.name} • ${member.job}'),
                  onPressed: () => Navigator.of(context).pushNamed(
                    PersonDetailScreen.routeName,
                    arguments: member.id,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget? _buildVideos(
    BuildContext context,
    AppLocalizations loc,
    Season season,
  ) {
    if (season.videos.isEmpty) {
      return null;
    }

    final filtered = season.videos
        .where((video) => video.key.isNotEmpty && video.site.isNotEmpty)
        .toList();
    if (filtered.isEmpty) {
      return null;
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.movie['videos'] ?? loc.t('movie.videos'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _SeasonVideoCard(
                video: filtered[index],
                allVideos: filtered,
                title: season.name.isNotEmpty
                    ? season.name
                    : '${loc.t('tv.season')} ${season.seasonNumber}',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildImages(
    BuildContext context,
    AppLocalizations loc,
    SeasonDetailProvider provider,
  ) {
    final theme = Theme.of(context);

    if (provider.showImagesError) {
      return ErrorDisplay(
        message: provider.imagesError ?? loc.t('errors.generic'),
        onRetry: provider.retryImages,
      );
    }

    if (!provider.hasAnyImages) {
      if (provider.isPrimingImages) {
        return const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return Text(
        loc.t('tv.no_images'),
        style: theme.textTheme.bodyMedium,
      );
    }

    final posters = provider.posters.take(12).toList();
    final backdrops = provider.backdrops.take(12).toList();

    void openGallery(List<ImageModel> items, int index, MediaImageType type) {
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0.9),
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: ImageGallery(
              images: items,
              mediaType: type,
              initialIndex: index,
              heroTagBuilder: (itemIndex, image) =>
                  'season-${provider.seasonNumber}-${type.name}-$itemIndex',
            ),
          );
        },
      );
    }

    final widgets = <Widget>[
      Text(
        loc.movie['images'] ?? loc.t('movie.images'),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
    ];

    if (provider.isLoadingImages && provider.hasLoadedImages) {
      widgets.add(const LinearProgressIndicator(minHeight: 2));
      widgets.add(const SizedBox(height: 12));
    }

    if (posters.isNotEmpty) {
      widgets.add(
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: posters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final image = posters[index];
              final heroTag = 'season-${provider.seasonNumber}-poster-$index';
              return GestureDetector(
                onTap: () => openGallery(posters, index, MediaImageType.poster),
                child: Hero(
                  tag: heroTag,
                  child: MediaImage(
                    path: image.filePath,
                    type: MediaImageType.poster,
                    size: MediaImageSize.w500,
                    width: 140,
                    height: 210,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }

    if (backdrops.isNotEmpty) {
      widgets.add(
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: backdrops.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final image = backdrops[index];
              final heroTag = 'season-${provider.seasonNumber}-backdrop-$index';
              return GestureDetector(
                onTap: () => openGallery(backdrops, index, MediaImageType.backdrop),
                child: Hero(
                  tag: heroTag,
                  child: MediaImage(
                    path: image.filePath,
                    type: MediaImageType.backdrop,
                    size: MediaImageSize.w1280,
                    width: 260,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  String? _formatAirDate(String? airDate) {
    if (airDate == null || airDate.isEmpty) {
      return null;
    }
    try {
      final parsed = DateTime.parse(airDate);
      return DateFormat.yMMMMd().format(parsed);
    } catch (_) {
      return airDate;
    }
  }
}

class _SeasonLoadingBanner extends StatelessWidget {
  const _SeasonLoadingBanner({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 2),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _SeasonHeader extends StatelessWidget {
  const _SeasonHeader({required this.season});

  final Season season;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    final seasonLabel =
        '${loc.t('tv.season')} ${season.seasonNumber.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          seasonLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          season.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SeasonEpisodeCard extends StatelessWidget {
  const _SeasonEpisodeCard({required this.episode, required this.tvId});

  final Episode episode;
  final int tvId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final episodeLabel =
        'E${episode.episodeNumber.toString().padLeft(2, '0')}';
    final airDate = _formatAirDate(episode.airDate);
    final runtime = episode.runtime != null && episode.runtime! > 0
        ? '${episode.runtime} ${loc.t('movie.minutes')}'
        : null;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushNamed(
          EpisodeDetailScreen.routeName,
          arguments: EpisodeDetailArgs(tvId: tvId, episode: episode),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: episode.stillPath != null && episode.stillPath!.isNotEmpty
                    ? MediaImage(
                        path: episode.stillPath,
                        type: MediaImageType.still,
                        size: MediaImageSize.w300,
                        width: 140,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 140,
                        height: 80,
                        color: theme.colorScheme.surface,
                        child: Icon(
                          Icons.image_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'S${episode.seasonNumber.toString().padLeft(2, '0')} · $episodeLabel',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (episode.voteAverage != null && episode.voteAverage! > 0)
                          RatingDisplay(
                            rating: episode.voteAverage!,
                            voteCount: episode.voteCount,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      episode.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (airDate != null)
                          _SeasonMetadataChip(
                            icon: Icons.event,
                            label: airDate,
                          ),
                        if (runtime != null)
                          _SeasonMetadataChip(
                            icon: Icons.schedule,
                            label: runtime,
                          ),
                      ],
                    ),
                    if (episode.overview != null && episode.overview!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          episode.overview!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _formatAirDate(String? airDate) {
    if (airDate == null || airDate.isEmpty) {
      return null;
    }
    try {
      final parsed = DateTime.parse(airDate);
      return DateFormat.yMMMd().format(parsed);
    } catch (_) {
      return airDate;
    }
  }
}

class _SeasonMetadataChip extends StatelessWidget {
  const _SeasonMetadataChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SeasonPersonCard extends StatelessWidget {
  const _SeasonPersonCard({required this.cast});

  final Cast cast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 140,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).pushNamed(
          PersonDetailScreen.routeName,
          arguments: cast.id,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MediaImage(
                path: cast.profilePath,
                type: MediaImageType.profile,
                size: MediaImageSize.w185,
                width: 140,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cast.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (cast.character != null && cast.character!.isNotEmpty)
              Text(
                cast.character!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SeasonVideoCard extends StatelessWidget {
  const _SeasonVideoCard({
    required this.video,
    required this.allVideos,
    required this.title,
  });

  final Video video;
  final List<Video> allVideos;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final site = video.site.toLowerCase();
    final thumbnailUrl = site == 'youtube'
        ? 'https://img.youtube.com/vi/${video.key}/mqdefault.jpg'
        : null;

    return SizedBox(
      width: 240,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openVideo(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (thumbnailUrl != null)
                    CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      width: 240,
                      height: 135,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      width: 240,
                      height: 135,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.play_circle_outline,
                        size: 48,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              video.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              video.type,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openVideo(BuildContext context) {
    Navigator.of(context).pushNamed(
      VideoPlayerScreen.routeName,
      arguments: VideoPlayerScreenArgs(
        videos: allVideos,
        initialVideoKey: video.key,
        title: title,
        autoPlay: true,
      ),
    );
  }
}
