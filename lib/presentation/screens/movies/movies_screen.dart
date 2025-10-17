import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../providers/movies_provider.dart';
import '../../../data/models/discover_filters_model.dart';
import '../../screens/movie_detail/movie_detail_screen.dart';
import '../movies/movies_filters_screen.dart';
import '../../widgets/app_drawer.dart';

class MoviesScreen extends StatefulWidget {
  static const routeName = '/movies';

  const MoviesScreen({
    super.key,
    this.initialSection = MovieSection.trending,
  });

  final MovieSection initialSection;

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  late final TextEditingController _searchController;
  List<Movie> _searchResults = const [];
  bool _isSearching = false;
  String? _searchError;
  late int _initialTabIndex;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _initialTabIndex = MovieSection.values.indexOf(widget.initialSection);
    if (_initialTabIndex < 0) {
      _initialTabIndex = 0;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoviesProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String query) async {
    final provider = context.read<MoviesProvider>();
    final normalized = query.trim();

    if (normalized.isEmpty) {
      setState(() {
        _searchResults = const [];
        _searchError = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await provider.search(normalized);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _searchError = null;
          _isSearching = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _searchResults = const [];
          _searchError = '$error';
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _refreshAll(BuildContext context) {
    return context.read<MoviesProvider>().refresh(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final sections = MovieSection.values;
    final hasQuery = _searchController.text.trim().isNotEmpty;

    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: sections.length,
      initialIndex:
          _initialTabIndex.clamp(0, sections.length - 1),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.t('movie.movies')),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final section in sections)
                Tab(text: _labelForSection(section, l)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: l.t('discover.filters'),
              icon: const Icon(Icons.filter_list),
              onPressed: _openFilters,
            ),
            PopupMenuButton<String>(
              tooltip: 'Trending',
              onSelected: (value) {
                context.read<MoviesProvider>().setTrendingWindow(value);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'day', child: Text('Trending: Day')),
                PopupMenuItem(value: 'week', child: Text('Trending: Week')),
              ],
              icon: const Icon(Icons.schedule),
            ),
            Builder(
              builder: (ctx) {
                return OutlinedButton(
                  child: const Text('Jump'),
                  onPressed: () async {
                    final tabController = DefaultTabController.of(ctx);
                    final currentIndex = tabController?.index ?? 0;
                    final sections = MovieSection.values;
                    final currentSection = sections[currentIndex];
                    final provider = ctx.read<MoviesProvider>();
                    final state = provider.sectionState(currentSection);
                    final currentPage = state.currentPage == 0 ? 1 : state.currentPage;
                    final totalPages = state.totalPages == 0 ? 1 : state.totalPages;
                    final controller = TextEditingController(text: '$currentPage');
                    final target = await showDialog<int>(
                      context: ctx,
                      builder: (dctx) => AlertDialog(
                        title: const Text('Jump to page'),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Enter page number'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dctx),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              final value = int.tryParse(controller.text.trim());
                              if (value != null && value >= 1 && value <= totalPages) {
                                Navigator.pop(dctx, value);
                              } else {
                                Navigator.pop(dctx);
                              }
                            },
                            child: const Text('Go'),
                          ),
                        ],
                      ),
                    );
                    if (target != null) {
                      await provider.jumpToPage(currentSection, target);
                    }
                  },
                );
              },
            ),
            Opacity(opacity: 0, child: Text('Page')),
          ],
        ),
        drawer: const AppDrawer(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l.t('search.search_movies'),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  isDense: true,
                ),
                onChanged: _handleSearch,
              ),
            ),
            if (_isSearching) const LinearProgressIndicator(minHeight: 2),
            if (_searchError != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _searchError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            if (hasQuery)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _handleSearch(_searchController.text),
                  child: _MoviesList(
                    movies: _searchResults,
                    emptyMessage: l.t('search.no_results'),
                  ),
                ),
              )
            else
              Expanded(
                child: TabBarView(
                  children: [
                    for (final section in sections)
                      _MoviesSectionView(
                        section: section,
                        onRefreshAll: _refreshAll,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _labelForSection(MovieSection section, AppLocalizations l) {
    switch (section) {
      case MovieSection.trending:
        return l.t('home.trending');
      case MovieSection.nowPlaying:
        return l.t('home.new_releases');
      case MovieSection.popular:
        return l.t('home.popular');
      case MovieSection.topRated:
        return l.t('home.top_rated');
      case MovieSection.upcoming:
        return l.t('discover.year');
      case MovieSection.discover:
        return l.t('discover.title');
    }
  }
}

extension on _MoviesScreenState {
  void _openFilters() {
    final current = context.read<MoviesProvider>().discoverFilters;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => MoviesFiltersScreen(initial: current),
            fullscreenDialog: true,
          ),
        )
        .then((result) async {
          if (!mounted) return;
          if (result is DiscoverFilters) {
            await context.read<MoviesProvider>().applyFilters(result);
            if (!mounted) return;
            final tabCtrl = DefaultTabController.maybeOf(context);
            if (tabCtrl != null) {
              final length = tabCtrl.length;
              if (length > 0) {
                final idx = MovieSection.values.indexOf(MovieSection.discover);
                if (idx >= 0 && idx < length) {
                  tabCtrl.animateTo(idx);
                }
              }
            }
          }
        });
  }
}

class _MoviesSectionView extends StatelessWidget {
  const _MoviesSectionView({required this.section, required this.onRefreshAll});

  final MovieSection section;
  final Future<void> Function(BuildContext context) onRefreshAll;

  @override
  Widget build(BuildContext context) {
    return Consumer<MoviesProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(section);
        // Always render pager controls; show loader within content area instead of returning early

        if (state.errorMessage != null && state.items.isEmpty) {
          return _ErrorView(
            message: state.errorMessage!,
            onRetry: () => onRefreshAll(context),
          );
        }

        return Column(
          children: [
            if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => onRefreshAll(context),
                child: _MoviesList(
                  movies: state.items,
                  emptyMessage: AppLocalizations.of(context).t('search.no_results'),
                ),
              ),
            ),
            _PagerControls(
              section: section,
              current: state.currentPage == 0 ? 1 : state.currentPage,
              total: state.totalPages == 0 ? 1 : state.totalPages,
            ),
          ],
        );
      },
    );
  }
}

