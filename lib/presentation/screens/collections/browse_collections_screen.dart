import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/collection_model.dart';
import '../../../data/services/api_config.dart';
import '../../../providers/collections_provider.dart';
import '../../widgets/app_drawer.dart';

class CollectionsBrowserScreen extends StatefulWidget {
  static const routeName = '/collections';

  const CollectionsBrowserScreen({super.key});

  @override
  State<CollectionsBrowserScreen> createState() => _CollectionsBrowserScreenState();
}

class _CollectionsBrowserScreenState extends State<CollectionsBrowserScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CollectionsProvider>().ensureInitialized();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final provider = context.read<CollectionsProvider>();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      provider.searchCollections(value);
    });
  }

  void _submitSearch(String value) {
    _debounce?.cancel();
    context.read<CollectionsProvider>().searchCollections(value);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    context.read<CollectionsProvider>().clearSearch();
  }

  void _openCollectionDetails(CollectionDetails details) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CollectionDetailsSheet(details: details),
    );
  }

  void _openCollectionPreview(Collection collection) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CollectionPreviewSheet(
        future: context.read<CollectionsProvider>().fetchCollectionPreview(collection.id),
        fallbackName: collection.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.browseCollections),
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: provider.refreshAll,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _SearchHeader(
                controller: _searchController,
                hasQuery: provider.hasSearchQuery,
                onChanged: _onSearchChanged,
                onSubmitted: _submitSearch,
                onClear: _clearSearch,
              ),
            ),
            if (provider.isSearching)
              const SliverToBoxAdapter(child: _SectionLoader()),
            if (!provider.isSearching && provider.hasSearchQuery)
              ..._buildSearchResultSlivers(provider, theme),
            if (!provider.hasSearchQuery)
              ..._buildCuratedSlivers(provider, theme),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSearchResultSlivers(
    CollectionsProvider provider,
    ThemeData theme,
  ) {
    if (provider.hasSearchError) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _SectionError(
              message: provider.searchError ?? AppStrings.collectionsUnavailable,
              onRetry: () => provider.searchCollections(provider.searchQuery),
            ),
          ),
        ),
      ];
    }

    if (!provider.hasSearchResults && provider.hasSearched) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: Text(
                AppStrings.noCollectionsFound,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ];
    }

    if (!provider.hasSearchResults) {
      return const [SliverToBoxAdapter(child: SizedBox.shrink())];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Search results',
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final collection = provider.searchResults[index];
            return _CollectionSearchResultTile(
              collection: collection,
              onTap: () => _openCollectionPreview(collection),
            );
          },
          childCount: provider.searchResults.length,
        ),
      ),
    ];
  }

  List<Widget> _buildCuratedSlivers(CollectionsProvider provider, ThemeData theme) {
    final slivers = <Widget>[];

    slivers.add(
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            AppStrings.popularCollections,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );

    if (provider.isPopularLoading && provider.popularCollections.isEmpty) {
      slivers.add(const SliverToBoxAdapter(child: _SectionLoader()));
    } else if (provider.popularError != null && provider.popularCollections.isEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _SectionError(
              message: provider.popularError ?? AppStrings.collectionsUnavailable,
              onRetry: provider.loadPopularCollections,
            ),
          ),
        ),
      );
    } else if (provider.popularCollections.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: SizedBox(
            height: 280,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final details = provider.popularCollections[index];
                return _CollectionShowcaseCard(
                  details: details,
                  onTap: () => _openCollectionDetails(details),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemCount: provider.popularCollections.length,
            ),
          ),
        ),
      );
    }

    slivers.add(
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
          child: Text(
            AppStrings.collectionsByGenre,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );

    if (provider.isGenresLoading && provider.collectionsByGenre.isEmpty) {
      slivers.add(const SliverToBoxAdapter(child: _SectionLoader()));
    } else if (provider.genresError != null && provider.collectionsByGenre.isEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _SectionError(
              message: provider.genresError ?? AppStrings.collectionsUnavailable,
              onRetry: provider.loadCollectionsByGenre,
            ),
          ),
        ),
      );
    } else if (provider.collectionsByGenre.isNotEmpty) {
      provider.collectionsByGenre.forEach((genre, collections) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Text(
                genre,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
        slivers.add(
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                scrollDirection: Axis.horizontal,
                itemCount: collections.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final details = collections[index];
                  return _CollectionShowcaseCard(
                    details: details,
                    onTap: () => _openCollectionDetails(details),
                  );
                },
              ),
            ),
          ),
        );
      });
    }

    if (slivers.length == 2 &&
        !provider.isPopularLoading &&
        !provider.isGenresLoading &&
        provider.popularCollections.isEmpty &&
        provider.collectionsByGenre.isEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                AppStrings.collectionsUnavailable,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return slivers;
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.hasQuery,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.searchCollections,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: AppStrings.searchCollections,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: hasQuery
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: AppStrings.clearSearch,
                      onPressed: onClear,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              filled: true,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            textInputAction: TextInputAction.search,
          ),
          if (hasQuery)
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.close),
              label: const Text(AppStrings.clearSearch),
            ),
        ],
      ),
    );
  }
}

