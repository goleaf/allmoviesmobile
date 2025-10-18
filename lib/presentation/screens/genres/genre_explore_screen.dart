import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/genre_model.dart';
import '../../../data/models/genre_statistics.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/search_result_model.dart';
import '../../../providers/genre_browse_provider.dart';
import '../../../data/tmdb_repository.dart';
import '../../widgets/media_image.dart';

class GenreExploreArgs {
  const GenreExploreArgs({required this.genre, required this.mediaType});

  final Genre genre;
  final MediaType mediaType;
}

/// Detailed explorer that surfaces statistics and paginated titles for a
/// single TMDB genre via the Discover API family (`GET /3/discover/movie` and
/// `GET /3/discover/tv`).
class GenreExploreScreen extends StatelessWidget {
  const GenreExploreScreen({super.key});

  static const routeName = '/genres/explore';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as GenreExploreArgs?;
    if (args == null) {
      return const Scaffold(
        body: Center(child: Text('Missing genre information.')),
      );
    }

    return ChangeNotifierProvider<GenreBrowseProvider>(
      create: (context) {
        final repository = context.read<TmdbRepository>();
        final provider = GenreBrowseProvider(
          repository: repository,
          genre: args.genre,
          mediaType: args.mediaType,
        );
        provider.loadInitial();
        return provider;
      },
      child: _GenreExploreView(args: args),
    );
  }
}

class _GenreExploreView extends StatelessWidget {
  const _GenreExploreView({required this.args});

  final GenreExploreArgs args;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final strings = localization.genreBrowser;
    final mediaLabel = args.mediaType == MediaType.movie
        ? strings['movies_tab'] ?? localization.navigation['movies'] ?? 'Movies'
        : strings['tv_tab'] ?? localization.navigation['series'] ?? 'TV Shows';

    return Scaffold(
      appBar: AppBar(
        title: Text('${args.genre.name} • $mediaLabel'),
      ),
      body: Consumer<GenreBrowseProvider>(
        builder: (context, provider, _) {
          if (provider.isInitialLoading && provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError && provider.items.isEmpty) {
            return _GenreErrorState(
              message: provider.errorMessage ??
                  localization.errors['generic'] ??
                      'Something went wrong',
              onRetry: provider.loadInitial,
            );
          }

          final stats = provider.statistics;
          final trending = provider.trendingTitles;
          final items = provider.items;
          final headerCount = 1 + (trending.isEmpty ? 0 : 1);
          final totalCount =
              items.length + headerCount + (provider.isLoadingMore ? 1 : 0);

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                final metrics = notification.metrics;
                final shouldLoadMore =
                    metrics.pixels >= metrics.maxScrollExtent - 200 &&
                        provider.hasMore &&
                        !provider.isLoadingMore;
                if (shouldLoadMore) {
                  provider.loadMore();
                }
                return false;
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: totalCount,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _GenreStatisticsCard(statistics: stats, strings: strings);
                  }

                  if (trending.isNotEmpty && index == 1) {
                    return _TrendingTitlesSection(
                      titles: trending,
                      mediaType: args.mediaType,
                      strings: strings,
                    );
                  }

                  final adjustedIndex = index - headerCount;
                  if (adjustedIndex < items.length) {
                    return _GenreMediaTile(movie: items[adjustedIndex]);
                  }

                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GenreStatisticsCard extends StatelessWidget {
  const _GenreStatisticsCard({required this.statistics, required this.strings});

  final GenreStatistics statistics;
  final Map<String, dynamic> strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium;
    final captionStyle =
        theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings['stats_title'] ?? 'Genre statistics',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _StatisticChip(
                  label: strings['trending_count']?.toString().replaceAll(
                        '{count}',
                        '${statistics.sampleSize}',
                      ) ??
                      '${statistics.sampleSize} titles',
                ),
                _StatisticChip(
                  label:
                      '${strings['stats_rating'] ?? 'Avg rating'}: ${statistics.averageRating.toStringAsFixed(1)}',
                ),
                _StatisticChip(
                  label:
                      '${strings['stats_popularity'] ?? 'Avg popularity'}: ${statistics.averagePopularity.toStringAsFixed(1)}',
                ),
                _StatisticChip(
                  label:
                      '${strings['stats_votes'] ?? 'Avg votes'}: ${statistics.averageVoteCount.toStringAsFixed(0)}',
                ),
                if (statistics.releaseYearRange != null)
                  _StatisticChip(
                    label:
                        '${strings['stats_years'] ?? 'Release span'}: ${statistics.releaseYearRange}',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              strings['stats_top_titles'] ?? 'Top titles',
              style: captionStyle,
            ),
            const SizedBox(height: 8),
            if (statistics.topTitles.isEmpty)
              Text(
                strings['stats_empty'] ?? 'No data available yet.',
                style: bodyStyle,
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final title in statistics.topTitles)
                    Chip(label: Text(title)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatisticChip extends StatelessWidget {
  const _StatisticChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.bar_chart, size: 16),
      label: Text(label),
    );
  }
}

class _TrendingTitlesSection extends StatelessWidget {
  const _TrendingTitlesSection({
    required this.titles,
    required this.mediaType,
    required this.strings,
  });

  final List<Movie> titles;
  final MediaType mediaType;
  final Map<String, dynamic> strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleStyle =
        theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings['trending_title'] ?? 'Trending now',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              mediaType == MediaType.movie
                  ? strings['movies_tab'] ?? 'Movies'
                  : strings['tv_tab'] ?? 'TV Shows',
              style: subtitleStyle,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final movie in titles)
                  Chip(
                    avatar: const Icon(Icons.trending_up, size: 16),
                    label: Text(movie.title),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreMediaTile extends StatelessWidget {
  const _GenreMediaTile({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    final details = <String>[];
    final year = movie.releaseYear;
    if (year != null && year.isNotEmpty) {
      details.add(year);
    }
    if (movie.voteAverage != null && movie.voteAverage! > 0) {
      details.add('${movie.voteAverage!.toStringAsFixed(1)} ★');
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: _GenrePoster(path: movie.posterPath),
        title: Text(movie.title, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details.isNotEmpty)
              Text(details.join(' • '), style: subtitleStyle),
            if (movie.genresText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  movie.genresText,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        isThreeLine: movie.genresText.isNotEmpty,
      ),
    );
  }
}

class _GenrePoster extends StatelessWidget {
  const _GenrePoster({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        width: 60,
        height: 90,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.movie,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: MediaImage(
        path: path,
        type: MediaImageType.poster,
        size: MediaImageSize.w154,
        width: 60,
        height: 90,
        fit: BoxFit.cover,
        placeholder: Container(
          width: 60,
          height: 90,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: Container(
          width: 60,
          height: 90,
          color: Theme.of(context).colorScheme.surfaceVariant,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _GenreErrorState extends StatelessWidget {
  const _GenreErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
