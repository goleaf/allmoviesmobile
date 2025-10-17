import 'package:flutter_test/flutter_test.dart';
import 'package:allmovies_mobile/providers/favorites_provider.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FavoritesProvider Tests', () {
    late FavoritesProvider provider;
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
      provider = FavoritesProvider(storage);
    });

    test('should start with empty favorites', () {
      expect(provider.favorites, isEmpty);
      expect(provider.count, 0);
    });

    test('should add movie to favorites', () async {
      await provider.addFavorite(123);

      expect(provider.isFavorite(123), true);
      expect(provider.count, 1);
      expect(provider.favorites, contains(123));
    });

    test('should remove movie from favorites', () async {
      await provider.addFavorite(123);
      await provider.removeFavorite(123);

      expect(provider.isFavorite(123), false);
      expect(provider.count, 0);
      expect(provider.favorites, isEmpty);
    });

    test('should toggle favorite status', () async {
      // Add
      await provider.toggleFavorite(123);
      expect(provider.isFavorite(123), true);

      // Remove
      await provider.toggleFavorite(123);
      expect(provider.isFavorite(123), false);
    });

    test('should handle multiple favorites', () async {
      await provider.addFavorite(1);
      await provider.addFavorite(2);
      await provider.addFavorite(3);

      expect(provider.count, 3);
      expect(provider.favorites, containsAll([1, 2, 3]));
    });

    test('should not add duplicate favorites', () async {
      await provider.addFavorite(123);
      await provider.addFavorite(123);

      expect(provider.count, 1);
    });

    test('should clear all favorites', () async {
      await provider.addFavorite(1);
      await provider.addFavorite(2);
      await provider.addFavorite(3);

      await provider.clearFavorites();

      expect(provider.count, 0);
      expect(provider.favorites, isEmpty);
    });

    test('should persist favorites', () async {
      await provider.addFavorite(123);
      await provider.addFavorite(456);

      // Create new provider with same storage
      final newProvider = FavoritesProvider(storage);

      expect(newProvider.count, 2);
      expect(newProvider.favorites, containsAll([123, 456]));
    });

    test('should not throw when removing non-existent favorite', () async {
      expect(() => provider.removeFavorite(999), returnsNormally);
    });
  });
}

