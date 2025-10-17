import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../local/isar/country_translation.dart';
import '../local/isar/genre_translation.dart';
import '../local/isar/isar_provider.dart';
import '../local/isar/language_translation.dart';
import '../local/isar/static_catalog_meta.dart';
import '../local/isar/watch_provider.dart';
import '../local/isar/watch_provider_region.dart';
import '../tmdb_repository.dart';

class PreloadProgress {
  final int current;
  final int total;
  final String message;
  const PreloadProgress(this.current, this.total, this.message);
}

class StaticCatalogService {
  StaticCatalogService(this._tmdb);

  final TmdbRepository _tmdb;

  static const _refreshInterval = Duration(days: 7);

  Future<bool> needsRefresh(Isar isar, List<Locale> locales) async {
    final meta = await isar.staticCatalogMetaEntitys.where().findFirst();
    if (meta == null) return true;
    final last = DateTime.fromMillisecondsSinceEpoch(meta.lastUpdatedMs);
    if (DateTime.now().difference(last) > _refreshInterval) return true;
    final cached = meta.localesCsv
        .split(',')
        .where((e) => e.isNotEmpty)
        .toSet();
    final requiredLocales = locales.map((e) => e.languageCode).toSet();
    return !cached.containsAll(requiredLocales);
  }

  Future<bool> isFirstRun(Isar isar) async {
    final meta = await isar.staticCatalogMetaEntitys.where().findFirst();
    return meta == null;
  }

