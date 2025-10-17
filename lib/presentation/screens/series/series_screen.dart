import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../providers/series_provider.dart';
import '../../screens/movie_detail/movie_detail_screen.dart';
import '../../widgets/app_drawer.dart';
import '../series/series_filters_screen.dart';

/// Screen that exposes curated TV series lists backed by several TMDB V3
/// endpoints such as `/3/tv/popular`, `/3/tv/top_rated`, `/3/tv/airing_today`,
/// `/3/tv/on_the_air`, and `/3/trending/tv/{time_window}`. The UI provides a
/// jump-to-page affordance to quickly navigate through paginated results.
class SeriesScreen extends StatefulWidget {
  static const routeName = '/series';

  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen>
    with SingleTickerProviderStateMixin {
  late final LocalStorageService _storageService;
  late final TabController _tabController;
  late final List<SeriesSection> _sections;
  final Map<SeriesSection, ScrollController> _scrollControllers = {};
  final Map<SeriesSection, Timer?> _persistTimers = {};

  @override
  void initState() {
    super.initState();
    _storageService = context.read<LocalStorageService>();
    _sections = SeriesSection.values;
    final initialIndex = _storageService
        .getSeriesTabIndex()
        .clamp(0, _sections.length - 1);
    _tabController = TabController(
      length: _sections.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }
      unawaited(_storageService.setSeriesTabIndex(_tabController.index));
    });

    for (final section in _sections) {
      final storedOffset =
          _storageService.getSeriesScrollOffset(section.name) ?? 0.0;
      final controller = ScrollController(initialScrollOffset: storedOffset);
      controller.addListener(() {
        _persistTimers[section]?.cancel();
        _persistTimers[section] = Timer(const Duration(milliseconds: 350), () {
          unawaited(
            _storageService.setSeriesScrollOffset(
              section.name,
              controller.offset,
            ),
          );
        });
      });
      _scrollControllers[section] = controller;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeriesProvider>().refresh();
    });
  }

  /// Forces every section to reload its data from the TMDB endpoints to keep
  /// pagination and filter results fresh for the user.
  Future<void> _refreshAll(BuildContext context) {
    return context.read<SeriesProvider>().refresh(force: true);
  }

  /// Opens the advanced TV discover filter sheet to let users build queries for
  /// `/3/discover/tv` before bringing them back to the Popular tab.
  Future<void> _openFilters() async {
    final provider = context.read<SeriesProvider>();
    final result = await Navigator.of(context).pushNamed(
      SeriesFiltersScreen.routeName,
      arguments: SeriesFiltersScreenArguments(
        initialFilters: provider.activeFilters,
        initialPresetName: provider.activePresetName,
      ),
    );

    if (!mounted) {
      return;
    }

    if (result is SeriesFilterResult) {
      await provider.applyTvFilters(
        result.filters,
        presetName: result.presetName,
      );
      if (!mounted) return;
      _tabController.animateTo(
        SeriesSection.values.indexOf(SeriesSection.popular),
      );
    }
  }

  @override
  void dispose() {
    for (final timer in _persistTimers.values) {
      timer?.cancel();
    }
    for (final entry in _scrollControllers.entries) {
      unawaited(
        _storageService.setSeriesScrollOffset(
          entry.key.name,
          entry.value.offset,
        ),
      );
      entry.value.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('tv.series')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            for (final section in _sections)
              Tab(text: _labelForSection(section, l)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.t('discover.filters'),
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilters,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          for (final section in _sections)
            _SeriesSectionView(
              section: section,
              controller: _scrollControllers[section]!,
              onRefreshAll: _refreshAll,
            ),
        ],
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
        return l.t('tv.airing_today');
      case SeriesSection.onTheAir:
        return l.t('tv.on_the_air');
    }
  }
}

class _SeriesSectionView extends StatelessWidget {
  const _SeriesSectionView({
    required this.section,
    required this.controller,
    required this.onRefreshAll,
  });

  final SeriesSection section;
  final ScrollController controller;
  final Future<void> Function(BuildContext context) onRefreshAll;

