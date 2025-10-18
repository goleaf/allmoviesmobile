import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/navigation/deep_link_parser.dart';
import '../../../core/utils/media_image_helper.dart';
import '../../../data/models/search_result_model.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/search_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/media_image.dart';
import '../../widgets/rating_display.dart';
import '../../widgets/share/deep_link_share_sheet.dart';
import '../../widgets/shimmer_loading.dart';
import '../movie_detail/movie_detail_screen.dart';
import '../person_detail/person_detail_screen.dart';
import '../tv_detail/tv_detail_screen.dart';
import 'search_results_list_screen.dart';
import 'widgets/search_list_tiles.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppStateProvider>();
      final savedQuery = appState.persistedSearchQuery;
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _performSearch(
          context.read<SearchProvider>(),
          query: widget.initialQuery!,
        );
      } else if (savedQuery.isNotEmpty) {
        _searchController.text = savedQuery;
        _performSearch(context.read<SearchProvider>(), query: savedQuery);
      } else {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Executes a multi-search request through TMDB's
  /// `GET /3/search/multi` endpoint and primes the companion company search via
  /// `GET /3/search/company` so the overview screen can display quick previews.
  void _performSearch(SearchProvider provider, {String? query}) {
    final queryText = (query ?? _searchController.text).trim();
    if (queryText.isEmpty) {
      return;
    }
    if (_searchController.text != queryText) {
      _searchController.value = TextEditingValue(
        text: queryText,
        selection: TextSelection.collapsed(offset: queryText.length),
      );
    }
    context.read<AppStateProvider>().saveSearchQuery(queryText);
    provider.search(queryText, forceRefresh: true);
  }

  /// Opens the dedicated "view all" screen for the provided argument set.
  void _openDedicatedResults(SearchResultsListArgs args) {
    Navigator.of(context).pushNamed(
      SearchResultsListScreen.routeName,
      arguments: args,
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final localization = AppLocalizations.of(context);

    return AppScaffold(
      appBar: _buildAppBar(searchProvider, localization),
      body: _buildBody(searchProvider),
    );
  }

  PreferredSizeWidget _buildAppBar(
    SearchProvider searchProvider,
    AppLocalizations localization,
  ) {
    return AppBar(
      title: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: localization.search['search_placeholder'] ??
              'Search movies, TV shows, people...',
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    searchProvider.clearResults();
                    searchProvider.clearSuggestions();
                    context.read<AppStateProvider>().clearSearchQuery();
                    setState(() {});
                  },
                )
              : null,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _performSearch(searchProvider),
        onChanged: (value) {
          searchProvider.updateInputQuery(value);
          setState(() {});
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: localization.movie['share'] ?? 'Share',
          onPressed: _searchController.text.trim().isEmpty
              ? null
              : () {
                  final query = _searchController.text.trim();
                  final httpLink = DeepLinkBuilder.search(query);
                  showDeepLinkShareSheet(
                    context,
                    title: query,
                    httpLink: httpLink,
                    customSchemeLink: DeepLinkBuilder.asCustomScheme(httpLink),
                  );
                },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _performSearch(searchProvider),
        ),
      ],
    );
  }

  Widget _buildBody(SearchProvider provider) {
    final bool isTyping =
        provider.inputQuery.trim().isNotEmpty && !provider.hasQuery;
    if (isTyping) {
      return _buildSuggestions(provider);
    }

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return _buildError(provider);
    }

    if (!provider.hasQuery) {
      return _buildSearchHistory(provider);
    }

    if (!provider.hasResults) {
      return _buildNoResults();
    }

    return _buildResults(provider);
  }

  Widget _buildSearchHistory(SearchProvider provider) {
    if (provider.searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).search['search_placeholder'] ??
                  'Search movies, TV shows, people...',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (provider.trendingSearches.isNotEmpty) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context).search['trending_searches'] ??
                        'Trending searches',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.trendingSearches
                      .map((q) => ActionChip(
                            avatar: const Icon(Icons.trending_up, size: 18),
                            label: Text(q),
                            onPressed: () {
                              _searchController.text = q;
                              _performSearch(provider, query: q);
                            },
                          ))
                      .toList(growable: false),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).search['recent_searches'] ??
                  'Recent Searches',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: provider.clearHistory,
              child: Text(
                AppLocalizations.of(context).search['clear_history'] ??
                    'Clear History',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...provider.searchHistory.map((query) {
          return ListTile(
            leading: const Icon(Icons.history),
            title: Text(query),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => provider.removeFromHistory(query),
            ),
            onTap: () {
              _searchController.text = query;
              provider.searchFromHistory(query);
            },
          );
        }),
        if (provider.trendingSearches.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).search['trending_searches'] ??
                'Trending searches',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.trendingSearches
                .map((q) => InputChip(
                      label: Text(q),
                      onPressed: () {
                        _searchController.text = q;
                        _performSearch(provider, query: q);
                      },
                    ))
                .toList(growable: false),
          ),
        ],
      ],
    );
  }

  /// Displays server-side autocomplete suggestions generated from the first
  /// page of TMDB's `GET /3/search/multi` and `GET /3/search/company` calls.
  Widget _buildSuggestions(SearchProvider provider) {
    if (provider.isFetchingSuggestions) {
      return const Center(child: CircularProgressIndicator());
    }

    final suggestions = provider.suggestions;
    if (suggestions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppLocalizations.of(context).search['no_suggestions'] ??
                'No suggestions yet',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      itemCount: suggestions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final text = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(text),
          onTap: () {
            _searchController.text = text;
            _performSearch(provider, query: text);
          },
        );
      },
    );
  }

  Widget _buildResults(SearchProvider provider) {
    final localization = AppLocalizations.of(context);
    final movies = provider.previewResults(MediaType.movie, limit: 6);
    final tvShows = provider.previewResults(MediaType.tv, limit: 6);
    final people = provider.previewResults(MediaType.person, limit: 6);
    final companies = provider.companyResults.take(6).toList(growable: false);

    final bool hasAnySection =
        movies.isNotEmpty || tvShows.isNotEmpty || people.isNotEmpty ||
            companies.isNotEmpty;

    if (!hasAnySection) {
      return _buildNoResults();
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (movies.isNotEmpty)
          _PreviewSection(
            title: localization.movie['title'] ?? 'Movies',
            subtitle: localization.search['multi_movies_subtitle'] ??
                'Top movie matches',
            onViewAll: () => _openDedicatedResults(
              const SearchResultsListArgs(mediaType: MediaType.movie),
            ),
            child: SizedBox(
              height: 320,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(
                  width: 220,
                  child: _SearchResultCard(result: movies[index]),
                ),
              ),
            ),
          ),
        if (tvShows.isNotEmpty)
          _PreviewSection(
            title: localization.tv['title'] ?? 'TV Shows',
            subtitle: localization.search['multi_tv_subtitle'] ??
                'Top TV show matches',
            onViewAll: () => _openDedicatedResults(
              const SearchResultsListArgs(mediaType: MediaType.tv),
            ),
            child: SizedBox(
              height: 320,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: tvShows.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(
                  width: 220,
                  child: _SearchResultCard(result: tvShows[index]),
                ),
              ),
            ),
          ),
        if (people.isNotEmpty)
          _PreviewSection(
            title: localization.person['title'] ?? 'People',
            subtitle: localization.search['multi_people_subtitle'] ??
                'Popular personalities related to your search',
            onViewAll: () => _openDedicatedResults(
              const SearchResultsListArgs(mediaType: MediaType.person),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (var i = 0; i < people.length; i++) ...[
                    SearchResultListTile(
                      result: people[i],
                      showDivider: i < people.length - 1,
                    ),
                  ],
                ],
              ),
            ),
          ),
        if (companies.isNotEmpty)
          _PreviewSection(
            title: localization.company['companies'] ?? 'Companies',
            subtitle: localization.search['multi_companies_subtitle'] ??
                'Production companies that match your query',
            onViewAll: () => _openDedicatedResults(
              const SearchResultsListArgs(showCompanies: true),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (var i = 0; i < companies.length; i++) ...[
                    CompanyResultTile(
                      company: companies[i],
                      showDivider: i < companies.length - 1,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).search['no_results'] ??
                'No results found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).search['try_different_keywords'] ??
                'Try a different search term',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildError(SearchProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                provider.clearError();
                _performSearch(provider);
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                AppLocalizations.of(context).common['retry'] ?? 'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.title,
    required this.child,
    this.subtitle,
    this.onViewAll,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewAllLabel =
        AppLocalizations.of(context).search['view_all'] ?? 'View all';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(viewAllLabel),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.result});

  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    final title = (result.title ?? result.name ?? '').trim();
    final overview = (result.overview ?? '').trim();
    final mediaLabel = switch (result.mediaType) {
      MediaType.movie => 'Movie',
      MediaType.tv => 'TV',
      MediaType.person => 'Person',
    };
    final posterPath = result.posterPath?.isNotEmpty == true
        ? result.posterPath
        : (result.profilePath?.isNotEmpty == true ? result.profilePath : null);
    final String? heroTag = switch (result.mediaType) {
      MediaType.movie => 'moviePoster-${result.id}',
      MediaType.tv => 'tvPoster-${result.id}',
      MediaType.person => null,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: switch (result.mediaType) {
          MediaType.movie => () {
              Navigator.pushNamed(
                context,
                MovieDetailScreen.routeName,
                arguments: result.id,
              );
            },
          MediaType.tv => () {
              Navigator.pushNamed(
                context,
                TVDetailScreen.routeName,
                arguments: result.id,
              );
            },
          MediaType.person => () {
              Navigator.pushNamed(
                context,
                PersonDetailScreen.routeName,
                arguments: result.id,
              );
            },
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPoster(heroTag, posterPath, context, title, mediaLabel),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty
                        ? '${_mediaLabel(context, result.mediaType, untitled: true)}'
                        : title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _mediaLabel(context, result.mediaType),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (result.voteAverage != null &&
                      result.voteAverage! > 0 &&
                      result.voteCount != null &&
                      result.voteCount! > 0) ...[
                    const SizedBox(height: 8),
                    RatingDisplay(
                      rating: result.voteAverage! / 2,
                      voteCount: result.voteCount!,
                    ),
                  ],
                  if (overview.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mediaLabel(
    BuildContext context,
    MediaType type, {
    bool untitled = false,
  }) {
    final loc = AppLocalizations.of(context);
    switch (type) {
      case MediaType.movie:
        return untitled
            ? (loc.movie['title'] != null
                  ? 'Untitled ${loc.movie['title']}'
                  : 'Untitled Movie')
            : (loc.movie['title'] ?? 'Movie');
      case MediaType.tv:
        return untitled
            ? (loc.tv['title'] != null
                  ? 'Untitled ${loc.tv['title']}'
                  : 'Untitled TV Show')
            : (loc.tv['title'] ?? 'TV Show');
      case MediaType.person:
        return untitled
            ? (loc.person['title'] != null
                  ? 'Untitled ${loc.person['title']}'
                  : 'Untitled Person')
            : (loc.person['title'] ?? 'Person');
    }
  }

  Widget _buildPoster(
    String? heroTag,
    String? posterPath,
    BuildContext context,
    String title,
    String mediaLabel,
  ) {
    final imageWidget = posterPath != null && posterPath.isNotEmpty
        ? MediaImage(
            path: posterPath,
            type: result.mediaType == MediaType.person
                ? MediaImageType.profile
                : MediaImageType.poster,
            size: MediaImageSize.w342,
            fit: BoxFit.cover,
            placeholder: const ShimmerLoading(
              width: double.infinity,
              height: double.infinity,
            ),
          )
        : Stack(
            fit: StackFit.expand,
            children: [
              const ShimmerLoading(
                width: double.infinity,
                height: double.infinity,
              ),
              Center(
                child: Text(
                  (title.isNotEmpty ? title[0] : mediaLabel[0]).toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                      ),
                ),
              ),
            ],
          );

    if (heroTag == null) {
      return imageWidget;
    }

    return Hero(tag: heroTag, child: imageWidget);
  }
}

/// Placeholder card shown while search results are still loading.
class _SearchResultShimmerCard extends StatelessWidget {
  const _SearchResultShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: ShimmerLoading(
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLoading(width: 140, height: 14),
                SizedBox(height: 8),
                ShimmerLoading(width: 100, height: 12),
                SizedBox(height: 6),
                ShimmerLoading(width: double.infinity, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
