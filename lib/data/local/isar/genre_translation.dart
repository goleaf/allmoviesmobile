import 'package:isar/isar.dart';

part 'genre_translation.g.dart';

@collection
class GenreTranslationEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late int genreId;

  /// 'movie' or 'tv'
  late String mediaType;

  /// BCP-47 or ISO code like 'en'/'ru'
  @Index()
  late String locale;

  late String name;
}
