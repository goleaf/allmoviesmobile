import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/core/utils/silent_updater.dart';
import 'package:allmovies_mobile/data/services/static_catalog_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('runIfDue does nothing when up-to-date', () async {
    var called = false;
    final catalog = StaticCatalogService(FakeRepository());
    final updater = SilentUpdater(catalog);
    await updater.runIfDue(
      locales: const [Locale('en')],
      needsOverride: () async => false,
      runOverride: () async => called = true,
    );
    expect(called, isFalse);
  });

  test('runIfDue triggers preload when stale', () async {
    var called = false;
    final catalog = StaticCatalogService(FakeRepository());
    final updater = SilentUpdater(catalog);
    await updater.runIfDue(
      locales: const [Locale('en')],
      needsOverride: () async => true,
      runOverride: () async => called = true,
    );
    expect(called, isTrue);
  });
}


