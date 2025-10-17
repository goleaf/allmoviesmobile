import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../providers/favorites_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';

class FavoritesScreen extends StatelessWidget {
  static const routeName = '/favorites';

  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final favoritesProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('favorites.title')),
        actions: [
          if (favoritesProvider.favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: loc.t('common.clear'),
              onPressed: () => _showClearDialog(context, favoritesProvider, loc),
            ),
        ],
      ),
      body: _buildBody(context, favoritesProvider, loc),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FavoritesProvider provider,
    AppLocalizations loc,
  ) {
    if (provider.favorites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        title: loc.t('favorites.empty'),
        message: loc.t('favorites.empty_message'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.favorites.length,
      itemBuilder: (context, index) {
        final movieId = provider.favorites.elementAt(index);
        return _FavoriteMovieCard(movieId: movieId);
      },
    );
  }

  Future<void> _showClearDialog(
    BuildContext context,
    FavoritesProvider provider,
    AppLocalizations loc,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.t('favorites.title')),
        content: Text('Are you sure you want to clear all favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.t('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(loc.t('common.clear')),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.clearFavorites();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favorites cleared')),
        );
      }
    }
  }
}

class _FavoriteMovieCard extends StatelessWidget {
  final int movieId;

  const _FavoriteMovieCard({required this.movieId});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch movie details using movieId
    // For now, show a placeholder
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.movie, size: 48, color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Movie ID: $movieId',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  context.read<FavoritesProvider>().removeFavorite(movieId);
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

