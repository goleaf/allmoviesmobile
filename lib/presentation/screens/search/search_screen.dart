import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/search_result_model.dart';
import '../../../providers/search_provider.dart';
import '../movie_detail/movie_detail_screen.dart';
import '../tv_detail/tv_detail_screen.dart';
import '../person_detail/person_detail_screen.dart';
import '../../widgets/media_image.dart';
import '../../../core/utils/media_image_helper.dart';
import '../../widgets/rating_display.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/app_scaffold.dart';
import '../../../providers/app_state_provider.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

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

  void _performSearch(SearchProvider provider, {String? query}) {
    final queryText = (query ?? _searchController.text).trim();
    if (queryText.isNotEmpty) {
      if (_searchController.text != queryText) {
        _searchController.value = TextEditingValue(
          text: queryText,
          selection: TextSelection.collapsed(offset: queryText.length),
        );
      }
      context.read<AppStateProvider>().saveSearchQuery(queryText);
      provider.search(queryText, forceRefresh: true);
    }
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
          hintText:
              localization.search['search_placeholder'] ??
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
          tooltip: 'Share',
          onPressed: _searchController.text.trim().isEmpty
              ? null
              : () {
                  final query = _searchController.text.trim();
                  final link = DeepLinkBuilder.search(query);
                  showDeepLinkShareSheet(
                    context,
                    title: query,
                    httpLink: link,
                    customSchemeLink: DeepLinkBuilder.asCustomScheme(link),
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
    // Suggestions panel while typing before committing a search
    final isTyping =
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
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).search['search_placeholder'] ??
                  'Search movies, TV shows, people...',
              style: Theme.of(context).textTheme.titleMedium,
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
                      .map((q) {
                        return ActionChip(
                          avatar: const Icon(Icons.trending_up, size: 18),
                          label: Text(q),
                          onPressed: () {
                            _searchController.text = q;
                            _performSearch(provider, query: q);
                          },
                        );
                      })
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                provider.clearHistory();
              },
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
              onPressed: () {
                provider.removeFromHistory(query);
              },
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.trendingSearches
                .map((q) {
                  return InputChip(
                    label: Text(q),
                    onPressed: () {
                      _searchController.text = q;
                      _performSearch(provider, query: q);
                    },
                  );
                })
                .toList(growable: false),
          ),
        ],
      ],
    );
  }

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
    final itemCount =
        provider.results.length + (provider.isLoadingMore ? 1 : 0);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        final shouldLoadMore =
            metrics.pixels >= metrics.maxScrollExtent - 200 &&
            provider.canLoadMore &&
            !provider.isLoadingMore &&
            !provider.isLoading;

        if (shouldLoadMore) {
          provider.loadMore();
        }

        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width >= 900 ? 3 : 2;
          final childAspectRatio = width >= 900 ? 0.65 : 0.7;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= provider.results.length) {
                return const _SearchResultShimmerCard();
              }

              final result = provider.results[index];
              return _SearchResultCard(result: result);
            },
          );
        },
      ),
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
