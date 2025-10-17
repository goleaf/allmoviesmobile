import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/services/static_catalog_service.dart';

class SplashPreloadScreen extends StatefulWidget {
  static const routeName = '/splash-preload';
  final StaticCatalogService service;
  final List<Locale> locales;
  final VoidCallback onDone;

  const SplashPreloadScreen({
    super.key,
    required this.service,
    required this.locales,
    required this.onDone,
  });

  @override
  State<SplashPreloadScreen> createState() => _SplashPreloadScreenState();
}

class _SplashPreloadScreenState extends State<SplashPreloadScreen> {
  double progress = 0;
  String message = '';

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      final totalLocales = widget.locales.length;
      await widget.service.preloadAll(
        locales: widget.locales,
        onProgress: (p) {
          setState(() {
            progress = p.current / p.total;
            message = p.message;
          });
        },
      );
      widget.onDone();
    } catch (_) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      setState(() {
        message = t.t('errors.load_failed');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(size: 96),
              const SizedBox(height: 24),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              Text(message.isEmpty ? t.t('common.loading') : message),
              const SizedBox(height: 16),
              if (message.isNotEmpty &&
                  message ==
                      AppLocalizations.of(context).t('errors.load_failed'))
                ElevatedButton(
                  onPressed: _run,
                  child: Text(t.t('common.retry')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
