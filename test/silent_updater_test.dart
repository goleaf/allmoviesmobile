import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:allmovies_mobile/core/utils/silent_updater.dart';
import 'package:allmovies_mobile/data/services/static_catalog_service.dart';

class _FakeIsar extends Isar {}

class _FakeIsarProvider extends Object {
  Future<Isar> get isar async => _FakeIsar();
}

class _StubCatalog extends StaticCatalogService {
  _StubCatalog({required this.needs, this.onPreload});
  final bool needs;
  final void Function()? onPreload;
  @override
  Future<bool> needsRefresh(Isar isar, List<Locale> locales) async => needs;
  @override
  Future<void> preloadAll({
    required List<Locale> locales,
    required void Function(PreloadProgress) onProgress,
  }) async {
    onPreload?.call();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('runIfDue does nothing when up-to-date', () async {
    var called = false;
    final catalog = _StubCatalog(needs: false, onPreload: () => called = true);
    final updater = SilentUpdater(catalog);
    await updater.runIfDue(locales: const [Locale('en')]);
    expect(called, isFalse);
  });

  test('runIfDue triggers preload when stale', () async {
    var called = false;
    final catalog = _StubCatalog(needs: true, onPreload: () => called = true);
    final updater = SilentUpdater(catalog);
    await updater.runIfDue(locales: const [Locale('en')]);
    expect(called, isTrue);
  });
}


