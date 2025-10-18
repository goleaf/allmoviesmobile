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
import '../../widgets/virtualized_list_view.dart';
import 'series_filters_screen.dart';

/// Primary entry point for browsing television series collections.
///
/// The screen mirrors the movies experience with tabbed sections, pagination
/// controls, and persistent filters stored locally for fast restoration.
class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  static const routeName = '/series';

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final LocalStorageService _storageService;
  late final List<SeriesSection> _sections;

  /// Individual scroll controllers per section so we can persist offsets.
  final Map<SeriesSection, ScrollController> _scrollControllers = {};

  /// Debounce timers that persist scroll offsets without spamming disk writes.
  final Map<SeriesSection, Timer?> _scrollPersistenceTimers = {};

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
      final initialOffset =
          _storageService.getSeriesScrollOffset(section.name) ?? 0.0;
      final controller = ScrollController(initialScrollOffset: initialOffset);
      controller.addListener(() {
        final timer = _scrollPersistenceTimers[section];
        timer?.cancel();
        _scrollPersistenceTimers[section] =
            Timer(const Duration(milliseconds: 350), () {
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

  @override
  void dispose() {
    for (final timer in _scrollPersistenceTimers.values) {
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

  /// Launch the advanced filters screen and apply the resulting selection.
  Future<void> _openFilters() async {
    final provider = context.read<SeriesProvider>();
    final result = await Navigator.of(context).pushNamed(
      SeriesFiltersScreen.routeName,
      arguments: SeriesFiltersScreenArguments(
        initialFilters: provider.activeFilters,
        initialPresetName: provider.activePresetName,
      ),
    );

    if (!mounted) return;
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

  /// Clear any active discover/network filters and reload the popular section.
  Future<void> _clearFilters() async {
    await context.read<SeriesProvider>().clearTvFilters();
    if (!mounted) return;
    _tabController.animateTo(
      SeriesSection.values.indexOf(SeriesSection.popular),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<SeriesProvider>();

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
          if (provider.hasActiveFilters)
            IconButton(
              tooltip: l.t('discover.clear_filters'),
              icon: const Icon(Icons.filter_alt_off_outlined),
              onPressed: _clearFilters,
            ),
          IconButton(
            tooltip: l.t('discover.filters'),
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilters,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          if (provider.hasActiveFilters)
            _ActiveFiltersBanner(provider: provider),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (final section in _sections)
                  _SeriesSectionView(
                    section: section,
                    controller: _scrollControllers[section]!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Map each section to the localized label used in the tab bar.
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

/// Highlights the currently applied preset or quick filters so users can see
/// why the popular feed looks the way it does.
class _ActiveFiltersBanner extends StatelessWidget {
  const _ActiveFiltersBanner({required this.provider});

  final SeriesProvider provider;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (provider.activePresetName != null &&
        provider.activePresetName!.isNotEmpty) {
      chips.add(
        InputChip(
          label: Text('Preset: ${provider.activePresetName!}'),
          onDeleted: () {
            unawaited(provider.clearTvFilters());
          },
        ),
      );
    }

    if (provider.activeNetworkId != null) {
      chips.add(
        InputChip(
          label: Text('Network #${provider.activeNetworkId}'),
          onDeleted: () {
            unawaited(provider.clearNetworkFilter());
          },
        ),
      );
    }

    if (chips.isEmpty && provider.activeFilters != null) {
      chips.add(
        InputChip(
          label: Text('${provider.activeFilters!.length} filters active'),
          onDeleted: () {
            unawaited(provider.clearTvFilters());
          },
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(spacing: 8, runSpacing: 8, children: chips),
      ),
    );
  }
}

/// Renders a single section list with pull-to-refresh and pagination controls.
class _SeriesSectionView extends StatelessWidget {
  const _SeriesSectionView({
    required this.section,
    required this.controller,
  });

  final SeriesSection section;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return Consumer<SeriesProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(section);
        final l = AppLocalizations.of(context);

        if (state.isLoading && state.items.isEmpty) {
          return const _SeriesListSkeleton();
        }

        if (state.errorMessage != null && state.items.isEmpty) {
          return _ErrorView(
            message: state.errorMessage!,
            onRetry: () => provider.refreshSection(section),
          );
        }

        return Column(
          children: [
            if (state.isLoading)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.refreshSection(section),
                child: state.items.isEmpty
                    ? _EmptySeriesList(
                        controller: controller,
                        message: l.t('discover.no_results'),
                      )
                    : VirtualizedSeparatedListView(
                        controller: controller,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final show = state.items[index];
                          return _SeriesCard(show: show);
                        },
                        cacheExtent: 720,
                        addAutomaticKeepAlives: true,
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
              _SeriesPaginationControls(section: section, state: state),
          ],
        );
      },
    );
  }
}

/// Lightweight empty-state widget shown when the filters produce no results.
class _EmptySeriesList extends StatelessWidget {
  const _EmptySeriesList({required this.controller, required this.message});

  final ScrollController controller;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 120),
      children: [
        Icon(
          Icons.live_tv_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

/// Pagination controls with previous/next buttons and a jump-to-page dialog.
class _SeriesPaginationControls extends StatelessWidget {
  const _SeriesPaginationControls({
    required this.section,
    required this.state,
  });

  final SeriesSection section;
  final SeriesSectionState state;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SeriesProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);

    Future<void> handleAction(Future<void> Function() action) async {
      final previousPage = provider.sectionState(section).currentPage;
      await action();
      final updated = provider.sectionState(section);
      if (updated.errorMessage != null && updated.currentPage == previousPage) {
        messenger.showSnackBar(
          SnackBar(content: Text(updated.errorMessage!)),
        );
      }
    }

    Future<void> showJumpDialog() async {
      final controller =
          TextEditingController(text: state.currentPage.toString());
      final selected = await showDialog<int>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(AppStrings.jumpToPage),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: AppStrings.page,
                helperText: AppStrings.enterPageNumber,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l.t('common.cancel')),
              ),
              FilledButton(
                onPressed: () {
                  final value = int.tryParse(controller.text.trim());
                  if (value == null) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.enterPageNumber),
                      ),
                    );
                    return;
                  }
                  Navigator.of(dialogContext).pop(value);
                },
                child: const Text(AppStrings.go),
              ),
            ],
          );
        },
      );

      if (selected == null) {
        return;
      }

      if (selected < 1 || selected > state.totalPages) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.page} must be between 1 and ${state.totalPages}.',
            ),
          ),
        );
        return;
      }

      await handleAction(
        () => provider.loadSectionPage(section, selected),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous page',
            onPressed: provider.canGoPrev(section) && !state.isLoading
                ? () => handleAction(() => provider.loadPreviousPage(section))
                : null,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppStrings.page} ${state.currentPage} ${AppStrings.of} ${state.totalPages}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: state.isLoading ? null : showJumpDialog,
                  icon: const Icon(Icons.input),
                  label: const Text(AppStrings.jump),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next page',
            onPressed: provider.canGoNext(section) && !state.isLoading
                ? () => handleAction(() => provider.loadNextPage(section))
                : null,
          ),
        ],
      ),
    );
  }
}

/// Skeleton shimmer used while the first page of a section is loading.
class _SeriesListSkeleton extends StatelessWidget {
  const _SeriesListSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceVariant;
    final accentColor = theme.colorScheme.secondaryContainer;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemBuilder: (_, __) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SkeletonBox(width: 48, height: 48, color: accentColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _SkeletonBox(width: double.infinity, height: 16),
                          SizedBox(height: 8),
                          _SkeletonBox(width: 160, height: 14),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _SkeletonBox(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                const _SkeletonBox(width: double.infinity, height: 14),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: 6,
    );
  }
}

/// Generic rounded rectangle placeholder block.
class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.color,
  });

  final double width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

/// Card representation of a single show with quick metadata and rating.
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(Movie show) {
    final segments = <String>[];
    if (show.releaseYear != null && show.releaseYear!.isNotEmpty) {
      segments.add(show.releaseYear!);
    }
    if (show.genresText.isNotEmpty) {
      segments.add(show.genresText);
    }
    return segments.join(' • ');
  }
}

/// Error presenter used when the initial load fails.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
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
