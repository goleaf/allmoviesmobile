import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
// Ensures Isar native libraries are bundled for Flutter (tests & app)
// ignore: unused_import
import 'package:isar_flutter_libs/isar_flutter_libs.dart';

import 'country_translation.dart';
import 'genre_translation.dart';
import 'language_translation.dart';
import 'static_catalog_meta.dart';
import 'watch_provider.dart';
import 'watch_provider_region.dart';

class IsarDbProvider {
  IsarDbProvider._();
  static final IsarDbProvider instance = IsarDbProvider._();

  Isar? _isar;
  Future<Isar>? _opening;

  Future<Isar> get isar async {
    if (_isar != null) return _isar!;
    // Ensure only one open is in flight; await existing if present
    _opening ??= _openInternal();
    _isar = await _opening!;
    _opening = null;
    return _isar!;
  }

  Future<Isar> _openInternal() async {
    Directory dir;
    try {
      dir = await getApplicationDocumentsDirectory();
    } catch (_) {
      // Tests/Vm without platform channels
      dir = await Directory.systemTemp.createTemp('isar_test_');
    }
    return Isar.open(
      [
        GenreTranslationEntitySchema,
        WatchProviderEntitySchema,
        WatchProviderTranslationEntitySchema,
        WatchProviderRegionEntitySchema,
        CountryTranslationEntitySchema,
        LanguageTranslationEntitySchema,
        StaticCatalogMetaEntitySchema,
      ],
      directory: dir.path,
      inspector: false,
    );
  }

  Future<void> close() async {
    final db = _isar;
    _isar = null;
    _opening = null;
    if (db != null && db.isOpen) {
      await db.close();
    }
  }
}

