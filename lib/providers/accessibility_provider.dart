import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/accessibility/accessibility_options.dart';
import '../core/constants/preferences_keys.dart';

/// {@template accessibility_provider}
/// Stores and persists accessibility-related user preferences that fine tune
/// the presentation of TMDB JSON data delivered by endpoints such as
/// `GET /3/movie/popular`, `GET /3/tv/popular`, and configuration payloads.
/// {@endtemplate}
class AccessibilityProvider extends ChangeNotifier {
  AccessibilityProvider(this._prefs)
      : _highContrast =
            _prefs.getBool(PreferenceKeys.accessibilityHighContrast) ?? false,
        _colorBlindFriendly =
            _prefs.getBool(PreferenceKeys.accessibilityColorBlind) ?? false,
        _boldText =
            _prefs.getBool(PreferenceKeys.accessibilityBoldText) ?? false,
        _showFocusIndicators =
            _prefs.getBool(PreferenceKeys.accessibilityFocusIndicators) ?? true,
        _keyboardNavigationHints =
            _prefs.getBool(PreferenceKeys.accessibilityKeyboardHints) ?? true,
        _textScaleFactor =
            _prefs.getDouble(PreferenceKeys.accessibilityTextScale) ?? 1.0;

  final SharedPreferences _prefs;

  bool _highContrast;
  bool _colorBlindFriendly;
  bool _boldText;
  bool _showFocusIndicators;
  bool _keyboardNavigationHints;
  double _textScaleFactor;

  bool get highContrast => _highContrast;
  bool get colorBlindFriendly => _colorBlindFriendly;
  bool get boldText => _boldText;
  bool get showFocusIndicators => _showFocusIndicators;
  bool get keyboardNavigationHints => _keyboardNavigationHints;
  double get textScaleFactor => _textScaleFactor;

  /// Returns a precomputed [AccessibilityOptions] snapshot.
  AccessibilityOptions get options => AccessibilityOptions(
        highContrast: _highContrast,
        colorBlindFriendly: _colorBlindFriendly,
        boldText: _boldText,
        showFocusIndicators: _showFocusIndicators,
        keyboardNavigationHints: _keyboardNavigationHints,
      );

  Future<void> setHighContrast(bool value) async {
    if (value == _highContrast) return;
    _highContrast = value;
    await _prefs.setBool(PreferenceKeys.accessibilityHighContrast, value);
    notifyListeners();
  }

  Future<void> setColorBlindFriendly(bool value) async {
    if (value == _colorBlindFriendly) return;
    _colorBlindFriendly = value;
    await _prefs.setBool(PreferenceKeys.accessibilityColorBlind, value);
    notifyListeners();
  }

  Future<void> setBoldText(bool value) async {
    if (value == _boldText) return;
    _boldText = value;
    await _prefs.setBool(PreferenceKeys.accessibilityBoldText, value);
    notifyListeners();
  }

  Future<void> setShowFocusIndicators(bool value) async {
    if (value == _showFocusIndicators) return;
    _showFocusIndicators = value;
    await _prefs.setBool(
      PreferenceKeys.accessibilityFocusIndicators,
      value,
    );
    notifyListeners();
  }

  Future<void> setKeyboardNavigationHints(bool value) async {
    if (value == _keyboardNavigationHints) return;
    _keyboardNavigationHints = value;
    await _prefs.setBool(
      PreferenceKeys.accessibilityKeyboardHints,
      value,
    );
    notifyListeners();
  }

  Future<void> setTextScaleFactor(double value) async {
    final normalized = value.clamp(1.0, 1.6) as double;
    if (normalized == _textScaleFactor) return;
    _textScaleFactor = normalized;
    await _prefs.setDouble(
      PreferenceKeys.accessibilityTextScale,
      normalized,
    );
    notifyListeners();
  }
}
