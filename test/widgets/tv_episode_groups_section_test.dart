import 'dart:async';

import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:allmovies_mobile/data/models/episode_group_model.dart';
import 'package:allmovies_mobile/data/models/tv_detailed_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/presentation/screens/tv_detail/tv_detail_screen.dart';
import 'package:allmovies_mobile/providers/tv_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _RepoStub extends TmdbRepository {
  _RepoStub({
    required this.details,
    this.groups = const <EpisodeGroup>[],
    this.groupsCompleter,
    this.error,
  }) : super(apiKey: 'test');

  final TVDetailed details;
  List<EpisodeGroup> groups;
  Completer<List<EpisodeGroup>>? groupsCompleter;
  Object? error;

  @override
  Future<TVDetailed> fetchTvDetails(
    int tvId, {
    bool forceRefresh = false,
  }) async {
    return details;
  }

  @override
  Future<List<EpisodeGroup>> fetchTvEpisodeGroups(
    int tvId, {
    bool forceRefresh = false,
  }) {
    final completer = groupsCompleter;
    if (completer != null) {
      return completer.future;
    }
    final currentError = error;
    if (currentError != null) {
      return Future<List<EpisodeGroup>>.error(currentError);
    }
    return Future.value(groups);
  }
}

EpisodeGroup _group(String id, String name, {List<EpisodeGroupNode>? nodes}) {
  return EpisodeGroup(
    id: id,
    name: name,
    type: 1,
    groups: nodes ?? const <EpisodeGroupNode>[],
  );
}

EpisodeGroupNode _node(String id, String name, {List<EpisodeGroupEpisode>? episodes}) {
  return EpisodeGroupNode(
    id: id,
    name: name,
    episodes: episodes ?? const <EpisodeGroupEpisode>[],
  );
}

EpisodeGroupEpisode _episode(int id, int season, int episode, String name) {
  return EpisodeGroupEpisode(
    id: id,
    name: name,
    seasonNumber: season,
    episodeNumber: episode,
  );
}

Widget _wrapWithProviders(TvDetailProvider provider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<TvDetailProvider>.value(value: provider),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: EpisodeGroupsSection()),
    ),
  );
}

void main() {
  const details = TVDetailed(
    id: 1,
    name: 'Demo',
    originalName: 'Demo',
    voteAverage: 0,
    voteCount: 0,
  );

  testWidgets('renders episode groups and allows switching', (tester) async {
    final groups = <EpisodeGroup>[
      _group(
        'original',
        'Original Order',
        nodes: [
          _node(
            'season1',
            'Season 1',
            episodes: [_episode(1, 1, 1, 'Pilot')],
          ),
        ],
      ),
      _group('dvd', 'DVD Order'),
    ];

    final repo = _RepoStub(details: details, groups: groups);
    final provider = TvDetailProvider(repo, tvId: 100);
    await provider.load();

    await tester.pumpWidget(_wrapWithProviders(provider));
    await tester.pumpAndSettle();

    expect(find.text('Episode Groups'), findsOneWidget);
    expect(find.text('Original Order'), findsOneWidget);
    expect(find.text('DVD Order'), findsOneWidget);
    expect(find.text('S01E01 • Pilot'), findsOneWidget);

    final dvdChip = find.widgetWithText(ChoiceChip, 'DVD Order');
    await tester.tap(dvdChip);
    await tester.pumpAndSettle();

    expect(provider.selectedEpisodeGroupId, 'dvd');
    expect(find.text('No episodes in this group.'), findsOneWidget);
    final chip = tester.widget<ChoiceChip>(dvdChip);
    expect(chip.selected, isTrue);
  });

  testWidgets('shows loading indicator then error state when fetch fails',
      (tester) async {
    final completer = Completer<List<EpisodeGroup>>();
    final repo = _RepoStub(
      details: details,
      groupsCompleter: completer,
    );
    final provider = TvDetailProvider(repo, tvId: 200);

    final loadFuture = provider.load();

    await tester.pumpWidget(_wrapWithProviders(provider));
    await tester.pump();

    expect(find.byType(LoadingIndicator), findsOneWidget);

    completer.completeError(const TmdbException('fetch failed'));
    await loadFuture;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Error'), findsOneWidget);
    expect(find.text('fetch failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows fallback message when there are no episode groups',
      (tester) async {
    final repo = _RepoStub(details: details, groups: const []);
    final provider = TvDetailProvider(repo, tvId: 300);
    await provider.load();

    await tester.pumpWidget(_wrapWithProviders(provider));
    await tester.pumpAndSettle();

    expect(
      find.text('No alternative episode groups available.'),
      findsOneWidget,
    );
  });
}
