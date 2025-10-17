import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/saved_media_item.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';

void main() {
  group('LocalStorageService', () {
    late SharedPreferences prefs;
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
    });

    test('favorites add/remove and retrieval', () async {
      expect(storage.getFavorites(), isEmpty);

      final items = <SavedMediaItem>[
        SavedMediaItem(id: 1, type: SavedMediaType.movie, title: 'Movie #1'),
        SavedMediaItem(id: 2, type: SavedMediaType.tv, title: 'TV #2'),
      ];
      await storage.saveFavoriteItems(items);

      final fetched = storage.getFavoriteItems();
      expect(fetched.map((e) => e.id).toSet(), {1, 2});

      await storage.saveFavorites({1});
      expect(storage.getFavorites(), {1});
    });

    test('watchlist set/get', () async {
      expect(storage.getWatchlist(), isEmpty);
      await storage.saveWatchlist({3, 4});
      expect(storage.getWatchlist(), {3, 4});
    });

    test('search history append/clear', () async {
      expect(storage.getSearchHistory(), isEmpty);
      await storage.addToSearchHistory('hello');
      await storage.addToSearchHistory('world');
      expect(storage.getSearchHistory(), ['world', 'hello']);
      await storage.clearSearchHistory();
      expect(storage.getSearchHistory(), isEmpty);
    });

    test('recently viewed add and trim', () async {
      await storage.addToRecentlyViewed(10);
      await storage.addToRecentlyViewed(11);
      final recent = storage.getRecentlyViewed();
      expect(recent, containsAll([11, 10]));
    });

    test('watch provider snapshots persist changes', () async {
      const mediaType = 'movie';
      const mediaId = 101;
      const region = 'us';

      expect(
        storage.hasWatchProviderSnapshot(mediaType, mediaId, region),
        isFalse,
      );
      expect(
        storage.getWatchProviderSnapshot(mediaType, mediaId, region),
        isEmpty,
      );

      await storage.saveWatchProviderSnapshot(
        mediaType,
        mediaId,
        region,
        const <int>{8, 9},
      );

      expect(
        storage.hasWatchProviderSnapshot(mediaType, mediaId, region),
        isTrue,
      );
      expect(
        storage.getWatchProviderSnapshot(mediaType, mediaId, region),
        {8, 9},
      );

      await storage.saveWatchProviderSnapshot(
        mediaType,
        mediaId,
        region,
        const <int>{9},
      );

      expect(
        storage.getWatchProviderSnapshot(mediaType, mediaId, region),
        {9},
      );

      await storage.clearWatchProviderSnapshot(mediaType, mediaId, region);

      expect(
        storage.hasWatchProviderSnapshot(mediaType, mediaId, region),
        isFalse,
      );
      expect(
        storage.getWatchProviderSnapshot(mediaType, mediaId, region),
        isEmpty,
      );
    });
  });
}
