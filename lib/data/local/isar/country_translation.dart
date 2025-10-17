import 'package:isar/isar.dart';

part 'country_translation.g.dart';

@collection
class CountryTranslationEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, composite: [CompositeIndex('locale')])
  late String iso3166_1;

  @Index()
  late String locale;

  late String name;
}
