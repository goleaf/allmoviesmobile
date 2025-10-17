import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _highContrastKey = 'accessibility_high_contrast';
const _textScaleKey = 'accessibility_text_scale';
const _focusIndicatorsKey = 'accessibility_focus_indicators';
const _keyboardNavigationKey = 'accessibility_keyboard_navigation';
const _colorBlindFriendlyKey = 'accessibility_color_blind_palette';

class AccessibilityProvider extends ChangeNotifier {
  AccessibilityProvider(this._prefs) {
    _highContrast = _prefs.getBool(_highContrastKey) ?? false;
    _textScaleFactor = _prefs.getDouble(_textScaleKey) ?? 1.0;
    _showFocusIndicators = _prefs.getBool(_focusIndicatorsKey) ?? true;
    _enableKeyboardNavigation =
        _prefs.getBool(_keyboardNavigationKey) ?? true;
    _colorBlindFriendlyPalette =
        _prefs.getBool(_colorBlindFriendlyKey) ?? false;
  }

  final SharedPreferences _prefs;

  late bool _highContrast;
  late double _textScaleFactor;
  late bool _showFocusIndicators;
  late bool _enableKeyboardNavigation;
  late bool _colorBlindFriendlyPalette;

  bool get highContrast => _highContrast;
  double get textScaleFactor => _textScaleFactor;
  bool get showFocusIndicators => _showFocusIndicators;
  bool get enableKeyboardNavigation => _enableKeyboardNavigation;
  bool get colorBlindFriendlyPalette => _colorBlindFriendlyPalette;

  Future<void> toggleHighContrast(bool value) async {
    if (_highContrast == value) return;
    _highContrast = value;
    await _prefs.setBool(_highContrastKey, value);
    notifyListeners();
  }

  Future<void> setTextScaleFactor(double factor) async {
    if (_textScaleFactor == factor) return;
    _textScaleFactor = factor.clamp(0.8, 1.6);
    await _prefs.setDouble(_textScaleKey, _textScaleFactor);
    notifyListeners();
  }

  Future<void> toggleFocusIndicators(bool value) async {
    if (_showFocusIndicators == value) return;
    _showFocusIndicators = value;
    await _prefs.setBool(_focusIndicatorsKey, value);
    notifyListeners();
  }

  Future<void> toggleKeyboardNavigation(bool value) async {
    if (_enableKeyboardNavigation == value) return;
    _enableKeyboardNavigation = value;
    await _prefs.setBool(_keyboardNavigationKey, value);
    notifyListeners();
  }

  Future<void> toggleColorBlindFriendlyPalette(bool value) async {
    if (_colorBlindFriendlyPalette == value) return;
    _colorBlindFriendlyPalette = value;
    await _prefs.setBool(_colorBlindFriendlyKey, value);
    notifyListeners();
  }
}
