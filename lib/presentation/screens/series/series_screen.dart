import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/movie.dart';
import '../../../providers/series_provider.dart';
import '../../screens/movie_detail/movie_detail_screen.dart';
import '../../widgets/app_drawer.dart';
import '../../../providers/watch_region_provider.dart';
import '../series/series_filters_screen.dart';

class SeriesScreen extends StatefulWidget {
  static const routeName = '/series';

  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeriesProvider>().refresh();
    });
  }

  Future<void> _refreshAll(BuildContext context) {
    return context.read<SeriesProvider>().refresh(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final sections = SeriesSection.values;

    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: sections.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.t('tv.series')),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final section in sections)
                Tab(text: _labelForSection(section, l)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Filter by Network',
              icon: const Icon(Icons.hub_outlined),
              onPressed: _openNetworkFilter,
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: TabBarView(
          children: [
            for (final section in sections)
              _SeriesSectionView(section: section, onRefreshAll: _refreshAll),
          ],
        ),
      ),
    );
  }

  String _labelForSection(SeriesSection section, AppLocalizations l) {
    switch (section) {
      case SeriesSection.trending:
        return l.t('home.trending');
      case SeriesSection.popular:
        return l.t('home.popular');
      case SeriesSection.topRated:
        return l.t('home.top_rated');
      case SeriesSection.airingToday:
        return l.t('tv.title');
      case SeriesSection.onTheAir:
        return l.t('tv.tv_shows');
    }
  }
}

extension on _SeriesScreenState {
  void _openNetworkFilter() {
    Navigator.of(context).pushNamed(SeriesFiltersScreen.routeName).then((
      result,
    ) async {
      if (!mounted) return;
      if (result is Map<String, String>) {
        await context.read<SeriesProvider>().applyTvFilters(result);
        if (!mounted) return;
        DefaultTabController.of(
          context,
        ).animateTo(SeriesSection.values.indexOf(SeriesSection.popular));
      }
    });
  }
}

class _NetworkChip extends StatelessWidget {
  const _NetworkChip({required this.id, required this.name});

  final int id;
  final String name;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        Navigator.pop(context);
        await context.read<SeriesProvider>().applyNetworkFilter(id);
        final controller = DefaultTabController.of(context);
        if (controller != null) {
          controller.animateTo(
            SeriesSection.values.indexOf(SeriesSection.popular),
          );
        }
      },
      icon: const Icon(Icons.tv),
      label: Text(name),
    );
  }
}

class _SeriesSectionView extends StatelessWidget {
  const _SeriesSectionView({required this.section, required this.onRefreshAll});

  final SeriesSection section;
  final Future<void> Function(BuildContext context) onRefreshAll;

  @override
  Widget build(BuildContext context) {
    return Consumer<SeriesProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(section);
        if (state.isLoading && state.items.isEmpty) {
          return const _SeriesListSkeleton();
        }

        if (state.errorMessage != null && state.items.isEmpty) {
          return _ErrorView(
            message: state.errorMessage!,
            onRetry: () => onRefreshAll(context),
          );
        }

        return RefreshIndicator(
          onRefresh: () => onRefreshAll(context),
          child: _SeriesList(series: state.items),
        );
      },
    );
  }
}

class _SeriesList extends StatelessWidget {
  const _SeriesList({required this.series});

  final List<Movie> series;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.live_tv_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              AppLocalizations.of(context).t('search.no_results'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: series.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final show = series[index];
        return _SeriesCard(show: show);
      },
    );
  }
}

class _SeriesListSkeleton extends StatelessWidget {
  const _SeriesListSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surfaceVariant;
    final chipColor = theme.colorScheme.secondaryContainer;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: cardColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBox(width: double.infinity, height: 16, color: cardColor),
                          const SizedBox(height: 8),
                          _SkeletonBox(width: 140, height: 12, color: cardColor),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _SkeletonBox(width: 28, height: 12, color: chipColor.withOpacity(0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SkeletonBox(width: double.infinity, height: 12, color: cardColor),
                const SizedBox(height: 6),
                _SkeletonBox(width: double.infinity, height: 12, color: cardColor),
                const SizedBox(height: 6),
                _SkeletonBox(width: 180, height: 12, color: cardColor),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.width, required this.height, required this.color});

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.show});

  final Movie show;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: show)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.live_tv_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          show.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _buildSubtitle(show),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (show.voteAverage != null)
                    Chip(
                      label: Text(show.formattedRating),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                ],
              ),
              if ((show.overview ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  show.overview!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(Movie show) {
    final buffer = <String>[];
    if (show.releaseYear != null && show.releaseYear!.isNotEmpty) {
      buffer.add(show.releaseYear!);
    }
    if (show.genresText.isNotEmpty) {
      buffer.add(show.genresText);
    }
    return buffer.join(' • ');
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context).t('common.retry')),
          ),
        ),
      ],
    );
  }
}

class _TvFilterState {
  static DateTime? startDate;
  static DateTime? endDate;
  static final Set<int> genres = <int>{};
  static bool includeNullFirstAirDates = false;
  static bool screenedTheatrically = false;
  static String timezone = '';
  static String watchProviders = '';
  static final Set<String> monetization = <String>{'flatrate', 'rent', 'buy'};
}
