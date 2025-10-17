import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/empty_state.dart';

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
                  context.read<WatchlistProvider>().removeFromWatchlist(movieId);
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.bookmark,
                    color: Colors.blue,
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

