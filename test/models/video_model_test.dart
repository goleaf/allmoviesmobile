import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/video_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Video', () {
    test('round-trips json', () async {
      final json = await loadJsonFixture('video.json');
      final video = Video.fromJson(json);
      expect(video.site, 'YouTube');
      expect(video.toJson(), equals(json));
      expect(video, equals(Video.fromJson(json)));
      expect(video.copyWith(name: 'Teaser').name, 'Teaser');
    });
  });
}
