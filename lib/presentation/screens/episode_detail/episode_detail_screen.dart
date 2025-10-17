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

  const EpisodeDetailScreen({
    super.key,
    required this.episode,
  });

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
    final seasonEpisodeLabel = 'S${episode.seasonNumber.toString().padLeft(2, '0')} · '
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          overview,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: items,
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

  const _MetadataChip({
    required this.icon,
    required this.label,
  });

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
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
