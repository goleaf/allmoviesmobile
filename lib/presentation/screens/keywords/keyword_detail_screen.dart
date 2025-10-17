import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/movie.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/keyword_provider.dart';
import '../../widgets/movie_card.dart';
import '../movie_detail/movie_detail_screen.dart';
import '../tv_detail/tv_detail_screen.dart';
import '../../widgets/fullscreen_modal_scaffold.dart';
import '../../../core/localization/app_localizations.dart';

class KeywordDetailScreen extends StatelessWidget {
  static const routeName = '/keyword-detail';

  final int keywordId;
  final String? keywordName;

  const KeywordDetailScreen({
    super.key,
    required this.keywordId,
    this.keywordName,
  });

  static Route<void> route({required int keywordId, String? keywordName}) {
    return MaterialPageRoute(
      builder: (_) =>
          KeywordDetailScreen(keywordId: keywordId, keywordName: keywordName),
      fullscreenDialog: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<TmdbRepository>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => KeywordDetailsProvider(
            repository,
            keywordId: keywordId,
            initialName: keywordName,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              KeywordMoviesProvider(repository, keywordId: keywordId),
        ),
        ChangeNotifierProvider(
          create: (_) => KeywordTvProvider(repository, keywordId: keywordId),
        ),
      ],
      child: DefaultTabController(length: 2, child: const _KeywordDetailView()),
    );
  }
}

class _KeywordDetailView extends StatelessWidget {
  const _KeywordDetailView();

