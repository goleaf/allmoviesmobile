import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityProvider extends ChangeNotifier {
  AccessibilityProvider(this._prefs) {
    _load();
  }

  static const _highContrastKey = 'accessibility_high_contrast_enabled';
  static const _textScaleKey = 'accessibility_text_scale_factor';
  static const _colorBlindKey = 'accessibility_color_blind_palette';

  final SharedPreferences _prefs;

  bool _highContrastEnabled = false;
  bool _colorBlindFriendlyPalette = false;
  double _textScaleFactor = 1.0;

  bool get highContrastEnabled => _highContrastEnabled;
  bool get colorBlindFriendlyPalette => _colorBlindFriendlyPalette;
  double get textScaleFactor => _textScaleFactor;

  Future<void> _load() async {
    _highContrastEnabled = _prefs.getBool(_highContrastKey) ?? false;
    _colorBlindFriendlyPalette = _prefs.getBool(_colorBlindKey) ?? false;
    _textScaleFactor = _prefs.getDouble(_textScaleKey) ?? 1.0;
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
}
