import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/tmdb_list_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('TmdbListDetails', () {
    test('parses list details fixture', () async {
      final json = await loadJsonFixture('tmdb_list_details.json');
      final details = TmdbListDetails.fromJson(json);
      expect(details.entries.results, everyElement(isA<Movie>()));
      expect(details.itemCount, 2);
      expect(details.entries.totalResults, 2);
      expect(details.name, 'Sci-Fi Classics');
    });
  });
}
