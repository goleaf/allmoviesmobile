import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/tv_detailed_model.dart';
import '../../../data/services/api_config.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/rating_display.dart';

class TVDetailScreen extends StatefulWidget {
  static const routeName = '/tv-detail';

  final Movie tvShow;

  const TVDetailScreen({
    super.key,
    required this.tvShow,
  });

  @override
  State<TVDetailScreen> createState() => _TVDetailScreenState();
}

class _TVDetailScreenState extends State<TVDetailScreen> {
  TVDetailed? _details;
  bool _isLoadingDetails = false;
  String? _detailsError;

  Movie get tvShow => widget.tvShow;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadDetails);
  }

  Future<void> _loadDetails({bool forceRefresh = false}) async {
    final repository = context.read<TmdbRepository>();

    setState(() {
      _isLoadingDetails = true;
      _detailsError = null;
    });

    try {
      final details = await repository.fetchTvDetails(
        tvShow.id,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _details = details;
        _isLoadingDetails = false;
        _detailsError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _details = null;
        _isLoadingDetails = false;
        _detailsError = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, loc),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, loc),
                _buildActions(context, loc),
                _buildOverview(context, loc),
                _buildMetadata(context, loc),
                _buildGenres(context, loc),
                _buildGuestStarsSection(context, loc),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations loc) {
    final backdropUrl = tvShow.backdropUrl;
    
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: backdropUrl != null && backdropUrl.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: backdropUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 64),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.tv, size: 64),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations loc) {
    final posterUrl = tvShow.posterUrl;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: posterUrl != null && posterUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: posterUrl,
                    width: 120,
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 120,
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 120,
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  )
                : Container(
                    width: 120,
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.tv),
                  ),
          ),
          const SizedBox(width: 16),
          // Title and basic info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tvShow.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tv,
                        size: 14,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'TV Series',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (tvShow.releaseYear != null && tvShow.releaseYear!.isNotEmpty)
                  Text(
                    '${loc.t('tv.first_aired')}: ${tvShow.releaseYear}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                const SizedBox(height: 8),
                if (tvShow.voteAverage != null && tvShow.voteAverage! > 0)
                  RatingDisplay(
                    rating: tvShow.voteAverage!,
                    voteCount: tvShow.voteCount,
                    size: 18,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations loc) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final watchlistProvider = context.watch<WatchlistProvider>();
    
    final isFavorite = favoritesProvider.isFavorite(tvShow.id);
    final isInWatchlist = watchlistProvider.isInWatchlist(tvShow.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                favoritesProvider.toggleFavorite(tvShow.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFavorite
                          ? loc.t('favorites.removed')
                          : loc.t('favorites.added'),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              label: Text(
                isFavorite
                    ? loc.t('tv.remove_from_favorites')
                    : loc.t('tv.add_to_favorites'),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                watchlistProvider.toggleWatchlist(tvShow.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isInWatchlist
                          ? loc.t('watchlist.removed')
                          : loc.t('watchlist.added'),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                color: isInWatchlist ? Colors.blue : null,
              ),
              label: Text(
                isInWatchlist
                    ? loc.t('tv.remove_from_watchlist')
                    : loc.t('tv.add_to_watchlist'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(BuildContext context, AppLocalizations loc) {
    if (tvShow.overview == null || tvShow.overview!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('tv.overview'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            tvShow.overview!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, AppLocalizations loc) {
    final metadata = <MapEntry<String, String>>[];

    if (tvShow.releaseDate != null && tvShow.releaseDate!.isNotEmpty) {
      metadata.add(MapEntry(
        loc.t('tv.first_air_date'),
        tvShow.releaseDate!,
      ));
    }

    if (tvShow.voteCount != null && tvShow.voteCount! > 0) {
      metadata.add(MapEntry(
        loc.t('tv.votes'),
        tvShow.voteCount.toString(),
      ));
    }

    if (tvShow.popularity != null) {
      metadata.add(MapEntry(
        loc.t('tv.popularity'),
        tvShow.popularity!.toStringAsFixed(0),
      ));
    }

    if (metadata.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...metadata.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(entry.value),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGenres(BuildContext context, AppLocalizations loc) {
    if (tvShow.genreIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('tv.genres'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tvShow.genreIds.map((genreId) {
              // Get genre name from Movie.genreMap
              final genreName = Movie.genreMap[genreId] ?? 'Genre $genreId';
              return Chip(
                label: Text(genreName),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestStarsSection(
    BuildContext context,
    AppLocalizations loc,
  ) {
    if (_isLoadingDetails) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_detailsError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.t('tv.guest_stars'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _detailsError!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _loadDetails(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: Text(loc.t('common.retry')),
            ),
          ],
        ),
      );
    }

    final details = _details;
    if (details == null || details.cast.isEmpty) {
      return const SizedBox.shrink();
    }

    final guestStars = details.cast.take(12).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('tv.guest_stars'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: guestStars.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final guest = guestStars[index];
                final profileUrl = ApiConfig.getProfileUrl(
                  guest.profilePath,
                  size: ApiConfig.profileSizeLarge,
                );

                return SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 2 / 3,
                          child: profileUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: profileUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.person),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.person),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        guest.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (guest.character != null && guest.character!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          guest.character!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

