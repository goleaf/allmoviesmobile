import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/tv_detailed_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('TVDetailed', () {
    test('parses tv details fixture', () async {
      final json = await loadJsonFixture('tv_full.json');
      final detailed = TVDetailed.fromJson(json);
      expect(detailed.name, 'Game of Thrones');
      expect(detailed.seasons, isNotEmpty);
      expect(detailed.episodeGroups, isNotEmpty);
      expect(detailed.toJson()['id'], 1399);
      expect(detailed.copyWith(name: 'GOT').name, 'GOT');
    });
  });
}
