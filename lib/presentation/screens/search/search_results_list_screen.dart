import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/search_result_model.dart';
import '../../../providers/search_provider.dart';
import 'widgets/search_list_tiles.dart';

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

/// Paginated list that renders dedicated search results for a specific
/// [MediaType] using TMDB's `GET /3/search/{media_type}` endpoints.
class _MediaResultsBody extends StatelessWidget {
  const _MediaResultsBody({required this.mediaType});

  final MediaType mediaType;

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        final PagingController<int, SearchResult> controller =
            provider.mediaPagingController(mediaType);
        final localization = AppLocalizations.of(context);
        final emptyLabel = localization.search['no_results'] ?? 'No results';

        return RefreshIndicator(
          onRefresh: () =>
              provider.reexecuteLastSearch(forceRefresh: true),
          child: PagedListView<int, SearchResult>(
            pagingController: controller,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            builderDelegate: PagedChildBuilderDelegate<SearchResult>(
              itemBuilder: (context, item, index) => SearchResultListTile(
                result: item,
                showDivider: true,
              ),
              firstPageProgressIndicatorBuilder: (_) => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              ),
              newPageProgressIndicatorBuilder: (_) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              firstPageErrorIndicatorBuilder: (_) => _PagedErrorView(
                message: localization.search['load_failed'] ??
                    'Unable to load results',
                onRetry: controller.refresh,
              ),
              newPageErrorIndicatorBuilder: (_) => _PagedErrorView(
                message: localization.search['load_failed'] ??
                    'Unable to load results',
                onRetry: controller.retryLastFailedRequest,
              ),
              noItemsFoundIndicatorBuilder: (_) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Text(emptyLabel),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Paginated list that renders production companies pulled from
/// `GET /3/search/company`.
class _CompanyResultsBody extends StatelessWidget {
  const _CompanyResultsBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        final PagingController<int, Company> controller =
            provider.companyPagingController;
        final localization = AppLocalizations.of(context);
        final emptyLabel = localization.search['no_results'] ?? 'No results';

        return RefreshIndicator(
          onRefresh: () =>
              provider.reexecuteLastSearch(forceRefresh: true),
          child: PagedListView<int, Company>(
            pagingController: controller,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            builderDelegate: PagedChildBuilderDelegate<Company>(
              itemBuilder: (context, item, index) => CompanyResultTile(
                company: item,
                showDivider: true,
              ),
              firstPageProgressIndicatorBuilder: (_) => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              ),
              newPageProgressIndicatorBuilder: (_) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              firstPageErrorIndicatorBuilder: (_) => _PagedErrorView(
                message: localization.search['load_failed'] ??
                    'Unable to load results',
                onRetry: controller.refresh,
              ),
              newPageErrorIndicatorBuilder: (_) => _PagedErrorView(
                message: localization.search['load_failed'] ??
                    'Unable to load results',
                onRetry: controller.retryLastFailedRequest,
              ),
              noItemsFoundIndicatorBuilder: (_) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Text(emptyLabel),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Lightweight inline error indicator for pagination failures.
class _PagedErrorView extends StatelessWidget {
  const _PagedErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context).common['retry'] ?? 'Retry'),
          ),
        ],
      ),
    );
  }
}
