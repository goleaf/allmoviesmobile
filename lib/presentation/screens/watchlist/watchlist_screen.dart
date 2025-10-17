import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/saved_movie_card.dart';

class WatchlistScreen extends StatelessWidget {
  static const routeName = '/watchlist';

  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final watchlistProvider = context.watch<WatchlistProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('watchlist.title')),
        actions: [
          if (watchlistProvider.watchlist.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: loc.t('common.clear'),
              onPressed: () => _showClearDialog(context, watchlistProvider, loc),
            ),
        ],
      ),
      body: _buildBody(context, watchlistProvider, loc),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WatchlistProvider provider,
    AppLocalizations loc,
  ) {
    if (provider.watchlist.isEmpty) {
      return EmptyState(
        icon: Icons.bookmark_border,
        title: loc.t('watchlist.empty'),
        message: loc.t('watchlist.empty_message'),
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
      itemCount: provider.watchlist.length,
      itemBuilder: (context, index) {
        final movieId = provider.watchlist.elementAt(index);
        return _WatchlistMovieCard(movieId: movieId);
      },
    );
  }

  Future<void> _showClearDialog(
    BuildContext context,
    WatchlistProvider provider,
    AppLocalizations loc,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.t('watchlist.title')),
        content: const Text('Are you sure you want to clear all watchlist items?'),
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
      await provider.clearWatchlist();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Watchlist cleared')),
        );
      }
    }
  }
}

class _WatchlistMovieCard extends StatelessWidget {
  final int movieId;

  const _WatchlistMovieCard({required this.movieId});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return SavedMovieCard(
      movieId: movieId,
      removeIcon: Icons.bookmark,
      removeColor: Theme.of(context).colorScheme.primary,
      removeTooltip: loc.t('movie.remove_from_watchlist'),
      onRemove: () async {
        await context.read<WatchlistProvider>().removeFromWatchlist(movieId);
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.t('watchlist.removed'))),
        );
      },
    );
  }
}

