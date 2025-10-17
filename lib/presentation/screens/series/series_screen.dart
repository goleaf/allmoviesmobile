import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/movie.dart';
import '../../../providers/series_provider.dart';
import '../../screens/movie_detail/movie_detail_screen.dart';
import '../../widgets/app_drawer.dart';
import '../../../data/services/local_storage_service.dart';
import '../series/series_filters_screen.dart';
import '../../widgets/virtualized_list_view.dart';

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
  final Map<SeriesSection, ScrollController> _scrollControllers = {};
  final Map<SeriesSection, VoidCallback> _scrollListeners = {};
  final Map<SeriesSection, Timer?> _scrollDebouncers = {};
  late final List<SeriesSection> _sections;

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
      final offset = _storageService.getSeriesScrollOffset(section.name);
      final controller = ScrollController(
        initialScrollOffset: offset ?? 0.0,
      );
      void listener() {
        _scrollDebouncers[section]?.cancel();
        _scrollDebouncers[section] = Timer(const Duration(milliseconds: 400), () {
          unawaited(
            _storageService.setSeriesScrollOffset(
              section.name,
              controller.offset,
            ),
          );
        });
      }

      controller.addListener(listener);
      _scrollControllers[section] = controller;
      _scrollListeners[section] = listener;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeriesProvider>().refresh();
    });
  }

  Future<void> _refreshSection(
    BuildContext context,
    SeriesSection section,
  ) {
    return context.read<SeriesProvider>().refreshSection(section);
  }

  Future<void> _refreshAll(BuildContext context) {
    return context.read<SeriesProvider>().refresh(force: true);
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
            tooltip: 'Filter by Network',
            icon: const Icon(Icons.hub_outlined),
            onPressed: _openNetworkFilter,
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
              onRefreshAll: _refreshAll,
              controller: _scrollControllers[section],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final section in _sections) {
      _scrollDebouncers[section]?.cancel();
      final controller = _scrollControllers[section];
      final listener = _scrollListeners[section];
      if (controller != null && listener != null) {
        controller.removeListener(listener);
        unawaited(
          _storageService.setSeriesScrollOffset(
            section.name,
            controller.offset,
          ),
        );
        controller.dispose();
      }
    }
    super.dispose();
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
    Navigator.of(context)
        .pushNamed(
      SeriesFiltersScreen.routeName,
      arguments: SeriesFiltersScreenArguments(
        initialFilters: context.read<SeriesProvider>().activeFilters,
        initialPresetName: context.read<SeriesProvider>().activePresetName,
      ),
    )
        .then((
      result,
    ) async {
      if (!mounted) return;
      if (result is SeriesFilterResult) {
        await context.read<SeriesProvider>().applyTvFilters(
              result.filters,
              presetName: result.presetName,
            );
        if (!mounted) return;
        _tabController.animateTo(
          SeriesSection.values.indexOf(SeriesSection.popular),
        );
      }

      if (!mounted) return;
      DefaultTabController.of(context)
          ?.animateTo(SeriesSection.values.indexOf(SeriesSection.popular));
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
        final screenState = context.findAncestorStateOfType<_SeriesScreenState>();
        if (screenState != null) {
          screenState._tabController.animateTo(
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
  const _SeriesSectionView({
    required this.section,
    required this.onRefreshAll,
    this.controller,
  });

  final SeriesSection section;
  final Future<void> Function(BuildContext context) onRefreshAll;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Consumer<SeriesProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(section);
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
            if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => onRefreshAll(context),
                child: _SeriesList(
                  series: state.items,
                  controller: controller,
                  emptyMessage: l.t('search.no_results'),
                ),
              ),
            ),
            if (state.errorMessage != null && state.items.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    this.controller,
  });

  final List<Movie> series;
  final String emptyMessage;
  final ScrollController? controller;

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

    return VirtualizedSeparatedListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: series.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final show = series[index];
        return _SeriesCard(show: show);
      },
      cacheExtent: 720,
      addAutomaticKeepAlives: true,
    );
  }
}

/// Pagination footer that exposes sequential controls plus a jump-to-page sheet.
class _PaginationControls extends StatelessWidget {
  const _PaginationControls({required this.section, required this.state});

  final SeriesSection section;
  final SeriesSectionState state;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SeriesProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final textTheme = Theme.of(context).textTheme;

    Future<void> handleAction(Future<void> Function() action) async {
      final previousPage = provider.sectionState(section).currentPage;
      await action();
      final nextState = provider.sectionState(section);
      if (nextState.errorMessage != null &&
          nextState.currentPage == previousPage) {
        messenger.showSnackBar(
          SnackBar(content: Text(nextState.errorMessage!)),
        );
      }
    }

    Future<void> showJumpSheet() async {
      if (state.totalPages <= 0) {
        return;
      }
      final totalPages = state.totalPages;
      final controller =
          TextEditingController(text: state.currentPage.toString());
      final selected = await showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) {
          var tempPage = state.currentPage;
          return StatefulBuilder(
            builder: (sheetContext, setModalState) {
              void updateTempPage(int value) {
                final clamped = value.clamp(1, totalPages);
                if (tempPage != clamped) {
                  tempPage = clamped;
                  controller.text = '$clamped';
                  controller.selection = TextSelection.collapsed(
                    offset: controller.text.length,
                  );
                  setModalState(() {});
                }
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.jumpToPage,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppStrings.page,
                        helperText:
                            '${AppStrings.page} 1 ${AppStrings.of} $totalPages',
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value.trim());
                        if (parsed != null) {
                          final clamped = parsed.clamp(1, totalPages);
                          setModalState(() {
                            tempPage = clamped;
                          });
                          if (clamped != parsed) {
                            controller.text = '$clamped';
                            controller.selection = TextSelection.collapsed(
                              offset: controller.text.length,
                            );
                          }
                        }
                      },
                    ),
                    if (totalPages > 1) ...[
                      const SizedBox(height: 12),
                      Slider(
                        min: 1,
                        max: totalPages.toDouble(),
                        divisions: math.min(totalPages - 1, 200).toInt(),
                        value: tempPage.toDouble(),
                        label: tempPage.toString(),
                        onChanged: (value) => updateTempPage(value.round()),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text(AppStrings.cancel),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () =>
                              Navigator.of(sheetContext).pop(tempPage),
                          icon: const Icon(Icons.check),
                          label: const Text(AppStrings.go),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

      if (selected != null) {
        if (selected < 1 || selected > totalPages) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                '${AppStrings.page} must be between 1 and $totalPages.',
              ),
            ),
          );
          return;
        }
        await handleAction(() => provider.jumpToPage(section, selected));
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous page',
            onPressed: provider.canGoPrev(section) && !state.isLoading
                ? () async {
                    await handleAction(
                      () => provider.loadPreviousPage(section),
                    );
                  }
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
                      : () async {
                          await showJumpSheet();
                        },
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
                ? () async {
                    await handleAction(
                      () => provider.loadNextPage(section),
                    );
                  }
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
