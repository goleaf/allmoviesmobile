import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/diagnostics/performance_profiler.dart';

class DiagnosticsProvider extends ChangeNotifier {
  DiagnosticsProvider(this._prefs) {
    _performanceOverlayEnabled =
        _prefs.getBool(_performanceOverlayKey) ?? false;
    _profilerEnabled = _prefs.getBool(_profilerKey) ?? false;

    if (_profilerEnabled) {
      PerformanceProfiler.instance.enable();
    }
  }

  static const String _performanceOverlayKey =
      'diagnostics.performance_overlay.enabled';
  static const String _profilerKey = 'diagnostics.profiler.enabled';

  final SharedPreferences _prefs;

  bool _performanceOverlayEnabled = false;
  bool _profilerEnabled = false;

  bool get performanceOverlayEnabled => _performanceOverlayEnabled;
  bool get profilerEnabled => _profilerEnabled;
  ValueListenable<FrameTimingsStats?> get statsListenable =>
      PerformanceProfiler.instance.statsNotifier;

  Future<void> setPerformanceOverlayEnabled(bool value) async {
    if (value == _performanceOverlayEnabled) {
      return;
    }
    _performanceOverlayEnabled = value;
    await _prefs.setBool(_performanceOverlayKey, value);
    notifyListeners();
  }

  Future<void> setProfilerEnabled(bool value) async {
    if (value == _profilerEnabled) {
      return;
    }
    _profilerEnabled = value;
    await _prefs.setBool(_profilerKey, value);
    if (value) {
      PerformanceProfiler.instance.enable();
    } else {
      PerformanceProfiler.instance.disable();
    }
    notifyListeners();
  }
}
