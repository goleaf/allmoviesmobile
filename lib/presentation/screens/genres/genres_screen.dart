import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/genre_model.dart';
import '../../../data/models/search_result_model.dart';
import '../../../providers/genres_provider.dart';
import '../../widgets/app_drawer.dart';
import 'genre_explore_screen.dart';

/// Top-level directory for browsing TMDB genres sourced from:
/// * `GET /3/genre/movie/list`
/// * `GET /3/genre/tv/list`
///
/// Those endpoints return payloads structured as:
/// ```json
/// {
///   "genres": [
///     {"id": 28, "name": "Action"}
///   ]
/// }
/// ```
///
/// The screen renders the complete catalog for both movies and TV series and
/// offers entry points into genre-specific discovery flows.
class GenresScreen extends StatefulWidget {
  const GenresScreen({super.key});

  static const routeName = '/genres';

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final provider = context.read<GenresProvider>();
    provider.fetchMovieGenres();
    provider.fetchTvGenres();
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final strings = localization.genreBrowser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings['title'] ?? localization.t('genres.title')),
          bottom: TabBar(
            tabs: [
              Tab(text: strings['movies_tab'] ?? localization.t('navigation.movies')),
              Tab(text: strings['tv_tab'] ?? localization.t('navigation.series')),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: TabBarView(
          children: const [
            _GenreTab(isTv: false),
            _GenreTab(isTv: true),
          ],
        ),
      ),
    );
  }
}

class _GenreTab extends StatelessWidget {
  const _GenreTab({required this.isTv});

  final bool isTv;

  @override
  Widget build(BuildContext context) {
    return Consumer<GenresProvider>(
      builder: (context, provider, _) {
        final localization = AppLocalizations.of(context);
        final strings = localization.genreBrowser;
        final genres = isTv ? provider.tvGenres : provider.movieGenres;
        final isLoading = isTv ? provider.isLoadingTv : provider.isLoadingMovies;
        final error = isTv ? provider.tvError : provider.movieError;

        if (isLoading && genres.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null && genres.isEmpty) {
          return _GenreErrorView(
            message: error,
            onRetry: () async {
              if (isTv) {
                await provider.fetchTvGenres(forceRefresh: true);
              } else {
                await provider.fetchMovieGenres(forceRefresh: true);
              }
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (isTv) {
              await provider.fetchTvGenres(forceRefresh: true);
            } else {
              await provider.fetchMovieGenres(forceRefresh: true);
            }
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: genres.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final helper = strings['selection_hint'] ??
                    'Pick one or more genres to filter results.';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    helper,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                );
              }

              final genre = genres[index - 1];
              return _GenreTile(
                genre: genre,
                mediaType: isTv ? MediaType.tv : MediaType.movie,
              );
            },
          ),
        );
      },
    );
  }
}

class _GenreTile extends StatelessWidget {
  const _GenreTile({required this.genre, required this.mediaType});

  final Genre genre;
  final MediaType mediaType;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final strings = localization.genreBrowser;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            GenreExploreScreen.routeName,
            arguments: GenreExploreArgs(genre: genre, mediaType: mediaType),
          );
        },
        child: ListTile(
          title: Text(
            genre.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            strings['trending_subtitle'] ?? 'What\'s popular right now',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class _GenreErrorView extends StatelessWidget {
  const _GenreErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(localization.common['retry'] ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
