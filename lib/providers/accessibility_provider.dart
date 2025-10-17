import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/preferences_keys.dart';

/// Stores accessibility preferences (contrast, font scale, etc.) and notifies listeners when they change.
///
/// The provider persists every toggle in [SharedPreferences] so the app can restore the user's
/// accessibility adjustments between sessions.  Each setter guards against redundant writes to keep
/// disk I/O low and to avoid spurious rebuilds.
class AccessibilityProvider extends ChangeNotifier {
  AccessibilityProvider(this._prefs)
      : _highContrast =
            _prefs.getBool(PreferenceKeys.accessibilityHighContrast) ?? false,
        _colorBlindFriendly =
            _prefs.getBool(PreferenceKeys.accessibilityColorBlindPalette) ??
                false,
        _textScale =
            _prefs.getDouble(PreferenceKeys.accessibilityTextScale) ?? 1.0,
        _focusIndicatorsEnabled =
            _prefs.getBool(PreferenceKeys.accessibilityFocusIndicators) ?? true,
        _keyboardNavigation =
            _prefs.getBool(PreferenceKeys.accessibilityKeyboardNavigation) ??
                true;

  final SharedPreferences _prefs;

  bool _highContrast;
  bool _colorBlindFriendly;
  double _textScale;
  bool _focusIndicatorsEnabled;
  bool _keyboardNavigation;

  bool get highContrast => _highContrast;
  bool get colorBlindFriendly => _colorBlindFriendly;
  double get textScale => _textScale;
  bool get focusIndicatorsEnabled => _focusIndicatorsEnabled;
  bool get keyboardNavigation => _keyboardNavigation;

  Future<void> setHighContrast(bool value) async {
    if (value == _highContrast) return;
    _highContrast = value;
    await _prefs.setBool(PreferenceKeys.accessibilityHighContrast, value);
    notifyListeners();
  }

  Future<void> setColorBlindFriendly(bool value) async {
    if (value == _colorBlindFriendly) return;
    _colorBlindFriendly = value;
    await _prefs.setBool(
      PreferenceKeys.accessibilityColorBlindPalette,
      value,
    );
    notifyListeners();
  }

  Future<void> setTextScale(double factor) async {
    final normalized = factor.clamp(0.8, 1.6);
    if (normalized == _textScale) return;
    _textScale = normalized;
    await _prefs.setDouble(
      PreferenceKeys.accessibilityTextScale,
      normalized,
    );
    notifyListeners();
  }

  Future<void> setFocusIndicatorsEnabled(bool value) async {
    if (value == _focusIndicatorsEnabled) return;
    _focusIndicatorsEnabled = value;
    await _prefs.setBool(
      PreferenceKeys.accessibilityFocusIndicators,
      value,
    );
    notifyListeners();
  }

  Future<void> setKeyboardNavigation(bool value) async {
    if (value == _keyboardNavigation) return;
    _keyboardNavigation = value;
    await _prefs.setBool(
      PreferenceKeys.accessibilityKeyboardNavigation,
      value,
    );
    notifyListeners();
  }
}
