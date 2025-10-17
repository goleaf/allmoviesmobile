import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/person_model.dart';
import '../../../data/services/api_config.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/people_provider.dart';
import '../../widgets/app_drawer.dart';

class PeopleScreen extends StatelessWidget {
  static const routeName = '/people';

  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<TmdbRepository>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PopularPeopleProvider(repository),
        ),
        ChangeNotifierProvider(
          create: (_) => TrendingPeopleProvider(repository),
        ),
        ChangeNotifierProvider(
          create: (_) => DepartmentPeopleProvider(repository),
        ),
        ChangeNotifierProvider(
          create: (_) => LatestPersonProvider(repository),
        ),
        ChangeNotifierProvider(
          create: (_) => PeopleSearchProvider(repository),
        ),
      ],
      child: const _PeopleScreenView(),
    );
  }
}

class _PeopleScreenView extends StatelessWidget {
  const _PeopleScreenView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.people),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Popular'),
              Tab(text: 'Trending'),
              Tab(text: 'Departments'),
              Tab(text: 'Latest'),
              Tab(text: 'Search'),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: const TabBarView(
          children: [
            _PopularPeopleTab(),
            _TrendingPeopleTab(),
            _DepartmentPeopleTab(),
            _LatestPersonTab(),
            _PeopleSearchTab(),
          ],
        ),
      ),
    );
  }
}

class _PopularPeopleTab extends StatelessWidget {
  const _PopularPeopleTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PopularPeopleProvider>();

    return RefreshIndicator(
      onRefresh: provider.refreshPeople,
      child: Builder(
        builder: (context) {
          if (provider.isLoading && provider.people.isEmpty) {
            return const _CenteredScrollable(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null && provider.people.isEmpty) {
            return _CenteredScrollable(
              child: _ErrorView(
                message: provider.errorMessage!,
                onRetry: provider.refreshPeople,
              ),
            );
          }

          if (provider.people.isEmpty) {
            return const _CenteredScrollable(
              child: _EmptyView(
                message: 'No people found right now. Pull to refresh.',
              ),
            );
          }

          final itemCount =
              provider.people.length + (provider.isLoadingMore ? 1 : 0);

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final metrics = notification.metrics;
              final shouldLoadMore =
                  metrics.pixels >= metrics.maxScrollExtent - 200 &&
                      provider.canLoadMore &&
                      !provider.isLoadingMore &&
                      !provider.isLoading;

              if (shouldLoadMore) {
                provider.loadMorePeople();
              }

              return false;
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: itemCount,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index >= provider.people.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final person = provider.people[index];
                return _PersonListTile(person: person);
              },
            ),
          );
        },
      ),
    );
  }
}

