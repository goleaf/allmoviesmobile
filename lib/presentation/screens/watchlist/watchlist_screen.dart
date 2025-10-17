import 'package:flutter/foundation.dart';
import '../../../data/models/movie_mappers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../data/tmdb_repository.dart';
import '../../../data/models/movie_mappers.dart';
import '../../../data/models/saved_media_item.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/empty_state.dart';

class WatchlistScreen extends StatefulWidget {
  static const routeName = '/watchlist';

  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

enum _SortMode { dateAdded, rating, title }

enum _TypeFilter { all, movie, tv }

class _WatchlistScreenState extends State<WatchlistScreen> {
  _SortMode _sortMode = _SortMode.dateAdded;
  _TypeFilter _typeFilter = _TypeFilter.all;

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
              onPressed: () =>
                  _showClearDialog(context, watchlistProvider, loc),
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenu(value, watchlistProvider),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sort',
                child: Text(loc.t('discover.sort_by')),
              ),
              PopupMenuItem(
                value: 'filter',
                child: Text(loc.t('discover.filters')),
              ),
              PopupMenuItem(
                value: 'share',
                child: Text(loc.movie['share'] ?? 'Share'),
              ),
            ],
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
    if (provider.watchlistItems.isEmpty) {
      return EmptyState(
        icon: Icons.bookmark_border,
        title: loc.t('watchlist.empty'),
        message: loc.t('watchlist.empty_message'),
      );
    }

    final filtered = provider.watchlistItems
        .where((item) {
          switch (_typeFilter) {
            case _TypeFilter.all:
              return true;
            case _TypeFilter.movie:
              return item.type == SavedMediaType.movie;
            case _TypeFilter.tv:
              return item.type == SavedMediaType.tv;
          }
        })
        .toList(growable: false);

    final addedAtById = {for (final item in filtered) item.id: item.addedAt};

    return _WatchlistList(
      ids: filtered.map((e) => e.id).toList(growable: false),
      sortMode: _sortMode,
      addedAtById: addedAtById,
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
        content: const Text(
          'Are you sure you want to clear all watchlist items?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.t('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(loc.t('common.clear')),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.clearWatchlist();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Watchlist cleared')));
      }
    }
  }

  Future<void> _handleMenu(String value, WatchlistProvider provider) async {
    switch (value) {
      case 'sort':
        _pickSortMode();
        break;
      case 'filter':
        _pickFilter();
        break;
      case 'share':
        final count = provider.watchlistItems.length;
        await Share.share(
          '${AppLocalizations.of(context).t('watchlist.title')}: $count',
        );
        break;
    }
  }

  Future<void> _pickSortMode() async {
    final selected = await showDialog<_SortMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(AppLocalizations.of(context).t('discover.sort_by')),
        children: [
          RadioListTile<_SortMode>(
            value: _SortMode.dateAdded,
            groupValue: _sortMode,
            title: Text(
              AppLocalizations.of(context).t('common.date_added') ??
                  'Date added',
            ),
            onChanged: (v) => Navigator.pop(context, v),
          ),
          RadioListTile<_SortMode>(
            value: _SortMode.rating,
            groupValue: _sortMode,
            title: Text(
              AppLocalizations.of(context).t('movie.rating') ?? 'Rating',
            ),
            onChanged: (v) => Navigator.pop(context, v),
          ),
          RadioListTile<_SortMode>(
            value: _SortMode.title,
            groupValue: _sortMode,
            title: Text(
              AppLocalizations.of(
                    context,
                  ).t('collection.translation_homepage') ??
                  'Title',
            ),
            onChanged: (v) => Navigator.pop(context, v),
          ),
        ],
      ),
    );
    if (selected != null) {
      setState(() => _sortMode = selected);
    }
  }

  Future<void> _pickFilter() async {
    final selected = await showDialog<_TypeFilter>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(AppLocalizations.of(context).t('discover.filters')),
        children: [
          RadioListTile<_TypeFilter>(
            value: _TypeFilter.all,
            groupValue: _typeFilter,
            title: Text(AppLocalizations.of(context).t('common.all')),
            onChanged: (v) => Navigator.pop(context, v),
          ),
          RadioListTile<_TypeFilter>(
            value: _TypeFilter.movie,
            groupValue: _typeFilter,
            title: Text(AppLocalizations.of(context).t('navigation.movies')),
            onChanged: (v) => Navigator.pop(context, v),
          ),
          RadioListTile<_TypeFilter>(
            value: _TypeFilter.tv,
            groupValue: _typeFilter,
            title: Text(AppLocalizations.of(context).t('navigation.tv_shows')),
            onChanged: (v) => Navigator.pop(context, v),
          ),
        ],
      ),
    );
    if (selected != null) {
      setState(() => _typeFilter = selected);
    }
  }

  Future<void> _promptImportUrl(WatchlistProvider provider) async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import from URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://example.com/watchlist.json',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (url == null || url.isEmpty) return;
    try {
      await provider.importFromRemoteJson(Uri.parse(url));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Imported watchlist.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }
}