  Future<void> preloadAll({
    required List<Locale> locales,
    required void Function(PreloadProgress) onProgress,
  }) async {
    final isar = await IsarDbProvider.instance.isar;

    final unitsPerLocale =
        6; // genres(movie,tv), providers(movie,tv), countries, languages
    final regionsUnits = 1;
    final total = regionsUnits + (locales.length * unitsPerLocale);
    var done = 0;

    void tick(String msg) => onProgress(PreloadProgress(++done, total, msg));

    // Regions once
    final regions = await _tmdb.fetchWatchProviderRegions(forceRefresh: true);
    await isar.writeTxn(() async {
      await isar.watchProviderRegionEntitys.clear();
      await isar.watchProviderRegionEntitys.putAll(
        regions
            .map((e) {
              final ent = WatchProviderRegionEntity()
                ..iso3166_1 = e.countryCode
                ..englishName = e.englishName
                ..nativeName = e.nativeName;
              return ent;
            })
            .toList(growable: false),
      );
    });
    tick('Regions loaded');

    // Per-locale catalogs
    for (final locale in locales) {
      final lang = locale.languageCode;

      // Genres movie
      final movieGenres = await _tmdb.fetchMovieGenresLocalized(lang);
      await isar.writeTxn(() async {
        await isar.genreTranslationEntitys
            .filter()
            .localeEqualTo(lang)
            .mediaTypeEqualTo('movie')
            .deleteAll();
        await isar.genreTranslationEntitys.putAll(
          movieGenres
              .map((g) {
                final ent = GenreTranslationEntity()
                  ..genreId = g.id
                  ..mediaType = 'movie'
                  ..locale = lang
                  ..name = g.name;
                return ent;
              })
              .toList(growable: false),
        );
      });
      tick('Movie genres ($lang)');

      // Genres TV
      final tvGenres = await _tmdb.fetchTVGenresLocalized(lang);
      await isar.writeTxn(() async {
        await isar.genreTranslationEntitys
            .filter()
            .localeEqualTo(lang)
            .mediaTypeEqualTo('tv')
            .deleteAll();
        await isar.genreTranslationEntitys.putAll(
          tvGenres
              .map((g) {
                final ent = GenreTranslationEntity()
                  ..genreId = g.id
                  ..mediaType = 'tv'
                  ..locale = lang
                  ..name = g.name;
                return ent;
              })
              .toList(growable: false),
        );
      });
      tick('TV genres ($lang)');

      // Providers movie
      final providersMovie = await _tmdb.fetchProvidersCatalog(
        mediaType: 'movie',
        language: lang,
      );
      final movieProviders = providersMovie
          .map(
            (p) => _ProviderLite(
              providerId: p.providerId ?? p.id,
              displayPriority: p.displayPriority,
              name: p.providerName ?? '',
            ),
          )
          .toList(growable: false);
      await _upsertProviders(isar, movieProviders, lang);
      tick('Movie providers ($lang)');

      // Providers tv
      final providersTv = await _tmdb.fetchProvidersCatalog(
        mediaType: 'tv',
        language: lang,
      );
      final tvProviders = providersTv
          .map(
            (p) => _ProviderLite(
              providerId: p.providerId ?? p.id,
              displayPriority: p.displayPriority,
              name: p.providerName ?? '',
            ),
          )
          .toList(growable: false);
      await _upsertProviders(isar, tvProviders, lang);
      tick('TV providers ($lang)');

      // Countries
      final countries = await _tmdb.fetchCountriesLocalized(
        lang,
        forceRefresh: true,
      );
      await isar.writeTxn(() async {
        await isar.countryTranslationEntitys
            .filter()
            .localeEqualTo(lang)
            .deleteAll();
        await isar.countryTranslationEntitys.putAll(
          countries
              .map((c) {
                final name = c.nativeName?.isNotEmpty == true
                    ? c.nativeName!
                    : c.englishName;
                final ent = CountryTranslationEntity()
                  ..iso3166_1 = c.code
                  ..locale = lang
                  ..name = name;
                return ent;
              })
              .toList(growable: false),
        );
      });
      tick('Countries ($lang)');

      // Languages
      final languages = await _tmdb.fetchLanguages(forceRefresh: true);
      await isar.writeTxn(() async {
        await isar.languageTranslationEntitys
            .filter()
            .localeEqualTo(lang)
            .deleteAll();
        await isar.languageTranslationEntitys.putAll(
          languages
              .map((l) {
                final name = l.name?.isNotEmpty == true
                    ? l.name!
                    : l.englishName;
                final ent = LanguageTranslationEntity()
                  ..iso639_1 = l.code
                  ..locale = lang
                  ..name = name;
                return ent;
              })
              .toList(growable: false),
        );
      });
      tick('Languages ($lang)');
    }

    // Meta update
    final localesCsv = locales.map((e) => e.languageCode).join(',');
    await isar.writeTxn(() async {
      final existing = await isar.staticCatalogMetaEntitys.where().findFirst();
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      if (existing == null) {
        final meta = StaticCatalogMetaEntity()
          ..lastUpdatedMs = nowMs
          ..localesCsv = localesCsv;
        await isar.staticCatalogMetaEntitys.put(meta);
      } else {
        existing.lastUpdatedMs = nowMs;
        existing.localesCsv = localesCsv;
        await isar.staticCatalogMetaEntitys.put(existing);
      }
    });
  }

  // Provider fetch now uses repository public method

  Future<void> _upsertProviders(
    Isar isar,
    List<_ProviderLite> providers,
    String locale,
  ) async {
    await isar.writeTxn(() async {
      for (final p in providers) {
        // base
        final existing = await isar.watchProviderEntitys
            .filter()
            .providerIdEqualTo(p.providerId)
            .findFirst();
        final base = existing ?? WatchProviderEntity()
          ..providerId = p.providerId;
        base.displayPriority = p.displayPriority;
        await isar.watchProviderEntitys.put(base);

        // translation
        final t = WatchProviderTranslationEntity()
          ..providerId = p.providerId
          ..locale = locale
          ..providerName = p.name;
        await isar.watchProviderTranslationEntitys.put(t);
      }
    });
  }
}

class _ProviderLite {
  final int providerId;
  final int? displayPriority;
  final String name;
  const _ProviderLite({
    required this.providerId,
    this.displayPriority,
    required this.name,
  });
}
