import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/core/constants/preferences_keys.dart';
import 'package:allmovies_mobile/providers/preferences_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PreferencesProvider TV filter presets', () {
    late SharedPreferences prefs;
    late PreferencesProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      provider = PreferencesProvider(prefs);
    });

    test('loadTvFilterPresets returns stored presets map', () async {
      final encoded = jsonEncode({
        'Drama Lovers': {'with_genres': '18'},
      });
      await prefs.setString(PreferenceKeys.tvFilterPresets, encoded);

      final presets = await provider.loadTvFilterPresets();
      expect(presets, contains('Drama Lovers'));
      expect(presets['Drama Lovers'], {'with_genres': '18'});
    });

    test('save, list, and delete presets', () async {
      await provider.saveTvFilterPreset('Binge Night', {'with_networks': '213'});
      await provider.saveTvFilterPreset('Documentaries', {'with_genres': '99'});

      var presets = await provider.loadTvFilterPresets();
      expect(presets.length, 2);
      expect(presets['Binge Night'], {'with_networks': '213'});

      final single = await provider.getTvFilterPreset('Documentaries');
      expect(single, {'with_genres': '99'});

      await provider.deleteTvFilterPreset('Binge Night');
      presets = await provider.loadTvFilterPresets();
      expect(presets.length, 1);
      expect(presets.containsKey('Binge Night'), isFalse);
    });
  });
}
