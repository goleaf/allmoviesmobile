import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/review_model.dart';
import 'package:allmovies_mobile/data/models/review_page.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('ReviewPage', () {
    test('parses paginated review response', () async {
      final json = await loadJsonFixture('reviews_page.json');
      final page = ReviewPage.fromJson(json);
      expect(page.page, 1);
      expect(page.totalPages, 2);
      expect(page.hasMore, isTrue);
      expect(page.reviews.single, isA<Review>());
    });
  });
}
