import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/preferences_keys.dart';

class AccessibilityProvider extends ChangeNotifier {
  AccessibilityProvider(this._prefs)
      : _highContrast =
            _prefs.getBool(PreferenceKeys.highContrast) ?? false,
        _colorBlindFriendly =
            _prefs.getBool(PreferenceKeys.colorBlindFriendly) ?? false,
        _focusIndicatorsEnabled =
            _prefs.getBool(PreferenceKeys.focusIndicators) ?? true,
        _textScaleFactor =
            _prefs.getDouble(PreferenceKeys.textScale) ?? 1.0;

  static const double minTextScale = 0.8;
  static const double maxTextScale = 1.6;
  static const double textScaleStep = 0.1;

  final SharedPreferences _prefs;

  bool _highContrast;
  bool _colorBlindFriendly;
  bool _focusIndicatorsEnabled;
  double _textScaleFactor;

  bool get highContrastEnabled => _highContrast;
  bool get colorBlindFriendlyEnabled => _colorBlindFriendly;
  bool get focusIndicatorsEnabled => _focusIndicatorsEnabled;
  double get textScaleFactor => _textScaleFactor;

  Future<void> setHighContrast(bool value) async {
    if (value == _highContrast) return;
    _highContrast = value;
    await _prefs.setBool(PreferenceKeys.highContrast, value);
    notifyListeners();
  }

  Future<void> setColorBlindFriendly(bool value) async {
    if (value == _colorBlindFriendly) return;
    _colorBlindFriendly = value;
    await _prefs.setBool(PreferenceKeys.colorBlindFriendly, value);
    notifyListeners();
  }

  Future<void> setFocusIndicatorsEnabled(bool value) async {
    if (value == _focusIndicatorsEnabled) return;
    _focusIndicatorsEnabled = value;
    await _prefs.setBool(PreferenceKeys.focusIndicators, value);
    notifyListeners();
  }

  Future<void> setTextScaleFactor(double value) async {
    final normalized = value.clamp(minTextScale, maxTextScale);
    if ((normalized - _textScaleFactor).abs() < 0.001) return;
    _textScaleFactor = normalized;
    await _prefs.setDouble(PreferenceKeys.textScale, normalized);
    notifyListeners();
  }

  void increaseTextScale() {
    final next = (_textScaleFactor + textScaleStep).clamp(
      minTextScale,
      maxTextScale,
    );
    setTextScaleFactor(next);
  }

  void decreaseTextScale() {
    final next = (_textScaleFactor - textScaleStep).clamp(
      minTextScale,
      maxTextScale,
    );
    setTextScaleFactor(next);
  }

  void resetTextScale() {
    setTextScaleFactor(1.0);
  }
}
