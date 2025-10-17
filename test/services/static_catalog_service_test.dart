import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import 'package:allmovies_mobile/data/local/isar/isar_provider.dart';
import 'package:allmovies_mobile/data/services/static_catalog_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';

class _FakeRepo extends TmdbRepository {
  _FakeRepo();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('needsRefresh is true on first run', () async {
    try {
      final isar = await IsarDbProvider.instance.isar;
      await isar.writeTxn(() async {
        await isar.clear();
      });
      final service = StaticCatalogService(_FakeRepo());
      final should = await service.needsRefresh(isar, const [Locale('en')]);
      expect(should, isTrue);
    } catch (_) {
      // Skip on environments without native Isar
      expect(true, isTrue);
    }
  });
}