  @override
  Widget build(BuildContext context) {
    final detailsProvider = context.watch<KeywordDetailsProvider>();
    final keywordName = detailsProvider.keywordName;

    final l = AppLocalizations.of(context);
    final tabBar = TabBar(
      tabs: [
        Tab(text: l.t('navigation.movies')),
        Tab(text: l.t('navigation.tv_shows')),
      ],
      labelStyle: Theme.of(context).textTheme.titleMedium,
    );

    return FullscreenModalScaffold(
      title: Text(keywordName ?? l.t('keywords.title')),
      actions: [
        IconButton(
          tooltip: l.t('common.retry'),
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<KeywordDetailsProvider>().fetchDetails(
              forceRefresh: true,
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
          48 + (detailsProvider.isLoading ? 2 : 0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            tabBar,
            if (detailsProvider.isLoading)
              const LinearProgressIndicator(minHeight: 2),
          ],
        ),
      ),
      body: Column(
        children: [
          if (detailsProvider.errorMessage != null)
            _KeywordInfoErrorBanner(
              message: detailsProvider.errorMessage!,
              onRetry: () => context
                  .read<KeywordDetailsProvider>()
                  .fetchDetails(forceRefresh: true),
            ),
          Expanded(
            child: TabBarView(
              children: [
                Consumer<KeywordMoviesProvider>(
                  builder: (context, provider, _) {
                    return _KeywordMediaTab(
                      provider: provider,
                      sortOptions: _movieSortOptions(context),
                      emptyMessage: l.t('search.no_results'),
                      isTv: false,
                    );
                  },
                ),
                Consumer<KeywordTvProvider>(
                  builder: (context, provider, _) {
                    return _KeywordMediaTab(
                      provider: provider,
                      sortOptions: _tvSortOptions(context),
                      emptyMessage: l.t('search.no_results'),
                      isTv: true,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption {
  const _SortOption({required this.value, required this.label});

  final String value;
  final String label;
}

List<_SortOption> _movieSortOptions(BuildContext context) {
  final l = AppLocalizations.of(context);
  return <_SortOption>[
    _SortOption(
      value: 'popularity.desc',
      label: l.t('discover.sort_popularity_desc'),
    ),
    _SortOption(
      value: 'popularity.asc',
      label: l.t('discover.sort_popularity_asc'),
    ),
    _SortOption(
      value: 'vote_average.desc',
      label: l.t('discover.sort_rating_desc'),
    ),
    _SortOption(
      value: 'vote_average.asc',
      label: l.t('discover.sort_rating_asc'),
    ),
    _SortOption(
      value: 'release_date.desc',
      label: l.t('discover.sort_release_date_desc'),
    ),
    _SortOption(
      value: 'release_date.asc',
      label: l.t('discover.sort_release_date_asc'),
    ),
  ];
}

List<_SortOption> _tvSortOptions(BuildContext context) {
  final l = AppLocalizations.of(context);
  return <_SortOption>[
    _SortOption(
      value: 'popularity.desc',
      label: l.t('discover.sort_popularity_desc'),
    ),
    _SortOption(
      value: 'popularity.asc',
      label: l.t('discover.sort_popularity_asc'),
    ),
    _SortOption(
      value: 'vote_average.desc',
      label: l.t('discover.sort_rating_desc'),
    ),
    _SortOption(
      value: 'vote_average.asc',
      label: l.t('discover.sort_rating_asc'),
    ),
    _SortOption(
      value: 'first_air_date.desc',
      label: l.t('discover.sort_release_date_desc'),
    ),
    _SortOption(
      value: 'first_air_date.asc',
      label: l.t('discover.sort_release_date_asc'),
    ),
  ];
}

class _KeywordMediaTab extends StatelessWidget {
  const _KeywordMediaTab({
    required this.provider,
    required this.sortOptions,
    required this.emptyMessage,
    required this.isTv,
  });

  final BaseKeywordMediaProvider provider;
  final List<_SortOption> sortOptions;
  final String emptyMessage;
  final bool isTv;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        final shouldLoadMore =
            metrics.pixels >= metrics.maxScrollExtent - 200 &&
            provider.canLoadMore &&
            !provider.isLoadingMore &&
            !provider.isLoading;

        if (shouldLoadMore) {
          provider.loadMoreMedia();
        }

        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => provider.refreshMedia(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _SortDropdown(
                selectedValue: provider.sortBy,
                options: sortOptions,
                onChanged: (value) {
                  if (value != null) {
                    provider.changeSort(value);
                  }
                },
              ),
            ),
            ..._buildContent(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    if (provider.isLoading && provider.media.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (provider.errorMessage != null && provider.media.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _KeywordErrorView(
            message: provider.errorMessage!,
            onRetry: () => provider.refreshMedia(),
          ),
        ),
      ];
    }

    if (provider.media.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _KeywordEmptyView(message: emptyMessage),
        ),
      ];
    }

    final slivers = <Widget>[
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.66,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = provider.media[index];
            return _KeywordMediaCard(movie: item, isTv: isTv);
          }, childCount: provider.media.length),
        ),
      ),
    ];

    if (provider.errorMessage != null) {
      slivers.add(
        SliverToBoxAdapter(
          child: _InlineErrorMessage(
            message: provider.errorMessage!,
            onRetry: () => provider.loadMoreMedia(),
          ),
        ),
      );
    }

    if (provider.isLoadingMore) {
      slivers.add(
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    return slivers;
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  final String selectedValue;
  final List<_SortOption> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Sort by',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            items: options
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option.value,
                    child: Text(option.label),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _KeywordMediaCard extends StatelessWidget {
  const _KeywordMediaCard({required this.movie, required this.isTv});

  final Movie movie;
  final bool isTv;

  @override
  Widget build(BuildContext context) {
    return MovieCard(
      id: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      voteAverage: movie.voteAverage,
      releaseDate: movie.releaseDate,
      heroTag: isTv ? 'tvPoster-${movie.id}' : 'moviePoster-${movie.id}',
      onTap: () {
        if (isTv) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TVDetailScreen(tvShow: movie),
              fullscreenDialog: true,
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MovieDetailScreen(movie: movie),
              fullscreenDialog: true,
            ),
          );
        }
      },
    );
  }
}

class _KeywordEmptyView extends StatelessWidget {
  const _KeywordEmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _KeywordErrorView extends StatelessWidget {
  const _KeywordErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _InlineErrorMessage extends StatelessWidget {
  const _InlineErrorMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Could not load more items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeywordInfoErrorBanner extends StatelessWidget {
  const _KeywordInfoErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
