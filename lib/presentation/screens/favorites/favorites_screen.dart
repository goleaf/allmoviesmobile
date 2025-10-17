import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../providers/favorites_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/saved_movie_card.dart';

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
    final loc = AppLocalizations.of(context);

    return SavedMovieCard(
      movieId: movieId,
      removeIcon: Icons.favorite,
      removeColor: Colors.redAccent,
      removeTooltip: loc.t('movie.remove_from_favorites'),
      onRemove: () async {
        await context.read<FavoritesProvider>().removeFavorite(movieId);
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.t('favorites.removed'))),
        );
      },
    );
  }
}

