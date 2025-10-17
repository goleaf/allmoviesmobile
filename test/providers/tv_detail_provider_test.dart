import 'package:allmovies_mobile/data/models/episode_group_model.dart';
import 'package:allmovies_mobile/data/models/tv_detailed_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/tv_detail_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository extends TmdbRepository {
  _FakeRepository({
    required this.details,
    this.groups = const <EpisodeGroup>[],
    this.episodeGroupsError,
  }) : super(apiKey: 'test');

  final TVDetailed details;
  List<EpisodeGroup> groups;
  Object? episodeGroupsError;

  int detailsCalls = 0;
  int episodeGroupCalls = 0;

  @override
  Future<TVDetailed> fetchTvDetails(
    int tvId, {
    bool forceRefresh = false,
  }) async {
    detailsCalls++;
    return details;
  }

  @override
  Future<List<EpisodeGroup>> fetchTvEpisodeGroups(
    int tvId, {
    bool forceRefresh = false,
  }) async {
    episodeGroupCalls++;
    final error = episodeGroupsError;
    if (error != null) {
      throw error;
    }
    return groups;
  }
}

EpisodeGroup _buildEpisodeGroup({
  required String id,
  required String name,
  List<EpisodeGroupNode> nodes = const <EpisodeGroupNode>[],
}) {
  return EpisodeGroup(
    id: id,
    name: name,
    type: 1,
    groups: nodes,
  );
}

EpisodeGroupNode _buildNode({
  required String id,
  required String name,
  List<EpisodeGroupEpisode> episodes = const <EpisodeGroupEpisode>[],
}) {
  return EpisodeGroupNode(
    id: id,
    name: name,
    episodes: episodes,
  );
}

EpisodeGroupEpisode _buildEpisode({
  required int id,
  required int season,
  required int episode,
  required String name,
}) {
  return EpisodeGroupEpisode(
    id: id,
    name: name,
    seasonNumber: season,
    episodeNumber: episode,
  );
}

void main() {
  const details = TVDetailed(
    id: 1,
    name: 'Test Show',
    originalName: 'Test Show',
    voteAverage: 0,
    voteCount: 0,
  );

  group('TvDetailProvider episode groups', () {
    test('load surfaces episode groups and selects first', () async {
      final groups = <EpisodeGroup>[
        _buildEpisodeGroup(
          id: 'original',
          name: 'Original Order',
          nodes: [
            _buildNode(
              id: 'season1',
              name: 'Season 1',
              episodes: [
                _buildEpisode(
                  id: 100,
                  season: 1,
                  episode: 1,
                  name: 'Pilot',
                ),
              ],
            ),
          ],
        ),
        _buildEpisodeGroup(id: 'dvd', name: 'DVD Order'),
      ];

      final repo = _FakeRepository(details: details, groups: groups);
      final provider = TvDetailProvider(repo, tvId: 42);

      await provider.load();

      expect(provider.details, equals(details));
      expect(provider.episodeGroups, groups);
      expect(provider.selectedEpisodeGroup?.id, groups.first.id);
      expect(provider.areEpisodeGroupsLoading, isFalse);
      expect(provider.episodeGroupsError, isNull);
      expect(repo.detailsCalls, 1);
      expect(repo.episodeGroupCalls, 1);
    });

    test('handles episode group load errors gracefully', () async {
      final repo = _FakeRepository(
        details: details,
        episodeGroupsError: const TmdbException('boom'),
      );
      final provider = TvDetailProvider(repo, tvId: 7);

      await provider.load();

      expect(provider.episodeGroups, isEmpty);
      expect(provider.selectedEpisodeGroup, isNull);
      expect(provider.episodeGroupsError, 'boom');
      expect(provider.areEpisodeGroupsLoading, isFalse);
      expect(repo.episodeGroupCalls, 1);
    });

    test('retryEpisodeGroups reloads data after failure', () async {
      final repo = _FakeRepository(
        details: details,
        episodeGroupsError: const TmdbException('network'),
      );
      final provider = TvDetailProvider(repo, tvId: 9);

      await provider.load();
      expect(provider.episodeGroups, isEmpty);

      final groups = <EpisodeGroup>[
        _buildEpisodeGroup(id: 'alt', name: 'Alt Order'),
      ];

      repo.episodeGroupsError = null;
      repo.groups = groups;

      await provider.retryEpisodeGroups();

      expect(provider.episodeGroups, groups);
      expect(provider.selectedEpisodeGroup?.id, groups.first.id);
      expect(provider.episodeGroupsError, isNull);
      expect(repo.episodeGroupCalls, 2);
    });

    test('selectEpisodeGroup updates selection when id exists', () async {
      final groups = <EpisodeGroup>[
        _buildEpisodeGroup(id: 'original', name: 'Original'),
        _buildEpisodeGroup(id: 'dvd', name: 'DVD'),
      ];

      final repo = _FakeRepository(details: details, groups: groups);
      final provider = TvDetailProvider(repo, tvId: 11);

      await provider.load();

      provider.selectEpisodeGroup('dvd');

      expect(provider.selectedEpisodeGroupId, 'dvd');
      expect(provider.selectedEpisodeGroup?.id, 'dvd');
    });
  });
}
