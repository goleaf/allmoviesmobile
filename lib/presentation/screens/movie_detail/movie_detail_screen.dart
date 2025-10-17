import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/certification_model.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/credit_model.dart';
import '../../../data/models/keyword_model.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/movie_detailed_model.dart';
import '../../../data/models/movie_ref_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/image_model.dart';
import '../../../data/models/alternative_title_model.dart';
import '../../../data/models/translation_model.dart';
import '../../../data/models/video_model.dart';
import '../../../data/models/watch_provider_model.dart';
import '../../../data/services/api_config.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/movie_detail_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/rating_display.dart';

class MovieDetailScreen extends StatelessWidget {
  static const routeName = '/movie-detail';

  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MovieDetailProvider>(
      create: (context) =>
          MovieDetailProvider(context.read<TmdbRepository>(), movie)..load(),
      child: const _MovieDetailView(),
    );
  }
}

class _MovieDetailView extends StatelessWidget {
  const _MovieDetailView();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<MovieDetailProvider>();
    final details = provider.details;
    final movie = provider.initialMovie;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => provider.load(forceRefresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(context, loc, movie, details),
            SliverToBoxAdapter(
              child: _buildBody(context, loc, provider, movie, details),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(
    BuildContext context,
    AppLocalizations loc,
    Movie movie,
    MovieDetailed? details,
  ) {
    final backdropUrl = details?.backdropUrl ?? movie.backdropUrl;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: loc.t('share'),
          onPressed: () => _shareMovie(context, movie, details),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.movie, size: 96),
              ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailProvider provider,
    Movie movie,
    MovieDetailed? details,
  ) {
    if (provider.isLoading && details == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 120),
        child: Center(child: LoadingIndicator()),
      );
    }

