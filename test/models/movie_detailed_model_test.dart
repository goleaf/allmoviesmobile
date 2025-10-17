import 'package:allmovies_mobile/data/models/keyword_model.dart';
import 'package:allmovies_mobile/data/models/movie_detailed_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MovieDetailed keywords parsing', () {
    test('parses keyword list when present', () {
      final json = {
        'id': 1,
        'title': 'Example',
        'original_title': 'Example',
        'vote_average': 7.2,
        'vote_count': 100,
        'keywords': [
          {'id': 12, 'name': 'space'},
          {'id': 18, 'name': 'adventure'},
        ],
      };

      final detailed = MovieDetailed.fromJson(json);

      expect(detailed.keywords.length, 2);
      expect(
        detailed.keywords.map((Keyword keyword) => keyword.name),
        containsAll(<String>['space', 'adventure']),
      );
    });

    test('defaults to empty keyword list when absent', () {
      final json = {
        'id': 2,
        'title': 'No Keywords',
        'original_title': 'No Keywords',
        'vote_average': 6.0,
        'vote_count': 5,
      };

      final detailed = MovieDetailed.fromJson(json);

      expect(detailed.keywords, isEmpty);
    });
  });
}
