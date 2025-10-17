import 'package:allmovies_mobile/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Prefs implements SharedPreferences {
  final Map<String, Object> _data = {};
  @override
  Set<String> getKeys() => _data.keys.toSet();
  @override
  Object? get(String key) => _data[key];
  @override
  bool containsKey(String key) => _data.containsKey(key);
  @override
  Future<bool> setString(String key, String value) async { _data[key] = value; return true; }
  @override
  Future<bool> clear() async { _data.clear(); return true; }
  @override
  Future<bool> remove(String key) async { _data.remove(key); return true; }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('LocaleProvider get/set', () async {
    final prefs = _Prefs();
    final provider = LocaleProvider(prefs);
    expect(provider.locale.languageCode, anyOf('en', 'ru', 'uk'));

    await provider.setLanguageCode('ru');
    expect(provider.languageCode, 'ru');
    expect(provider.languageName, 'Русский');

    await provider.setLocale(const Locale('uk'));
    expect(provider.languageCode, 'uk');
    expect(provider.getLanguageName(const Locale('en')), 'English');
  });
}


