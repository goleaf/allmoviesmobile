import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/custom_list.dart';
import 'package:allmovies_mobile/data/models/saved_media_item.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('CustomList', () {
    test('parses list with saved media items', () async {
      final json = await loadJsonFixture('custom_list.json');
      final list = CustomList.fromJson(json);
      expect(list.name, 'Weekend Watch');
      expect(list.itemCount, 1);
      expect(list.items.single.title, 'The Matrix');
      expect(list.copyWith(name: 'Updated').name, 'Updated');
      expect(list.toJson()['is_public'], isTrue);
    });
  });

  group('SavedMediaItem', () {
    test('round-trips json and computed properties', () async {
      final json = await loadJsonFixture('custom_list.json');
      final itemJson = (json['items'] as List).first as Map<String, dynamic>;
      final item = SavedMediaItem.fromJson(itemJson);
      expect(item.voteAverageRounded, 8.7);
      expect(item.releaseYear, '1999');
      expect(item.storageId, 'movie_603');
      expect(item.copyWith(watched: true).watched, isTrue);
    });
  });
}
