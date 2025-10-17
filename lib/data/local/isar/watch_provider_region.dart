import 'package:isar/isar.dart';

part 'watch_provider_region.g.dart';

@collection
class WatchProviderRegionEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String iso3166_1;

  late String englishName;

  String? nativeName;
}