class _WatchlistList extends StatefulWidget {
  const _WatchlistList({
    required this.ids,
    required this.sortMode,
    required this.addedAtById,
  });

  final List<int> ids;
  final _SortMode sortMode;
  final Map<int, DateTime> addedAtById;

  @override
  State<_WatchlistList> createState() => _WatchlistListState();
}

class _WatchlistListState extends State<_WatchlistList> {
  late Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _loadMovies();
  }

  @override
  void didUpdateWidget(covariant _WatchlistList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.ids, oldWidget.ids) ||
        widget.sortMode != oldWidget.sortMode) {
      setState(() {
        _moviesFuture = _loadMovies();
      });
    }
  }

  Future<List<Movie>> _loadMovies() async {
    final repository = context.read<TmdbRepository>();
    final movies = <Movie>[];
    for (final id in widget.ids) {
      try {
        try {
          final details = await repository.fetchMovieDetails(id);
          movies.add(details.toMovieSummary());
          continue;
        } catch (_) {}

        try {
          final tv = await repository.fetchTvDetails(id);
          movies.add(tv.toMovieSummaryFromTv());
          continue;
        } catch (_) {}
      } catch (_) {}
    }

    switch (widget.sortMode) {
      case _SortMode.dateAdded:
        movies.sort((a, b) {
          final ad = widget.addedAtById[a.id];
          final bd = widget.addedAtById[b.id];
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad);
        });
        break;
      case _SortMode.rating:
        movies.sort((a, b) {
          final ar = a.voteAverage ?? -1;
          final br = b.voteAverage ?? -1;
          return br.compareTo(ar);
        });
        break;
      case _SortMode.title:
        movies.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }

    return movies;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    return FutureBuilder<List<Movie>>(
      future: _moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final movies = snapshot.data ?? const <Movie>[];
        if (movies.isEmpty) {
          return const SizedBox.shrink();
        }

        final avgRating = _averageRating(movies);
        final totalRuntime = _totalRuntimeMinutes(movies);

        return Column(
          children: [
            _StatsBar(
              count: movies.length,
              avgRating: avgRating,
              totalRuntimeMinutes: totalRuntime,
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  final isInWatchlist = provider.isInWatchlist(movie.id);
                  return Dismissible(
                    key: ValueKey('watch_${movie.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.12),
                      child: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onDismissed: (_) => provider.removeFromWatchlist(movie.id),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          movie.title.isNotEmpty ? movie.title[0] : '?',
                        ),
                      ),
                      title: Text(movie.title),
                      subtitle: Row(
                        children: [
                          Expanded(child: Text(_subtitleFor(movie))),
                          if (provider.isWatched(movie.id))
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.visibility, size: 16),
                                  SizedBox(width: 4),
                                  Text('Watched'),
                                ],
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isInWatchlist
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                        ),
                        onPressed: () => provider.toggleWatchlist(movie.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _subtitleFor(Movie movie) {
    final parts = <String>[];
    final year = movie.releaseYear;
    if (year != null && year.isNotEmpty) parts.add(year);
    final rating = movie.voteAverage;
    if (rating != null && rating > 0) parts.add(rating.toStringAsFixed(1));
    return parts.join(' • ');
  }

  double _averageRating(List<Movie> movies) {
    final ratings = movies
        .map((m) => m.voteAverage)
        .whereType<double>()
        .toList(growable: false);
    if (ratings.isEmpty) return 0;
    final sum = ratings.reduce((a, b) => a + b);
    return sum / ratings.length;
  }

  int _totalRuntimeMinutes(List<Movie> movies) {
    int total = 0;
    for (final m in movies) {
      final r = m.runtime;
      if (r != null && r > 0) total += r;
    }
    return total;
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.count,
    required this.avgRating,
    required this.totalRuntimeMinutes,
  });

  final int count;
  final double avgRating;
  final int totalRuntimeMinutes;

  @override
  Widget build(BuildContext context) {
    String _formatRuntime(int minutes) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (hours == 0) return '${mins}m';
      return '${hours}h ${mins}m';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text('Items: $count'),
          const SizedBox(width: 16),
          Text('Avg rating: ${avgRating.toStringAsFixed(1)}'),
          const SizedBox(width: 16),
          Text('Runtime: ${_formatRuntime(totalRuntimeMinutes)}'),
        ],
      ),
    );
  }
}
