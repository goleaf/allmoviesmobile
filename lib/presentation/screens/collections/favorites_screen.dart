import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/mock_movie_repository.dart';
import '../../../providers/auth_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final favoriteIds = authProvider.favorites;
          if (favoriteIds.isEmpty) {
            return _EmptyCollectionMessage(
              icon: Icons.favorite_border,
              message:
                  'You have no favorites yet. Tap the heart icon on a movie to save it here.',
            );
          }

          final favorites = MockMovieRepository.getByIds(favoriteIds);

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final movie = favorites[index];
              final isInWatchlist = authProvider.isInWatchlist(movie.id);
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.movie_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(movie.title),
                  subtitle: Text('${movie.year} • ${movie.genre}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite),
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: 'Remove from favorites',
                        onPressed: () {
                          authProvider.toggleFavorite(movie.id);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          isInWatchlist
                              ? Icons.bookmark
                              : Icons.bookmark_add_outlined,
                        ),
                        tooltip: isInWatchlist
                            ? 'Remove from watchlist'
                            : 'Add to watchlist',
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

class _EmptyCollectionMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyCollectionMessage({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
