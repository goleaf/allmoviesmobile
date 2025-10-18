import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/navigation/deep_link_handler.dart';
import '../../../core/navigation/deep_link_parser.dart';
import '../../../data/models/episode_model.dart';
import '../../../data/models/image_model.dart';
import '../../../data/models/video_model.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/episode_detail_provider.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/fullscreen_modal_scaffold.dart';
import '../../widgets/image_gallery.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/media_image.dart';
import '../../widgets/rating_display.dart';
import '../../widgets/share/deep_link_share_sheet.dart';
import '../person_detail/person_detail_screen.dart';
import '../video_player/video_player_screen.dart';

class EpisodeDetailScreen extends StatelessWidget {
  static const routeName = '/episode-detail';

  const EpisodeDetailScreen({
    super.key,
    required this.episode,
    required this.tvId,
  });

  final Episode episode;
  final int tvId;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<TmdbRepository>();

    return ChangeNotifierProvider(
      create: (_) => EpisodeDetailProvider(
        repository,
        tvId: tvId,
        seasonNumber: episode.seasonNumber,
        episodeNumber: episode.episodeNumber,
        initialEpisode: episode,
      )..load(),
      child: _EpisodeDetailView(tvId: tvId),
    );
  }
}

class _EpisodeDetailView extends StatelessWidget {
  const _EpisodeDetailView({required this.tvId});

  final int tvId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EpisodeDetailProvider>();
    final loc = AppLocalizations.of(context);
    final episode = provider.episode;

    if (episode == null) {
      if (provider.isPrimingEpisode) {
        return const FullscreenModalScaffold(
          body: Center(child: LoadingIndicator()),
        );
      }

      final message = provider.episodeError ?? loc.t('errors.generic');
      return FullscreenModalScaffold(
        body: ErrorDisplay(
          message: message,
          onRetry: () => provider.retryEpisode(),
        ),
      );
    }

