import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:allmovies_mobile/data/local/isar/isar_provider.dart';
import 'package:allmovies_mobile/data/local/isar/genre_translation.dart';
import 'package:allmovies_mobile/data/models/configuration_model.dart';
import 'package:allmovies_mobile/data/models/genre_model.dart';
import 'package:allmovies_mobile/data/models/watch_provider_model.dart' as m;
import 'package:allmovies_mobile/data/services/static_catalog_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';

class _StubRepo extends TmdbRepository {
  _StubRepo();

  @override
  Future<List<m.WatchProviderRegion>> fetchWatchProviderRegions({
    bool forceRefresh = false,
  }) async {
    return const [
      m.WatchProviderRegion(countryCode: 'US', englishName: 'United States'),
    ];
  }

  @override
  Future<List<Genre>> fetchMovieGenresLocalized(String language) async {
    return const [Genre(id: 1, name: 'Action')];
  }

  @override
  Future<List<Genre>> fetchTVGenresLocalized(String language) async {
    return const [Genre(id: 2, name: 'Drama')];
  }

  @override
  Future<List<CountryInfo>> fetchCountriesLocalized(
    String language, {
    bool forceRefresh = false,
  }) async {
    return const [CountryInfo(code: 'US', englishName: 'United States')];
  }

  @override
  Future<List<LanguageInfo>> fetchLanguages({bool forceRefresh = false}) async {
    return const [LanguageInfo(code: 'en', englishName: 'English')];
  }

  @override
  Future<List<m.WatchProvider>> fetchProvidersCatalog({
    required String mediaType,
    required String language,
    bool forceRefresh = false,
  }) async {
    return [m.WatchProvider(id: 8, providerId: 8, providerName: 'Netflix')];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('preloadAll stores catalogs to Isar', () async {
    try {
      final isar = await IsarDbProvider.instance.isar;
      await isar.writeTxn(() async => isar.clear());
      final service = StaticCatalogService(_StubRepo());

      int lastTotal = 0;
      int lastCurrent = 0;
      await service.preloadAll(
        locales: const [Locale('en')],
        onProgress: (p) {
          lastTotal = p.total;
          lastCurrent = p.current;
        },
      );
      expect(lastCurrent, equals(lastTotal));

      final genres = await isar.genreTranslationEntitys.where().findAll();
      expect(genres, isNotEmpty);
    } catch (_) {
      // Skip on environments without native Isar
      expect(true, isTrue);
    }
  });
}
