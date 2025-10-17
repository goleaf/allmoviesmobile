import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/movie.dart';
import '../../../data/models/person_model.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/keyword_model.dart';
import '../../../data/models/collection_model.dart';
import '../../../data/models/search_filters.dart';
import '../../../providers/dedicated_search_provider.dart';
import '../../../providers/search_provider.dart';
import '../../widgets/movie_card.dart';
import '../movie_detail/movie_detail_screen.dart';
import '../tv_detail/tv_detail_screen.dart';
import '../person_detail/person_detail_screen.dart';

enum SearchCategory {
  movies,
  tv,
  people,
  companies,
  keywords,
  collections,
}

extension on SearchCategory {
  String get label {
    switch (this) {
      case SearchCategory.movies:
        return 'Movies';
      case SearchCategory.tv:
        return 'TV';
      case SearchCategory.people:
        return 'People';
      case SearchCategory.companies:
        return 'Companies';
      case SearchCategory.keywords:
        return 'Keywords';
      case SearchCategory.collections:
        return 'Collections';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchCategory.movies:
        return Icons.movie_outlined;
      case SearchCategory.tv:
        return Icons.tv_outlined;
      case SearchCategory.people:
        return Icons.people_outline;
      case SearchCategory.companies:
        return Icons.business_outlined;
      case SearchCategory.keywords:
        return Icons.tag_outlined;
      case SearchCategory.collections:
        return Icons.collections_bookmark_outlined;
    }
  }
}

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  late final TabController _tabController;
  final List<SearchCategory> _categories = SearchCategory.values;
  String _submittedQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this)
      ..addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging || _submittedQuery.isEmpty) {
      return;
    }

    final provider = _providerForCategory(_categories[_tabController.index]);
    if (!provider.hasSearched || provider.query != _submittedQuery) {
      provider.search(_submittedQuery);
    }
  }

  PaginatedSearchProvider<dynamic> _providerForCategory(SearchCategory category) {
    switch (category) {
      case SearchCategory.movies:
        return context.read<MovieSearchProvider>();
      case SearchCategory.tv:
        return context.read<TvSearchProvider>();
      case SearchCategory.people:
        return context.read<PersonSearchProvider>();
      case SearchCategory.companies:
        return context.read<CompanySearchProvider>();
      case SearchCategory.keywords:
        return context.read<KeywordSearchProvider>();
      case SearchCategory.collections:
        return context.read<CollectionSearchProvider>();
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _clearAll();
      return;
    }

    setState(() {
      _submittedQuery = query;
    });

    final provider = _providerForCategory(_categories[_tabController.index]);
    provider.search(query, forceRefresh: true);
    context.read<SearchProvider>().recordQuery(query);
  }

  void _clearAll() {
    _searchController.clear();
    setState(() {
      _submittedQuery = '';
    });
    _clearAllProviders();
    context.read<SearchProvider>()
      ..setQuery('')
      ..clearError();
  }

  void _clearAllProviders() {
    context.read<MovieSearchProvider>().clear();
    context.read<TvSearchProvider>().clear();
    context.read<PersonSearchProvider>().clear();
    context.read<CompanySearchProvider>().clear();
    context.read<KeywordSearchProvider>().clear();
    context.read<CollectionSearchProvider>().clear();
  }

  void _onHistorySelected(String query) {
    _searchController.text = query;
    setState(() {
      _submittedQuery = query;
    });
    final provider = _providerForCategory(_categories[_tabController.index]);
    provider.search(query, forceRefresh: true);
    context.read<SearchProvider>().recordQuery(query);
  }

  List<Widget> _buildActions() {
    final currentCategory = _categories[_tabController.index];
    final actions = <Widget>[];

    if (_searchController.text.isNotEmpty) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.clear),
          tooltip: 'Clear search',
          onPressed: _clearAll,
        ),
      );
    }

    if (currentCategory == SearchCategory.movies) {
      final filters = context.watch<MovieSearchProvider>().filters;
      final hasActiveFilters = filters.hasActiveFilters;
      actions.add(
        IconButton(
          icon: Icon(
            Icons.tune,
            color: hasActiveFilters
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          tooltip: 'Movie filters',
          onPressed: () => _showMovieFilters(context.read<MovieSearchProvider>()),
        ),
      );
    } else if (currentCategory == SearchCategory.tv) {
      final filters = context.watch<TvSearchProvider>().filters;
      final hasActiveFilters = filters.hasActiveFilters;
      actions.add(
        IconButton(
          icon: Icon(
            Icons.tune,
            color: hasActiveFilters
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          tooltip: 'TV filters',
          onPressed: () => _showTvFilters(context.read<TvSearchProvider>()),
        ),
      );
    }

    actions.add(
      IconButton(
        icon: const Icon(Icons.search),
        tooltip: 'Search',
        onPressed: _performSearch,
      ),
    );

    return actions;
  }

  Future<void> _showMovieFilters(MovieSearchProvider provider) async {
    final current = provider.filters;
    final yearController =
        TextEditingController(text: current.primaryReleaseYear ?? '');
    final languageController =
        TextEditingController(text: current.language ?? '');
    final regionController =
        TextEditingController(text: current.region ?? '');
    var includeAdult = current.includeAdult;

    final result = await showModalBottomSheet<MovieSearchFilters>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Movie filters',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: includeAdult,
                      title: const Text('Include adult results'),
                      onChanged: (value) => setState(() {
                        includeAdult = value;
                      }),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: yearController,
                      decoration: const InputDecoration(
                        labelText: 'Release year',
                        hintText: 'e.g. 2024',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: languageController,
                      decoration: const InputDecoration(
                        labelText: 'Language (ISO 639-1)',
                        hintText: 'e.g. en',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: regionController,
                      decoration: const InputDecoration(
                        labelText: 'Region (ISO 3166-1)',
                        hintText: 'e.g. US',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(const MovieSearchFilters());
                          },
                          child: const Text('Reset'),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(
                              MovieSearchFilters(
                                includeAdult: includeAdult,
                                primaryReleaseYear: _emptyToNull(
                                  yearController.text,
                                ),
                                language: _emptyToNull(
                                  languageController.text,
                                ),
                                region: _emptyToNull(
                                  regionController.text,
                                ),
                              ),
                            );
                          },
                          child: const Text('Apply filters'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    yearController.dispose();
    languageController.dispose();
    regionController.dispose();

    if (result != null) {
      provider.updateFilters(result);
    }
  }

  Future<void> _showTvFilters(TvSearchProvider provider) async {
    final current = provider.filters;
    final yearController =
        TextEditingController(text: current.firstAirDateYear ?? '');
    final languageController =
        TextEditingController(text: current.language ?? '');
    var includeAdult = current.includeAdult;

    final result = await showModalBottomSheet<TvSearchFilters>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TV filters',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: includeAdult,
                      title: const Text('Include adult results'),
                      onChanged: (value) => setState(() {
                        includeAdult = value;
                      }),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: yearController,
                      decoration: const InputDecoration(
                        labelText: 'First air date year',
                        hintText: 'e.g. 2022',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: languageController,
                      decoration: const InputDecoration(
                        labelText: 'Language (ISO 639-1)',
                        hintText: 'e.g. en',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(const TvSearchFilters());
                          },
                          child: const Text('Reset'),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(
                              TvSearchFilters(
                                includeAdult: includeAdult,
                                firstAirDateYear:
                                    _emptyToNull(yearController.text),
                                language: _emptyToNull(languageController.text),
                              ),
                            );
                          },
                          child: const Text('Apply filters'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    yearController.dispose();
    languageController.dispose();

    if (result != null) {
      provider.updateFilters(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search movies, TV, people, companies... ',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _performSearch(),
          onChanged: (_) => setState(() {}),
        ),
        actions: _buildActions(),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories
              .map(
                (category) => Tab(
                  icon: Icon(category.icon),
                  text: category.label,
                ),
              )
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MovieSearchTab(
            query: _submittedQuery,
            onHistorySelected: _onHistorySelected,
          ),
          _TvSearchTab(
            query: _submittedQuery,
            onHistorySelected: _onHistorySelected,
          ),
          _PeopleSearchTab(
            query: _submittedQuery,
            onHistorySelected: _onHistorySelected,
          ),
          _CompanySearchTab(
            query: _submittedQuery,
            onHistorySelected: _onHistorySelected,
          ),
          _KeywordSearchTab(
            query: _submittedQuery,
            onHistorySelected: _onHistorySelected,
          ),
          _CollectionSearchTab(
            query: _submittedQuery,
            onHistorySelected: _onHistorySelected,
          ),
        ],
      ),
    );
  }
}

class _MovieSearchTab extends StatelessWidget {
  const _MovieSearchTab({
    required this.query,
    required this.onHistorySelected,
  });

  final String query;
  final ValueChanged<String> onHistorySelected;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieSearchProvider>();

    if (query.isEmpty) {
      return _SearchHistoryView(onHistorySelected: onHistorySelected);
    }

    if (provider.isLoading && !provider.hasResults) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && !provider.hasResults) {
      return _SearchErrorView(
        message: provider.errorMessage!,
        onRetry: () => provider.search(query, forceRefresh: true),
      );
    }

    if (!provider.hasResults) {
      return _NoResultsView(query: query);
    }

    final results = provider.results;

    return Column(
      children: [
        if (provider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _InlineError(message: provider.errorMessage!),
          ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
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
                childAspectRatio: 0.63,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: results.length + (provider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= results.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final movie = results[index];
                return MovieCard(
                  id: movie.id,
                  title: movie.title,
                  posterPath: movie.posterPath,
                  voteAverage: movie.voteAverage,
                  releaseDate: movie.releaseDate,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      MovieDetailScreen.routeName,
                      arguments: movie.id,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TvSearchTab extends StatelessWidget {
  const _TvSearchTab({
    required this.query,
    required this.onHistorySelected,
  });

  final String query;
  final ValueChanged<String> onHistorySelected;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TvSearchProvider>();

    if (query.isEmpty) {
      return _SearchHistoryView(onHistorySelected: onHistorySelected);
    }

    if (provider.isLoading && !provider.hasResults) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && !provider.hasResults) {
      return _SearchErrorView(
        message: provider.errorMessage!,
        onRetry: () => provider.search(query, forceRefresh: true),
      );
    }

    if (!provider.hasResults) {
      return _NoResultsView(query: query);
    }

    final results = provider.results;

    return Column(
      children: [
        if (provider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _InlineError(message: provider.errorMessage!),
          ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
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
                childAspectRatio: 0.63,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: results.length + (provider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= results.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final show = results[index];
                return MovieCard(
                  id: show.id,
                  title: show.title,
                  posterPath: show.posterPath,
                  voteAverage: show.voteAverage,
                  releaseDate: show.releaseDate,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      TvDetailScreen.routeName,
                      arguments: show.id,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PeopleSearchTab extends StatelessWidget {
  const _PeopleSearchTab({
    required this.query,
    required this.onHistorySelected,
  });

  final String query;
  final ValueChanged<String> onHistorySelected;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PersonSearchProvider>();

    if (query.isEmpty) {
      return _SearchHistoryView(onHistorySelected: onHistorySelected);
    }

    if (provider.isLoading && !provider.hasResults) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && !provider.hasResults) {
      return _SearchErrorView(
        message: provider.errorMessage!,
        onRetry: () => provider.search(query, forceRefresh: true),
      );
    }

    if (!provider.hasResults) {
      return _NoResultsView(query: query);
    }

    final results = provider.results;

    return Column(
      children: [
        if (provider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _InlineError(message: provider.errorMessage!),
          ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
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
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: results.length + (provider.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index >= results.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final Person person = results[index];
                final subtitleParts = <String>[];
                if (person.knownForDepartment != null &&
                    person.knownForDepartment!.isNotEmpty) {
                  subtitleParts.add(person.knownForDepartment!);
                }
                if (person.popularity != null) {
                  subtitleParts.add(
                      'Popularity ${person.popularity!.toStringAsFixed(1)}');
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      person.name.substring(0, 1).toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  title: Text(person.name),
                  subtitle: subtitleParts.isEmpty
                      ? null
                      : Text(subtitleParts.join(' • ')),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      PersonDetailScreen.routeName,
                      arguments: person.id,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanySearchTab extends StatelessWidget {
  const _CompanySearchTab({
    required this.query,
    required this.onHistorySelected,
  });

  final String query;
  final ValueChanged<String> onHistorySelected;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompanySearchProvider>();

    if (query.isEmpty) {
      return _SearchHistoryView(onHistorySelected: onHistorySelected);
    }

    if (provider.isLoading && !provider.hasResults) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && !provider.hasResults) {
      return _SearchErrorView(
        message: provider.errorMessage!,
        onRetry: () => provider.search(query, forceRefresh: true),
      );
    }

    if (!provider.hasResults) {
      return _NoResultsView(query: query);
    }

    final results = provider.results;

    return Column(
      children: [
        if (provider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _InlineError(message: provider.errorMessage!),
          ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
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
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: results.length + (provider.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= results.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final Company company = results[index];
                return Card(
                  child: ListTile(
                    title: Text(company.name),
                    subtitle: company.originCountry != null
                        ? Text('Country: ${company.originCountry}')
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _KeywordSearchTab extends StatelessWidget {
  const _KeywordSearchTab({
    required this.query,
    required this.onHistorySelected,
  });

  final String query;
  final ValueChanged<String> onHistorySelected;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KeywordSearchProvider>();

    if (query.isEmpty) {
      return _SearchHistoryView(onHistorySelected: onHistorySelected);
    }

    if (provider.isLoading && !provider.hasResults) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && !provider.hasResults) {
      return _SearchErrorView(
        message: provider.errorMessage!,
        onRetry: () => provider.search(query, forceRefresh: true),
      );
    }

    if (!provider.hasResults) {
      return _NoResultsView(query: query);
    }

    final results = provider.results;

    return Column(
      children: [
        if (provider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _InlineError(message: provider.errorMessage!),
          ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
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
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: results.length + (provider.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= results.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final Keyword keyword = results[index];
                return Card(
                  child: ListTile(
                    title: Text(keyword.name),
                    subtitle: Text('Keyword ID: ${keyword.id}'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CollectionSearchTab extends StatelessWidget {
  const _CollectionSearchTab({
    required this.query,
    required this.onHistorySelected,
  });

  final String query;
  final ValueChanged<String> onHistorySelected;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionSearchProvider>();

    if (query.isEmpty) {
      return _SearchHistoryView(onHistorySelected: onHistorySelected);
    }

    if (provider.isLoading && !provider.hasResults) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && !provider.hasResults) {
      return _SearchErrorView(
        message: provider.errorMessage!,
        onRetry: () => provider.search(query, forceRefresh: true),
      );
    }

    if (!provider.hasResults) {
      return _NoResultsView(query: query);
    }

    final results = provider.results;

    return Column(
      children: [
        if (provider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _InlineError(message: provider.errorMessage!),
          ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
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
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: results.length + (provider.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= results.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final Collection collection = results[index];
                return Card(
                  child: ListTile(
                    title: Text(collection.name),
                    subtitle: collection.overview != null &&
                            collection.overview!.isNotEmpty
                        ? Text(
                            collection.overview!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchHistoryView extends StatelessWidget {
  const _SearchHistoryView({required this.onHistorySelected});

  final ValueChanged<String> onHistorySelected;

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final history = searchProvider.searchHistory;

    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Search for movies, TV shows, people, studios, keywords or collections.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
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
              'Recent searches',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: searchProvider.clearHistory,
              child: const Text('Clear all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final query in history)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(query),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => searchProvider.removeFromHistory(query),
            ),
            onTap: () => onHistorySelected(query),
          ),
      ],
    );
  }
}

class _SearchErrorView extends StatelessWidget {
  const _SearchErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  const _NoResultsView({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "$query"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
