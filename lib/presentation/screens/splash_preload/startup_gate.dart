import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/services/static_catalog_service.dart';
import '../../../data/local/isar/isar_provider.dart';
import '../../../data/tmdb_repository.dart';
import 'splash_preload_screen.dart';

/// Decides whether to show a splash preload sequence before rendering [child].
class StartupGate extends StatefulWidget {
  const StartupGate({super.key, required this.child});

  final Widget child;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool _ready = false;
  bool _shouldPreload = false;
  StaticCatalogService? _service;

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final repo = context.read<TmdbRepository>();
    final service = StaticCatalogService(repo);
    _service = service;

    try {
      // Only preload if first run or refresh needed for supported locales.
      // We use the app's supported locales list from [AppLocalizations].
      final locales = AppLocalizations.supportedLocales;

      // needsRefresh requires an Isar instance; the service will obtain it internally for preload,
      // but for the decision we conservatively show the preloader on first run only to avoid
      // Isar warmup here. This keeps startup lightweight and safe across platforms.
      // If you wish to force refresh periodically, you can always show the preloader unconditionally.
      // For now, check first run via a quick metadata read performed by the service after Isar opens.
      // We keep the decision simple: attempt a lightweight preload check by calling isFirstRun indirectly
      // through a tiny preload gate – if anything fails, we fall back to showing the preloader.

      // Show preloader when it's the first run. Otherwise continue to app.
      // We need to open Isar to check; delegate to service.isFirstRun safely.
      final isar = await IsarDbProvider.instance.isar; // ignore: invalid_use_of_visible_for_testing_member
      final isFirst = await service.isFirstRun(isar);

      if (!mounted) return;
      setState(() {
        _shouldPreload = isFirst;
        _ready = !isFirst;
      });
    } catch (_) {
      if (!mounted) return;
      // If decision fails (e.g., DB init), show preloader which will also provide retry.
      setState(() {
        _shouldPreload = true;
        _ready = false;
      });
    }
  }

  void _onPreloadDone() {
    if (!mounted) return;
    setState(() {
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return widget.child;
    }

    if (_shouldPreload && _service != null) {
      return SplashPreloadScreen(
        service: _service!,
        locales: AppLocalizations.supportedLocales,
        onDone: _onPreloadDone,
      );
    }

    // Minimal placeholder while deciding.
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}


