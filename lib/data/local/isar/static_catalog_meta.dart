import 'package:isar/isar.dart';

part 'static_catalog_meta.g.dart';

@collection
class StaticCatalogMetaEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String key = 'static_catalog';

  late int lastUpdatedMs;

  /// Stored as comma-separated locales
  String localesCsv = '';
}

