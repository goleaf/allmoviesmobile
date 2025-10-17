import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/movie.dart';
import '../../../providers/series_provider.dart';
import '../../widgets/app_drawer.dart';

class SeriesScreen extends StatelessWidget {
  static const routeName = '/series';

  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SeriesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.series),
      ),
      drawer: const AppDrawer(),
      body: _SeriesBody(provider: provider),
    );
  }
}

class _SeriesBody extends StatelessWidget {
  const _SeriesBody({required this.provider});

  final SeriesProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.series.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.series.isEmpty) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: provider.refreshSeries,
      );
    }

    if (provider.series.isEmpty) {
      return const _EmptyView(message: 'No TV shows found right now. Pull to refresh.');
    }

    final itemCount = provider.series.length + (provider.isLoadingMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: provider.refreshSeries,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          final shouldLoadMore =
              metrics.pixels >= metrics.maxScrollExtent - 200 &&
                  provider.canLoadMore &&
                  !provider.isLoadingMore &&
                  !provider.isLoading;

          if (shouldLoadMore) {
            provider.loadMoreSeries();
          }

          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index >= provider.series.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final show = provider.series[index];
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
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
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
