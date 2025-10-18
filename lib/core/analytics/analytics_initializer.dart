import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import '../logging/app_logger.dart';
import 'analytics_service.dart';

/// Bootstraps the analytics stack. The initializer attempts to configure
/// Firebase Analytics and gracefully falls back to the debug implementation
/// when no Firebase configuration is available (common for local/offline runs).
class AnalyticsInitializer {
  const AnalyticsInitializer({required this.logger});

  final AppLogger logger;

  Future<AnalyticsService> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      final firebaseAnalytics = FirebaseAnalytics.instance;
      await firebaseAnalytics.setAnalyticsCollectionEnabled(true);

      return FirebaseAnalyticsService(
        analytics: firebaseAnalytics,
        logger: logger,
      );
    } catch (error, stackTrace) {
      logger.warning(
        'Firebase Analytics initialization failed; using debug analytics instead.',
        error,
        stackTrace,
      );
      return DebugAnalyticsService(logger);
    }
  }
}
