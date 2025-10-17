import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/person_model.dart';
import '../../../providers/people_provider.dart';
import '../../widgets/app_drawer.dart';

class PeopleScreen extends StatelessWidget {
  static const routeName = '/people';

  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeopleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.people),
      ),
      drawer: const AppDrawer(),
      body: _PeopleBody(provider: provider),
    );
  }
}

class _PeopleBody extends StatelessWidget {
  const _PeopleBody({required this.provider});

  final PeopleProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.people.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.people.isEmpty) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: provider.refreshPeople,
      );
    }

    if (provider.people.isEmpty) {
      return const _EmptyView(message: 'No people found right now. Pull to refresh.');
    }

    final itemCount = provider.people.length + (provider.isLoadingMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: provider.refreshPeople,
      child: NotificationListener<ScrollNotification>(
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
            return _PersonCard(person: person);
          },
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.person});

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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                person.name.substring(0, 1).toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitleParts.join(' • '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (person.biography?.isNotEmpty ?? false)
                        ? person.biography!
                        : 'Biography not available yet.',
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
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
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
