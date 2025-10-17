import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/movie.dart';
import '../../../providers/movies_provider.dart';
import '../../screens/movie_detail/movie_detail_screen.dart';
import '../../widgets/app_drawer.dart';

class MoviesScreen extends StatefulWidget {
  static const routeName = '/movies';

  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  late final TextEditingController _searchController;
  List<Movie> _searchResults = const [];
  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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

    return DefaultTabController(
      length: sections.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.movies),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final section in sections) Tab(text: _labelForSection(section)),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.searchMovies,
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
            if (_isSearching)
              const LinearProgressIndicator(minHeight: 2),
            if (_searchError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    emptyMessage: AppStrings.noResultsFound,
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

  String _labelForSection(MovieSection section) {
    switch (section) {
      case MovieSection.trending:
        return AppStrings.trending;
      case MovieSection.nowPlaying:
        return AppStrings.nowPlaying;
      case MovieSection.popular:
        return AppStrings.popular;
      case MovieSection.topRated:
        return AppStrings.topRated;
      case MovieSection.upcoming:
        return AppStrings.upcoming;
      case MovieSection.discover:
        return AppStrings.discover;
    }
  }
}

class _MoviesSectionView extends StatelessWidget {
  const _MoviesSectionView({
    required this.section,
    required this.onRefreshAll,
  });

  final MovieSection section;
  final Future<void> Function(BuildContext context) onRefreshAll;

  @override
  Widget build(BuildContext context) {
    return Consumer<MoviesProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(section);
        if (state.isLoading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage != null && state.items.isEmpty) {
          return _ErrorView(
            message: state.errorMessage!,
            onRetry: () => onRefreshAll(context),
          );
        }

        return RefreshIndicator(
          onRefresh: () => onRefreshAll(context),
          child: _MoviesList(
            movies: state.items,
            emptyMessage: AppStrings.noResultsFound,
          ),
        );
      },
    );
  }
}

class _MoviesList extends StatelessWidget {
  const _MoviesList({
    required this.movies,
    required this.emptyMessage,
  });

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
            MaterialPageRoute(
              builder: (_) => MovieDetailScreen(movie: movie),
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
                          _buildSubtitle(movie),
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

  String _buildSubtitle(Movie movie) {
    final buffer = <String>[];
    if (movie.releaseYear != null && movie.releaseYear!.isNotEmpty) {
      buffer.add(movie.releaseYear!);
    }
    if (movie.genresText.isNotEmpty) {
      buffer.add(movie.genresText);
    }
    if (movie.formattedPopularity.isNotEmpty) {
      buffer.add('Popularity ${movie.formattedPopularity}');
    }
    return buffer.join(' • ');
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

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
            label: const Text(AppStrings.retry),
          ),
        ),
      ],
    );
  }
}
