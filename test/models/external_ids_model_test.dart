import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/external_ids_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('ExternalIds', () {
    test('parses nullable ids', () async {
      final tv = await loadJsonFixture('tv_full.json');
      final ids = ExternalIds.fromJson(tv['external_ids'] as Map<String, dynamic>);
      expect(ids.imdbId, 'tt0944947');
      expect(ids.toJson(), equals(tv['external_ids']));
      expect(ids, equals(ExternalIds.fromJson(ids.toJson())));
      expect(ids.copyWith(facebookId: null).facebookId, isNull);
    });
  });
}
