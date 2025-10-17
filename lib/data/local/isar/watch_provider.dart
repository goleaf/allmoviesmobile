import 'package:isar/isar.dart';

part 'watch_provider.g.dart';

@collection
class WatchProviderEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int providerId;

  int? displayPriority;
}

@collection
class WatchProviderTranslationEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late int providerId;

  @Index()
  late String locale;

  late String providerName;
}

