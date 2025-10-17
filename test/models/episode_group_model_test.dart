import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/episode_group_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('EpisodeGroup', () {
    test('parses nested group structure', () async {
      final json = await loadJsonFixture('episode_group.json');
      final group = EpisodeGroup.fromJson(json);
      expect(group.name, 'Original Broadcast');
      expect(group.network, isNotNull);
      expect(group.groups.single.episodes.single.name, 'Winter Is Coming');
      expect(group.toJson(), equals(json));
      expect(group, equals(EpisodeGroup.fromJson(json)));
    });
  });

  group('EpisodeGroupNode', () {
    test('supports equality semantics', () async {
      final json = await loadJsonFixture('episode_group.json');
      final node = EpisodeGroupNode.fromJson(
        (json['groups'] as List).first as Map<String, dynamic>,
      );
      expect(node, equals(EpisodeGroupNode.fromJson(node.toJson())));
    });
  });

  group('EpisodeGroupEpisode', () {
    test('round-trips json', () async {
      final json = await loadJsonFixture('episode_group.json');
      final episodeMap = ((json['groups'] as List).first as Map<String, dynamic>)[
              'episodes']
          .first as Map<String, dynamic>;
      final episode = EpisodeGroupEpisode.fromJson(episodeMap);
      expect(episode.toJson(), equals(episodeMap));
      expect(episode.name, 'Winter Is Coming');
    });
  });
}
