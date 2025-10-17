import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/search_result_model.dart';
import '../../../providers/search_provider.dart';
import 'widgets/search_list_tiles.dart';

class SearchResultsListArgs {
  const SearchResultsListArgs({
    this.mediaType,
    this.showCompanies = false,
  }) : assert(mediaType != null || showCompanies, 'Either mediaType must be set or showCompanies must be true.');

  final MediaType? mediaType;
  final bool showCompanies;
}

class SearchResultsListScreen extends StatelessWidget {
  static const routeName = '/search/results';

  const SearchResultsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as SearchResultsListArgs?;
    if (args == null) {
      return const Scaffold(body: Center(child: Text('No results to display')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForArgs(args)),
      ),
      body: args.showCompanies ? const _CompanyResultsBody() : _MediaResultsBody(mediaType: args.mediaType!),
    );
  }

  String _titleForArgs(SearchResultsListArgs args) {
    if (args.showCompanies) {
      return 'Companies';
    }

    return switch (args.mediaType) {
      MediaType.movie => 'Movies',
      MediaType.tv => 'TV Shows',
      MediaType.person => 'People',
    };
  }
}

class _MediaResultsBody extends StatelessWidget {
  const _MediaResultsBody({required this.mediaType});

  final MediaType mediaType;

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        final results = provider.groupedResults[mediaType] ?? const <SearchResult>[];

        if (results.isEmpty && provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (results.isEmpty) {
          return const Center(child: Text('No results yet.')); // Should not happen normally.
        }

        final itemCount = results.length + (provider.isLoadingMore ? 1 : 0);

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            final shouldLoadMore =
                metrics.pixels >= metrics.maxScrollExtent - 200 && provider.canLoadMore && !provider.isLoadingMore;

            if (shouldLoadMore) {
              provider.loadMore();
            }

            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: itemCount,
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

        if (results.isEmpty && (provider.isLoading || provider.isLoadingCompanies)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (results.isEmpty) {
          return const Center(child: Text('No companies found.'));
        }

        final itemCount = results.length + (provider.isLoadingMoreCompanies ? 1 : 0);

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            final shouldLoadMore = metrics.pixels >= metrics.maxScrollExtent - 200 &&
                provider.canLoadMoreCompanies &&
                !provider.isLoadingMoreCompanies;

            if (shouldLoadMore) {
              provider.loadMoreCompanies();
            }

            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: itemCount,
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
