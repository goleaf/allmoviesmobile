import 'package:isar/isar.dart';

import '../local/isar/country_translation.dart';
import '../local/isar/genre_translation.dart';
import '../local/isar/isar_provider.dart';
import '../local/isar/language_translation.dart';
import '../local/isar/watch_provider.dart';

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
}

