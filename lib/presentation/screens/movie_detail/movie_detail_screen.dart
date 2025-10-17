import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/movie_detailed_model.dart';
import '../../../data/models/credit_model.dart';
import '../../../data/models/keyword_model.dart';
import '../../../data/models/video_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/movie_detail_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../../providers/watch_region_provider.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/rating_display.dart';
import '../../widgets/media_image.dart';
import '../../../core/utils/media_image_helper.dart';
import '../../../core/utils/media_image_helper.dart';
import '../../widgets/fullscreen_modal_scaffold.dart';

class MovieDetailScreen extends StatelessWidget {
  static const routeName = '/movie-detail';
  
  final Movie movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final repository = context.read<TmdbRepository>();

    return ChangeNotifierProvider(
      create: (_) => MovieDetailProvider(repository, movie)..load(),
      child: const _MovieDetailView(),
    );
  }
}

class _MovieDetailView extends StatelessWidget {
  const _MovieDetailView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieDetailProvider>();
    final loc = AppLocalizations.of(context);

    if (provider.isLoading && provider.details == null) {
      return FullscreenModalScaffold(
        title: Text(provider.initialMovie.title),
        body: const Center(child: LoadingIndicator()),
      );
    }

    if (provider.hasError && provider.details == null) {
      return FullscreenModalScaffold(
        title: Text(provider.initialMovie.title),
        body: Center(
          child: ErrorDisplay(
            message: provider.errorMessage ?? 'Failed to load movie details',
            onRetry: () => provider.load(forceRefresh: true),
          ),
        ),
      );
    }

