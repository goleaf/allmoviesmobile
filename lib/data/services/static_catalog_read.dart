import 'package:isar/isar.dart';

import '../local/isar/country_translation.dart';
import '../local/isar/genre_translation.dart';
import '../local/isar/isar_provider.dart';
import '../local/isar/language_translation.dart';
import '../local/isar/watch_provider.dart';
import '../local/isar/watch_provider_region.dart';

class StaticCatalogReadService {
  Future<List<GenreTranslationEntity>> genres(String mediaType, String locale) async {
    final isar = await IsarDbProvider.instance.isar;
    return isar.genreTranslationEntitys
        .filter()
        .mediaTypeEqualTo(mediaType)
        .and()
        .localeEqualTo(locale)
        .findAll();
  }

  Future<List<WatchProviderTranslationEntity>> watchProviders(String locale) async {
    final isar = await IsarDbProvider.instance.isar;
    return isar.watchProviderTranslationEntitys.filter().localeEqualTo(locale).findAll();
  }

  Future<List<CountryTranslationEntity>> countries(String locale) async {
    final isar = await IsarDbProvider.instance.isar;
    return isar.countryTranslationEntitys.filter().localeEqualTo(locale).findAll();
  }

  Future<List<LanguageTranslationEntity>> languages(String locale) async {
    final isar = await IsarDbProvider.instance.isar;
    return isar.languageTranslationEntitys.filter().localeEqualTo(locale).findAll();
  }

  // ----------------------------------------------
  // UI helpers for reading from Isar caches
  // ----------------------------------------------

  /// Returns a map of genreId -> localized name for quick UI lookups.
  Future<Map<int, String>> genreNameMap(String mediaType, String locale) async {
    final list = await genres(mediaType, locale);
    final result = <int, String>{};
    for (final item in list) {
      result[item.genreId] = item.name;
    }
    return result;
  }

  /// Returns a map of ISO 3166-1 code -> localized country name.
  Future<Map<String, String>> countryNameMap(String locale) async {
    final list = await countries(locale);
    final result = <String, String>{};
    for (final item in list) {
      result[item.iso3166_1] = item.name;
    }
    return result;
  }

  /// Returns a map of ISO 639-1 code -> localized language name.
  Future<Map<String, String>> languageNameMap(String locale) async {
    final list = await languages(locale);
    final result = <String, String>{};
    for (final item in list) {
      result[item.iso639_1] = item.name;
    }
    return result;
  }

  /// UI model for a watch provider combined with base metadata.
  Future<List<WatchProviderUi>> watchProvidersUi(String locale) async {
    final isar = await IsarDbProvider.instance.isar;

    // Fetch translations for the locale and all base providers to join locally
    final translations = await isar.watchProviderTranslationEntitys
        .filter()
        .localeEqualTo(locale)
        .findAll();
    final bases = await isar.watchProviderEntitys.where().findAll();
    final baseById = {for (final b in bases) b.providerId: b};

    final list = translations
        .map((t) {
          final base = baseById[t.providerId];
          return WatchProviderUi(
            providerId: t.providerId,
            name: t.providerName,
            displayPriority: base?.displayPriority,
          );
        })
        .toList(growable: false);

    // Sort by display priority (asc, nulls last) then by name
    list.sort((a, b) {
      final ap = a.displayPriority;
      final bp = b.displayPriority;
      if (ap == null && bp == null) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      if (ap == null) return 1;
      if (bp == null) return -1;
      final cmp = ap.compareTo(bp);
      if (cmp != 0) return cmp;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return list;
  }

  /// Regions combined to a simple UI list (code + preferred name).
  /// Uses nativeName when available, otherwise falls back to englishName.
  Future<List<RegionUi>> regionsUi() async {
    final isar = await IsarDbProvider.instance.isar;
    final regions = await isar.watchProviderRegionEntitys.where().findAll();
    final list = regions
        .map((r) => RegionUi(
              code: r.iso3166_1,
              name: (r.nativeName?.isNotEmpty == true) ? r.nativeName! : r.englishName,
            ))
        .toList(growable: false);
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  /// Convenience: resolve a genre name for UI, or empty string if not found.
  Future<String> resolveGenreName(int genreId, String mediaType, String locale) async {
    final isar = await IsarDbProvider.instance.isar;
    final item = await isar.genreTranslationEntitys
        .filter()
        .genreIdEqualTo(genreId)
        .and()
        .mediaTypeEqualTo(mediaType)
        .and()
        .localeEqualTo(locale)
        .findFirst();
    return item?.name ?? '';
  }

  /// Convenience: resolve a provider name for UI, or empty string if not found.
  Future<String> resolveProviderName(int providerId, String locale) async {
    final isar = await IsarDbProvider.instance.isar;
    final item = await isar.watchProviderTranslationEntitys
        .filter()
        .providerIdEqualTo(providerId)
        .and()
        .localeEqualTo(locale)
        .findFirst();
    return item?.providerName ?? '';
  }

  /// Convenience: resolve a country name for UI by ISO code.
  Future<String> resolveCountryName(String iso3166_1, String locale) async {
    final isar = await IsarDbProvider.instance.isar;
    final item = await isar.countryTranslationEntitys
        .filter()
        .iso3166_1EqualTo(iso3166_1)
        .and()
        .localeEqualTo(locale)
        .findFirst();
    return item?.name ?? '';
  }

  /// Convenience: resolve a language name for UI by ISO code.
  Future<String> resolveLanguageName(String iso639_1, String locale) async {
    final isar = await IsarDbProvider.instance.isar;
    final item = await isar.languageTranslationEntitys
        .filter()
        .iso639_1EqualTo(iso639_1)
        .and()
        .localeEqualTo(locale)
        .findFirst();
    return item?.name ?? '';
  }
}

class WatchProviderUi {
  final int providerId;
  final String name;
  final int? displayPriority;
  const WatchProviderUi({required this.providerId, required this.name, required this.displayPriority});
}

class RegionUi {
  final String code;
  final String name;
  const RegionUi({required this.code, required this.name});
}