class _SectionLoader extends StatelessWidget {
  const _SectionLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text(AppStrings.retry),
          ),
        ],
      ],
    );
  }
}

class _CollectionShowcaseCard extends StatelessWidget {
  const _CollectionShowcaseCard({required this.details, this.onTap});

  final CollectionDetails details;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posterUrl = ApiConfig.getPosterUrl(details.posterPath, size: ApiConfig.posterSizeLarge);

    return SizedBox(
      width: 200,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 2 / 3,
                child: posterUrl.isNotEmpty
                    ? Image.network(
                        posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _PosterFallbackIcon(theme: theme),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      )
                    : _PosterFallbackIcon(theme: theme),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (details.overview ?? '').isNotEmpty
                          ? details.overview!
                          : AppStrings.noOverviewAvailable,
                      style: theme.textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosterFallbackIcon extends StatelessWidget {
  const _PosterFallbackIcon({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.primaryContainer,
      child: Icon(
        Icons.collections_bookmark_outlined,
        size: 48,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

class _CollectionSearchResultTile extends StatelessWidget {
  const _CollectionSearchResultTile({required this.collection, required this.onTap});

  final Collection collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posterUrl = ApiConfig.getPosterUrl(collection.posterPath, size: ApiConfig.posterSizeSmall);

    return ListTile(
      leading: posterUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                posterUrl,
                width: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PosterFallbackIcon(theme: theme),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return const SizedBox(
                    width: 56,
                    height: 84,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                  );
                },
              ),
            )
          : SizedBox(
              width: 56,
              child: _PosterFallbackIcon(theme: theme),
            ),
      title: Text(collection.name),
      subtitle: Text('Collection ID: ${collection.id}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _CollectionPreviewSheet extends StatelessWidget {
  const _CollectionPreviewSheet({required this.future, required this.fallbackName});

  final Future<CollectionDetails?> future;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CollectionDetails?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: _SectionError(
              message: 'Failed to load $fallbackName.',
              onRetry: () {
                Navigator.pop(context);
              },
            ),
          );
        }

        final details = snapshot.data;
        if (details == null) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: _SectionError(
              message: AppStrings.collectionsUnavailable,
              onRetry: () {
                Navigator.pop(context);
              },
            ),
          );
        }

        return _CollectionDetailsSheet(details: details);
      },
    );
  }
}

class _CollectionDetailsSheet extends StatelessWidget {
  const _CollectionDetailsSheet({required this.details});

  final CollectionDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posterUrl = ApiConfig.getPosterUrl(details.posterPath, size: ApiConfig.posterSizeLarge);
    final overview = details.overview?.trim();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewPadding.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    details.name,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (posterUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _PosterFallbackIcon(theme: theme),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              (overview != null && overview.isNotEmpty)
                  ? overview
                  : AppStrings.noOverviewAvailable,
              style: theme.textTheme.bodyMedium,
            ),
            if (details.parts.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                AppStrings.includedTitles,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...details.parts.map(
                (part) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.movie_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          part.title,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
