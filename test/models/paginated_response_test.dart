import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('PaginatedResponse', () {
    test('parses results list into model instances', () async {
      final json = await loadJsonFixture('discover.json');
      final response = PaginatedResponse<Movie>.fromJson(
        json,
        (map) => Movie.fromJson(map, mediaType: map['media_type'] as String?),
      );
      expect(response.results, isNotEmpty);
      expect(response.results.first, isA<Movie>());
      expect(response.hasMore, isTrue);
    });
  });
}
