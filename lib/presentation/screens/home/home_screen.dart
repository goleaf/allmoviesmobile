import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/movie.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/movies_provider.dart';
import '../../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MoviesProvider>();
      _searchController.text = provider.searchQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final moviesProvider = context.watch<MoviesProvider>();
    final movies = moviesProvider.visibleMovies;
    final userName = authProvider.currentUser?.fullName ?? AppStrings.guestUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.movie_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(AppStrings.appName),
          ],
        ),
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.search,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  isDense: true,
                ),
                onChanged: moviesProvider.updateSearchQuery,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.welcome} $userName!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _FiltersSection(provider: moviesProvider),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: moviesProvider.loadMovies,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildContent(context, moviesProvider, movies),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MoviesProvider moviesProvider,
    List<Movie> movies,
  ) {
    if (moviesProvider.isLoading && movies.isEmpty) {
      return ListView(
        key: const ValueKey('loading-state'),
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (moviesProvider.errorMessage != null && movies.isEmpty) {
      return ListView(
        key: const ValueKey('error-state'),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Icon(
              Icons.wifi_off,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              AppStrings.unableToLoadMovies,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              moviesProvider.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: moviesProvider.retry,
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
            ),
          ),
          const SizedBox(height: 120),
        ],
      );
    }

    if (movies.isEmpty) {
      return ListView(
        key: const ValueKey('empty-state'),
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: Icon(Icons.movie_filter_outlined, size: 64)),
          SizedBox(height: 16),
          Center(
            child: Text(
              AppStrings.noMoviesFound,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 120),
        ],
      );
    }

    return GridView.builder(
      key: ValueKey('${moviesProvider.selectedFilter}-${moviesProvider.selectedSort}-${moviesProvider.searchQuery}'),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _MovieCard(movie: movie);
      },
    );
  }
}

class _FiltersSection extends StatelessWidget {
  const _FiltersSection({required this.provider});

  final MoviesProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.discoverHeading,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...MovieFilterOption.values.map(
              (filter) => ChoiceChip(
                label: Text(_filterLabel(filter)),
                selected: provider.selectedFilter == filter,
                onSelected: (_) => provider.updateFilter(filter),
              ),
            ),
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(AppStrings.sortBy),
                const SizedBox(width: 8),
                DropdownButton<MovieSortOption>(
                  value: provider.selectedSort,
                  onChanged: (option) {
                    if (option != null) {
                      provider.updateSort(option);
                    }
                  },
                  items: MovieSortOption.values
                      .map(
                        (option) => DropdownMenuItem<MovieSortOption>(
                          value: option,
                          child: Text(_sortLabel(option)),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _filterLabel(MovieFilterOption option) {
    return switch (option) {
      MovieFilterOption.all => AppStrings.filterAll,
      MovieFilterOption.trending => AppStrings.filterTrending,
      MovieFilterOption.popular => AppStrings.filterPopular,
    };
  }

  String _sortLabel(MovieSortOption option) {
    return switch (option) {
      MovieSortOption.popularity => AppStrings.sortPopularity,
      MovieSortOption.rating => AppStrings.sortRating,
      MovieSortOption.releaseDate => AppStrings.sortReleaseDate,
      MovieSortOption.title => AppStrings.sortTitle,
    };
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = _buildSubtitle();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: movie.posterImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: movie.posterImageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => _PosterFallback(theme: theme),
                  )
                : _PosterFallback(theme: theme),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: theme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _buildSubtitle() {
    final releaseYear = movie.releaseDateTime?.year;
    final rating = movie.voteAverage > 0 ? '${movie.voteAverage.toStringAsFixed(1)} ★' : null;

    if (releaseYear == null && rating == null) {
      return null;
    }

    final parts = <String>[];
    if (releaseYear != null) {
      parts.add('$releaseYear');
    }
    if (rating != null) {
      parts.add(rating);
    }

    return parts.join(' • ');
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.primaryContainer,
      width: double.infinity,
      child: Icon(
        Icons.local_movies,
        size: 48,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
