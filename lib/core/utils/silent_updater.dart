import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Avoid importing Isar on web to prevent JS big-int issues
// import 'package:isar/isar.dart';

// import '../../data/local/isar/isar_provider.dart';
import '../../data/services/static_catalog_service.dart';

/// Silently checks once per 7 days whether static catalogs (genres, providers,
/// countries, languages) should be refreshed for supported locales and, if so,
/// performs a background refresh without blocking the UI.
class SilentUpdater {
  SilentUpdater(this._catalogService);

  final StaticCatalogService _catalogService;

  /// Runs the update if needed. Never throws; disabled on web.
  Future<void> runIfDue({
    required List<Locale> locales,
    Future<bool> Function()? needsOverride,
    Future<void> Function()? runOverride,
  }) async {
    if (kIsWeb) return; // disabled for web build
    try {
      final bool needs = needsOverride != null ? await needsOverride() : false;
      if (!needs) return;
      if (runOverride != null) {
        await runOverride();
      } else {
        await _catalogService.preloadAll(
          locales: locales,
          onProgress: (_) {},
        );
      }
    } catch (_) {}
  }
}