class _MoviesList extends StatelessWidget {
  const _MoviesList({required this.movies, required this.emptyMessage});

  final List<Movie> movies;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.movie_filter_outlined,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: movies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _MovieCard(movie: movie);
      },
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
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
                      Icons.movie_creation_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _buildSubtitle(context, movie),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (movie.voteAverage != null)
                    Chip(
                      label: Text(movie.formattedRating),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                ],
              ),
              if ((movie.overview ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  movie.overview!,
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

  String _buildSubtitle(BuildContext context, Movie movie) {
    final buffer = <String>[];
    if (movie.releaseYear != null && movie.releaseYear!.isNotEmpty) {
      buffer.add(movie.releaseYear!);
    }
    if (movie.genresText.isNotEmpty) {
      buffer.add(movie.genresText);
    }
    if (movie.formattedPopularity.isNotEmpty) {
      buffer.add(
        '${AppLocalizations.of(context).t('person.popularity')} ${movie.formattedPopularity}',
      );
    }
    return buffer.join(' • ');
  }
}

class _PagerControls extends StatelessWidget {
  const _PagerControls({
    required this.section,
    required this.current,
    required this.total,
  });

  final MovieSection section;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MoviesProvider>();
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Text('Page $current of $total'),
            const Spacer(),
            IconButton(
              tooltip: '${AppLocalizations.of(context).t('common.page')} ${current - 1}',
              onPressed: current > 1
                  ? () => provider.loadPage(section, current - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: '${AppLocalizations.of(context).t('common.page')} ${current + 1}',
              onPressed: current < total
                  ? () => provider.loadPage(section, current + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.keyboard),
              label: const Text('Jump'),
              onPressed: () async {
                final controller = TextEditingController(text: '$current');
                final target = await showDialog<int>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Jump to page'),
                    content: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Enter page number'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          final value = int.tryParse(controller.text.trim());
                          final maxPage = total == 0 ? 1 : total;
                          if (value != null && value >= 1 && value <= maxPage) {
                            Navigator.pop(ctx, value);
                          } else {
                            Navigator.pop(ctx);
                          }
                        },
                        child: const Text('Go'),
                      ),
                    ],
                  ),
                );
                if (target != null) {
                  await provider.jumpToPage(section, target);
                }
              },
            ),
          ],
              ),
      ),
    );
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
