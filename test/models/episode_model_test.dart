import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/episode_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Episode', () {
    test('parses full episode payload', () async {
      final json = await loadJsonFixture('episode.json');
      final episode = Episode.fromJson(json);
      expect(episode.episodeNumber, 7);
      expect(episode.cast, hasLength(1));
      expect(episode.videos.first.site, 'YouTube');
      expect(episode.toJson(), equals(json));
      expect(episode, equals(Episode.fromJson(json)));
      expect(episode.copyWith(name: 'Episode 7').name, 'Episode 7');
    });
  });
}
