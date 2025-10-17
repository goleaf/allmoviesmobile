import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/local/isar/isar_provider.dart';
import '../../../data/services/static_catalog_service.dart';
import 'splash_preload_screen.dart';

/// Gate shown at app startup that decides whether a preload is required.
class BootGate extends StatefulWidget {
  const BootGate({super.key, required this.service, required this.onNavigateToHome});

  final StaticCatalogService service;
  final String Function() onNavigateToHome;

  @override
  State<BootGate> createState() => _BootGateState();
}

class _BootGateState extends State<BootGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decide();
    });
  }

  Future<void> _decide() async {
    final locales = AppLocalizations.supportedLocales;
    final isar = await IsarDbProvider.instance.isar;
    final firstRun = await widget.service.isFirstRun(isar);
    final refresh = await widget.service.needsRefresh(isar, locales);

    if (!mounted) return;

    if (firstRun || refresh) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SplashPreloadScreen(
            service: widget.service,
            locales: locales,
            onDone: () {
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed(widget.onNavigateToHome());
            },
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacementNamed(widget.onNavigateToHome());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}


