import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/navigation/app_destination.dart';

class AppStateProvider extends ChangeNotifier {
  AppStateProvider(this._prefs) {
    _currentDestinationIndex =
        _prefs.getInt(_destinationKey) ?? AppDestination.home.index;
    final rawRoutes = _prefs.getString(_routesKey);
    if (rawRoutes != null && rawRoutes.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawRoutes) as Map<String, dynamic>;
        _lastRoutes = decoded.map(
          (key, value) => MapEntry(key, value as String),
        );
      } catch (_) {
        _lastRoutes = <String, String>{};
      }
    }
    _persistedSearchQuery =
        _prefs.getString(_searchQueryKey)?.trim() ?? '';
  }

  static const _destinationKey = 'app_state.current_destination';
  static const _routesKey = 'app_state.routes';
  static const _searchQueryKey = 'app_state.search.query';

  final SharedPreferences _prefs;

  int _currentDestinationIndex = AppDestination.home.index;
  Map<String, String> _lastRoutes = <String, String>{};
  String _persistedSearchQuery = '';

  AppDestination get currentDestination {
    final values = AppDestination.values;
    final clampedIndex = _currentDestinationIndex.clamp(0, values.length - 1);
    return values[clampedIndex];
  }

  String? lastRouteFor(AppDestination destination) =>
      _lastRoutes[destination.name];

  String get persistedSearchQuery => _persistedSearchQuery;

  void updateDestination(AppDestination destination) {
    if (destination.index == _currentDestinationIndex) {
      return;
    }
    _currentDestinationIndex = destination.index;
    unawaited(_prefs.setInt(_destinationKey, _currentDestinationIndex));
    notifyListeners();
  }

  void persistLastRoute({
    required AppDestination destination,
    String? route,
  }) {
    if (route == null || route.isEmpty) {
      return;
    }
    final next = Map<String, String>.from(_lastRoutes);
    next[destination.name] = route;
    _lastRoutes = next;
    unawaited(_prefs.setString(_routesKey, jsonEncode(_lastRoutes)));
  }

  void saveSearchQuery(String query) {
    final trimmed = query.trim();
    if (trimmed == _persistedSearchQuery) {
      return;
    }
    _persistedSearchQuery = trimmed;
    unawaited(_prefs.setString(_searchQueryKey, trimmed));
    notifyListeners();
  }

  void clearSearchQuery() {
    if (_persistedSearchQuery.isEmpty) {
      return;
    }
    _persistedSearchQuery = '';
    unawaited(_prefs.remove(_searchQueryKey));
    notifyListeners();
  }
}
