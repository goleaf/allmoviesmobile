import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/collection_detail_view.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Collection detail view', () {
    test('combines details, images, and translations', () async {
      final details = await loadJsonFixture('collection.json');
      final images = await loadJsonFixture('collection_images.json');
      final translations = await loadJsonFixture('collection_translations.json');
      final view = CollectionDetailViewData.fromResponses(
        details: details,
        images: images,
        translations: translations,
      );
      expect(view.parts.first.title, 'The Matrix');
      expect(view.images, hasLength(2));
      expect(view.translations.single.englishName, 'English');
      expect(view.totalRevenue, 0);
    });

    test('CollectionPartItem formats release date', () {
      final item = CollectionPartItem.fromJson({
        'id': 1,
        'title': 'Sample',
        'release_date': '1999-03-31',
        'vote_average': 8.7,
        'order': 1,
      });
      expect(item.formattedReleaseDate('en_US'), isNotEmpty);
      expect(item.copyWith(revenue: 100).revenue, 100);
    });

    test('CollectionImageItem parses dimensions', () {
      final json = {
        'file_path': '/image.jpg',
        'width': 100,
        'height': 200,
        'vote_average': 4.0,
        'vote_count': 20,
      };
      final image = CollectionImageItem.fromJson(json, type: 'poster');
      expect(image.type, 'poster');
      expect(image.voteAverage, 4.0);
    });

    test('CollectionTranslationItem reads nested data', () {
      final translation = CollectionTranslationItem.fromJson({
        'iso_639_1': 'en',
        'iso_3166_1': 'US',
        'name': 'English',
        'english_name': 'English',
        'data': {
          'title': 'Matrix',
          'overview': 'Overview',
          'homepage': 'https://matrix.com',
        }
      });
      expect(translation.title, 'Matrix');
      expect(translation.overview, 'Overview');
    });
  });
}
