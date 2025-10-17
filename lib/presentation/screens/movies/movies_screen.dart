import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/movie.dart';
import '../../../providers/movies_provider.dart';
import '../../widgets/app_drawer.dart';

class MoviesScreen extends StatelessWidget {
  static const routeName = '/movies';

  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MoviesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.movies),
      ),
      drawer: const AppDrawer(),
      body: _MoviesBody(provider: provider),
    );
  }
}

class _MoviesBody extends StatelessWidget {
  const _MoviesBody({required this.provider});

  final MoviesProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.movies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.movies.isEmpty) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: provider.refreshMovies,
      );
    }

    if (provider.movies.isEmpty) {
      return const _EmptyView(message: 'No movies found right now. Pull to refresh.');
    }

    final itemCount = provider.movies.length + (provider.isLoadingMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: provider.refreshMovies,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          final shouldLoadMore =
              metrics.pixels >= metrics.maxScrollExtent - 200 &&
                  provider.canLoadMore &&
                  !provider.isLoadingMore &&
                  !provider.isLoading;

          if (shouldLoadMore) {
            provider.loadMoreMovies();
          }

          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index >= provider.movies.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final movie = provider.movies[index];
            return _MovieCard(movie: movie);
          },
        ),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[];
    final releaseYear = movie.releaseYear;
    if (releaseYear != null && releaseYear.isNotEmpty) {
      subtitleParts.add(releaseYear);
    }
    final mediaLabel = movie.mediaLabel;
    if (mediaLabel.isNotEmpty) {
      subtitleParts.add(mediaLabel);
    }
    final showing = movie.showingLabel;
    if (showing != null && showing.isNotEmpty) {
      subtitleParts.add(showing);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.movie_creation_outlined,
                    color: Theme.of(context).colorScheme.primary,
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
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleParts.join(' • '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(movie.formattedRating),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              movie.overview ?? 'No overview available.',
              style: Theme.of(context).textTheme.bodyMedium,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
