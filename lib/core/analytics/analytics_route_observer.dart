import 'dart:async';

import 'package:flutter/material.dart';

import 'app_analytics.dart';

/// Listens to navigation changes and forwards screen view events to
/// [AppAnalytics]. This mirrors the default behaviour provided by the
/// firebase_analytics navigator observer but keeps the implementation
/// framework-agnostic.
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  AnalyticsRouteObserver(this._analytics);

  final AppAnalytics _analytics;

  void _sendScreenView(PageRoute<dynamic> route) {
    final screenName = route.settings.name ?? route.runtimeType.toString();
    unawaited(
      _analytics.logScreenView(
        screenName: screenName,
        screenClass: route.runtimeType.toString(),
      ),
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute<dynamic>) {
      _sendScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute<dynamic>) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute<dynamic>) {
      _sendScreenView(previousRoute);
    }
  }
}
