import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/saved_media_item.dart';
import '../../../providers/collections_provider.dart';
import '../../../providers/movies_provider.dart';
import '../../../providers/people_provider.dart';
import '../../../providers/recommendations_provider.dart';
import '../../../providers/series_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/media_image.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../movie_detail/movie_detail_screen.dart';
import '../person_detail/person_detail_screen.dart';
import '../tv_detail/tv_detail_screen.dart';
import '../movies/movies_screen.dart';
import '../movies/movies_filters_screen.dart';
import '../explorer/api_explorer_screen.dart';
import '../search/search_screen.dart';
import '../collections/collection_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadContent();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _preloadContent() async {
    final moviesProvider = context.read<MoviesProvider>();
    final seriesProvider = context.read<SeriesProvider>();
    final peopleProvider = context.read<PeopleProvider>();
    final collectionsProvider = context.read<CollectionsProvider>();
    final recommendationsProvider = context.read<RecommendationsProvider>();

    await Future.wait<void>([
      moviesProvider.refresh(),
      seriesProvider.refresh(),
      peopleProvider.refresh(),
      collectionsProvider.ensureInitialized(),
    ]);
    if (!recommendationsProvider.hasRecommendations &&
        !recommendationsProvider.isLoading) {
      await recommendationsProvider.fetchPersonalizedRecommendations();
    }
  }

  Future<void> _refreshAll() async {
    final moviesProvider = context.read<MoviesProvider>();
    final seriesProvider = context.read<SeriesProvider>();
    final peopleProvider = context.read<PeopleProvider>();
    final collectionsProvider = context.read<CollectionsProvider>();
    final recommendationsProvider = context.read<RecommendationsProvider>();

    await Future.wait<void>([
      moviesProvider.refresh(force: true),
      seriesProvider.refresh(force: true),
      peopleProvider.refresh(force: true),
      collectionsProvider.refreshAll(),
      recommendationsProvider.fetchPersonalizedRecommendations(),
    ]);
  }

  void _openSearch(BuildContext context, String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }
    Navigator.of(context).pushNamed(
      SearchScreen.routeName,
      arguments: trimmed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.navigation['home'] ?? 'Home',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            _HomeSearchField(
              controller: _searchController,
              hintText: loc.search['search_placeholder'] ??
                  loc.t('search.search_movies'),
              onSubmitted: (value) => _openSearch(context, value),
            ),
          ],
        ),
        toolbarHeight: 112,
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 16),
            _QuickAccessSection(
              title: loc.home['quick_access'] ?? 'Quick Access',
              items: [
                _QuickAccessItem(
                  icon: Icons.explore,
                  label: loc.discover['title'] ?? 'Discover',
                  onTap: () => Navigator.of(context)
                      .pushNamed(ApiExplorerScreen.routeName),
                ),
                _QuickAccessItem(
                  icon: Icons.local_fire_department_outlined,
                  label: loc.home['trending'] ?? 'Trending',
                  onTap: () => Navigator.of(context)
                      .pushNamed(MoviesScreen.routeName),
                ),
                _QuickAccessItem(
                  icon: Icons.category_outlined,
                  label: loc.home['genres'] ?? 'Genres',
                  onTap: () => Navigator.of(context)
                      .pushNamed(MoviesFiltersScreen.routeName),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _MoviesCarousel(
              title:
                  loc.home['of_the_moment_movies'] ?? 'Of the moment movies',
              section: MovieSection.trending,
            ),
            const SizedBox(height: 24),
            _SeriesCarousel(
              title: loc.home['of_the_moment_tv'] ?? 'Of the moment TV',
              section: SeriesSection.trending,
            ),
            const SizedBox(height: 24),
            _PeopleCarousel(
              title: loc.home['popular_people'] ?? 'Popular people',
            ),
            const SizedBox(height: 24),
            _CollectionsCarousel(
              title:
                  loc.home['featured_collections'] ?? 'Featured collections',
            ),
            const SizedBox(height: 24),
            _MoviesCarousel(
              title: loc.home['new_releases'] ?? 'New releases',
              section: MovieSection.nowPlaying,
            ),
            const SizedBox(height: 24),
            _ContinueWatchingSection(
              title: loc.home['continue_watching'] ?? 'Continue watching',
            ),
            const SizedBox(height: 24),
            _RecommendationsSection(
              title:
                  loc.home['personalized_recommendations'] ??
                      'Recommended for you',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HomeSearchField extends StatelessWidget {
  const _HomeSearchField({
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      style: TextStyle(color: colorScheme.onPrimary),
      cursorColor: colorScheme.onPrimary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: colorScheme.onPrimary.withOpacity(0.7),
        ),
        prefixIcon: Icon(Icons.search, color: colorScheme.onPrimary),
        filled: true,
        fillColor: colorScheme.primary.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}

class _QuickAccessSection extends StatelessWidget {
  const _QuickAccessSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_QuickAccessItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          FocusTraversalGroup(
            policy: const WidgetOrderTraversalPolicy(),
            child: Row(
              children: [
                for (final item in items)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _QuickAccessCard(item: item),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessItem {
  const _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({required this.item});

  final _QuickAccessItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: item.label,
      hint: l.t('common.viewDetailsHint'),
      child: Material(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon,
                    size: 28, color: colorScheme.onSecondaryContainer),
                const SizedBox(height: 12),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoviesCarousel extends StatelessWidget {
  const _MoviesCarousel({
    required this.title,
    required this.section,
  });

  final String title;
  final MovieSection section;

  @override
  Widget build(BuildContext context) {
    return Consumer<MoviesProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(section);
        return _HorizontalMediaSection(
          title: title,
          isLoading: state.isLoading,
          errorMessage: state.errorMessage,
          items: state.items
              .take(20)
              .map(
                (movie) => MovieCard(
                  id: movie.id,
                  title: movie.title,
                  posterPath: movie.posterPath,
                  voteAverage: movie.voteAverage,
                  releaseDate: movie.releaseDate,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      MovieDetailScreen.routeName,
                      arguments: movie,
                    );
                  },
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _SeriesCarousel extends StatelessWidget {
  const _SeriesCarousel({
    required this.title,
    required this.section,
  });

  final String title;
  final SeriesSection section;

  @override
  Widget build(BuildContext context) {
    return Consumer<SeriesProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(section);
        return _HorizontalMediaSection(
          title: title,
          isLoading: state.isLoading,
          errorMessage: state.errorMessage,
          items: state.items
              .take(20)
              .map(
                (show) => MovieCard(
                  id: show.id,
                  title: show.title,
                  posterPath: show.posterPath,
                  voteAverage: show.voteAverage,
                  releaseDate: show.releaseDate,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      TVDetailScreen.routeName,
                      arguments: show,
                    );
                  },
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _PeopleCarousel extends StatelessWidget {
  const _PeopleCarousel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Consumer<PeopleProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(PeopleSection.popular);
        return _HorizontalMediaSection(
          title: title,
          isLoading: state.isLoading,
          errorMessage: state.errorMessage,
          items: state.items
              .take(20)
              .map(
                (person) => _PersonCard(
                  name: person.name,
                  subtitle: person.knownForDepartment ?? '',
                  profilePath: person.profilePath,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      PersonDetailScreen.routeName,
                      arguments: person,
                    );
                  },
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _CollectionsCarousel extends StatelessWidget {
  const _CollectionsCarousel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionsProvider>(
      builder: (context, provider, _) {
        final collections = provider.popularCollections;
        final isLoading = provider.isPopularLoading && collections.isEmpty;
        final error = provider.popularError;
        return _HorizontalMediaSection(
          title: title,
          isLoading: isLoading,
          errorMessage: error,
          items: collections
              .map(
                (collection) => _CollectionCard(
                  name: collection.name,
                  posterPath: collection.posterPath,
                  overview: collection.overview,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      CollectionDetailScreen.routeName,
                      arguments: collection.id,
                    );
                  },
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _ContinueWatchingSection extends StatelessWidget {
  const _ContinueWatchingSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, _) {
        final items = provider.watchlistItems
            .where((item) => !item.watched)
            .toList(growable: false)
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        return _HorizontalMediaSection(
          title: title,
          isLoading: false,
          items: items
              .take(15)
              .map((item) => _WatchlistCard(item: item))
              .toList(growable: false),
        );
      },
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationsProvider>(
      builder: (context, provider, _) {
        final movies = provider.recommendedMovies;
        final isLoading = provider.isLoading && movies.isEmpty;
        final error = provider.errorMessage;
        if (!isLoading && movies.isEmpty && error == null) {
          return const SizedBox.shrink();
        }
        return _HorizontalMediaSection(
          title: title,
          isLoading: isLoading,
          errorMessage: error,
          items: movies
              .map(
                (movie) => MovieCard(
                  id: movie.id,
                  title: movie.title,
                  posterPath: movie.posterPath,
                  voteAverage: movie.voteAverage,
                  releaseDate: movie.releaseDate,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      MovieDetailScreen.routeName,
                      arguments: movie,
                    );
                  },
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _HorizontalMediaSection extends StatelessWidget {
  const _HorizontalMediaSection({
    required this.title,
    required this.items,
    this.isLoading = false,
    this.errorMessage,
  });

  final String title;
  final List<Widget> items;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const SizedBox(
            height: 220,
            child: Center(child: LoadingIndicator()),
          )
        else if (errorMessage != null && errorMessage!.isNotEmpty)
          SizedBox(
            height: 220,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ErrorDisplay(
                  message: errorMessage!,
                ),
              ),
            ),
          )
        else if (items.isEmpty)
          const SizedBox(
            height: 220,
            child: Center(child: Text('No items available')),
          )
        else
          SizedBox(
            height: 260,
            child: FocusTraversalGroup(
              policy: const WidgetOrderTraversalPolicy(),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => SizedBox(
                  width: 160,
                  child: items[index],
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: items.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.name,
    required this.subtitle,
    required this.profilePath,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final String? profilePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final semanticsLabel = subtitle.isEmpty ? name : '$name, $subtitle';
    return Semantics(
      button: true,
      label: semanticsLabel,
      hint: l.t('common.viewDetailsHint'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: (profilePath != null && profilePath!.isNotEmpty)
                        ? MediaImage(
                            path: profilePath,
                            type: MediaImageType.profile,
                            size: MediaImageSize.w185,
                            fit: BoxFit.cover,
                            semanticsLabel:
                                '${l.t('common.profileLabelPrefix')} $name',
                          )
                        : ExcludeSemantics(
                            child: Container(
                              color: colorScheme.surfaceVariant,
                              child: Icon(
                                Icons.person,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.name,
    required this.posterPath,
    required this.overview,
    required this.onTap,
  });

  final String name;
  final String? posterPath;
  final String? overview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final description = (overview ?? '').trim();
    final truncatedDescription = description.length > 120
        ? '${description.substring(0, 117)}...'
        : description;
    final semanticsLabel =
        truncatedDescription.isEmpty ? name : '$name. $truncatedDescription';

    return Semantics(
      button: true,
      label: semanticsLabel,
      hint: l.t('common.viewDetailsHint'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: (posterPath != null && posterPath!.isNotEmpty)
                    ? MediaImage(
                        path: posterPath,
                        type: MediaImageType.poster,
                        size: MediaImageSize.w342,
                        fit: BoxFit.cover,
                        semanticsLabel:
                            '${l.t('common.posterLabelPrefix')} $name',
                      )
                    : ExcludeSemantics(
                        child: Container(
                          color: colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.collections_bookmark,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (overview != null && overview!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        overview!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WatchlistCard extends StatelessWidget {
  const _WatchlistCard({required this.item});

  final SavedMediaItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final releaseYear = item.releaseYear;
    final l = AppLocalizations.of(context);
    final typeLabel = item.type == SavedMediaType.tv
        ? (l.navigation['series'] ?? 'Series')
        : (l.navigation['movies'] ?? 'Movies');
    final semanticsParts = <String>[
      item.title,
      typeLabel,
      if (releaseYear != null) releaseYear,
    ];

    return Semantics(
      button: true,
      label: semanticsParts.join(', '),
      hint: l.t('common.viewDetailsHint'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            final route = item.type == SavedMediaType.tv
                ? TVDetailScreen.routeName
                : MovieDetailScreen.routeName;
            Navigator.of(context).pushNamed(route, arguments: item.id);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: (item.posterPath != null && item.posterPath!.isNotEmpty)
                    ? MediaImage(
                        path: item.posterPath,
                        type: MediaImageType.poster,
                        size: MediaImageSize.w342,
                        fit: BoxFit.cover,
                        semanticsLabel:
                            '${l.t('common.posterLabelPrefix')} ${item.title}',
                      )
                    : ExcludeSemantics(
                        child: Container(
                          color: colorScheme.surfaceVariant,
                          child: Icon(
                            item.type == SavedMediaType.tv
                                ? Icons.tv
                                : Icons.movie,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (releaseYear != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        releaseYear,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
