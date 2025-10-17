import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/image_model.dart';
import 'package:allmovies_mobile/data/models/media_images.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('MediaImages', () {
    test('indicates presence when any list populated', () async {
      final json = await loadJsonFixture('image.json');
      final posters = (json['posters'] as List).cast<Map<String, dynamic>>();
      final model = MediaImages(posters: posters.map(ImageModel.fromJson));
      expect(model.hasAny, isTrue);
      expect(() => model.posters.add(ImageModel.fromJson(posters.first)), throwsUnsupportedError);
    });

    test('empty constructor has no images', () {
      final empty = MediaImages.empty();
      expect(empty.hasAny, isFalse);
    });
  });
}
