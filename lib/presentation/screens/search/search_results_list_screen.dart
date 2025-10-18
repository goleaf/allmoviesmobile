import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/search_result_model.dart';
import '../../../providers/search_provider.dart';
import 'widgets/search_list_tiles.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/virtualized_list_view.dart';

class SearchResultsListArgs {
  const SearchResultsListArgs({this.mediaType, this.showCompanies = false})
    : assert(
        mediaType != null || showCompanies,
        'Either mediaType must be set or showCompanies must be true.',
      );

  final MediaType? mediaType;
  final bool showCompanies;
}

class SearchResultsListScreen extends StatelessWidget {
  static const routeName = '/search/results';

  const SearchResultsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as SearchResultsListArgs?;
    if (args == null) {
      return Scaffold(
        body: Center(
          child: Text(
            AppLocalizations.of(context).search['no_results'] ??
                'No results found',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_titleForArgs(context, args))),
      body: args.showCompanies
          ? const _CompanyResultsBody()
          : _MediaResultsBody(mediaType: args.mediaType!),
    );
  }

  String _titleForArgs(BuildContext context, SearchResultsListArgs args) {
    if (args.showCompanies) {
      return AppLocalizations.of(context).company['companies'] ?? 'Companies';
    }

    final type = args.mediaType;
    if (type == null) {
      return AppLocalizations.of(context).search['title'] ?? 'Search';
    }
    switch (type) {
      case MediaType.movie:
        return AppLocalizations.of(context).navigation['movies'] ?? 'Movies';
      case MediaType.tv:
        return AppLocalizations.of(context).navigation['tv_shows'] ??
            'TV Shows';
      case MediaType.person:
        return AppLocalizations.of(context).navigation['people'] ?? 'People';
    }
  }
}

class _MediaResultsBody extends StatelessWidget {
  const _MediaResultsBody({required this.mediaType});

  final MediaType mediaType;

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        final results =
            provider.groupedResults[mediaType] ?? const <SearchResult>[];

        if (results.isEmpty && provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (results.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context).search['no_results'] ??
                  'No results found',
            ),
          ); // Should not happen normally.
        }

        final itemCount = results.length + (provider.isLoadingMore ? 1 : 0);

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            final shouldLoadMore =
                metrics.pixels >= metrics.maxScrollExtent - 200 &&
                provider.canLoadMore &&
                !provider.isLoadingMore;

            if (shouldLoadMore) {
              provider.loadMore();
            }

            return false;
          },
          child: VirtualizedListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: itemCount,
            cacheExtent: 800,
            addAutomaticKeepAlives: true,
            itemBuilder: (context, index) {
              if (index >= results.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return SearchResultListTile(result: results[index]);
            },
          ),
        );
      },
    );
  }
}

class _CompanyResultsBody extends StatelessWidget {
  const _CompanyResultsBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        final results = provider.companyResults;

        if (results.isEmpty &&
            (provider.isLoading || provider.isLoadingCompanies)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (results.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context).search['no_results'] ??
                  'No results found',
            ),
          );
        }

        final itemCount =
            results.length + (provider.isLoadingMoreCompanies ? 1 : 0);

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            final shouldLoadMore =
                metrics.pixels >= metrics.maxScrollExtent - 200 &&
                provider.canLoadMoreCompanies &&
                !provider.isLoadingMoreCompanies;

            if (shouldLoadMore) {
              provider.loadMoreCompanies();
            }

            return false;
          },
          child: VirtualizedListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: itemCount,
            cacheExtent: 800,
            addAutomaticKeepAlives: true,
            itemBuilder: (context, index) {
              if (index >= results.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return CompanyResultTile(company: results[index]);
            },
          ),
        );
      },
    );
  }
}
