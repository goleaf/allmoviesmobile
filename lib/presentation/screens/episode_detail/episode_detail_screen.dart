import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/episode_model.dart';
import '../../../data/services/api_config.dart';
import '../../widgets/rating_display.dart';
import '../../../core/utils/media_image_helper.dart';
import '../../widgets/media_image.dart';
import '../../widgets/fullscreen_modal_scaffold.dart';

class EpisodeDetailScreen extends StatelessWidget {
  static const routeName = '/episode-detail';

  final Episode episode;

  const EpisodeDetailScreen({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return FullscreenModalScaffold(
      includeDefaultSliverAppBar: false,
      slivers: [
        _buildStillAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildOverview(context, loc),
                const SizedBox(height: 16),
                _buildMetadata(context, loc),
                const SizedBox(height: 16),
                _buildImages(context),
                const SizedBox(height: 16),
                _buildGuestStars(context),
                const SizedBox(height: 16),
                _buildCrew(context),
                const SizedBox(height: 16),
                _buildVideos(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStillAppBar(BuildContext context) {
    final hasStill = episode.stillPath != null && episode.stillPath!.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(episode.name, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                          Colors.black.withOpacity(0.1),
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

  Widget _buildHeader(BuildContext context) {
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

  Widget _buildOverview(BuildContext context, AppLocalizations loc) {
    final overview = episode.overview?.trim();
    if (overview == null || overview.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('movie.overview'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(overview, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildMetadata(BuildContext context, AppLocalizations loc) {
    final items = <Widget>[];

    final airDateText = _formatAirDate(episode.airDate);
    if (airDateText != null) {
      items.add(
        _MetadataChip(
          icon: Icons.event,
          label: '${loc.t('tv.first_air_date')}: $airDateText',
        ),
      );
    }

    if (episode.runtime != null && episode.runtime! > 0) {
      final runtimeText = '${episode.runtime} ${loc.t('movie.minutes')}';
      items.add(
        _MetadataChip(
          icon: Icons.schedule,
          label: '${loc.t('tv.episode_runtime')}: $runtimeText',
        ),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Wrap(spacing: 12, runSpacing: 8, children: items)],
    );
  }

  Widget _buildGuestStars(BuildContext context) {
    if (episode.guestStars.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).t('person.known_for'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: episode.guestStars.length,
            itemBuilder: (context, index) {
              final cast = episode.guestStars[index];
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCrew(BuildContext context) {
    if (episode.crew.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final display = episode.crew.take(12).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crew',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: display
              .map(
                (c) => Chip(
                  label: Text('${c.name}${c.job != null ? ' • ${c.job}' : ''}'),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildVideos(BuildContext context) {
    if (episode.videos.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final trailers = episode.videos
        .where(
          (v) =>
              v.site == 'YouTube' &&
              (v.type == 'Trailer' || v.type == 'Teaser'),
        )
        .toList();
    if (trailers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Videos',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trailers.length,
            itemBuilder: (context, index) {
              final video = trailers[index];
              final thumbnailUrl =
                  'https://img.youtube.com/vi/${video.key}/mqdefault.jpg';
              final videoTitle = (video.name ?? '').trim();
              final semanticLabel =
                  videoTitle.isEmpty ? 'Video thumbnail' : '$videoTitle thumbnail';
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
                      semanticLabel: semanticLabel,
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
    );
  }

  Widget _buildImages(BuildContext context) {
    // Basic gallery using the primary still image when available.
    final still = episode.stillPath;
    if (still == null || still.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Container(
                width: 240,
                margin: const EdgeInsets.only(right: 12),
                child: MediaImage(
                  path: still,
                  type: MediaImageType.still,
                  size: MediaImageSize.w780,
                  width: 240,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ],
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
  final IconData icon;
  final String label;

  const _MetadataChip({required this.icon, required this.label});

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
