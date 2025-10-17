import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/movie.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/series_provider.dart';

class SeriesCategoryScreen extends StatelessWidget {
  static const routeName = '/series/browse';

  final SeriesCategoryArguments arguments;

  const SeriesCategoryScreen({super.key, required this.arguments});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SeriesProvider>(
      create: (_) => SeriesProvider(context.read<TmdbRepository>()),
      child: _SeriesCategoryView(arguments: arguments),
    );
  }
}

class SeriesCategoryArguments {
  const SeriesCategoryArguments({required this.title, this.subtitle});

  final String title;
  final String? subtitle;
}

class _SeriesCategoryView extends StatelessWidget {
  const _SeriesCategoryView({required this.arguments});

  final SeriesCategoryArguments arguments;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SeriesProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(arguments.title)),
      body: _SeriesBody(provider: provider, header: arguments.subtitle),
    );
  }
}

class _SeriesBody extends StatelessWidget {
  const _SeriesBody({required this.provider, this.header});

  final SeriesProvider provider;
  final String? header;

  @override
  Widget build(BuildContext context) {
    if (provider.isRefreshing &&
        provider.sectionState(SeriesSection.popular).items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.globalError != null &&
        provider.sectionState(SeriesSection.popular).items.isEmpty) {
      return _ErrorView(
        message: provider.globalError!,
        onRetry: () => provider.refresh(force: true),
      );
    }

    final hasHeader = header != null && header!.trim().isNotEmpty;

    if (provider.sectionState(SeriesSection.popular).items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.refresh(force: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (hasHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  header!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const Padding(
              padding: EdgeInsets.all(24),
              child: _EmptyView(
                message: 'No TV shows found right now. Pull to refresh.',
              ),
            ),
          ],
        ),
      );
    }

    final popular = provider.sectionState(SeriesSection.popular);
    final items = popular.items;
    final itemCount = items.length + (popular.isLoading ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () => provider.refresh(force: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          final shouldLoadMore =
              metrics.pixels >= metrics.maxScrollExtent - 200 &&
              !popular.isLoading &&
              items.isNotEmpty;

          if (shouldLoadMore) {
            // With new provider API, refreshing popular acts as load more when filtered
            provider.applyTvFilters(const <String, String>{});
          }

          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: itemCount + (hasHeader ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (hasHeader) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    header!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }
              index -= 1;
            }

            if (index >= items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final show = items[index];
            return _SeriesCard(show: show);
          },
        ),
      ),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.show});

  final Movie show;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[];
    final releaseYear = show.releaseYear;
    if (releaseYear != null && releaseYear.isNotEmpty) {
      subtitleParts.add(releaseYear);
    }
    if (show.mediaLabel.isNotEmpty) {
      subtitleParts.add(show.mediaLabel);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tv_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        show.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleParts.join(' • '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(show.formattedRating),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              show.overview ?? 'No overview available.',
              style: Theme.of(context).textTheme.bodyMedium,
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
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
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
