import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/paginated_response.dart';
import '../../../data/models/review_model.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/rating_display.dart';

class MovieDetailScreen extends StatelessWidget {
  static const routeName = '/movie-detail';
  
  final Movie movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

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
                const SizedBox(height: 24),
                _MovieReviewsSection(movieId: movie.id),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations loc) {
    final backdropUrl = movie.backdropUrl;
    
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
                child: const Icon(Icons.movie, size: 64),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations loc) {
    final posterUrl = movie.posterUrl;
    
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
                    child: const Icon(Icons.movie),
                  ),
          ),
          const SizedBox(width: 16),
          // Title and basic info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (movie.releaseYear != null && movie.releaseYear!.isNotEmpty)
                  Text(
                    movie.releaseYear!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                const SizedBox(height: 8),
                if (movie.voteAverage != null && movie.voteAverage! > 0)
                  RatingDisplay(
                    rating: movie.voteAverage!,
                    voteCount: movie.voteCount,
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
    
    final isFavorite = favoritesProvider.isFavorite(movie.id);
    final isInWatchlist = watchlistProvider.isInWatchlist(movie.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                favoritesProvider.toggleFavorite(movie.id);
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
                    ? loc.t('movie.remove_from_favorites')
                    : loc.t('movie.add_to_favorites'),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                watchlistProvider.toggleWatchlist(movie.id);
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
                    ? loc.t('movie.remove_from_watchlist')
                    : loc.t('movie.add_to_watchlist'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(BuildContext context, AppLocalizations loc) {
    if (movie.overview == null || movie.overview!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('movie.overview'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.overview!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, AppLocalizations loc) {
    final metadata = <MapEntry<String, String>>[];

    if (movie.releaseDate != null && movie.releaseDate!.isNotEmpty) {
      metadata.add(MapEntry(
        loc.t('movie.release_date'),
        movie.releaseDate!,
      ));
    }

    if (movie.runtime != null && movie.runtime! > 0) {
      metadata.add(MapEntry(
        loc.t('movie.runtime'),
        '${movie.runtime} ${loc.t('movie.minutes')}',
      ));
    }

    if (movie.voteCount != null && movie.voteCount! > 0) {
      metadata.add(MapEntry(
        loc.t('movie.votes'),
        movie.voteCount.toString(),
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
    if (movie.genreIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('movie.genres'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: movie.genreIds.map((genreId) {
              // TODO: Get genre name from GenresProvider
              return Chip(
                label: Text('Genre $genreId'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MovieReviewsSection extends StatefulWidget {
  const _MovieReviewsSection({
    required this.movieId,
  });

  final int movieId;

  @override
  State<_MovieReviewsSection> createState() => _MovieReviewsSectionState();
}

class _MovieReviewsSectionState extends State<_MovieReviewsSection> {
  late Future<PaginatedResponse<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _loadReviews();
  }

  Future<PaginatedResponse<Review>> _loadReviews({bool forceRefresh = false}) {
    final repository = context.read<TmdbRepository>();
    return repository.fetchMovieReviews(
      widget.movieId,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _retry() async {
    setState(() {
      _reviewsFuture = _loadReviews(forceRefresh: true);
    });
    await _reviewsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('movie.user_reviews'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<PaginatedResponse<Review>>(
            future: _reviewsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              }

              if (snapshot.hasError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.t('movie.user_reviews_error'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: Text(loc.t('common.retry')),
                    ),
                  ],
                );
              }

              final reviews = snapshot.data?.results ?? const <Review>[];
              if (reviews.isEmpty) {
                return Text(
                  loc.t('movie.user_reviews_empty'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                );
              }

              final visibleReviews = reviews.take(3).toList(growable: false);

              return Column(
                children: [
                  for (final review in visibleReviews) ...[
                    _ReviewCard(review: review),
                    const SizedBox(height: 12),
                  ],
                  if (reviews.length > visibleReviews.length)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        loc.t('movie.user_reviews_more_available'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
  });

  final Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final author = review.authorDetails;
    final displayName = author.name.trim().isNotEmpty
        ? author.name
        : (author.username.trim().isNotEmpty ? author.username : review.author);
    final avatarUrl = _resolveAvatarUrl(author.avatarPath);
    final createdAt = DateTime.tryParse(review.createdAt);
    final formattedDate = createdAt != null
        ? DateFormat.yMMMd().format(createdAt)
        : loc.t('common.unknown');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AvatarThumbnail(avatarUrl: avatarUrl, name: displayName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                      if (author.rating != null) ...[
                        const SizedBox(height: 8),
                        RatingStars(
                          rating: author.rating!.clamp(0, 10).toDouble(),
                          size: 18,
                          color: theme.colorScheme.secondary,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.content.trim(),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String? _resolveAvatarUrl(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }
    final trimmed = path.trim();
    if (trimmed.startsWith('http')) {
      return trimmed.startsWith('/http') ? trimmed.substring(1) : trimmed;
    }
    return 'https://image.tmdb.org/t/p/w185$trimmed';
  }
}

class _AvatarThumbnail extends StatelessWidget {
  const _AvatarThumbnail({
    required this.avatarUrl,
    required this.name,
  });

  final String? avatarUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = _computeInitials(name);

    if (avatarUrl == null) {
      return CircleAvatar(
        radius: 24,
        child: Text(
          initials,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundImage: NetworkImage(avatarUrl!),
      backgroundColor: Colors.grey[200],
    );
  }

  String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '?';
    }

    String firstInitial = '';
    String secondInitial = '';

    if (parts.first.isNotEmpty) {
      firstInitial = parts.first[0];
    }

    if (parts.length > 1 && parts.last.isNotEmpty) {
      secondInitial = parts.last[0];
    } else if (parts.first.length > 1) {
      secondInitial = parts.first[1];
    }

    final combined = (firstInitial + secondInitial).toUpperCase();
    return combined.isNotEmpty ? combined : '?';
  }
}