    return FullscreenModalScaffold(
      includeDefaultSliverAppBar: false,
      sliverScrollWrapper: (scrollView) => Builder(
        builder: (context) => RefreshIndicator(
          onRefresh: () => context.read<EpisodeDetailProvider>().refresh(),
          child: scrollView,
        ),
      ),
      slivers: [
        _buildStillAppBar(context, loc, episode),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildBody(context, loc, episode, provider),
          ),
        ),
      ],
    );
  }

  Widget _buildStillAppBar(
    BuildContext context,
    AppLocalizations loc,
    Episode episode,
  ) {
    final hasStill = episode.stillPath != null && episode.stillPath!.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      actions: [
        IconButton(
          tooltip: loc.movie['share'] ?? loc.t('movie.share'),
          icon: const Icon(Icons.share),
          onPressed: () {
            final title = episode.name.isNotEmpty
                ? episode.name
                : '${loc.t('tv.episode')} ${episode.episodeNumber}';
            final httpLink = DeepLinkBuilder.episode(
              tvId,
              episode.seasonNumber,
              episode.episodeNumber,
            );
            final customLink = DeepLinkHandler.buildEpisodeUri(
              tvId,
              episode.seasonNumber,
              episode.episodeNumber,
            );
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
          episode.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: hasStill
            ? Stack(
                fit: StackFit.expand,
                children: [
                  MediaImage(
                    path: episode.stillPath,
                    type: MediaImageType.still,
                    size: MediaImageSize.w780,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: Container(
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
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.image_outlined,
                  size: 64,
                  color: Colors.grey[700],
                ),
              ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations loc,
    Episode episode,
    EpisodeDetailProvider provider,
  ) {
    final theme = Theme.of(context);
    final children = <Widget>[
      _buildLoadingBanner(provider),
    ];

    if (provider.episodeError != null && provider.hasLoadedEpisode) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            provider.episodeError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      );
    }

    children.add(_buildHeader(context, episode));

    void addSection(Widget? widget) {
      if (widget == null) return;
      children.add(const SizedBox(height: 24));
      children.add(widget);
    }

    addSection(_buildMetadata(context, loc, episode));
    addSection(_buildOverview(context, loc, episode));
    addSection(_buildCast(context, loc, episode.cast));
    addSection(
      _buildCast(
        context,
        loc,
        episode.guestStars,
        title: loc.episode['guest_stars'] ?? loc.t('episode.guest_stars'),
      ),
    );
    addSection(_buildCrew(context, loc, episode));
    addSection(_buildVideos(context, loc, episode));
    addSection(_buildImages(context, loc, episode, provider));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildLoadingBanner(EpisodeDetailProvider provider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: provider.isLoadingEpisode && provider.hasLoadedEpisode
          ? const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 2),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildHeader(BuildContext context, Episode episode) {
    final theme = Theme.of(context);
    final seasonEpisodeLabel =
        'S${episode.seasonNumber.toString().padLeft(2, '0')} · '
        'E${episode.episodeNumber.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          seasonEpisodeLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          episode.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (episode.voteAverage != null && episode.voteAverage! > 0)
          RatingDisplay(
            rating: episode.voteAverage!,
            voteCount: episode.voteCount,
            size: 18,
          ),
      ],
    );
  }

  Widget? _buildOverview(
    BuildContext context,
    AppLocalizations loc,
    Episode episode,
  ) {
    final overview = episode.overview?.trim();
    if (overview == null || overview.isEmpty) {
      return null;
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.movie['overview'] ?? loc.t('movie.overview'),
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

  Widget? _buildMetadata(
    BuildContext context,
    AppLocalizations loc,
    Episode episode,
  ) {
    final chips = <Widget>[];
    final airDateText = _formatAirDate(episode.airDate);
    if (airDateText != null) {
      chips.add(
        _MetadataChip(
          icon: Icons.event,
          label: '${loc.t('tv.first_air_date')}: $airDateText',
        ),
      );
    }

    if (episode.runtime != null && episode.runtime! > 0) {
      final runtimeText = '${episode.runtime} ${loc.t('movie.minutes')}';
      chips.add(
        _MetadataChip(
          icon: Icons.schedule,
          label: '${loc.t('tv.episode_runtime')}: $runtimeText',
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

  Widget? _buildCast(
    BuildContext context,
    AppLocalizations loc,
    List<Cast> cast, {
    String? title,
  }) {
    if (cast.isEmpty) {
      return null;
    }

    final theme = Theme.of(context);
    final display = cast.take(12).toList();
    final resolvedTitle = title ??
        loc.episode['cast'] ??
        loc.movie['cast'] ??
        loc.t('movie.cast');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resolvedTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: display.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final member = display[index];
              return _EpisodePersonCard(cast: member);
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildCrew(
    BuildContext context,
    AppLocalizations loc,
    Episode episode,
  ) {
    if (episode.crew.isEmpty) {
      return null;
    }

    final theme = Theme.of(context);
    final display = episode.crew.take(20).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.episode['crew'] ?? loc.t('episode.crew'),
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
                  label: Text(
                    member.job.isEmpty
                        ? member.name
                        : '${member.name} • ${member.job}',
                  ),
                  onPressed: () => _openPerson(context, member.id),
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
    Episode episode,
  ) {
    if (episode.videos.isEmpty) {
      return null;
    }

    final theme = Theme.of(context);
    final videos = episode.videos
        .where((video) =>
            (video.key.isNotEmpty && video.site.isNotEmpty))
        .toList();

    if (videos.isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.episode['videos'] ??
              loc.movie['videos'] ??
              loc.t('movie.videos'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = videos[index];
              return _EpisodeVideoCard(
                video: video,
                allVideos: videos,
                title: episode.name,
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
    Episode episode,
    EpisodeDetailProvider provider,
  ) {
    final stills = provider.stills;
    final hasFallbackStill =
        episode.stillPath != null && episode.stillPath!.isNotEmpty;
    final theme = Theme.of(context);

    if (stills.isEmpty && !hasFallbackStill) {
      if (provider.isLoadingImages) {
        return const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (provider.imagesError != null) {
        return ErrorDisplay(
          message: provider.imagesError!,
          onRetry: provider.retryImages,
        );
      }

      return null;
    }

    final widgets = <Widget>[
      Text(
        loc.episode['images'] ??
            loc.movie['images'] ??
            loc.t('movie.images'),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
    ];

    if (stills.isNotEmpty) {
      widgets.add(
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stills.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final image = stills[index];
              final heroTag = 'episode-${episode.id}-still-$index';
              return GestureDetector(
                onTap: () => _openGallery(context, episode, stills, index),
                child: Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MediaImage(
                      path: image.filePath,
                      type: MediaImageType.still,
                      size: MediaImageSize.w780,
                      width: 240,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (hasFallbackStill) {
      widgets.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: MediaImage(
            path: episode.stillPath,
            type: MediaImageType.still,
            size: MediaImageSize.w780,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (provider.isLoadingImages) {
      widgets.add(const SizedBox(height: 12));
      widgets.add(const LinearProgressIndicator(minHeight: 2));
    } else if (provider.imagesError != null && stills.isNotEmpty) {
      widgets.add(const SizedBox(height: 12));
      widgets.add(
        Text(
          provider.imagesError!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  void _openPerson(BuildContext context, int personId) {
    Navigator.of(context).pushNamed(
      PersonDetailScreen.routeName,
      arguments: personId,
    );
  }

  void _openGallery(
    BuildContext context,
    Episode episode,
    List<ImageModel> images,
    int initialIndex,
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
            mediaType: MediaImageType.still,
            initialIndex: initialIndex,
            heroTagBuilder: (index, image) =>
                'episode-${episode.id}-still-$index',
          ),
        );
      },
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

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _EpisodePersonCard extends StatelessWidget {
  const _EpisodePersonCard({required this.cast});

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

class _EpisodeVideoCard extends StatelessWidget {
  const _EpisodeVideoCard({
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
    final normalizedSite = video.site.toLowerCase();
    final thumbnailUrl = normalizedSite == 'youtube'
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
              maxLines: 1,
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

  void _openVideo(BuildContext context) {
    Navigator.of(context).pushNamed(
      VideoPlayerScreen.routeName,
      arguments: VideoPlayerScreenArgs(
        videos: allVideos,
        initialVideoKey: video.key,
        title: title.isNotEmpty ? title : null,
        autoPlay: true,
      ),
    );
  }
}
