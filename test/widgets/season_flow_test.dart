import 'package:allmovies_mobile/data/models/episode_model.dart';
import 'package:allmovies_mobile/data/models/season_model.dart';
import 'package:allmovies_mobile/data/models/media_images.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/presentation/navigation/season_detail_args.dart';
import 'package:allmovies_mobile/presentation/screens/episode_detail/episode_detail_screen.dart';
import 'package:allmovies_mobile/presentation/screens/season_detail/season_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _RepoStub extends TmdbRepository {
  final Season season;
  _RepoStub(this.season);

  @override
  Future<Season> fetchTvSeason(
    int tvId,
    int seasonNumber, {
    bool forceRefresh = false,
  }) async {
    return season;
  }

  @override
  Future<MediaImages> fetchTvSeasonImages(
    int tvId,
    int seasonNumber, {
    bool forceRefresh = false,
  }) async {
    return MediaImages.empty();
  }
}

void main() {
  testWidgets('Tapping episode opens EpisodeDetailScreen', (tester) async {
    final episode = Episode(
      id: 10,
      name: 'Pilot',
      episodeNumber: 1,
      seasonNumber: 1,
      overview: 'The beginning.',
    );
    final season = Season(
      id: 1,
      name: 'Season 1',
      seasonNumber: 1,
      episodeCount: 1,
      episodes: [episode],
    );

    final repo = _RepoStub(season);

    await tester.pumpWidget(
      Provider<TmdbRepository>.value(
        value: repo,
        child: MaterialApp(
          home: const Scaffold(),
          onGenerateRoute: (settings) {
            if (settings.name == SeasonDetailScreen.routeName) {
              final args = settings.arguments as SeasonDetailArgs;
              return MaterialPageRoute(
                builder: (_) => SeasonDetailScreen(args: args),
                settings: settings,
              );
            }
            if (settings.name == EpisodeDetailScreen.routeName) {
              final ep = settings.arguments as EpisodeDetailArgs;
              return MaterialPageRoute(
                builder: (_) => EpisodeDetailScreen(
                  episode: ep.episode,
                  tvId: ep.tvId,
                ),
                settings: settings,
              );
            }
            return null;
          },
          // Start with no initial route; we'll push the route with args below
          routes: const {},
        ),
      ),
    );

    // Push SeasonDetail
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.pushNamed(
      SeasonDetailScreen.routeName,
      arguments: const SeasonDetailArgs(tvId: 100, seasonNumber: 1),
    );
    await tester.pumpAndSettle();

    // Episodes section visible
    expect(find.text('Episodes'), findsOneWidget);

    // Tap the first episode tile
    await tester.tap(find.textContaining('E1:'));
    await tester.pumpAndSettle();

    // Episode detail screen shows episode name
    expect(find.text('Pilot'), findsWidgets);
  });
}
