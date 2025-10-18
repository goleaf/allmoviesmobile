import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityProvider extends ChangeNotifier {
  AccessibilityProvider(this._prefs) {
    _load();
  }

  static const _highContrastKey = 'accessibility_high_contrast_enabled';
  static const _textScaleKey = 'accessibility_text_scale_factor';
  static const _colorBlindKey = 'accessibility_color_blind_palette';
  static const _focusIndicatorsKey = 'accessibility_show_focus_indicators';
  static const _keyboardNavigationKey =
      'accessibility_enable_keyboard_navigation';

  final SharedPreferences _prefs;

  bool _highContrastEnabled = false;
  bool _colorBlindFriendlyPalette = false;
  double _textScaleFactor = 1.0;
  bool _showFocusIndicators = false;
  bool _enableKeyboardNavigation = false;

  bool get highContrastEnabled => _highContrastEnabled;
  bool get colorBlindFriendlyPalette => _colorBlindFriendlyPalette;
  double get textScaleFactor => _textScaleFactor;
  bool get showFocusIndicators => _showFocusIndicators;
  bool get enableKeyboardNavigation => _enableKeyboardNavigation;

  Future<void> _load() async {
    _highContrastEnabled = _prefs.getBool(_highContrastKey) ?? false;
    _colorBlindFriendlyPalette = _prefs.getBool(_colorBlindKey) ?? false;
    _textScaleFactor = _prefs.getDouble(_textScaleKey) ?? 1.0;
    _showFocusIndicators = _prefs.getBool(_focusIndicatorsKey) ?? false;
    _enableKeyboardNavigation =
        _prefs.getBool(_keyboardNavigationKey) ?? false;
    notifyListeners();
  }

  Future<void> setHighContrastEnabled(bool value) async {
    if (value == _highContrastEnabled) return;
    _highContrastEnabled = value;
    await _prefs.setBool(_highContrastKey, value);
    notifyListeners();
  }

  Future<void> setColorBlindFriendlyPalette(bool value) async {
    if (value == _colorBlindFriendlyPalette) return;
    _colorBlindFriendlyPalette = value;
    await _prefs.setBool(_colorBlindKey, value);
    notifyListeners();
  }

  Future<void> setTextScaleFactor(double value) async {
    if (value == _textScaleFactor) return;
    final normalized = value.clamp(0.8, 2.0);
    _textScaleFactor =
        normalized is double ? normalized : (normalized as num).toDouble();
    await _prefs.setDouble(_textScaleKey, _textScaleFactor);
    notifyListeners();
  }

  Future<void> setShowFocusIndicators(bool value) async {
    if (value == _showFocusIndicators) return;
    _showFocusIndicators = value;
    await _prefs.setBool(_focusIndicatorsKey, value);
    notifyListeners();
  }

  Future<void> setEnableKeyboardNavigation(bool value) async {
    if (value == _enableKeyboardNavigation) return;
    _enableKeyboardNavigation = value;
    await _prefs.setBool(_keyboardNavigationKey, value);
    notifyListeners();
  }
}
