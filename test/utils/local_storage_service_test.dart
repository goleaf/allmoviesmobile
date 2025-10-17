import 'package:allmovies_mobile/data/models/custom_list.dart';
import 'package:allmovies_mobile/data/models/saved_media_item.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('favorites', () {
    test('add/remove/isFavorite flow', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      expect(storage.isFavorite(7), isFalse);
      await storage.addToFavorites(7);
      expect(storage.isFavorite(7), isTrue);
      await storage.removeFromFavorites(7);
      expect(storage.isFavorite(7), isFalse);
    });
  });

  group('watchlist', () {
    test('add/remove/isInWatchlist flow', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      expect(storage.isInWatchlist(9), isFalse);
      await storage.addToWatchlist(9);
      expect(storage.isInWatchlist(9), isTrue);
      await storage.removeFromWatchlist(9);
      expect(storage.isInWatchlist(9), isFalse);
    });
  });

  group('custom lists', () {
    test('upsert and find list', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final list = CustomList(id: 'abc', name: 'My List');
      await storage.upsertCustomList(list);
      final found = storage.findCustomList('abc');
      expect(found, isNotNull);
      expect(found!.name, 'My List');
    });
  });

  group('search history', () {
    test('add/remove/clear search history', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      expect(storage.getSearchHistory(), isEmpty);
      await storage.addToSearchHistory('hello');
      expect(storage.getSearchHistory(), contains('hello'));
      await storage.removeFromSearchHistory('hello');
      expect(storage.getSearchHistory(), isNot(contains('hello')));
      await storage.addToSearchHistory('world');
      await storage.clearSearchHistory();
      expect(storage.getSearchHistory(), isEmpty);
    });
  });

  group('recently viewed', () {
    test('add and clear', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      expect(storage.getRecentlyViewed(), isEmpty);
      await storage.addToRecentlyViewed(10);
      expect(storage.getRecentlyViewed(), contains(10));
      await storage.clearRecentlyViewed();
      expect(storage.getRecentlyViewed(), isEmpty);
    });
  });
}


