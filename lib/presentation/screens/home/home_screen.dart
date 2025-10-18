import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/saved_media_item.dart';
import '../../../providers/collections_provider.dart';
import '../../../providers/movies_provider.dart';
import '../../../providers/people_provider.dart';
import '../../../providers/recommendations_provider.dart';
import '../../../providers/series_provider.dart';
import '../../../providers/search_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/media_image.dart';
import '../../widgets/movie_card.dart';
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

  /// Preloads the content required for the home screen sections.
  ///
  /// Movies, TV series, and people rely on the following TMDB endpoints via
  /// their respective providers to populate the UI with the latest data:
  /// * GET `/3/trending/movie/{time_window}` ("Of the moment" movies carousel)
  /// * GET `/3/trending/tv/{time_window}` ("Of the moment" TV carousel)
  /// * GET `/3/person/popular` (Popular people carousel)
  /// * GET `/3/collection/{collection_id}` (Featured collections carousel)
  /// * GET `/3/movie/now_playing` (New releases section)
  /// Personalized recommendations are fetched from the local
  /// `RecommendationsProvider`, which wraps TMDB account recommendation APIs
  /// and cached insights when available in offline mode.
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

  /// Forces a refresh of every provider that backs a home section so the user
  /// always sees the freshest JSON payloads from the same TMDB endpoints listed
  /// in [_preloadContent].
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

  /// Navigates to the search screen once the user confirms an inline query.
  ///
  /// The search screen ultimately calls TMDB's multi-search endpoint
  /// `GET /3/search/multi`, so we avoid sending empty queries from here to keep
  /// network requests clean.
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

    final sectionBuilders = <WidgetBuilder>[
      (_) => const SizedBox(height: 16),
      (_) => _QuickAccessSection(
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
      (_) => _TrendingSearchesSection(
            title: loc.search['trending_searches'] ?? 'Trending searches',
          ),
      (_) => const SizedBox(height: 24),
      (_) => _MoviesCarousel(
            title: loc.home['of_the_moment_movies'] ?? 'Of the moment movies',
            section: MovieSection.trending,
          ),
      (_) => const SizedBox(height: 24),
      (_) => _SeriesCarousel(
            title: loc.home['of_the_moment_tv'] ?? 'Of the moment TV',
            section: SeriesSection.trending,
          ),
      (_) => const SizedBox(height: 24),
      (_) => _PeopleCarousel(
            title: loc.home['popular_people'] ?? 'Popular people',
          ),
      (_) => const SizedBox(height: 24),
      (_) => _CollectionsCarousel(
            title: loc.home['featured_collections'] ?? 'Featured collections',
          ),
      (_) => const SizedBox(height: 24),
      (_) => _MoviesCarousel(
            title: loc.home['new_releases'] ?? 'New releases',
            section: MovieSection.nowPlaying,
          ),
      (_) => const SizedBox(height: 24),
      (_) => _ContinueWatchingSection(
            title: loc.home['continue_watching'] ?? 'Continue watching',
          ),
      (_) => const SizedBox(height: 24),
      (_) => _RecommendationsSection(
            title: loc.home['personalized_recommendations'] ??
                'Recommended for you',
          ),
      (_) => const SizedBox(height: 24),
    ];

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
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => sectionBuilders[index](context),
                  childCount: sectionBuilders.length,
                ),
              ),
            ),
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
    final accessibility = AppLocalizations.of(context).accessibility;
    final semanticsLabel =
        accessibility['search_label'] ?? 'Search the catalog';
    final semanticsHint =
        accessibility['search_hint'] ?? 'Search for movies, shows, or people';

    return Semantics(
      label: semanticsLabel,
      hint: semanticsHint,
      textField: true,
      child: TextField(
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
      ),
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
    final accessibility = AppLocalizations.of(context).accessibility;
    final navLabel =
        accessibility['quick_access_navigation'] ?? 'Quick actions';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Semantics(
        container: true,
        label: navLabel,
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
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 720
                    ? 3
                    : constraints.maxWidth > 480
                        ? 2
                        : 1;
                final spacing = 12.0;
                final totalSpacing = spacing * (columns - 1);
                final itemWidth = (constraints.maxWidth - totalSpacing) /
                    columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: items
                      .map(
                        (item) => SizedBox(
                          width: itemWidth,
                          child: _QuickAccessCard(item: item),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ],
        ),
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
    final accessibility = AppLocalizations.of(context).accessibility;
    final hint =
        '${accessibility['open_details'] ?? 'Open details'}: ${item.label}';

    return Semantics(
      button: true,
      label: item.label,
      hint: hint,
      child: Focus(
        child: Tooltip(
          message: item.label,
          child: Material(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(16),
              focusColor: Theme.of(context).focusColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 28,
                      color: colorScheme.onSecondaryContainer,
                    ),
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
        ),
      ),
    );
  }
}

