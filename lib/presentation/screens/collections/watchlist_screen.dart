import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/mock_movie_repository.dart';
import '../../../providers/auth_provider.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final watchlistIds = authProvider.watchlist;
          if (watchlistIds.isEmpty) {
            return const _EmptyWatchlistMessage();
          }

          final watchlist = MockMovieRepository.getByIds(watchlistIds);

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: watchlist.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final movie = watchlist[index];
              final isFavorite = authProvider.isFavorite(movie.id);
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.bookmark,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: Text(movie.title),
                  subtitle: Text('${movie.year} • ${movie.genre}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        tooltip: isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: () {
                          authProvider.toggleFavorite(movie.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Remove from watchlist',
                        onPressed: () {
                          authProvider.toggleWatchlist(movie.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyWatchlistMessage extends StatelessWidget {
  const _EmptyWatchlistMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_add_outlined,
                size: 64, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 16),
            Text(
              'Start building your watchlist by tapping the bookmark icon on a movie.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
