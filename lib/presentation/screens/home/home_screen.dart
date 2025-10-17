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

/// HomeScreen is the main landing experience for the application and exposes
/// shortcuts, curated carousels, and personalized recommendations.
///
/// The screen is intentionally stateful so we can pre-load the different
/// providers that back the carousels as soon as the widget is created.
class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Holds the imperative logic for [HomeScreen], including eager pre-loading of
/// remote data and handling refresh/search interactions.
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

  /// Pre-loads every provider required by the home experience so the carousels
  /// have data ready when the user scrolls.
  ///
  /// # TMDB endpoints consumed via providers
  /// - MoviesProvider.refresh ->
  ///   `GET /3/trending/movie/{time_window}` returning JSON `{ "results": [ { "id": 634649, "title": "Spider-Man", "poster_path": "/path.jpg", "vote_average": 7.9, "release_date": "2023-06-02" } ] }`
  /// - SeriesProvider.refresh ->
  ///   `GET /3/trending/tv/{time_window}` returning JSON `{ "results": [ { "id": 12971, "name": "Loki", "poster_path": "/poster.jpg", "vote_average": 8.0, "first_air_date": "2023-10-06" } ] }`
  /// - PeopleProvider.refresh ->
  ///   `GET /3/person/popular` returning JSON `{ "results": [ { "id": 287, "name": "Brad Pitt", "profile_path": "/profile.jpg", "known_for_department": "Acting" } ] }`
  /// - CollectionsProvider.ensureInitialized ->
  ///   `GET /3/collection/{collection_id}` returning JSON `{ "id": 10, "name": "Star Wars Collection", "poster_path": "/poster.jpg", "overview": "Epic space saga" }`
  /// - RecommendationsProvider.fetchPersonalizedRecommendations ->
  ///   internally aggregates `GET /3/movie/{id}/recommendations` JSON payloads
  ///   shaped as `{ "results": [ { "id": 508947, "title": "Turning Red", "poster_path": "/poster.jpg" } ] }`
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

  /// Allows the pull-to-refresh gesture to re-fetch all the sections at once.
  ///
  /// Each provider re-issues the same TMDB REST calls described in
  /// [_preloadContent] to guarantee fresh JSON payloads for the UI widgets.
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

  /// Navigates to the global search screen when the user submits a keyword.
  ///
  /// The search feature eventually calls
  /// `GET /3/search/multi?query=<keyword>` and expects JSON shaped as
  /// `{ "results": [ { "media_type": "movie", "id": 603692, "title": "John Wick", "poster_path": "/poster.jpg" } ] }`.
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
  /// Builds the scrollable home layout.
  ///
  /// The layout stitches together quick access shortcuts, multiple media
  /// carousels, and personalized blocks while keeping a persistent search bar
  /// within the app bar.
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

/// Renders the persistent search text field that sits inside the home app bar.
/// The field simply proxies submissions to the callback injected by the parent.
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
    // Styling is aligned with the current Material color scheme so the field
    // blends with the themed app bar background.
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

/// Displays a single row of quick access cards that deep-link into other parts
/// of the app (API explorer, trending, genres, etc.).
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
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
        ],
      ),
    );
  }
}

/// Configuration object for a quick access card.
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

/// Lightweight material card that renders a [_QuickAccessItem].
class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({required this.item});

  final _QuickAccessItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
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
              Icon(item.icon, size: 28, color: colorScheme.onSecondaryContainer),
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
    );
  }
}

/// Horizontal carousel for movies. The [section] determines which TMDB
/// endpoint is used by [MoviesProvider].
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
        // The provider already fetched JSON payloads such as
        // `{ "results": [ { "id": 634649, "title": "Spider-Man", "poster_path": "/path.jpg" } ] }`
        // from endpoints like `/3/trending/movie/{time_window}` or
        // `/3/movie/now_playing`.
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

/// Horizontal carousel for TV series leveraging [SeriesProvider].
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
        // The provider obtains JSON resembling
        // `{ "results": [ { "id": 84958, "name": "Loki", "poster_path": "/poster.jpg" } ] }`
        // from endpoints like `/3/trending/tv/{time_window}`.
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

/// Renders the popular people carousel using [PeopleProvider].
class _PeopleCarousel extends StatelessWidget {
  const _PeopleCarousel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Consumer<PeopleProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(PeopleSection.popular);
        // Backed by the `/3/person/popular` endpoint that returns JSON like
        // `{ "results": [ { "id": 287, "name": "Brad Pitt", "profile_path": "/profile.jpg" } ] }`.
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

/// Displays featured collections curated in [CollectionsProvider].
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
        // Each collection card maps to `/3/collection/{collection_id}` JSON
        // payloads (name, poster_path, overview, parts, etc.).
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

/// Shows unfinished watchlist entries sourced from [WatchlistProvider].
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
        // The watchlist lives in the local persistence layer so we only show a
        // section when unfinished entries exist.
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

/// Personalized recommendations aggregated in [RecommendationsProvider].
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
        // The provider consolidates responses from `/3/movie/{id}/recommendations`
        // JSON payloads so we can render them as plain movie cards.
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

/// Reusable widget that renders a titled horizontal list of cards handling
/// loading and error states consistently across sections.
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
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
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
      ],
    );
  }
}

/// Card widget tailored for TMDB people entries.
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
    return Card(
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
    );
  }
}

/// Card widget for featured collections including poster and overview excerpt.
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
    return Card(
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
    );
  }
}

/// Card widget for entries persisted in the watchlist so the user can resume
/// watching quickly.
class _WatchlistCard extends StatelessWidget {
  const _WatchlistCard({required this.item});

  final SavedMediaItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final releaseYear = item.releaseYear;
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
              child: (item.posterPath != null && item.posterPath!.isNotEmpty)
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
    );
  }
}