class _TrendingPeopleTab extends StatelessWidget {
  const _TrendingPeopleTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrendingPeopleProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(24),
            isSelected: [
              provider.timeWindow == 'day',
              provider.timeWindow == 'week',
            ],
            onPressed: (index) {
              final newWindow = index == 0 ? 'day' : 'week';
              provider.setTimeWindow(newWindow);
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Trending today'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Trending this week'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: provider.refreshTrendingPeople,
            child: Builder(
              builder: (context) {
                if (provider.isLoading && provider.people.isEmpty) {
                  return const _CenteredScrollable(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.errorMessage != null && provider.people.isEmpty) {
                  return _CenteredScrollable(
                    child: _ErrorView(
                      message: provider.errorMessage!,
                      onRetry: provider.refreshTrendingPeople,
                    ),
                  );
                }

                if (provider.people.isEmpty) {
                  return const _CenteredScrollable(
                    child: _EmptyView(
                      message:
                          'No trending people found for this timeframe. Pull to refresh.',
                    ),
                  );
                }

                final itemCount =
                    provider.people.length + (provider.isLoadingMore ? 1 : 0);

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    final metrics = notification.metrics;
                    final shouldLoadMore =
                        metrics.pixels >= metrics.maxScrollExtent - 200 &&
                            provider.canLoadMore &&
                            !provider.isLoadingMore &&
                            !provider.isLoading;

                    if (shouldLoadMore) {
                      provider.loadMoreTrendingPeople();
                    }

                    return false;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (index >= provider.people.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final person = provider.people[index];
                      return _PersonGridCard(person: person);
                    },
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

class _DepartmentPeopleTab extends StatelessWidget {
  const _DepartmentPeopleTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DepartmentPeopleProvider>();
    final departments = provider.departments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: departments
                .map(
                  (department) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(department),
                      selected: provider.selectedDepartment == department,
                      onSelected: (selected) {
                        if (selected) {
                          provider.selectDepartment(department);
                        }
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: provider.refreshDepartmentPeople,
            child: Builder(
              builder: (context) {
                if (provider.isLoading && provider.people.isEmpty) {
                  return const _CenteredScrollable(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.errorMessage != null && provider.people.isEmpty) {
                  return _CenteredScrollable(
                    child: _ErrorView(
                      message: provider.errorMessage!,
                      onRetry: provider.refreshDepartmentPeople,
                    ),
                  );
                }

                if (provider.people.isEmpty) {
                  return _CenteredScrollable(
                    child: _EmptyView(
                      message:
                          'No people found for ${provider.selectedDepartment}. Try refreshing.',
                    ),
                  );
                }

                final itemCount =
                    provider.people.length + (provider.isLoadingMore ? 1 : 0);

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    final metrics = notification.metrics;
                    final shouldLoadMore =
                        metrics.pixels >= metrics.maxScrollExtent - 200 &&
                            provider.canLoadMore &&
                            !provider.isLoadingMore &&
                            !provider.isLoading;

                    if (shouldLoadMore) {
                      provider.loadMoreDepartmentPeople();
                    }

                    return false;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (index >= provider.people.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final person = provider.people[index];
                      return _PersonGridCard(person: person);
                    },
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

class _LatestPersonTab extends StatelessWidget {
  const _LatestPersonTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LatestPersonProvider>();

    return RefreshIndicator(
      onRefresh: provider.refreshLatestPerson,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 120),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.errorMessage != null)
            _ErrorView(
              message: provider.errorMessage!,
              onRetry: provider.refreshLatestPerson,
            )
          else if (provider.person == null)
            const _EmptyView(
              message: 'Unable to load the latest person right now.',
            )
          else
            _LatestPersonCard(person: provider.person!),
        ],
      ),
    );
  }
}

class _PeopleSearchTab extends StatefulWidget {
  const _PeopleSearchTab();

  @override
  State<_PeopleSearchTab> createState() => _PeopleSearchTabState();
}

class _PeopleSearchTabState extends State<_PeopleSearchTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeopleSearchProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search people by name',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: provider.hasQuery
                  ? IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        provider.search('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: provider.search,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Builder(
              builder: (context) {
                if (!provider.hasQuery) {
                  return const _CenteredScrollable(
                    child: _EmptyView(
                      message: 'Start typing to search people by their name.',
                    ),
                  );
                }

                if (provider.isLoading && provider.results.isEmpty) {
                  return const _CenteredScrollable(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.errorMessage != null && provider.results.isEmpty) {
                  return _CenteredScrollable(
                    child: _ErrorView(
                      message: provider.errorMessage!,
                      onRetry: () => provider.search(provider.query),
                    ),
                  );
                }

                if (provider.results.isEmpty) {
                  return const _CenteredScrollable(
                    child: _EmptyView(
                      message: 'No people match your search yet. Try another name.',
                    ),
                  );
                }

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
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: itemCount,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index >= provider.results.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final person = provider.results[index];
                      return _PersonListTile(person: person);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonListTile extends StatelessWidget {
  const _PersonListTile({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[];
    if (person.knownForDepartment != null && person.knownForDepartment!.isNotEmpty) {
      subtitleParts.add(person.knownForDepartment!);
    }
    if (person.popularity != null) {
      subtitleParts.add('Popularity ${person.popularity!.toStringAsFixed(1)}');
    }

    final biography = (person.biography?.isNotEmpty ?? false)
        ? person.biography!
        : 'Biography not available yet.';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileAvatar(person: person, size: 56),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitleParts.join(' • '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    biography,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonGridCard extends StatelessWidget {
  const _PersonGridCard({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final profileUrl = ApiConfig.getProfileUrl(
      person.profilePath,
      size: ApiConfig.profileSizeLarge,
    );
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: profileUrl.isEmpty
                ? Container(
                    color: theme.colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.person_outline,
                      size: 56,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: profileUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.person_off_outlined,
                        size: 56,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  person.knownForDepartment ?? 'Creative',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestPersonCard extends StatelessWidget {
  const _LatestPersonCard({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileUrl = ApiConfig.getProfileUrl(person.profilePath);
    final subtitleParts = <String>[];
    if (person.knownForDepartment != null && person.knownForDepartment!.isNotEmpty) {
      subtitleParts.add(person.knownForDepartment!);
    }
    if (person.popularity != null) {
      subtitleParts.add('Popularity ${person.popularity!.toStringAsFixed(1)}');
    }

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profileUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: profileUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 220,
                color: theme.colorScheme.surfaceVariant,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 220,
                color: theme.colorScheme.surfaceVariant,
                child: Icon(
                  Icons.person_off_outlined,
                  size: 72,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: theme.textTheme.titleLarge,
                ),
                if (subtitleParts.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitleParts.join(' • '),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  (person.biography?.isNotEmpty ?? false)
                      ? person.biography!
                      : 'Biography not available yet.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.person, this.size = 56});

  final Person person;
  final double size;

  @override
  Widget build(BuildContext context) {
    final profileUrl = ApiConfig.getProfileUrl(person.profilePath);
    final theme = Theme.of(context);

    if (profileUrl.isEmpty) {
      return _InitialAvatar(person: person, size: size);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: CachedNetworkImage(
        imageUrl: profileUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          color: theme.colorScheme.surfaceVariant,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => _InitialAvatar(person: person, size: size),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.person, this.size = 56});

  final Person person;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = person.name.isNotEmpty ? person.name[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        initial,
        style: theme.textTheme.titleMedium,
      ),
    );
  }
}

class _CenteredScrollable extends StatelessWidget {
  const _CenteredScrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight > 0 ? constraints.maxHeight * 0.5 : 200;
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            SizedBox(
              height: height,
              child: Center(child: child),
            ),
          ],
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onRetry,
          child: const Text('Try Again'),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.center,
    );
  }
}
