import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/tv_detailed_model.dart';
import '../../../data/services/api_config.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/rating_display.dart';
import '../search/search_screen.dart';

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
  late Future<TVDetailed> _tvFuture;
  bool _isOverviewExpanded = false;

  @override
  void initState() {
    super.initState();
    _tvFuture = _fetchTvDetails();
  }

  Future<TVDetailed> _fetchTvDetails({bool forceRefresh = false}) {
    final repository = context.read<TmdbRepository>();
    return repository.fetchTvDetails(
      widget.tvShow.id,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: FutureBuilder<TVDetailed>(
        future: _tvFuture,
        builder: (context, snapshot) {
          final details = snapshot.data;

          if (snapshot.hasError) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(context, loc, details),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorState(
                    message: loc.t('errors.load_failed'),
                    onRetry: () {
                      setState(() {
                        _tvFuture = _fetchTvDetails(forceRefresh: true);
                      });
                    },
                  ),
                ),
              ],
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, loc, details),
              if (details == null)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: LoadingIndicator()),
                )
              else
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, loc, details),
                      _buildActions(context, loc),
                      _buildOverview(context, loc, details),
                      _buildQuickFacts(context, loc, details),
                      _buildGenres(context, loc, details),
                      _buildProductionCountries(context, loc, details),
                      _buildSpokenLanguages(context, loc, details),
                      _buildNetworks(context, loc, details),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed? details,
  ) {
    final fallbackBackdrop = widget.tvShow.backdropUrl;
    final backdropUrl = details != null
        ? ApiConfig.getBackdropUrl(
            details.backdropPath,
            size: ApiConfig.backdropSizeLarge,
          )
        : fallbackBackdrop;
    final posterUrl = details != null
        ? ApiConfig.getPosterUrl(
            details.posterPath,
            size: ApiConfig.posterSizeLarge,
          )
        : widget.tvShow.posterUrl;

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(details?.name ?? widget.tvShow.title),
      flexibleSpace: FlexibleSpaceBar(
        title: const SizedBox.shrink(),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (backdropUrl != null && backdropUrl.isNotEmpty)
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
              )
            else
              Container(
                color: Colors.grey[300],
                child: const Icon(Icons.tv, size: 64),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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
                                child:
                                    const Center(child: CircularProgressIndicator()),
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
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.tv, size: 48),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          details?.name ?? widget.tvShow.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed details,
  ) {
    final theme = Theme.of(context);
    final rating = details.voteAverage;
    final voteCount = details.voteCount;
    final tagline = details.tagline;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tagline != null && tagline.isNotEmpty) ...[
            Text(
              tagline,
              style: theme.textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            details.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (rating > 0)
            RatingDisplay(
              rating: rating,
              voteCount: voteCount,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations loc) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final watchlistProvider = context.watch<WatchlistProvider>();

    final isFavorite = favoritesProvider.isFavorite(widget.tvShow.id);
    final isInWatchlist = watchlistProvider.isInWatchlist(widget.tvShow.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                favoritesProvider.toggleFavorite(widget.tvShow.id);
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
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                watchlistProvider.toggleWatchlist(widget.tvShow.id);
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

  Widget _buildOverview(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed details,
  ) {
    final overview = details.overview?.trim().isNotEmpty == true
        ? details.overview!.trim()
        : widget.tvShow.overview;

    if (overview == null || overview.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isOverviewExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              overview,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            secondChild: Text(
              overview,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isOverviewExpanded = !_isOverviewExpanded;
                });
              },
              icon: Icon(
                _isOverviewExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              label: Text(
                _isOverviewExpanded
                    ? loc.t('common.show_less')
                    : loc.t('common.show_more'),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuickFacts(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed details,
  ) {
    final dateFormatter = DateFormat.yMMMMd();

    String? formatDate(String? value) {
      if (value == null || value.isEmpty) return null;
      try {
        return dateFormatter.format(DateTime.parse(value));
      } catch (_) {
        return value;
      }
    }

    String? formatRuntime(List<int> runtimes) {
      final valid = runtimes.where((element) => element > 0).toList();
      if (valid.isEmpty) return null;
      if (valid.length == 1) {
        return '${valid.first} ${loc.t('movie.minutes')}';
      }

      final min = valid.reduce((a, b) => a < b ? a : b);
      final max = valid.reduce((a, b) => a > b ? a : b);
      if (min == max) {
        return '$min ${loc.t('movie.minutes')}';
      }
      return '$min–$max ${loc.t('movie.minutes')}';
    }

    String? formatOriginalLanguage() {
      final originalIso = widget.tvShow.originalLanguage;
      if (originalIso == null || originalIso.isEmpty) {
        return null;
      }

      if (details.spokenLanguages.isEmpty) {
        return originalIso.toUpperCase();
      }

      final matchingLanguage = details.spokenLanguages.firstWhere(
        (language) =>
            language.iso6391.toLowerCase() == originalIso.toLowerCase(),
        orElse: () => details.spokenLanguages.first,
      );

      final languageName = matchingLanguage.name.trim();
      if (languageName.isEmpty) {
        return originalIso.toUpperCase();
      }

      return '${originalIso.toUpperCase()} • $languageName';
    }

    final infoItems = <_InfoItem>[
      _InfoItem(
        label: loc.t('tv.first_air_date'),
        value: formatDate(details.firstAirDate) ??
            (widget.tvShow.releaseDate ?? loc.t('common.not_available')),
      ),
      if (details.lastAirDate != null && details.lastAirDate!.isNotEmpty)
        _InfoItem(
          label: loc.t('tv.last_air_date'),
          value: formatDate(details.lastAirDate),
        ),
      if (formatRuntime(details.episodeRunTime) != null)
        _InfoItem(
          label: loc.t('tv.episode_runtime'),
          value: formatRuntime(details.episodeRunTime),
        ),
      if (details.numberOfSeasons != null)
        _InfoItem(
          label: loc.t('tv.number_of_seasons'),
          value: details.numberOfSeasons.toString(),
        ),
      if (details.numberOfEpisodes != null)
        _InfoItem(
          label: loc.t('tv.number_of_episodes'),
          value: details.numberOfEpisodes.toString(),
        ),
      if ((details.status ?? '').isNotEmpty)
        _InfoItem(
          label: loc.t('tv.status'),
          value: details.status!,
        ),
      if (formatOriginalLanguage() != null)
        _InfoItem(
          label: loc.t('tv.original_language'),
          value: formatOriginalLanguage(),
        ),
      if (details.originalName.isNotEmpty &&
          details.originalName != widget.tvShow.title)
        _InfoItem(
          label: loc.t('tv.original_name'),
          value: details.originalName,
        ),
    ];

    if (infoItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('tv.details'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...infoItems.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 160,
                    child: Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value ?? loc.t('common.not_available'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGenres(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed details,
  ) {
    if (details.genres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            children: details.genres
                .map(
                  (genre) => ActionChip(
                    label: Text(genre.name),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(
                            initialQuery: genre.name,
                          ),
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProductionCountries(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed details,
  ) {
    if (details.productionCountries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('tv.production_countries'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: details.productionCountries
                .map(
                  (country) => Chip(
                    label: Text('${country.name} (${country.iso31661})'),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSpokenLanguages(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed details,
  ) {
    if (details.spokenLanguages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('tv.spoken_languages'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: details.spokenLanguages
                .map(
                  (language) => Chip(
                    label: Text('${language.name} (${language.iso6391.toUpperCase()})'),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNetworks(
    BuildContext context,
    AppLocalizations loc,
    TVDetailed details,
  ) {
    if (details.networks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('tv.networks'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: details.networks.map((network) {
                final logoUrl = network.logoPath != null
                    ? '${ApiConfig.tmdbImageBaseUrl}/w300${network.logoPath}'
                    : null;

                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Container(
                        height: 70,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: logoUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: logoUrl,
                                  fit: BoxFit.contain,
                                  errorWidget: (context, url, error) => Center(
                                    child: Text(
                                      network.name,
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    network.name,
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        network.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (network.originCountry != null &&
                          network.originCountry!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          network.originCountry!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem({required this.label, this.value});

  final String label;
  final String? value;
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).t('common.retry')),
            ),
          ],
        ),
      ),
    );
  }
}