    if (provider.hasError && details == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.t('error_generic_title'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(provider.errorMessage ?? loc.t('error_generic_message')),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.load(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: Text(loc.t('actions.retry')),
            ),
          ],
        ),
      );
    }

    final children = <Widget>[];
    _addSection(children, _buildHeader(context, loc, provider, movie, details));
    _addSection(
      children,
      _buildActions(context, loc, provider, movie, details),
    );
    _addSection(
      children,
      _buildOverview(context, loc, provider, movie, details),
    );

    if (details != null) {
      _addSection(children, _buildFacts(context, loc, details));
      _addSection(children, _buildGenres(context, loc, movie, details));
      _addSection(children, _buildKeywords(context, loc, details.keywords));
      _addSection(children, _buildCountriesLanguages(context, loc, details));
      _addSection(children, _buildProductionCompanies(context, details));
      _addSection(children, _buildCastSection(context, loc, details.cast));
      _addSection(children, _buildCrewSection(context, loc, details.crew));
      _addSection(children, _buildVideosSection(context, loc, details.videos));
      _addSection(
        children,
        _buildImageGalleries(
          context,
          loc,
          backdrops: details.imageBackdrops,
          posters: details.imagePosters,
          profiles: details.imageProfiles,
        ),
      );
      _addSection(
        children,
        _buildReviewsSection(context, loc, details.reviews),
      );
      _addSection(children, _buildCollectionSection(context, loc, details));
      _addSection(
        children,
        _buildRecommendations(context, loc, details.recommendations),
      );
      _addSection(children, _buildSimilar(context, loc, details.similar));
      _addSection(
        children,
        _buildWatchProvidersSection(context, loc, details.watchProviders),
      );
      _addSection(children, _buildExternalLinks(context, loc, details));
      _addSection(
        children,
        _buildAlternativeTitles(context, loc, details.alternativeTitles),
      );
      _addSection(
        children,
        _buildReleaseDates(context, loc, details.releaseDates),
      );
      _addSection(
        children,
        _buildTranslations(context, loc, details.translations),
      );
    }

    children.add(const SizedBox(height: 32));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.isLoading && details != null) ...[
            const LinearProgressIndicator(minHeight: 2),
            const SizedBox(height: 16),
          ],
          ...children,
        ],
      ),
    );
  }

  void _addSection(List<Widget> children, Widget? section) {
    if (section == null) return;
    if (children.isNotEmpty) {
      children.add(const SizedBox(height: 24));
    }
    children.add(section);
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailProvider provider,
    Movie movie,
    MovieDetailed? details,
  ) {
    final posterUrl = details?.posterUrl ?? movie.posterUrl;
    final title = details?.title ?? movie.title;
    final tagline = details?.tagline;
    final releaseYear = details?.releaseYear ?? movie.releaseYear;
    final runtime = details?.formattedRuntime;
    final rating = details?.voteAverage ?? movie.voteAverage ?? 0;
    final voteCount = details?.voteCount ?? movie.voteCount ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: posterUrl != null && posterUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: posterUrl,
                  width: 140,
                  height: 210,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 140,
                    height: 210,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 140,
                    height: 210,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  ),
                )
              : Container(
                  width: 140,
                  height: 210,
                  color: Colors.grey[300],
                  child: const Icon(Icons.movie, size: 48),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (tagline != null && tagline.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  tagline,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (releaseYear != null)
                    _InfoChip(icon: Icons.event, label: releaseYear),
                  if (runtime != null)
                    _InfoChip(icon: Icons.access_time, label: runtime),
                  if (details?.status != null && details!.status!.isNotEmpty)
                    _InfoChip(icon: Icons.movie_filter, label: details.status!),
                ],
              ),
              const SizedBox(height: 16),
              RatingDisplay(rating: rating, voteCount: voteCount, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailProvider provider,
    Movie movie,
    MovieDetailed? details,
  ) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final watchlistProvider = context.watch<WatchlistProvider>();

    final isFavorite = favoritesProvider.isFavorite(movie.id);
    final isInWatchlist = watchlistProvider.isInWatchlist(movie.id);

    return Row(
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
        const SizedBox(width: 12),
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
        const SizedBox(width: 12),
        IconButton.filledTonal(
          onPressed: () => _shareMovie(context, movie, details),
          icon: const Icon(Icons.share),
          tooltip: loc.t('share'),
        ),
      ],
    );
  }

  Widget? _buildOverview(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailProvider provider,
    Movie movie,
    MovieDetailed? details,
  ) {
    final overview = details?.overview ?? movie.overview;
    if (overview == null || overview.isEmpty) {
      return null;
    }

    final isExpanded = provider.isOverviewExpanded;
    final maxLines = isExpanded ? null : 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.overview')),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: Text(
            overview,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(overview),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: provider.toggleOverview,
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            label: Text(
              isExpanded
                  ? loc.t('actions.show_less')
                  : loc.t('actions.show_more'),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildFacts(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailed details,
  ) {
    final facts = <MapEntry<String, String>>[];

    if (details.releaseDate != null && details.releaseDate!.isNotEmpty) {
      facts.add(
        MapEntry(loc.t('movie.release_date'), details.formattedReleaseDate),
      );
    }
    if (details.formattedRuntime != null) {
      facts.add(MapEntry(loc.t('movie.runtime'), details.formattedRuntime!));
    }
    if (details.status != null && details.status!.isNotEmpty) {
      facts.add(MapEntry(loc.t('movie.status'), details.status!));
    }
    if (details.originalLanguage != null &&
        details.originalLanguage!.isNotEmpty) {
      facts.add(
        MapEntry(
          loc.t('movie.original_language'),
          details.originalLanguage!.toUpperCase(),
        ),
      );
    }
    if (details.originalTitle.isNotEmpty &&
        details.originalTitle.toLowerCase() != details.title.toLowerCase()) {
      facts.add(MapEntry(loc.t('movie.original_title'), details.originalTitle));
    }
    facts.add(
      MapEntry(loc.t('movie.budget'), details.formatCurrency(details.budget)),
    );
    facts.add(
      MapEntry(loc.t('movie.revenue'), details.formatCurrency(details.revenue)),
    );

    if (facts.isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.details')),
        const SizedBox(height: 12),
        ...facts.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(child: Text(entry.value)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildGenres(
    BuildContext context,
    AppLocalizations loc,
    Movie movie,
    MovieDetailed? details,
  ) {
    final genreNames = details?.genreNames ?? movie.genres;
    if (genreNames.isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.genres')),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genreNames
              .map(
                (genre) => ActionChip(
                  label: Text(genre),
                  onPressed: () {
                    final message = loc
                        .t('movie.genre_filter_unavailable')
                        .replaceFirst('{0}', genre);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget? _buildKeywords(
    BuildContext context,
    AppLocalizations loc,
    List<Keyword> keywords,
  ) {
    if (keywords.isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.keywords')),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keywords
              .map((keyword) => Chip(label: Text('#${keyword.name}')))
              .toList(),
        ),
      ],
    );
  }

  Widget? _buildCountriesLanguages(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailed details,
  ) {
    final countries = details.productionCountries.map((c) => c.name).toList();
    final languages = details.spokenLanguages.map((l) => l.name).toList();

    if (countries.isEmpty && languages.isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.additional_information')),
        if (countries.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            loc.t('movie.production_countries'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: countries.map((c) => Chip(label: Text(c))).toList(),
          ),
        ],
        if (languages.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            loc.t('movie.spoken_languages'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: languages.map((l) => Chip(label: Text(l))).toList(),
          ),
        ],
      ],
    );
  }

  Widget? _buildProductionCompanies(
    BuildContext context,
    MovieDetailed details,
  ) {
    if (details.productionCompanies.isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Production Companies'),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: details.productionCompanies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final Company company = details.productionCompanies[index];
              final logoUrl = ApiConfig.getLogoUrl(
                company.logoPath,
                size: ApiConfig.logoSizeMedium,
              );
              return Container(
                width: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (logoUrl.isNotEmpty)
                      Expanded(
                        child: CachedNetworkImage(
                          imageUrl: logoUrl,
                          fit: BoxFit.contain,
                        ),
                      )
                    else
                      Expanded(
                        child: Icon(
                          Icons.apartment,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      company.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildCastSection(
    BuildContext context,
    AppLocalizations loc,
    List<Cast> cast,
  ) {
    if (cast.isEmpty) {
      return null;
    }

    final displayCast = cast.take(20).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.cast')),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: displayCast.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final Cast actor = displayCast[index];
              final profileUrl = ApiConfig.getProfileUrl(actor.profilePath);
              return SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: profileUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: profileUrl,
                              height: 180,
                              width: 140,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 180,
                                width: 140,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 180,
                                width: 140,
                                color: Colors.grey[300],
                                child: const Icon(Icons.person),
                              ),
                            )
                          : Container(
                              height: 180,
                              width: 140,
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, size: 48),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      actor.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if ((actor.character ?? '').isNotEmpty)
                      Text(
                        actor.character!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildCrewSection(
    BuildContext context,
    AppLocalizations loc,
    List<Crew> crew,
  ) {
    if (crew.isEmpty) {
      return null;
    }

    final prioritizedJobs = [
      'Director',
      'Writer',
      'Screenplay',
      'Story',
      'Producer',
      'Executive Producer',
      'Editor',
      'Director of Photography',
      'Original Music Composer',
    ];

    final uniqueCrew = <int>{};
    final orderedCrew = <Crew>[];

    for (final job in prioritizedJobs) {
      for (final member in crew.where((c) => c.job == job)) {
        if (uniqueCrew.add(member.id)) {
          orderedCrew.add(member);
        }
      }
    }

    for (final member in crew) {
      if (uniqueCrew.add(member.id)) {
        orderedCrew.add(member);
      }
      if (orderedCrew.length >= 15) {
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.crew')),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orderedCrew.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final Crew member = orderedCrew[index];
            final profileUrl = ApiConfig.getProfileUrl(member.profilePath);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                backgroundImage: profileUrl.isNotEmpty
                    ? CachedNetworkImageProvider(profileUrl)
                    : null,
                child: profileUrl.isEmpty ? const Icon(Icons.person) : null,
              ),
              title: Text(member.name),
              subtitle: Text(member.job),
            );
          },
        ),
      ],
    );
  }

  Widget? _buildVideosSection(
    BuildContext context,
    AppLocalizations loc,
    List<Video> videos,
  ) {
    if (videos.isEmpty) {
      return null;
    }

    final visibleVideos = videos.take(12).toList();
    final dateFormat = DateFormat.yMMMd();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.videos')),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visibleVideos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = visibleVideos[index];
              final published = DateTime.tryParse(video.publishedAt);
              final thumbnail = 'https://img.youtube.com/vi/${video.key}/0.jpg';
              return GestureDetector(
                onTap: () => _openVideo(video),
                child: Container(
                  width: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: thumbnail,
                          height: 120,
                          width: 240,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 120,
                            width: 240,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 120,
                            width: 240,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.play_circle_outline,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${video.type} • ${video.site}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (published != null)
                              Text(
                                dateFormat.format(published),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildImageGalleries(
    BuildContext context,
    AppLocalizations loc, {
    required List<ImageModel> backdrops,
    required List<ImageModel> posters,
    required List<ImageModel> profiles,
  }) {
    if (backdrops.isEmpty && posters.isEmpty && profiles.isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.photos')),
        const SizedBox(height: 12),
        if (backdrops.isNotEmpty)
          _buildImageCarousel(
            context,
            title: loc.t('movie.backdrops'),
            images: backdrops,
            buildUrl: (image) => ApiConfig.getBackdropUrl(
              image.filePath,
              size: ApiConfig.backdropSizeLarge,
            ),
            height: 180,
          ),
        if (posters.isNotEmpty)
          _buildImageCarousel(
            context,
            title: loc.t('movie.posters'),
            images: posters,
            buildUrl: (image) => ApiConfig.getPosterUrl(
              image.filePath,
              size: ApiConfig.posterSizeLarge,
            ),
            height: 220,
          ),
        if (profiles.isNotEmpty)
          _buildImageCarousel(
            context,
            title: loc.t('movie.stills'),
            images: profiles,
            buildUrl: (image) => ApiConfig.getProfileUrl(
              image.filePath,
              size: ApiConfig.profileSizeLarge,
            ),
            height: 200,
          ),
      ],
    );
  }

  Widget _buildImageCarousel(
    BuildContext context, {
    required String title,
    required List<ImageModel> images,
    required String Function(ImageModel) buildUrl,
    required double height,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: min(images.length, 20),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final image = images[index];
              final imageUrl = buildUrl(image);
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: height,
                  width:
                      height *
                      (image.aspectRatio > 0 ? image.aspectRatio : 1.5),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget? _buildReviewsSection(
    BuildContext context,
    AppLocalizations loc,
    List<Review> reviews,
  ) {
    if (reviews.isEmpty) {
      return null;
    }

    final displayReviews = reviews.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.reviews')),
        const SizedBox(height: 12),
        ...displayReviews.map(
          (review) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _showReview(context, review, loc),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            review.author,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (review.authorDetails.rating != null)
                          _InfoChip(
                            icon: Icons.star,
                            label: review.authorDetails.rating!.toString(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      review.content,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        loc.t('actions.tap_to_expand'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildCollectionSection(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailed details,
  ) {
    final collection = details.collection;
    if (collection == null) {
      return null;
    }

    final posterUrl = ApiConfig.getPosterUrl(collection.posterPath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.collection')),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: posterUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: posterUrl,
                    width: 56,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.collections_bookmark),
            title: Text(collection.name),
            subtitle: Text(loc.t('movie.collection_hint')),
          ),
        ),
      ],
    );
  }

  Widget? _buildRecommendations(
    BuildContext context,
    AppLocalizations loc,
    List<MovieRef> recommendations,
  ) {
    if (recommendations.isEmpty) {
      return null;
    }

    return _buildMovieRefCarousel(
      context,
      loc,
      title: loc.t('movie.recommendations'),
      items: recommendations,
    );
  }

  Widget? _buildSimilar(
    BuildContext context,
    AppLocalizations loc,
    List<MovieRef> similar,
  ) {
    if (similar.isEmpty) {
      return null;
    }

    return _buildMovieRefCarousel(
      context,
      loc,
      title: loc.t('movie.similar'),
      items: similar,
    );
  }

  Widget _buildMovieRefCarousel(
    BuildContext context,
    AppLocalizations loc, {
    required String title,
    required List<MovieRef> items,
  }) {
    final visibleItems = items.take(15).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visibleItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = visibleItems[index];
              final posterUrl = item.posterUrl;
              return SizedBox(
                width: 150,
                child: GestureDetector(
                  onTap: () => _openMovie(context, item),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: posterUrl != null && posterUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: posterUrl,
                                height: 210,
                                width: 150,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 210,
                                  width: 150,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 210,
                                  width: 150,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                ),
                              )
                            : Container(
                                height: 210,
                                width: 150,
                                color: Colors.grey[300],
                                child: const Icon(Icons.movie),
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildWatchProvidersSection(
    BuildContext context,
    AppLocalizations loc,
    Map<String, WatchProviderResults> watchProviders,
  ) {
    if (watchProviders.isEmpty) {
      return null;
    }

    final entries = watchProviders.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.watch_providers')),
        const SizedBox(height: 12),
        ...entries
            .map((entry) {
              final regionCode = entry.key;
              final results = entry.value;
              if (results.flatrate.isEmpty &&
                  results.buy.isEmpty &&
                  results.rent.isEmpty) {
                return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(regionCode),
                  subtitle: results.link != null
                      ? Text(
                          loc
                              .t('movie.watch_on')
                              .replaceFirst(
                                '{0}',
                                Uri.parse(results.link!).host,
                              ),
                        )
                      : null,
                  children: [
                    if (results.flatrate.isNotEmpty)
                      _buildProviderRow(
                        context,
                        loc.t('movie.streaming'),
                        results.flatrate,
                      ),
                    if (results.rent.isNotEmpty)
                      _buildProviderRow(
                        context,
                        loc.t('movie.rent'),
                        results.rent,
                      ),
                    if (results.buy.isNotEmpty)
                      _buildProviderRow(
                        context,
                        loc.t('movie.buy'),
                        results.buy,
                      ),
                    if (results.link != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _launchUrl(results.link!),
                          icon: const Icon(Icons.open_in_new),
                          label: Text(loc.t('actions.visit_site')),
                        ),
                      ),
                  ],
                ),
              );
            })
            .where((widget) => widget is! SizedBox)
            .cast<Widget>(),
      ],
    );
  }

  Widget _buildProviderRow(
    BuildContext context,
    String title,
    List<WatchProvider> providers,
  ) {
    final sortedProviders = providers.toList()
      ..sort(
        (a, b) =>
            (a.displayPriority ?? 999).compareTo(b.displayPriority ?? 999),
      );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: sortedProviders.map((provider) {
              final logoUrl = ApiConfig.getLogoUrl(provider.logoPath);
              return Chip(
                avatar: logoUrl.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(logoUrl),
                      )
                    : null,
                label: Text(provider.providerName ?? 'Unknown'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget? _buildExternalLinks(
    BuildContext context,
    AppLocalizations loc,
    MovieDetailed details,
  ) {
    final links = <_ExternalLink>[];

    if (details.homepage != null && details.homepage!.isNotEmpty) {
      links.add(
        _ExternalLink(
          label: loc.t('movie.homepage'),
          icon: Icons.home_outlined,
          url: details.homepage!,
        ),
      );
    }
    if (details.externalIds.imdbId != null &&
        details.externalIds.imdbId!.isNotEmpty) {
      links.add(
        _ExternalLink(
          label: 'IMDb',
          icon: Icons.local_movies_outlined,
          url: 'https://www.imdb.com/title/${details.externalIds.imdbId}',
        ),
      );
    }
    if (details.externalIds.facebookId != null &&
        details.externalIds.facebookId!.isNotEmpty) {
      links.add(
        _ExternalLink(
          label: 'Facebook',
          icon: Icons.facebook,
          url: 'https://www.facebook.com/${details.externalIds.facebookId}',
        ),
      );
    }
    if (details.externalIds.twitterId != null &&
        details.externalIds.twitterId!.isNotEmpty) {
      links.add(
        _ExternalLink(
          label: 'Twitter',
          icon: Icons.alternate_email,
          url: 'https://twitter.com/${details.externalIds.twitterId}',
        ),
      );
    }
    if (details.externalIds.instagramId != null &&
        details.externalIds.instagramId!.isNotEmpty) {
      links.add(
        _ExternalLink(
          label: 'Instagram',
          icon: Icons.camera_alt_outlined,
          url: 'https://instagram.com/${details.externalIds.instagramId}',
        ),
      );
    }

    if (links.isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.external_links')),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: links
              .map(
                (link) => ActionChip(
                  avatar: Icon(link.icon),
                  label: Text(link.label),
                  onPressed: () => _launchUrl(link.url),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget? _buildAlternativeTitles(
    BuildContext context,
    AppLocalizations loc,
    List<AlternativeTitle> titles,
  ) {
    if (titles.isEmpty) {
      return null;
    }

    final visibleTitles = titles.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.alternative_titles')),
        const SizedBox(height: 12),
        ...visibleTitles.map(
          (title) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.translate),
            title: Text(title.displayLabel),
            subtitle: Text(title.iso31661),
          ),
        ),
      ],
    );
  }

  Widget? _buildReleaseDates(
    BuildContext context,
    AppLocalizations loc,
    List<ReleaseDatesResult> releaseDates,
  ) {
    if (releaseDates.isEmpty) {
      return null;
    }

    final typeLabels = {
      1: loc.t('movie.release_type_premiere'),
      2: loc.t('movie.release_type_theatrical_limited'),
      3: loc.t('movie.release_type_theatrical'),
      4: loc.t('movie.release_type_digital'),
      5: loc.t('movie.release_type_physical'),
      6: loc.t('movie.release_type_tv'),
    };

    final dateFormat = DateFormat.yMMMd();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.release_dates')),
        const SizedBox(height: 12),
        ...releaseDates
            .map((result) {
              final entries = result.releaseDates;
              if (entries.isEmpty) {
                return const SizedBox.shrink();
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.countryCode,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...entries.map((entry) {
                        final date = DateTime.tryParse(entry.releaseDate ?? '');
                        final label =
                            typeLabels[entry.type] ?? loc.t('movie.release');
                        final certification = entry.certification;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              if (certification != null &&
                                  certification.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                  ),
                                  child: Text(
                                    certification,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  '${label} • ${date != null ? dateFormat.format(date) : (entry.releaseDate ?? '')}',
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            })
            .where((widget) => widget is! SizedBox)
            .cast<Widget>(),
      ],
    );
  }

  Widget? _buildTranslations(
    BuildContext context,
    AppLocalizations loc,
    List<Translation> translations,
  ) {
    if (translations.isEmpty) {
      return null;
    }

    final visibleTranslations = translations.take(12).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: loc.t('movie.translations')),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: visibleTranslations
              .map((translation) => Chip(label: Text(translation.displayName)))
              .toList(),
        ),
      ],
    );
  }

  void _shareMovie(BuildContext context, Movie movie, MovieDetailed? details) {
    final title = details?.title ?? movie.title;
    final year = details?.releaseYear ?? movie.releaseYear;
    final url = 'https://www.themoviedb.org/movie/${movie.id}';
    final message = year != null ? '$title ($year)\n$url' : '$title\n$url';
    Share.share(message);
  }

  Future<void> _openMovie(BuildContext context, MovieRef ref) async {
    final movie = Movie(
      id: ref.id,
      title: ref.title,
      overview: null,
      posterPath: ref.posterPath,
      backdropPath: ref.backdropPath,
      releaseDate: ref.releaseDate,
      voteAverage: ref.voteAverage,
      voteCount: null,
      popularity: null,
      originalLanguage: null,
      originalTitle: ref.title,
      mediaType: ref.mediaType,
      genreIds: const [],
      adult: false,
    );

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MovieDetailScreen(movie: movie),
        ),
      );
    }
  }

  void _openVideo(Video video) {
    final site = video.site.toLowerCase();
    String? url;
    if (site.contains('youtube')) {
      url = 'https://www.youtube.com/watch?v=${video.key}';
    } else if (site.contains('vimeo')) {
      url = 'https://vimeo.com/${video.key}';
    }
    if (url != null) {
      _launchUrl(url);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrlString(uri.toString());
    }
  }

  void _showReview(BuildContext context, Review review, AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.rate_review,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          review.author,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Text(review.content),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _ExternalLink {
  const _ExternalLink({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final IconData icon;
  final String url;
}
