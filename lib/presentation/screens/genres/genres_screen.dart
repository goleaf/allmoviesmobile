import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/discover_filters_model.dart';
import '../../../data/models/genre_model.dart';
import '../../../providers/genres_provider.dart';
import '../../../providers/movies_provider.dart';
import '../../screens/movies/movies_screen.dart';
import '../../screens/movies/movies_filters_screen.dart';
import '../../screens/series/series_filters_screen.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/empty_state.dart';

class GenresScreen extends StatefulWidget {
  const GenresScreen({super.key});

  static const routeName = '/genres';

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<GenresProvider>();
      provider.fetchMovieGenres();
      provider.fetchTvGenres();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: AppBar(
          title: Text(loc.t('genres.title')),
          bottom: TabBar(
            tabs: [
              Tab(text: loc.t('genres.movies_tab')),
              Tab(text: loc.t('genres.tv_tab')),
            ],
          ),
        ),
        body: Consumer<GenresProvider>(
          builder: (context, provider, _) {
            return TabBarView(
              children: [
                _GenreTab(
                  genres: provider.movieGenres,
                  isLoading: provider.isLoadingMovies,
                  errorMessage: provider.movieError,
                  emptyMessage: loc.t('genres.empty_movies'),
                  emptyTitle: loc.t('genres.movies_tab'),
                  onRefresh: () =>
                      provider.fetchMovieGenres(forceRefresh: true),
                  onDiscover: (genre) => _openMovieDiscover(context, genre),
                  onAdjustFilters: () => _openMovieFilters(context),
                  discoverLabel: loc.t('genres.discover_movies'),
                  filtersLabel: loc.t('genres.adjust_filters'),
                  errorSupportingText: loc.t('genres.error_fallback'),
                ),
                _GenreTab(
                  genres: provider.tvGenres,
                  isLoading: provider.isLoadingTv,
                  errorMessage: provider.tvError,
                  emptyMessage: loc.t('genres.empty_tv'),
                  emptyTitle: loc.t('genres.tv_tab'),
                  onRefresh: () => provider.fetchTvGenres(forceRefresh: true),
                  onDiscover: (genre) => _openSeriesFilters(context, genre),
                  discoverLabel: loc.t('genres.discover_tv'),
                  filtersLabel: loc.t('genres.adjust_filters'),
                  errorSupportingText: loc.t('genres.error_fallback'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openMovieDiscover(BuildContext context, Genre genre) {
    final filters = DiscoverFilters(withGenres: '${genre.id}');
    Navigator.of(context).pushNamed(
      MoviesScreen.routeName,
      arguments: {
        'initialSection': MovieSection.discover,
        'discoverFilters': filters,
      },
    );
  }

  void _openMovieFilters(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const MoviesFiltersScreen(),
      ),
    );
  }

  void _openSeriesFilters(BuildContext context, Genre genre) {
    Navigator.of(context).pushNamed(
      SeriesFiltersScreen.routeName,
      arguments: SeriesFiltersScreenArguments(
        initialFilters: {'with_genres': '${genre.id}'},
      ),
    );
  }
}

class _GenreTab extends StatelessWidget {
  const _GenreTab({
    required this.genres,
    required this.isLoading,
    required this.errorMessage,
    required this.emptyMessage,
    required this.emptyTitle,
    required this.onRefresh,
    required this.onDiscover,
    this.onAdjustFilters,
    required this.discoverLabel,
    required this.filtersLabel,
    required this.errorSupportingText,
  });

  final List<Genre> genres;
  final bool isLoading;
  final String? errorMessage;
  final String emptyMessage;
  final String emptyTitle;
  final Future<void> Function() onRefresh;
  final void Function(Genre) onDiscover;
  final VoidCallback? onAdjustFilters;
  final String discoverLabel;
  final String filtersLabel;
  final String errorSupportingText;

  @override
  Widget build(BuildContext context) {
    if (isLoading && genres.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final children = <Widget>[];

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      children.add(_GenreErrorBanner(
        message: errorMessage!,
        supportingText: errorSupportingText,
        onRetry: onRefresh,
      ));
    }

    if (genres.isEmpty) {
      final loc = AppLocalizations.of(context);
      children.add(
        EmptyState(
          icon: Icons.category_outlined,
          title: emptyTitle,
          message: emptyMessage,
          actionLabel: loc.common['refresh'] ?? 'Refresh',
          onAction: () => onRefresh(),
        ),
      );
    } else {
      for (final genre in genres) {
        children.add(
          _GenreCard(
            genre: genre,
            onDiscover: () => onDiscover(genre),
            onAdjustFilters: onAdjustFilters,
            discoverLabel: discoverLabel,
            filtersLabel: filtersLabel,
          ),
        );
      }
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: children.length,
      ),
    );
  }
}

class _GenreCard extends StatelessWidget {
  const _GenreCard({
    required this.genre,
    required this.onDiscover,
    required this.discoverLabel,
    required this.filtersLabel,
    this.onAdjustFilters,
  });

  final Genre genre;
  final VoidCallback onDiscover;
  final VoidCallback? onAdjustFilters;
  final String discoverLabel;
  final String filtersLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodySmall = theme.textTheme.bodySmall;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              genre.name,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text('TMDB ID: ${genre.id}', style: bodySmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onDiscover,
                  icon: const Icon(Icons.travel_explore_outlined),
                  label: Text(discoverLabel),
                ),
                if (onAdjustFilters != null)
                  OutlinedButton.icon(
                    onPressed: onAdjustFilters,
                    icon: const Icon(Icons.filter_list),
                    label: Text(filtersLabel),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreErrorBanner extends StatelessWidget {
  const _GenreErrorBanner({
    required this.message,
    required this.supportingText,
    required this.onRetry,
  });

  final String message;
  final String supportingText;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            if (supportingText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                supportingText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.onErrorContainer,
                foregroundColor: colorScheme.error,
              ),
              child:
                  Text(AppLocalizations.of(context).common['retry'] ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
