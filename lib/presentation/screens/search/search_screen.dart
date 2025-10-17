import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/search_result_model.dart';
import '../../../providers/search_provider.dart';
import '../movie_detail/movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  final String? initialQuery;

  const SearchScreen({
    super.key,
    this.initialQuery,
  });

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
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _performSearch(
          context.read<SearchProvider>(),
          query: widget.initialQuery!,
        );
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
      provider.search(queryText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search movies, TV shows...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      searchProvider.clearResults();
                    },
                  )
                : null,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _performSearch(searchProvider),
          onChanged: (value) {
            setState(() {});
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(searchProvider),
          ),
        ],
      ),
      body: _buildBody(searchProvider),
    );
  }

  Widget _buildBody(SearchProvider provider) {
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
              'Search for movies and TV shows',
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
              'Recent Searches',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                provider.clearHistory();
              },
              child: const Text('Clear All'),
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
      ],
    );
  }

  Widget _buildResults(SearchProvider provider) {
    final itemCount = provider.results.length + (provider.isLoadingMore ? 1 : 0);

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
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= provider.results.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = provider.results[index];
          return _SearchResultCard(result: result);
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
            'No results found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
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
              label: const Text('Try Again'),
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
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  image: _posterImage != null
                      ? DecorationImage(
                          image: NetworkImage(_posterImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _posterImage == null
                    ? Center(
                        child: Text(
                          (title.isNotEmpty ? title[0] : mediaLabel[0]).toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                      )
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? 'Untitled $mediaLabel' : title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mediaLabel,
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

  String? get _posterImage {
    if (result.posterPath != null && result.posterPath!.isNotEmpty) {
      return AppConfig.tmdbImageBaseUrl + '/w342' + (result.posterPath!.startsWith('/') ? '' : '/') + result.posterPath!;
    }
    if (result.profilePath != null && result.profilePath!.isNotEmpty) {
      return AppConfig.tmdbImageBaseUrl + '/w342' + (result.profilePath!.startsWith('/') ? '' : '/') + result.profilePath!;
    }
    return null;
  }
}

