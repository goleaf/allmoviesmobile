import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/movie.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/trending_titles_provider.dart';
import '../../widgets/app_drawer.dart';
import '../companies/companies_screen.dart';
import '../movie_detail/movie_detail_screen.dart';
import '../movies/movies_screen.dart';
import '../people/people_screen.dart';
import '../series/series_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final trendingProvider = context.watch<TrendingTitlesProvider>();
    final filteredTitles = _filterTitles(trendingProvider.titles);
    final isLoading = trendingProvider.isLoading;
    final errorMessage = trendingProvider.errorMessage;
    final hasSearchQuery = _searchQuery.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(
            Icons.movie_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: 40,
            width: double.infinity,
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
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Open sections',
            onSelected: (routeName) {
              Navigator.pushNamed(context, routeName);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: MoviesScreen.routeName,
                child: Text(AppStrings.movies),
              ),
              PopupMenuItem(
                value: SeriesScreen.routeName,
                child: Text(AppStrings.series),
              ),
              PopupMenuItem(
                value: PeopleScreen.routeName,
                child: Text(AppStrings.people),
              ),
              PopupMenuItem(
                value: CompaniesScreen.routeName,
                child: Text(AppStrings.companies),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: const AppDrawer(),
      endDrawerEnableOpenDragGesture: true,
      drawerEnableOpenDragGesture: false,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${authProvider.currentUser?.fullName ?? "Guest"}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.exploreCollections,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (errorMessage != null) {
                    return _ErrorView(
                      message: errorMessage!,
                      onRetry: trendingProvider.loadTrendingTitles,
                    );
                  }

                  if (filteredTitles.isEmpty) {
                    final message = hasSearchQuery
                        ? 'No titles match your search yet.'
                        : 'No titles found right now.';
                    return Center(
                      child: Text(
                        message,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: trendingProvider.loadTrendingTitles,
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredTitles.length,
                      itemBuilder: (context, index) {
                        final movie = filteredTitles[index];
                        return _MovieCard(movie: movie);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Movie> _filterTitles(List<Movie> titles) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return titles;
    }

    return titles
        .where((movie) => movie.title.toLowerCase().contains(query))
        .toList(growable: false);
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movie: movie),
            ),
          );
        },
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: _PosterImage(movie: movie),
                ),
                if (movie.voteAverage != null && movie.voteAverage! > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (movie.genresText.isNotEmpty)
                  Text(
                    movie.genresText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  _buildSubtitle(movie),
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterUrl;

    if (posterUrl == null) {
      return Icon(
        Icons.movie_outlined,
        size: 64,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                onRetry();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

String _buildSubtitle(Movie movie) {
  final segments = <String>[];

  final releaseYear = movie.releaseYear;
  if (releaseYear != null && releaseYear.isNotEmpty) {
    segments.add(releaseYear);
  }

  segments.add(movie.mediaLabel);

  return segments.join(' • ');
}
