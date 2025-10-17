import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/movie_detailed_model.dart';
import '../../../data/services/api_config.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/rating_display.dart';
import '../company_detail/company_detail_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  static const routeName = '/movie-detail';

  final Movie movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<MovieDetailed> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  Future<MovieDetailed> _loadDetails({bool forceRefresh = false}) {
    return context.read<TmdbRepository>().fetchMovieDetails(
          widget.movie.id,
          forceRefresh: forceRefresh,
        );
  }

  Future<void> _refreshDetails() async {
    final future = _loadDetails(forceRefresh: true);
    setState(() {
      _detailsFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: FutureBuilder<MovieDetailed>(
              future: _detailsFuture,
              builder: (context, snapshot) {
                final details = snapshot.data;
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;
                final error = snapshot.hasError ? snapshot.error : null;

                final children = <Widget>[
                  _buildHeader(context),
                  _buildActions(context, loc),
                  _buildOverview(context, loc),
                  _buildMetadata(context, loc, details),
                  _buildGenres(context, loc, details),
                ];

                if (isLoading && details == null) {
                  children.add(
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                } else if (error != null && details == null) {
                  children.add(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _DetailError(onRetry: _refreshDetails),
                    ),
                  );
                } else {
                  if (isLoading && details != null) {
                    children.add(
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    );
                    children.add(const SizedBox(height: 16));
                  }

                  if (details != null) {
                    children.add(_buildProductionCompanies(context, loc, details));
                  }
                }

                children.add(const SizedBox(height: 24));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final backdropUrl = widget.movie.backdropUrl;

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

  Widget _buildHeader(BuildContext context) {
    final posterUrl = widget.movie.posterUrl;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.movie.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (widget.movie.releaseYear != null &&
                    widget.movie.releaseYear!.isNotEmpty)
                  Text(
                    widget.movie.releaseYear!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                const SizedBox(height: 8),
                if (widget.movie.voteAverage != null &&
                    widget.movie.voteAverage! > 0)
                  RatingDisplay(
                    rating: widget.movie.voteAverage!,
                    voteCount: widget.movie.voteCount,
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

    final isFavorite = favoritesProvider.isFavorite(widget.movie.id);
    final isInWatchlist = watchlistProvider.isInWatchlist(widget.movie.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                favoritesProvider.toggleFavorite(widget.movie.id);
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
                watchlistProvider.toggleWatchlist(widget.movie.id);
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
    if (widget.movie.overview == null || widget.movie.overview!.isEmpty) {
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
            widget.movie.overview!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailed? details,
  ) {
    final metadata = <MapEntry<String, String>>[];

    final releaseDate = details?.releaseDate ?? widget.movie.releaseDate;
    if (releaseDate != null && releaseDate.isNotEmpty) {
      metadata.add(MapEntry(
        loc.t('movie.release_date'),
        releaseDate,
      ));
    }

    final runtime = details?.runtime;
    if (runtime != null && runtime > 0) {
      metadata.add(MapEntry(
        loc.t('movie.runtime'),
        '$runtime ${loc.t('movie.minutes')}',
      ));
    }

    final voteCount = details?.voteCount ?? widget.movie.voteCount;
    if (voteCount != null && voteCount > 0) {
      metadata.add(MapEntry(
        loc.t('movie.votes'),
        voteCount.toString(),
      ));
    }

    if (details?.status != null && details!.status!.isNotEmpty) {
      metadata.add(MapEntry(
        loc.t('movie.status'),
        details.status!,
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
          ...metadata.map(
            (entry) => Padding(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenres(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailed? details,
  ) {
    final genreNames = details != null
        ? details.genres.map((genre) => genre.name).toList()
        : widget.movie.genres;

    if (genreNames.isEmpty) {
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
            children: genreNames
                .map(
                  (name) => Chip(
                    label: Text(name),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionCompanies(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailed details,
  ) {
    final companies = details.productionCompanies;
    if (companies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('movie.production_companies'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: companies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final company = companies[index];
                return _ProductionCompanyCard(company: company);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductionCompanyCard extends StatelessWidget {
  const _ProductionCompanyCard({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoUrl = ApiConfig.getLogoUrl(company.logoPath);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          CompanyDetailScreen.routeName,
          arguments: company,
        );
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.2),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
              child: logoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: logoUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.business_outlined,
                        color: theme.colorScheme.primary,
                        size: 36,
                      ),
                    )
                  : Icon(
                      Icons.business_outlined,
                      color: theme.colorScheme.primary,
                      size: 36,
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              company.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (company.originCountry != null &&
                company.originCountry!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                company.originCountry!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Failed to load movie details.',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            onRetry();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}
