import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/review_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Review', () {
    test('parses review page fixture', () async {
      final json = await loadJsonFixture('reviews_page.json');
      final reviewJson = (json['results'] as List).first as Map<String, dynamic>;
      final review = Review.fromJson(reviewJson);
      expect(review.authorDetails.rating, 8.0);
      expect(review.toJson(), equals(reviewJson));
      expect(review, equals(Review.fromJson(reviewJson)));
      expect(review.copyWith(content: 'Updated').content, 'Updated');
    });
  });

  group('ReviewAuthor', () {
    test('round-trips json', () {
      const author = ReviewAuthor(name: 'Test', username: 'test', rating: 7.0);
      expect(ReviewAuthor.fromJson(author.toJson()), equals(author));
    });
  });
}
