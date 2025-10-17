import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/collection_model.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/person_model.dart';
import '../../../data/models/saved_media_item.dart';
import '../../../providers/collections_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/recommendations_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/media_image.dart';
import '../movie_detail/movie_detail_screen.dart';
import '../tv_detail/tv_detail_screen.dart';
import '../person_detail/person_detail_screen.dart';
import '../collections/collection_detail_screen.dart';
import '../collections/browse_collections_screen.dart';
import '../movies/movies_screen.dart';
import '../movies/movies_filters_screen.dart';
import '../search/search_screen.dart';

/// Home screen with curated carousels and quick access to discovery features.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomeProvider>();
      final collectionsProvider = context.read<CollectionsProvider>();
      final recommendationsProvider = context.read<RecommendationsProvider>();

      homeProvider.load();
      collectionsProvider.ensureInitialized();
      recommendationsProvider.fetchPersonalizedRecommendations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Refreshes every data source used on the Home screen so pull-to-refresh
  /// reliably rehydrates the UI.
  Future<void> _refreshAll() async {
    final homeProvider = context.read<HomeProvider>();
    final collectionsProvider = context.read<CollectionsProvider>();
    final recommendationsProvider = context.read<RecommendationsProvider>();

    await Future.wait<void>(<Future<void>>[
      homeProvider.refresh(),
      collectionsProvider.refreshAll(),
      recommendationsProvider.fetchPersonalizedRecommendations(),
    ]);
  }

  /// Opens the global search experience, optionally seeding the provided text.
  void _openSearch([String? query]) {
    final trimmed = (query ?? _searchController.text).trim();
    Navigator.of(context).pushNamed(
      SearchScreen.routeName,
      arguments: trimmed.isEmpty ? null : trimmed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final homeProvider = context.watch<HomeProvider>();
    final collectionsProvider = context.watch<CollectionsProvider>();
    final recommendationsProvider = context.watch<RecommendationsProvider>();
    final watchlistProvider = context.watch<WatchlistProvider>();

    final continueWatching = watchlistProvider.watchlistItems
        .where((item) => !item.watched)
        .toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return AppScaffold(
      appBar: _HomeSearchAppBar(
        controller: _searchController,
        onSubmit: _openSearch,
        hintText: loc.search['search_placeholder'] ??
            'Search movies, TV shows, people...',
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _SectionHeader(
              title: loc.home['of_the_moment_movies'] ??
                  'Of the moment • Movies',
              subtitle: loc.home['updated_daily'] ?? 'Updated daily',
            ),
            _HorizontalSection(
              height: 260,
              isLoading: homeProvider.isLoading &&
                  !homeProvider.hasLoaded,
              errorMessage: homeProvider.ofTheMomentMoviesError,
              items: homeProvider.ofTheMomentMovies
                  .map(
                    (movie) => _PosterCard(
                      title: movie.title,
                      subtitle: movie.releaseYear,
                      posterPath: movie.posterPath,
                      voteAverage: movie.voteAverage,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          MovieDetailScreen.routeName,
                          arguments: movie,
                        );
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            _SectionHeader(
              title:
                  loc.home['of_the_moment_tv'] ?? 'Of the moment • TV shows',
              subtitle: loc.home['updated_daily'] ?? 'Updated daily',
            ),
            _HorizontalSection(
              height: 260,
              isLoading: homeProvider.isLoading &&
                  !homeProvider.hasLoaded,
              errorMessage: homeProvider.ofTheMomentTvError,
              items: homeProvider.ofTheMomentTvShows
                  .map(
                    (show) => _PosterCard(
                      title: show.title,
                      subtitle: show.releaseYear,
                      posterPath: show.posterPath,
                      voteAverage: show.voteAverage,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          TVDetailScreen.routeName,
                          arguments: show,
                        );
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            _SectionHeader(
              title: loc.home['quick_access'] ?? 'Quick Access',
              subtitle: loc.home['jump_back_in'] ?? 'Jump back into discovery',
            ),
            _QuickAccessGrid(
              onDiscover: () {
                Navigator.of(context).pushNamed(MoviesScreen.routeName);
              },
              onTrending: () {
                Navigator.of(context).pushNamed(
                  MoviesFiltersScreen.routeName,
                );
              },
              onGenres: () {
                Navigator.of(context).pushNamed(
                  CollectionsBrowserScreen.routeName,
                );
              },
              discoverLabel: loc.navigation['discover'] ?? 'Discover',
              trendingLabel: loc.home['trending'] ?? 'Trending',
              genresLabel: loc.home['genres'] ?? 'Genres',
            ),
            const SizedBox(height: 16),
            _SectionHeader(
              title: loc.home['popular_people'] ?? 'Popular people',
              subtitle: loc.home['spotlight'] ?? 'Spotlight talent this week',
            ),
            _HorizontalSection(
              height: 220,
              isLoading: homeProvider.isLoading &&
                  !homeProvider.hasLoaded,
              errorMessage: homeProvider.popularPeopleError,
              items: homeProvider.popularPeople
                  .map(
                    (person) => _PersonCard(
                      person: person,
                      onTap: () => Navigator.of(context).pushNamed(
                        PersonDetailScreen.routeName,
                        arguments: person,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            _SectionHeader(
              title: loc.home['featured_collections'] ??
                  'Featured collections',
              subtitle: loc.home['editorial_picks'] ?? 'Editorial picks',
              onActionTap: () => Navigator.of(context).pushNamed(
                CollectionsBrowserScreen.routeName,
              ),
              actionLabel: loc.home['see_all'] ?? 'See all',
            ),
            _HorizontalSection(
              height: 220,
              isLoading: collectionsProvider.isPopularLoading &&
                  collectionsProvider.popularCollections.isEmpty,
              errorMessage: collectionsProvider.popularError,
              items: collectionsProvider.popularCollections
                  .map(
                    (collection) => _CollectionCard(
                      collection: collection,
                      onTap: () => Navigator.of(context).pushNamed(
                        CollectionDetailScreen.routeName,
                        arguments: collection.id,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            _SectionHeader(
              title: loc.home['new_releases'] ?? 'New releases',
              subtitle: loc.home['in_theaters_now'] ?? 'In theaters now',
            ),
            _HorizontalSection(
              height: 260,
              isLoading: homeProvider.isLoading &&
                  !homeProvider.hasLoaded,
              errorMessage: homeProvider.newReleasesError,
              items: homeProvider.newReleases
                  .map(
                    (movie) => _PosterCard(
                      title: movie.title,
                      subtitle: movie.releaseYear,
                      posterPath: movie.posterPath,
                      voteAverage: movie.voteAverage,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          MovieDetailScreen.routeName,
                          arguments: movie,
                        );
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            if (continueWatching.isNotEmpty) ...[
              _SectionHeader(
                title: loc.home['continue_watching'] ?? 'Continue watching',
                subtitle:
                    loc.home['pick_up_where_left'] ?? 'Pick up where you left',
              ),
              _HorizontalSection(
                height: 220,
                items: continueWatching
                    .take(20)
                    .map(
                      (item) => _ContinueWatchingCard(
                        item: item,
                        onTap: () {
                          final movie = Movie(
                            id: item.id,
                            title: item.title,
                            posterPath: item.posterPath,
                            mediaType:
                                item.type == SavedMediaType.tv ? 'tv' : 'movie',
                          );
                          Navigator.of(context).pushNamed(
                            item.type == SavedMediaType.tv
                                ? TVDetailScreen.routeName
                                : MovieDetailScreen.routeName,
                            arguments: movie,
                          );
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 16),
            ],
            _SectionHeader(
              title: loc.home['recommended'] ?? 'Recommended for you',
              subtitle:
                  loc.home['based_on_activity'] ?? 'Based on your favorites',
            ),
            _HorizontalSection(
              height: 260,
              isLoading: recommendationsProvider.isLoading &&
                  recommendationsProvider.recommendedMovies.isEmpty,
              errorMessage: recommendationsProvider.errorMessage,
              items: recommendationsProvider.recommendedMovies
                  .map(
                    (movie) => _PosterCard(
                      title: movie.title,
                      subtitle: movie.releaseYear,
                      posterPath: movie.posterPath,
                      voteAverage: movie.voteAverage,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          MovieDetailScreen.routeName,
                          arguments: movie,
                        );
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

/// App bar that keeps a persistent search field at the top of the Home screen.
class _HomeSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeSearchAppBar({
    required this.controller,
    required this.onSubmit,
    required this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String?> onSubmit;
  final String hintText;

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                    ),
                    onSubmitted: onSubmit,
                    textInputAction: TextInputAction.search,
                  ),
                ),
                if (value.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: controller.clear,
                  ),
              ],
            ),
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => onSubmit(controller.text),
        ),
      ],
    );
  }
}

/// Displays the section title, optional subtitle and an optional action link.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.onActionTap,
    this.actionLabel,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ) ??
                      const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (onActionTap != null && actionLabel != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// Horizontally scrollable carousel used across Home sections.
class _HorizontalSection extends StatelessWidget {
  const _HorizontalSection({
    required this.items,
    this.height = 220,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Widget> items;
  final double height;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null && items.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No content available yet',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => SizedBox(
          width: 150,
          child: items[index],
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }
}

/// Generic poster-based card that can render movie or TV artwork.
class _PosterCard extends StatelessWidget {
  const _PosterCard({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.posterPath,
    this.voteAverage,
  });

  final String title;
  final String? subtitle;
  final String? posterPath;
  final double? voteAverage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: posterPath != null
                  ? MediaImage(
                      path: posterPath,
                      type: MediaImageType.poster,
                      size: MediaImageSize.w342,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.movie, size: 40, color: Colors.grey),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (voteAverage != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          voteAverage!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
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

/// Card used for showcasing popular people.
class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.person, required this.onTap});

  final Person person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Expanded(
              child: person.profilePath != null
                  ? MediaImage(
                      path: person.profilePath,
                      type: MediaImageType.profile,
                      size: MediaImageSize.w342,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name ?? 'Unknown',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (person.knownForDepartment != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      person.knownForDepartment!,
                      style: Theme.of(context).textTheme.bodySmall,
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

/// Highlights a featured collection with its poster and part count.
class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection, required this.onTap});

  final CollectionDetails collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: collection.posterPath != null
                  ? MediaImage(
                      path: collection.posterPath,
                      type: MediaImageType.poster,
                      size: MediaImageSize.w342,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child:
                            Icon(Icons.collections, size: 40, color: Colors.grey),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${collection.parts.length} titles',
                    style: Theme.of(context).textTheme.bodySmall,
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

/// Displays an entry from the local watchlist so users can resume quickly.
class _ContinueWatchingCard extends StatelessWidget {
  const _ContinueWatchingCard({required this.item, required this.onTap});

  final SavedMediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: item.posterPath != null
                  ? MediaImage(
                      path: item.posterPath,
                      type: MediaImageType.poster,
                      size: MediaImageSize.w342,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.play_circle_fill,
                            size: 40, color: Colors.grey),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (item.releaseYear != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.releaseYear!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    item.type.displayLabel,
                    style: Theme.of(context).textTheme.bodySmall,
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

/// Wrap layout providing quick entry points to key exploration features.
class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({
    required this.onDiscover,
    required this.onTrending,
    required this.onGenres,
    required this.discoverLabel,
    required this.trendingLabel,
    required this.genresLabel,
  });

  final VoidCallback onDiscover;
  final VoidCallback onTrending;
  final VoidCallback onGenres;
  final String discoverLabel;
  final String trendingLabel;
  final String genresLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _QuickAccessCard(
            icon: Icons.explore,
            label: discoverLabel,
            onTap: onDiscover,
          ),
          _QuickAccessCard(
            icon: Icons.trending_up,
            label: trendingLabel,
            onTap: onTrending,
          ),
          _QuickAccessCard(
            icon: Icons.category,
            label: genresLabel,
            onTap: onGenres,
          ),
        ],
      ),
    );
  }
}

/// Individual quick access tile used inside [_QuickAccessGrid].
class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 28,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
