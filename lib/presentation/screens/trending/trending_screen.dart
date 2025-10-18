import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/search_result_model.dart';
import '../../../providers/trending_titles_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/media_image.dart';
import '../../../core/utils/media_image_helper.dart';
import '../movie_detail/movie_detail_screen.dart';
import '../person_detail/person_detail_screen.dart';
import '../tv_detail/tv_detail_screen.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  static const routeName = '/trending';

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen>
    with SingleTickerProviderStateMixin {
  static const List<TrendingMediaType> _tabOrder = <TrendingMediaType>[
    TrendingMediaType.movie,
    TrendingMediaType.tv,
    TrendingMediaType.person,
    TrendingMediaType.all,
  ];

  late final TabController _tabController;
  TrendingWindow _window = TrendingWindow.day;

  TrendingMediaType get _selectedMediaType => _tabOrder[_tabController.index];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabOrder.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }
      _ensureCurrentData(loadBothWindows: true);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureCurrentData(loadBothWindows: true);
    });
  }

  void _ensureCurrentData({bool loadBothWindows = false}) {
    final provider = context.read<TrendingTitlesProvider>();
    final mediaType = _selectedMediaType;
    unawaited(
      provider.ensureLoaded(mediaType: mediaType, window: _window),
    );
    if (loadBothWindows) {
      final alternate = provider.alternateWindow(_window);
      unawaited(
        provider.ensureLoaded(mediaType: mediaType, window: alternate),
      );
    }
  }

  void _handleWindowChanged(TrendingWindow window) {
    if (_window == window) {
      return;
    }
    setState(() {
      _window = window;
    });
    _ensureCurrentData(loadBothWindows: true);
  }

  Future<void> _handleRefresh() async {
    final provider = context.read<TrendingTitlesProvider>();
    final mediaType = _selectedMediaType;
    final otherWindow = provider.alternateWindow(_window);
    await Future.wait<void>([
      provider.load(
        mediaType: mediaType,
        window: _window,
        forceRefresh: true,
      ),
      provider.load(
        mediaType: mediaType,
        window: otherWindow,
        forceRefresh: true,
      ),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final navigationLabels = loc.navigation;
    final trendingLabel = loc.home['trending'] ?? 'Trending';

    return Scaffold(
      appBar: AppBar(
        title: Text(trendingLabel),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  Tab(text: navigationLabels['movies'] ?? 'Movies'),
                  Tab(text: navigationLabels['series'] ?? 'TV Shows'),
                  Tab(text: navigationLabels['people'] ?? 'People'),
                  Tab(text: loc.common['all'] ?? 'All'),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TrendingWindowToggle(
                  window: _window,
                  onChanged: _handleWindowChanged,
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Consumer<TrendingTitlesProvider>(
        builder: (context, provider, _) {
          final mediaType = _selectedMediaType;
          final state = provider.stateFor(mediaType, _window);
          final otherWindow = provider.alternateWindow(_window);
          final otherLoaded = provider.hasLoaded(mediaType, otherWindow);

          if (state.isLoading && !state.hasLoaded) {
            return const _TrendingLoadingView();
          }

          if (state.errorMessage != null && state.items.isEmpty) {
            return _TrendingErrorView(
              message: state.errorMessage!,
              onRetry: () => provider.load(
                mediaType: mediaType,
                window: _window,
                forceRefresh: true,
              ),
            );
          }

          if (state.items.isEmpty) {
            return _TrendingEmptyView(onRefresh: _handleRefresh);
          }

          final showInlineError = state.errorMessage != null;
          final itemCount = state.items.length + (showInlineError ? 1 : 0);

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: itemCount,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (showInlineError && index == 0) {
                  return _TrendingErrorBanner(
                    message: state.errorMessage!,
                    onRetry: () => provider.load(
                      mediaType: mediaType,
                      window: _window,
                      forceRefresh: true,
                    ),
                  );
                }

                final itemIndex = showInlineError ? index - 1 : index;
                final item = state.items[itemIndex];
                final rank = itemIndex + 1;
                final delta = provider.rankDelta(
                  mediaType: mediaType,
                  window: _window,
                  item: item,
                );
                final isNewEntry = otherLoaded &&
                    !provider.containsItem(
                      mediaType: mediaType,
                      window: otherWindow,
                      item: item,
                    );

                return _TrendingListTile(
                  item: item,
                  rank: rank,
                  rankDelta: delta,
                  isNewEntry: isNewEntry,
                  otherWindowLoaded: otherLoaded,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TrendingWindowToggle extends StatelessWidget {
  const _TrendingWindowToggle({
    required this.window,
    required this.onChanged,
  });

  final TrendingWindow window;
  final ValueChanged<TrendingWindow> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDay = window == TrendingWindow.day;

    return ToggleButtons(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      constraints: const BoxConstraints(minHeight: 36, minWidth: 96),
      isSelected: [isDay, !isDay],
      onPressed: (index) {
        onChanged(index == 0 ? TrendingWindow.day : TrendingWindow.week);
      },
      selectedColor: theme.colorScheme.onPrimary,
      fillColor: theme.colorScheme.primary,
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wb_sunny_outlined, size: 18),
              SizedBox(width: 8),
              Text('Today'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_view_week, size: 18),
              SizedBox(width: 8),
              Text('This Week'),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrendingLoadingView extends StatelessWidget {
  const _TrendingLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _TrendingPlaceholderTile(),
    );
  }
}

class _TrendingPlaceholderTile extends StatelessWidget {
  const _TrendingPlaceholderTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ShimmerLoading(
              width: 60,
              height: 90,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading(
                    width: double.infinity,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  SizedBox(height: 8),
                  ShimmerLoading(
                    width: 160,
                    height: 12,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  SizedBox(height: 12),
                  ShimmerLoading(
                    width: double.infinity,
                    height: 48,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingErrorView extends StatelessWidget {
  const _TrendingErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
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

class _TrendingEmptyView extends StatelessWidget {
  const _TrendingEmptyView({
    required this.onRefresh,
  });

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(48),
        children: [
          Icon(Icons.trending_up_outlined,
              size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'No trending results yet',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for fresh highlights.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TrendingErrorBanner extends StatelessWidget {
  const _TrendingErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: ListTile(
        leading: Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
        title: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
        trailing: TextButton(
          onPressed: onRetry,
          child: Text(
            'Retry',
            style: TextStyle(color: theme.colorScheme.onErrorContainer),
          ),
        ),
      ),
    );
  }
}

class _TrendingListTile extends StatelessWidget {
  const _TrendingListTile({
    required this.item,
    required this.rank,
    required this.rankDelta,
    required this.isNewEntry,
    required this.otherWindowLoaded,
  });

  final SearchResult item;
  final int rank;
  final int? rankDelta;
  final bool isNewEntry;
  final bool otherWindowLoaded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (item.title ?? item.name ?? '').trim();
    final overview = (item.overview ?? '').trim();
    final imagePath = item.posterPath?.isNotEmpty == true
        ? item.posterPath
        : (item.profilePath?.isNotEmpty == true ? item.profilePath : null);
    final imageType = item.mediaType == MediaType.person
        ? MediaImageType.profile
        : MediaImageType.poster;
    final metaParts = <String>[];

    metaParts.add(_mediaTypeLabel(context, item.mediaType));
    final releaseYear = _extractYear(
      item.mediaType == MediaType.tv ? item.firstAirDate : item.releaseDate,
    );
    if (releaseYear != null) {
      metaParts.add(releaseYear);
    }
    if (item.voteAverage != null && item.voteAverage! > 0) {
      metaParts.add('${item.voteAverage!.toStringAsFixed(1)} ★');
    }
    if (item.popularity != null) {
      metaParts.add('Popularity ${item.popularity!.round()}');
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetails(context, item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RankBadge(rank: rank),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 108,
                  child: MediaImage(
                    path: imagePath,
                    type: imageType,
                    size: MediaImageSize.w185,
                    previewSize: MediaImageSize.w92,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? 'Untitled' : title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (metaParts.isNotEmpty)
                      Text(
                        metaParts.join(' • '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (overview.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        overview,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _TrendDeltaIndicator(
                delta: rankDelta,
                isNewEntry: isNewEntry,
                otherWindowLoaded: otherWindowLoaded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _mediaTypeLabel(BuildContext context, MediaType type) {
    switch (type) {
      case MediaType.movie:
        return 'Movie';
      case MediaType.tv:
        return 'TV';
      case MediaType.person:
        return 'Person';
    }
  }

  String? _extractYear(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return raw.split('-').first;
  }

  void _openDetails(BuildContext context, SearchResult item) {
    switch (item.mediaType) {
      case MediaType.movie:
        Navigator.pushNamed(
          context,
          MovieDetailScreen.routeName,
          arguments: item.id,
        );
        break;
      case MediaType.tv:
        Navigator.pushNamed(
          context,
          TVDetailScreen.routeName,
          arguments: item.id,
        );
        break;
      case MediaType.person:
        Navigator.pushNamed(
          context,
          PersonDetailScreen.routeName,
          arguments: item.id,
        );
        break;
    }
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool highlight = rank <= 3;
    final Color backgroundColor = switch (rank) {
      1 => theme.colorScheme.primary,
      2 => theme.colorScheme.secondary,
      3 => theme.colorScheme.tertiary,
      _ => theme.colorScheme.surfaceVariant,
    };
    final Color foreground = highlight
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      width: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        '#$rank',
        style: theme.textTheme.titleSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TrendDeltaIndicator extends StatelessWidget {
  const _TrendDeltaIndicator({
    required this.delta,
    required this.isNewEntry,
    required this.otherWindowLoaded,
  });

  final int? delta;
  final bool isNewEntry;
  final bool otherWindowLoaded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!otherWindowLoaded) {
      return const SizedBox(
        width: 56,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (isNewEntry) {
      return _buildChip(
        context,
        icon: Icons.arrow_upward_rounded,
        label: 'NEW',
        color: theme.colorScheme.primary,
      );
    }

    if (delta == null) {
      return const SizedBox(width: 56);
    }

    if (delta! > 0) {
      return _buildChip(
        context,
        icon: Icons.arrow_upward_rounded,
        label: '+${delta!}',
        color: Colors.green,
      );
    }

    if (delta! < 0) {
      return _buildChip(
        context,
        icon: Icons.arrow_downward_rounded,
        label: '${delta!}',
        color: theme.colorScheme.error,
      );
    }

    return _buildChip(
      context,
      icon: Icons.horizontal_rule,
      label: '0',
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
