import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/repositories/mock_movie_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  late final List<MovieModel> _movies;
  late List<MovieModel> _visibleMovies;

  @override
  void initState() {
    super.initState();
    _movies = MockMovieRepository.getMovies();
    _visibleMovies = _movies;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
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
                onChanged: (value) {
                  final query = value.trim().toLowerCase();
                  setState(() {
                    if (query.isEmpty) {
                      _visibleMovies = _movies;
                    } else {
                      _visibleMovies = _movies
                          .where((movie) => movie.title.toLowerCase().contains(query))
                          .toList();
                    }
                  });
                },
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
              'Welcome, ${authProvider.currentUser?.fullName ?? "Guest"}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _visibleMovies.length,
                itemBuilder: (context, index) {
                  final movie = _visibleMovies[index];
                  return _MovieCard(movie: movie);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final MovieModel movie;

  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.movie_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${movie.year} • ${movie.genre}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        final isFavorite = authProvider.isFavorite(movie.id);
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color,
                          ),
                          tooltip: isFavorite
                              ? 'Remove from favorites'
                              : 'Add to favorites',
                          onPressed: () {
                            authProvider.toggleFavorite(movie.id);
                          },
                        );
                      },
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        final isInWatchlist = authProvider.isInWatchlist(movie.id);
                        return IconButton(
                          icon: Icon(
                            isInWatchlist
                                ? Icons.bookmark
                                : Icons.bookmark_add_outlined,
                            color: isInWatchlist
                                ? theme.colorScheme.secondary
                                : theme.iconTheme.color,
                          ),
                          tooltip: isInWatchlist
                              ? 'Remove from watchlist'
                              : 'Add to watchlist',
                          onPressed: () {
                            authProvider.toggleWatchlist(movie.id);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
