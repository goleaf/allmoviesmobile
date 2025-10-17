import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../../data/local/isar/isar_provider.dart';
import '../../data/services/static_catalog_service.dart';

/// Silently checks once per 7 days whether static catalogs (genres, providers,
/// countries, languages) should be refreshed for supported locales and, if so,
/// performs a background refresh without blocking the UI.
class SilentUpdater {
  SilentUpdater(this._catalogService, {IsarDbProvider? isarProvider})
      : _isarProvider = isarProvider ?? IsarDbProvider.instance;

  final StaticCatalogService _catalogService;
  final IsarDbProvider _isarProvider;

  /// Runs the update if needed. Never throws; errors are swallowed.
  Future<void> runIfDue({
    required List<Locale> locales,
    Future<bool> Function()? needsOverride,
    Future<void> Function()? runOverride,
  }) async {
    try {
      final bool needs;
      if (needsOverride != null) {
        needs = await needsOverride();
      } else {
        final isar = await _isarProvider.isar;
        needs = await _catalogService.needsRefresh(isar, locales);
      }
      if (!needs) return;

      if (runOverride != null) {
        await runOverride();
      } else {
        // Fire and await silently to keep logic simple; callers can choose to not await.
        await _catalogService.preloadAll(
          locales: locales,
          onProgress: (_) {},
        );
      }
    } catch (_) {
      // Intentionally ignore errors to avoid disrupting UX.
    }
  }
}


