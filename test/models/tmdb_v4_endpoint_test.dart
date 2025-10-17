import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/tmdb_v4_endpoint.dart';

void main() {
  group('TmdbV4Endpoint', () {
    test('buildUri merges sample and override query', () {
      const endpoint = TmdbV4Endpoint(
        id: 'lists/get',
        title: 'Get List',
        description: 'Retrieve a list',
        category: 'Lists',
        path: '/list/1',
        sampleQuery: {'page': 1},
      );
      final uri = endpoint.buildUri(overrideQuery: {'page': 2, 'language': 'en'});
      expect(uri.path, '/4/list/1');
      expect(uri.queryParameters['page'], '2');
      expect(uri.queryParameters['language'], 'en');
      expect(endpoint.props, contains('Lists'));
    });
  });
}
