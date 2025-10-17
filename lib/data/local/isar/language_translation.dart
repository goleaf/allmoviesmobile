import 'package:isar/isar.dart';

part 'language_translation.g.dart';

@collection
class LanguageTranslationEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, composite: [CompositeIndex('locale')])
  late String iso639_1;

  @Index()
  late String locale;

  late String name;
}