  Future<void> _onRefreshSection(BuildContext context) {
    return context.read<SeriesProvider>().refreshSection(section);
  }

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
            onRetry: () => _onRefreshSection(context),
          );
        }

        return Column(
          children: [
            if (state.isLoading)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => onRefreshAll(context),
                child: _SeriesList(
                  controller: controller,
                  series: state.items,
                  emptyMessage: AppStrings.noResultsFound,
                ),
              ),
            ),
            if (state.errorMessage != null && state.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ),
              ),
            if (state.totalPages > 1)
              _PaginationControls(
                section: section,
                state: state,
              ),
          ],
        );
      },
    );
  }
}

class _SeriesList extends StatelessWidget {
  const _SeriesList({
    required this.series,
    required this.emptyMessage,
    required this.controller,
  });

  final List<Movie> series;
  final String emptyMessage;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return ListView(
        controller: controller,
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
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
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

class _PaginationControls extends StatelessWidget {
  const _PaginationControls({required this.section, required this.state});

  final SeriesSection section;
  final SeriesSectionState state;

  /// Executes pagination actions (previous/next/jump) and displays any
  /// resulting errors via a snackbar.
  Future<void> _handleNavigation(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final provider = context.read<SeriesProvider>();
    final previousPage = provider.sectionState(section).currentPage;
    await action();
    final nextState = provider.sectionState(section);
    if (nextState.errorMessage != null && nextState.currentPage == previousPage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nextState.errorMessage!)),
      );
    }
  }

  Future<void> _showJumpDialog(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController(text: state.currentPage.toString());
    final l = AppLocalizations.of(context);

    final selectedPage = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.jumpToPage),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppStrings.page,
              helperText:
                  '${AppStrings.enterPageNumber} (1-${state.totalPages})',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l.t('common.cancel')),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                if (parsed == null) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(AppStrings.enterPageNumber)),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(parsed);
              },
              child: Text(AppStrings.go),
            ),
          ],
        );
      },
    );

    if (selectedPage == null) {
      return;
    }

    if (selectedPage < 1 || selectedPage > state.totalPages) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.page} 1-${state.totalPages}',
          ),
        ),
      );
      return;
    }

    await _handleNavigation(
      context,
      () => context.read<SeriesProvider>().loadSectionPage(
            section,
            selectedPage,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SeriesProvider>();
    final canGoBack = provider.canGoPrev(section) && !state.isLoading;
    final canGoForward = provider.canGoNext(section) && !state.isLoading;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous page',
            icon: const Icon(Icons.chevron_left),
            onPressed: canGoBack
                ? () => _handleNavigation(
                      context,
                      () => provider.loadPreviousPage(section),
                    )
                : null,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppStrings.page} ${state.currentPage} ${AppStrings.of} ${state.totalPages}',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => _showJumpDialog(context),
                  icon: const Icon(Icons.input),
                  label: const Text(AppStrings.jump),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Next page',
            icon: const Icon(Icons.chevron_right),
            onPressed: canGoForward
                ? () => _handleNavigation(
                      context,
                      () => provider.loadNextPage(section),
                    )
                : null,
          ),
        ],
      ),
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
                    CircleAvatar(radius: 20, backgroundColor: cardColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBox(
                            width: double.infinity,
                            height: 16,
                            color: cardColor,
                          ),
                          const SizedBox(height: 8),
                          _SkeletonBox(
                            width: 140,
                            height: 12,
                            color: cardColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _SkeletonBox(
                        width: 28,
                        height: 12,
                        color: chipColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SkeletonBox(
                  width: double.infinity,
                  height: 12,
                  color: cardColor,
                ),
                const SizedBox(height: 6),
                _SkeletonBox(
                  width: double.infinity,
                  height: 12,
                  color: cardColor,
                ),
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
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
  });

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
            MaterialPageRoute(
              builder: (_) => MovieDetailScreen(movie: show),
            ),
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
    final l = AppLocalizations.of(context);
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
            label: Text(l.t('common.retry')),
          ),
        ),
      ],
    );
  }
}
