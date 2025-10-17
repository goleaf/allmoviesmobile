import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
// Disabled Isar/web preload paths
// import '../../../data/local/isar/isar_provider.dart';
// import '../../../data/services/static_catalog_service.dart';
import 'splash_preload_screen.dart';

/// Gate shown at app startup that decides whether a preload is required.
class BootGate extends StatefulWidget {
  const BootGate({super.key, required this.onNavigateToHome});

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
    if (!mounted) return;
    // On web: skip preload
    if (kIsWeb) {
      Navigator.of(context).pushReplacementNamed(widget.onNavigateToHome());
      return;
    }
    // On native: show simple loading and pass-through for now
    Navigator.of(context).pushReplacementNamed(widget.onNavigateToHome());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
