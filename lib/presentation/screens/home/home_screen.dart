import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/collection_model.dart';
import '../../../data/models/discover_filters_model.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/person_model.dart';
import '../../../data/models/saved_media_item.dart';
import '../../../providers/collections_provider.dart';
import '../../../providers/genres_provider.dart';
import '../../../providers/movies_provider.dart';
import '../../../providers/people_provider.dart';
import '../../../providers/recommendations_provider.dart';
import '../../../providers/series_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/media_image.dart';
import '../../widgets/movie_card.dart';
import '../collections/collection_detail_screen.dart';
import '../movie_detail/movie_detail_screen.dart';
import '../movies/movies_screen.dart';
import '../person_detail/person_detail_screen.dart';
import '../search/search_screen.dart';
import '../tv_detail/tv_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;
  bool _hasSearchText = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_handleSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CollectionsProvider>().ensureInitialized();
      context
          .read<RecommendationsProvider>()
          .fetchPersonalizedRecommendations();
      context.read<GenresProvider>().fetchMovieGenres();
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    final hasText = _searchController.text.trim().isNotEmpty;
    if (hasText != _hasSearchText) {
      setState(() => _hasSearchText = hasText);
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait<void>([
      context.read<MoviesProvider>().refresh(force: true),
      context.read<SeriesProvider>().refresh(force: true),
      context.read<PeopleProvider>().refresh(force: true),
      context.read<CollectionsProvider>().refreshAll(),
      context
          .read<RecommendationsProvider>()
          .fetchPersonalizedRecommendations(),
      context.read<GenresProvider>().fetchMovieGenres(forceRefresh: true),
    ]);
  }

  void _submitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(initialQuery: trimmed),
      ),
    );
  }

  void _openMovie(Movie movie) {
    final mediaType = movie.mediaType ?? 'movie';
    if (mediaType == 'tv') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TVDetailScreen(tvShow: movie)),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
      );
    }
  }

  void _openPerson(Person person) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PersonDetailScreen(
          personId: person.id,
          initialPerson: person,
        ),
      ),
    );
  }

  void _openCollection(CollectionDetails details) {
    Navigator.of(context).pushNamed(
      CollectionDetailScreen.routeName,
      arguments: details.id,
    );
  }

  void _openQuickDiscover() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MoviesScreen(
          initialSection: MovieSection.discover,
        ),
      ),
    );
  }

  void _openQuickTrending() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MoviesScreen(
          initialSection: MovieSection.trending,
        ),
      ),
    );
  }

  void _openQuickGenres() {
    final rootContext = context;
    showModalBottomSheet<void>(
      context: rootContext,
      builder: (sheetContext) {
        return Consumer<GenresProvider>(
          builder: (context, genresProvider, _) {
            final genres = genresProvider.movieGenres;
            if (genresProvider.isLoadingMovies && genres.isEmpty) {
              return const SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (genres.isEmpty) {
              return SizedBox(
                height: 240,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      AppLocalizations.of(context).t('search.no_results'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).t('home.quick_genres'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final genre in genres)
                          ActionChip(
                            label: Text(genre.name),
                            onPressed: () async {
                              Navigator.of(sheetContext).pop();
                              final moviesProvider =
                                  rootContext.read<MoviesProvider>();
                              await moviesProvider.applyFilters(
                                DiscoverFilters(withGenres: '${genre.id}'),
                              );
                              if (!mounted) return;
                              Navigator.of(rootContext).push(
                                MaterialPageRoute(
                                  builder: (_) => const MoviesScreen(
                                    initialSection: MovieSection.discover,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text(l.t('navigation.home')),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(72),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _submitSearch,
                    decoration: InputDecoration(
                      hintText: l.t('home.search_hint'),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _hasSearchText
                          ? IconButton(
                              tooltip: l.t('common.clear'),
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildQuickAccess(l),
                  const SizedBox(height: 24),
                  _buildTrendingMovies(l),
                  const SizedBox(height: 24),
                  _buildTrendingTv(l),
                  const SizedBox(height: 24),
                  _buildPopularPeople(l),
                  const SizedBox(height: 24),
                  _buildCollections(l),
                  const SizedBox(height: 24),
                  _buildNewReleases(l),
                  const SizedBox(height: 24),
                  _buildContinueWatching(l),
                  const SizedBox(height: 24),
                  _buildRecommendations(l),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccess(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: l.t('home.quick_access')),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickAccessCard(
                icon: Icons.explore,
                label: l.t('home.quick_discover'),
                onTap: _openQuickDiscover,
              ),
              const SizedBox(width: 12),
              _QuickAccessCard(
                icon: Icons.trending_up,
                label: l.t('home.quick_trending'),
                onTap: _openQuickTrending,
              ),
              const SizedBox(width: 12),
              _QuickAccessCard(
                icon: Icons.category,
                label: l.t('home.quick_genres'),
                onTap: _openQuickGenres,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingMovies(AppLocalizations l) {
    return Consumer<MoviesProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(MovieSection.trending);
        final items = state.items.take(12).toList(growable: false);
        return _HomeHorizontalSection<Movie>(
          title: l.t('home.trending_movies'),
          items: items,
          itemHeight: 280,
          isLoading: state.isLoading && items.isEmpty,
          errorMessage: state.errorMessage,
          onRetry: () =>
              context.read<MoviesProvider>().loadPage(MovieSection.trending, 1),
          itemBuilder: (context, movie) {
            return SizedBox(
              width: 160,
              child: MovieCard(
                id: movie.id,
                title: movie.title,
                posterPath: movie.posterPath,
                voteAverage: movie.voteAverage,
                releaseDate: movie.releaseDate,
                onTap: () => _openMovie(movie),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrendingTv(AppLocalizations l) {
    return Consumer<SeriesProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(SeriesSection.trending);
        final items = state.items.take(12).toList(growable: false);
        return _HomeHorizontalSection<Movie>(
          title: l.t('home.trending_tv'),
          items: items,
          itemHeight: 280,
          isLoading: state.isLoading && items.isEmpty,
          errorMessage: state.errorMessage,
          onRetry: () => context.read<SeriesProvider>().refresh(force: true),
          itemBuilder: (context, show) {
            final tvShow = Movie(
              id: show.id,
              title: show.title,
              overview: show.overview,
              posterPath: show.posterPath,
              backdropPath: show.backdropPath,
              mediaType: 'tv',
              releaseDate: show.releaseDate,
              voteAverage: show.voteAverage,
              voteCount: show.voteCount,
            );
            return SizedBox(
              width: 160,
              child: MovieCard(
                id: tvShow.id,
                title: tvShow.title,
                posterPath: tvShow.posterPath,
                voteAverage: tvShow.voteAverage,
                releaseDate: tvShow.releaseDate,
                onTap: () => _openMovie(tvShow),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPopularPeople(AppLocalizations l) {
    return Consumer<PeopleProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(PeopleSection.popular);
        final items = state.items.take(12).toList(growable: false);
        return _HomeHorizontalSection<Person>(
          title: l.t('home.popular_people'),
          items: items,
          itemHeight: 220,
          isLoading: state.isLoading && items.isEmpty,
          errorMessage: state.errorMessage ?? provider.globalError,
          onRetry: () => context.read<PeopleProvider>().refresh(force: true),
          itemBuilder: (context, person) {
            return SizedBox(
              width: 140,
              child: _PersonPreviewCard(
                person: person,
                onTap: () => _openPerson(person),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCollections(AppLocalizations l) {
    return Consumer<CollectionsProvider>(
      builder: (context, provider, _) {
        final items =
            provider.popularCollections.take(10).toList(growable: false);
        final isLoading = provider.isPopularLoading && items.isEmpty;
        return _HomeHorizontalSection<CollectionDetails>(
          title: l.t('home.featured_collections'),
          items: items,
          itemHeight: 260,
          isLoading: isLoading,
          errorMessage: provider.popularError,
          onRetry: () =>
              context.read<CollectionsProvider>().loadPopularCollections(
                    forceRefresh: true,
                  ),
          itemBuilder: (context, collection) {
            return SizedBox(
              width: 200,
              child: _CollectionPreviewCard(
                details: collection,
                onTap: () => _openCollection(collection),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNewReleases(AppLocalizations l) {
    return Consumer<MoviesProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(MovieSection.nowPlaying);
        final items = state.items.take(12).toList(growable: false);
        return _HomeHorizontalSection<Movie>(
          title: l.t('home.new_releases'),
          items: items,
          itemHeight: 280,
          isLoading: state.isLoading && items.isEmpty,
          errorMessage: state.errorMessage,
          onRetry: () =>
              context.read<MoviesProvider>().loadPage(MovieSection.nowPlaying, 1),
          itemBuilder: (context, movie) {
            return SizedBox(
              width: 160,
              child: MovieCard(
                id: movie.id,
                title: movie.title,
                posterPath: movie.posterPath,
                voteAverage: movie.voteAverage,
                releaseDate: movie.releaseDate,
                onTap: () => _openMovie(movie),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContinueWatching(AppLocalizations l) {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, _) {
        final items = provider.watchlistItems
            .where((item) => !item.watched)
            .toList(growable: false)
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return _HomeHorizontalSection<SavedMediaItem>(
          title: l.t('home.continue_watching'),
          items: items,
          itemHeight: 240,
          isLoading: false,
          errorMessage: null,
          emptyPlaceholder: _SectionPlaceholder(
            message: l.t('search.no_results'),
          ),
          itemBuilder: (context, item) {
            return SizedBox(
              width: 160,
              child: _SavedMediaCard(
                item: item,
                onTap: () {
                  final movie = Movie(
                    id: item.id,
                    title: item.title,
                    overview: item.overview,
                    posterPath: item.posterPath,
                    backdropPath: item.backdropPath,
                    mediaType:
                        item.type == SavedMediaType.tv ? 'tv' : 'movie',
                    releaseDate: item.releaseDate,
                    voteAverage: item.voteAverage,
                    voteCount: item.voteCount,
                  );
                  _openMovie(movie);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecommendations(AppLocalizations l) {
    return Consumer<RecommendationsProvider>(
      builder: (context, provider, _) {
        final items =
            provider.recommendedMovies.take(12).toList(growable: false);
        return _HomeHorizontalSection<Movie>(
          title: l.t('home.recommended'),
          items: items,
          itemHeight: 280,
          isLoading: provider.isLoading && items.isEmpty,
          errorMessage: provider.errorMessage,
          onRetry: () => context
              .read<RecommendationsProvider>()
              .fetchPersonalizedRecommendations(),
          emptyPlaceholder: _SectionPlaceholder(
            message: l.t('search.no_results'),
          ),
          itemBuilder: (context, movie) {
            return SizedBox(
              width: 160,
              child: MovieCard(
                id: movie.id,
                title: movie.title,
                posterPath: movie.posterPath,
                voteAverage: movie.voteAverage,
                releaseDate: movie.releaseDate,
                onTap: () => _openMovie(movie),
              ),
            );
          },
        );
      },
    );
  }
}

class _HomeHorizontalSection<T> extends StatelessWidget {
  const _HomeHorizontalSection({
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.isLoading = false,
    this.errorMessage,
    this.emptyPlaceholder,
    this.onRetry,
    this.itemHeight = 260,
  });

  final String title;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final bool isLoading;
  final String? errorMessage;
  final Widget? emptyPlaceholder;
  final VoidCallback? onRetry;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title),
          const SizedBox(height: 12),
          if (isLoading)
            SizedBox(
              height: itemHeight,
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null && errorMessage!.isNotEmpty &&
              items.isEmpty)
            _SectionError(
              message: errorMessage!,
              onRetry: onRetry,
            )
          else if (items.isEmpty)
            emptyPlaceholder ??
                _SectionPlaceholder(
                  message: AppLocalizations.of(context).t('search.no_results'),
                )
          else
            SizedBox(
              height: itemHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 16),
                itemBuilder: (context, index) => itemBuilder(
                  context,
                  items[index],
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: items.length,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.onErrorContainer),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).t('common.retry')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

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
    return Expanded(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonPreviewCard extends StatelessWidget {
  const _PersonPreviewCard({required this.person, this.onTap});

  final Person person;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: MediaImage(
                path: person.profilePath,
                type: MediaImageType.profile,
                size: MediaImageSize.w185,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if ((person.knownForDepartment ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      person.knownForDepartment!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class _CollectionPreviewCard extends StatelessWidget {
  const _CollectionPreviewCard({required this.details, this.onTap});

  final CollectionDetails details;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MediaImage(
                path: details.posterPath,
                type: MediaImageType.poster,
                size: MediaImageSize.w500,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    details.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if ((details.overview ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      details.overview!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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

class _SavedMediaCard extends StatelessWidget {
  const _SavedMediaCard({required this.item, this.onTap});

  final SavedMediaItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: MediaImage(
                path: item.posterPath,
                type: MediaImageType.poster,
                size: MediaImageSize.w342,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (item.releaseYear != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.releaseYear!,
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