    final details = provider.details;
    if (details == null) {
      return FullscreenModalScaffold(
        title: Text(provider.initialMovie.title),
        body: const Center(child: Text('No details available')),
      );
    }
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, details, loc),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, details, loc),
                _buildActions(context, details, loc),
                _buildOverview(context, details, loc),
                _buildMetadata(context, details, loc),
                _buildGenres(context, details, loc),
                _buildCast(context, details, loc),
                _buildCrew(context, details, loc),
                _buildVideos(context, details, loc),
                _buildKeywords(context, details, loc),
                _buildReviews(context, details, loc),
                _buildReleaseDates(context, details),
                _buildTranslations(context, details),
                _buildWatchProviders(context, details, loc),
                _buildExternalLinks(context, details, loc),
                if (details.collection != null) _buildCollection(context, details, loc),
                _buildRecommendations(context, details, loc),
                _buildSimilar(context, details, loc),
                _buildProductionInfo(context, details, loc),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    final backdropUrl = details.backdropUrl;
    
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      actions: [
        IconButton(
          tooltip: 'Share',
          icon: const Icon(Icons.share),
          onPressed: () {
            final url = details.homepage?.isNotEmpty == true
                ? details.homepage!
                : 'https://www.themoviedb.org/movie/${details.id}';
            Share.share('${details.title} — $url');
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          details.title,
          style: const TextStyle(
            shadows: [Shadow(color: Colors.black, blurRadius: 8)],
          ),
        ),
        background: backdropUrl != null && backdropUrl.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  MediaImage(
                    path: details.backdropPath,
                    type: MediaImageType.backdrop,
                    size: MediaImageSize.w780,
                    fit: BoxFit.cover,
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

  Widget _buildHeader(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    final posterUrl = details.posterUrl;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: MediaImage(
              path: details.posterPath,
              type: MediaImageType.poster,
              size: MediaImageSize.w500,
              width: 120,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Title and basic info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (details.tagline != null && details.tagline!.isNotEmpty) ...[
                Text(
                    details.tagline!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                ],
                if (details.releaseYear != null && details.releaseYear!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                  Text(
                        details.releaseYear!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (details.formattedRuntime != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          details.formattedRuntime!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ],
                  ),
                const SizedBox(height: 8),
                if (details.voteAverage > 0)
                  RatingDisplay(
                    rating: details.voteAverage,
                    voteCount: details.voteCount,
                    size: 18,
                  ),
                const SizedBox(height: 8),
                if (details.status != null)
                  Chip(
                    label: Text(details.status!),
                    avatar: Icon(
                      details.status == 'Released' ? Icons.check_circle : Icons.schedule,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final watchlistProvider = context.watch<WatchlistProvider>();
    
    final isFavorite = favoritesProvider.isFavorite(details.id);
    final isInWatchlist = watchlistProvider.isInWatchlist(details.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                favoritesProvider.toggleFavorite(details.id);
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
              ),
              label: Text(
                isFavorite ? loc.t('movie.remove_from_favorites') : loc.t('movie.add_to_favorites'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFavorite ? Colors.red.withOpacity(0.1) : null,
                foregroundColor: isFavorite ? Colors.red : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                watchlistProvider.toggleWatchlist(details.id);
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
              ),
              label: Text(
                isInWatchlist
                    ? loc.t('movie.remove_from_watchlist')
                    : loc.t('movie.add_to_watchlist'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isInWatchlist ? Colors.blue.withOpacity(0.1) : null,
                foregroundColor: isInWatchlist ? Colors.blue : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    if (details.overview == null || details.overview!.isEmpty) {
      return const SizedBox.shrink();
    }

    final provider = context.watch<MovieDetailProvider>();

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
            details.overview!,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: provider.isOverviewExpanded ? null : 4,
            overflow: provider.isOverviewExpanded ? null : TextOverflow.ellipsis,
          ),
          if (details.overview!.length > 200)
            TextButton(
              onPressed: provider.toggleOverview,
              child: Text(
                provider.isOverviewExpanded ? 'Show less' : 'Show more',
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    final metadata = <MapEntry<String, String>>[];

    if (details.formattedReleaseDate.isNotEmpty) {
      metadata.add(MapEntry(loc.t('movie.release_date'), details.formattedReleaseDate));
    }

    if (details.originalLanguage != null) {
      metadata.add(MapEntry('Original Language', details.originalLanguage!.toUpperCase()));
    }

    if (details.budget != null && details.budget! > 0) {
      metadata.add(MapEntry('Budget', details.formatCurrency(details.budget)));
    }

    if (details.revenue != null && details.revenue! > 0) {
      metadata.add(MapEntry('Revenue', details.formatCurrency(details.revenue)));
    }

    if (details.popularity != null) {
      metadata.add(MapEntry('Popularity', details.popularity!.toStringAsFixed(1)));
    }

    if (metadata.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
        ),
      ),
    );
  }

  Widget _buildGenres(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    if (details.genres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            children: details.genres.map((genre) {
              return Chip(
                label: Text(genre.name),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCast(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    if (details.cast.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayCast = details.cast.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Cast',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayCast.length,
            itemBuilder: (context, index) {
              final castMember = displayCast[index];
              return _CastCard(cast: castMember);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCrew(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    if (details.crew.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter important crew members (Director, Writer, Producer)
    final importantCrew = details.crew
        .where((member) =>
            member.job == 'Director' ||
            member.job == 'Writer' ||
            member.job == 'Screenplay' ||
            member.job == 'Producer' ||
            member.job == 'Executive Producer')
        .take(8)
        .toList();

    if (importantCrew.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crew',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ...importantCrew.map((member) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            member.job ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(member.name),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideos(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    if (details.videos.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter trailers and teasers
    final trailers = details.videos
        .where((video) => video.type == 'Trailer' || video.type == 'Teaser')
        .take(5)
        .toList();

    if (trailers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Videos & Trailers',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: trailers.length,
            itemBuilder: (context, index) {
              final video = trailers[index];
              return _VideoCard(video: video);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKeywords(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    if (details.keywords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Keywords',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: details.keywords.take(20).map((keyword) {
              return Chip(
                label: Text(keyword.name),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    if (details.reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Reviews',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...details.reviews.take(3).map((review) => _ReviewCard(review: review)),
      ],
    );
  }

  Widget _buildReleaseDates(BuildContext context, MovieDetailed details) {
    if (details.releaseDates.isEmpty) return const SizedBox.shrink();
    final region = context.watch<WatchRegionProvider>().region;
    final match = details.releaseDates.firstWhere(
      (r) => (r.countryCode ?? '').toUpperCase() == region.toUpperCase(),
      orElse: () => details.releaseDates.first,
    );
    final dates = match.releaseDates;
    if (dates == null || dates.isEmpty) return const SizedBox.shrink();

    final items = dates.take(3).map((d) {
      final label = d.note?.isNotEmpty == true ? d.note! : 'Type ${d.type ?? ''}';
      final dateStr = d.releaseDate?.split('T').first ?? '';
      final cert = (d.certification ?? '').isNotEmpty ? ' • ${d.certification}' : '';
      return '$dateStr • $label$cert';
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.event),
                  const SizedBox(width: 8),
                  Text(
                    'Release Dates ($region)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...items.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(e),
                  )),
            ],
          )),
      ),
    );
  }

  Widget _buildTranslations(BuildContext context, MovieDetailed details) {
    if (details.translations.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Translations',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: details.translations.take(24).map((t) {
              final code = t.iso6391?.toUpperCase() ?? '';
              final name = t.englishName?.isNotEmpty == true ? t.englishName! : t.name ?? code;
              return Chip(label: Text(name));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchProviders(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    if (!details.hasWatchProviders) {
      return const SizedBox.shrink();
    }

    final region = context.watch<WatchRegionProvider>().region;
    final providers = details.watchProviders[region] ?? details.watchProviders['US'];
    if (providers == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Where to Watch ($region)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  if ((providers.link ?? '').isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        final url = providers.link!;
                        final uri = Uri.parse(url);
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (providers.flatrate.isNotEmpty) ...[
                Text('Stream:', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: providers.flatrate
                      .map((provider) => _ProviderLogo(logoPath: provider.logoPath ?? ''))
                .toList(),
          ),
                const SizedBox(height: 12),
              ],
              if (providers.rent.isNotEmpty) ...[
                Text('Rent:', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: providers.rent
                      .map((provider) => _ProviderLogo(logoPath: provider.logoPath ?? ''))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              if (providers.buy.isNotEmpty) ...[
                Text('Buy:', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: providers.buy
                      .map((provider) => _ProviderLogo(logoPath: provider.logoPath ?? ''))
                      .toList(),
                ),
              ],
              if (providers.ads.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('With Ads:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: providers.ads
                      .map((provider) => _ProviderLogo(logoPath: provider.logoPath ?? ''))
                      .toList(),
                ),
              ],
              if (providers.free.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Free:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: providers.free
                      .map((provider) => _ProviderLogo(logoPath: provider.logoPath ?? ''))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExternalLinks(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    final links = <MapEntry<String, String>>[];

    if (details.homepage != null && details.homepage!.isNotEmpty) {
      links.add(MapEntry('Homepage', details.homepage!));
    }

    if (details.externalIds.imdbId != null) {
      links.add(MapEntry(
        'IMDb',
        'https://www.imdb.com/title/${details.externalIds.imdbId}',
      ));
    }

    if (details.externalIds.facebookId != null) {
      links.add(MapEntry(
        'Facebook',
        'https://www.facebook.com/${details.externalIds.facebookId}',
      ));
    }

    if (details.externalIds.twitterId != null) {
      links.add(MapEntry(
        'Twitter',
        'https://twitter.com/${details.externalIds.twitterId}',
      ));
    }

    if (details.externalIds.instagramId != null) {
      links.add(MapEntry(
        'Instagram',
        'https://www.instagram.com/${details.externalIds.instagramId}',
      ));
    }

    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
                'External Links',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
                children: links.map((link) {
                  return OutlinedButton.icon(
                    onPressed: () => _launchURL(link.value),
                    icon: Icon(_getIconForLink(link.key)),
                    label: Text(link.key),
              );
            }).toList(),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollection(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    final collection = details.collection!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to collection details
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (collection.backdropPath != null)
                MediaImage(
                  path: collection.backdropPath,
                  type: MediaImageType.backdrop,
                  size: MediaImageSize.w780,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Part of Collection',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      collection.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    // Overview not available on basic Collection; omit
                    if (false) ...[
                      const SizedBox(height: 8),
                      SizedBox.shrink(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    if (details.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recommended Movies',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: details.recommendations.take(10).length,
            itemBuilder: (context, index) {
              final movie = details.recommendations[index];
              return SizedBox(
                width: 140,
                child: MovieCard(
                  id: movie.id,
                  title: movie.title,
                  posterPath: movie.posterPath,
                  voteAverage: movie.voteAverage,
                  releaseDate: movie.releaseDate,
                  onTap: () {
                    // Navigate to movie details
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(
                          movie: Movie(
                            id: movie.id,
                            title: movie.title,
                            posterPath: movie.posterPath,
                            backdropPath: movie.backdropPath,
                            voteAverage: movie.voteAverage,
                            voteCount: 0,
                            releaseDate: movie.releaseDate,
                            genreIds: [],
                          ),
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSimilar(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    if (details.similar.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Similar Movies',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: details.similar.take(10).length,
            itemBuilder: (context, index) {
              final movie = details.similar[index];
              return SizedBox(
                width: 140,
                child: MovieCard(
                  id: movie.id,
                  title: movie.title,
                  posterPath: movie.posterPath,
                  voteAverage: movie.voteAverage,
                  releaseDate: movie.releaseDate,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(
                          movie: Movie(
                            id: movie.id,
                            title: movie.title,
                            posterPath: movie.posterPath,
                            backdropPath: movie.backdropPath,
                            voteAverage: movie.voteAverage,
                            voteCount: 0,
                            releaseDate: movie.releaseDate,
                            genreIds: [],
                          ),
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductionInfo(BuildContext context, MovieDetailed details, AppLocalizations loc) {
    if (details.productionCompanies.isEmpty && details.productionCountries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Production',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              if (details.productionCompanies.isNotEmpty) ...[
                Text(
                  'Companies:',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: details.productionCompanies.map((company) {
                    if ((company.logoPath ?? '').isNotEmpty) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: MediaImage(
                          path: company.logoPath,
                          type: MediaImageType.logo,
                          size: MediaImageSize.w92,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      );
                    }
                    return Chip(label: Text(company.name));
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              if (details.productionCountries.isNotEmpty) ...[
                Text(
                  'Countries:',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  details.productionCountries.map((c) => c.name).join(', '),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  IconData _getIconForLink(String linkName) {
    switch (linkName.toLowerCase()) {
      case 'homepage':
        return Icons.language;
      case 'imdb':
        return Icons.movie;
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
        return Icons.tag;
      case 'instagram':
        return Icons.photo_camera;
      default:
        return Icons.link;
    }
  }
}

class _CastCard extends StatelessWidget {
  final Cast cast;

  const _CastCard({required this.cast});

  @override
  Widget build(BuildContext context) {
    final profileUrl = cast.profilePath;

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: MediaImage(
              path: profileUrl,
              type: MediaImageType.profile,
              size: MediaImageSize.w185,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cast.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (cast.character != null)
            Text(
              cast.character!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final Video video;

  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = video.site == 'YouTube'
        ? 'https://img.youtube.com/vi/${video.key}/mqdefault.jpg'
        : null;

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _launchVideo(video),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (thumbnailUrl != null)
                    CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      width: 240,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      width: 240,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.play_circle_outline, size: 48),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              video.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _launchVideo(Video video) async {
    if (video.site == 'YouTube') {
      final url = 'https://www.youtube.com/watch?v=${video.key}';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.author,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (review.authorDetails?.rating != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${review.authorDetails!.rating!.toStringAsFixed(1)} ⭐',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Review by ${review.author}'),
                      content: SingleChildScrollView(
                        child: Text(review.content),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Read Full Review'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderLogo extends StatelessWidget {
  final String logoPath;

  const _ProviderLogo({required this.logoPath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: MediaImage(
        path: logoPath,
        type: MediaImageType.logo,
        size: MediaImageSize.w92,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      ),
    );
  }
}