/// Displays the top trending multi-search queries sourced from
/// `GET /3/trending/movie/{time_window}` so the user can jump straight into the
/// universal search experience.
class _TrendingSearchesSection extends StatelessWidget {
  const _TrendingSearchesSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        final queries = provider.trendingSearches.take(8).toList();
        if (queries.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: queries
                    .map(
                      (query) => ActionChip(
                        label: Text(query),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            SearchScreen.routeName,
                            arguments: query,
                          );
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        );
      },
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
    // Each carousel uses cached JSON payloads from the movies provider, which
    // maps to:
    // * GET `/3/trending/movie/{time_window}` for [MovieSection.trending]
    // * GET `/3/movie/now_playing` for [MovieSection.nowPlaying]
    // * GET `/3/movie/popular` for [MovieSection.popular]
    // * GET `/3/movie/top_rated` for [MovieSection.topRated]
    // * GET `/3/movie/upcoming` for [MovieSection.upcoming]
    // * GET `/3/discover/movie` for [MovieSection.discover]
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
                  heroTag: 'movie-poster-${movie.id}',
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
    // Series sections rely on the series provider which fetches JSON payloads
    // from TMDB's TV catalog such as:
    // * GET `/3/trending/tv/{time_window}` for trending entries
    // * GET `/3/tv/on_the_air` and related collections depending on
    //   [SeriesSection]
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
                  heroTag: 'tv-poster-${show.id}',
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
    // Popular people leverage TMDB's `GET /3/person/popular` endpoint to
    // surface the latest trending talent.
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
                  id: person.id,
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
    // Collections are sourced via the collections provider which batches
    // requests to `GET /3/collection/{collection_id}` to keep artwork and
    // descriptions fresh.
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
                  id: collection.id,
                  name: collection.name,
                  posterPath: collection.posterPath,
                  overview: collection.overview,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      CollectionDetailScreen.routeName,
                      arguments: {
                        'id': collection.id,
                        'name': collection.name,
                        'posterPath': collection.posterPath,
                        'backdropPath': collection.backdropPath,
                      },
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
    // Continue watching relies on the locally persisted watchlist cache rather
    // than remote endpoints so the UI remains instant even when offline.
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
    // Personalized recommendations use TMDB's account recommendation APIs
    // (GET `/4/account/{account_id}/movie/recommendations`) when authenticated
    // and gracefully fall back to locally curated mixes.
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
                  heroTag: 'movie-poster-${movie.id}',
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

class _HorizontalMediaSection extends StatefulWidget {
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
  State<_HorizontalMediaSection> createState() => _HorizontalMediaSectionState();
}

class _HorizontalMediaSectionState extends State<_HorizontalMediaSection> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollFocusedIntoView() {
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        focusedContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 220),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accessibility = AppLocalizations.of(context).accessibility;
    final sectionHint = accessibility['section_list_hint'] ??
        'Horizontal list. Use left and right arrows to browse items.';
    final textScale = MediaQuery.textScaleFactorOf(context);
    final baseHeight = widget.items.isEmpty ? 220.0 : 260.0;
    final scaledHeight = math.max(baseHeight, baseHeight + (textScale - 1) * 120);

    return Semantics(
      container: true,
      label: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Semantics(
              header: true,
              child: Text(
                widget.title,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const _HorizontalMediaSkeleton()
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
        ],
      ),
    );
  }
}

/// Skeleton placeholder card used while carousel data loads.
class _ShimmerMediaCard extends StatelessWidget {
  const _ShimmerMediaCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: ShimmerLoading(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLoading(width: 120, height: 12),
                SizedBox(height: 8),
                ShimmerLoading(width: 80, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalMediaSkeleton extends StatelessWidget {
  const _HorizontalMediaSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => const _MediaSkeletonCard(),
      ),
    );
  }
}

class _MediaSkeletonCard extends StatelessWidget {
  const _MediaSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => ShimmerLoading(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLoading(
                    width: 120,
                    height: 12,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  SizedBox(height: 8),
                  ShimmerLoading(
                    width: 80,
                    height: 10,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
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

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.profilePath,
    required this.onTap,
  });

  final int id;
  final String name;
  final String subtitle;
  final String? profilePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'person-profile-$id',
                flightShuttleBuilder: _buildFadeFlight,
                child: ClipOval(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: (profilePath != null && profilePath!.isNotEmpty)
                        ? MediaImage(
                            path: profilePath,
                            type: MediaImageType.profile,
                            size: MediaImageSize.w185,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.person,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildFadeFlight(
  BuildContext context,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  return FadeTransition(
    opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
    child: toHeroContext.widget,
  );
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.id,
    required this.name,
    required this.posterPath,
    required this.overview,
    required this.onTap,
  });

  final int id;
  final String name;
  final String? posterPath;
  final String? overview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'collection-poster-$id',
                flightShuttleBuilder: _buildFadeFlight,
                child: (posterPath != null && posterPath!.isNotEmpty)
                    ? MediaImage(
                        path: posterPath,
                        type: MediaImageType.poster,
                        size: MediaImageSize.w342,
                        fit: BoxFit.cover,
                      )
                    : Container(
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
    final heroTag = item.type == SavedMediaType.tv
        ? 'tv-poster-${item.id}'
        : 'movie-poster-${item.id}';
    return Card(
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
              child: Hero(
                tag: heroTag,
                flightShuttleBuilder: _buildFadeFlight,
                child:
                    (item.posterPath != null && item.posterPath!.isNotEmpty)
                        ? MediaImage(
                            path: item.posterPath,
                            type: MediaImageType.poster,
                            size: MediaImageSize.w342,
                            fit: BoxFit.cover,
                          )
                        : Container(
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
      ),
    );
  }
}
