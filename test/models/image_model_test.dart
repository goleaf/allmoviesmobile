import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/image_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('ImageModel', () {
    test('parses movie image fixture', () async {
      final json = await loadJsonFixture('image.json');
      final images = (json['posters'] as List).cast<Map<String, dynamic>>();
      final model = ImageModel.fromJson(images.first);
      expect(model.filePath, equals(images.first['file_path']));
      expect(model.toJson(), equals(images.first));
      expect(model, equals(ImageModel.fromJson(images.first)));
      expect(model.copyWith(width: 1000).width, 1000);
    });
  });
}
