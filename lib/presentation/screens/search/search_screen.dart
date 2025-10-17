import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/search_result_model.dart';
import '../../../providers/search_provider.dart';
import 'search_results_list_screen.dart';
import 'widgets/search_list_tiles.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SearchProvider>();
      if (provider.inputQuery.isNotEmpty) {
        _searchController.text = provider.inputQuery;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchController.text.length),
        );
      }
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(SearchProvider provider, {String? query}) {
    final effectiveQuery = (query ?? _searchController.text).trim();
    if (effectiveQuery.isEmpty) {
      provider.clearResults();
      return;
    }

    _searchController.text = effectiveQuery;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: effectiveQuery.length),
    );

    provider.search(effectiveQuery);
    provider.clearSuggestions();
    FocusScope.of(context).unfocus();
  }

  void _handleSuggestionTap(SearchProvider provider, String suggestion) {
    _performSearch(provider, query: suggestion);
  }

  void _openViewAll(MediaType type) {
    Navigator.pushNamed(
      context,
      SearchResultsListScreen.routeName,
      arguments: SearchResultsListArgs(mediaType: type),
    );
  }

  void _openViewAllCompanies() {
    Navigator.pushNamed(
      context,
      SearchResultsListScreen.routeName,
      arguments: const SearchResultsListArgs(showCompanies: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final trimmedInput = searchProvider.inputQuery.trim();
    final showSuggestions = trimmedInput.isNotEmpty &&
        (trimmedInput != searchProvider.query.trim() || !searchProvider.hasQuery) &&
        (searchProvider.suggestions.isNotEmpty || searchProvider.isFetchingSuggestions);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search movies, TV shows, people, companies...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<SearchProvider>()
                        ..clearResults()
                        ..clearSuggestions();
                    },
                  )
                : null,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _performSearch(searchProvider),
          onChanged: (value) {
            context.read<SearchProvider>().updateInputQuery(value);
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
      body: Column(
        children: [
          if (showSuggestions) _buildSuggestions(searchProvider),
          Expanded(child: _buildBody(searchProvider)),
        ],
      ),
    );
  }

  Widget _buildSuggestions(SearchProvider provider) {
    final suggestions = provider.suggestions;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (provider.isFetchingSuggestions)
            const LinearProgressIndicator(minHeight: 2),
          ...suggestions.map((suggestion) {
            return ListTile(
              leading: const Icon(Icons.search),
              title: Text(suggestion),
              onTap: () => _handleSuggestionTap(provider, suggestion),
            );
          }),
          if (!provider.isFetchingSuggestions && suggestions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No suggestions yet. Keep typing...'),
            ),
        ],
      ),
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
      return _buildInitialContent(provider);
    }

    final hasAnyResults = provider.hasResults || provider.hasCompanyResults;
    if (!hasAnyResults) {
      return _buildNoResults();
    }

    return _buildResults(provider);
  }

  Widget _buildInitialContent(SearchProvider provider) {
    final hasHistory = provider.searchHistory.isNotEmpty;
    final hasTrending = provider.trendingSearches.isNotEmpty;

    if (!hasHistory && !hasTrending) {
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
              'Search for movies, shows, people or companies',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (hasHistory) ...[
          _SectionHeader(
            title: 'Recent Searches',
            actionLabel: 'Clear All',
            onActionTap: provider.clearHistory,
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
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: query.length),
                );
                provider.searchFromHistory(query);
              },
            );
          }),
          const SizedBox(height: 24),
        ],
        if (hasTrending) ...[
          const _SectionHeader(title: 'Trending Searches'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.trendingSearches
                .map(
                  (query) => ActionChip(
                    avatar: const Icon(Icons.trending_up, size: 18),
                    label: Text(query),
                    onPressed: () => _handleSuggestionTap(provider, query),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildResults(SearchProvider provider) {
    final sections = <Widget>[];

    void addMediaSection(String title, MediaType type) {
      final results = provider.groupedResults[type] ?? const <SearchResult>[];
      if (results.isEmpty) return;

      sections.add(
        _ResultSection(
          title: title,
          onViewAll: () => _openViewAll(type),
          children: results.take(5).map((result) {
            return SearchResultListTile(result: result);
          }).toList(),
        ),
      );
    }

    addMediaSection('Movies', MediaType.movie);
    addMediaSection('TV Shows', MediaType.tv);
    addMediaSection('People', MediaType.person);

    if (provider.companyResults.isNotEmpty) {
      sections.add(
        _ResultSection(
          title: 'Companies',
          onViewAll: provider.canLoadMoreCompanies || provider.companyResults.length > 5
              ? _openViewAllCompanies
              : null,
          children: provider.companyResults.take(5).map((company) {
            return CompanyResultTile(company: company);
          }).toList(),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: sections,
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

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.children,
    this.onViewAll,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View all'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (actionLabel != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
