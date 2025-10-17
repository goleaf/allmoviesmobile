import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/tv_filter_preset.dart';
import 'package:allmovies_mobile/data/tv_filter_presets_repository.dart';

void main() {
  group('TvFilterPresetsRepository', () {
    late SharedPreferences prefs;
    late TvFilterPresetsRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      repository = TvFilterPresetsRepository(prefs);
    });

    test('savePreset adds or replaces presets by name', () async {
      await repository.savePreset(
        const TvFilterPreset(name: 'Favorites', filters: {'sort_by': 'popularity.desc'}),
      );
      await repository.savePreset(
        const TvFilterPreset(name: 'Favorites', filters: {'sort_by': 'vote_average.desc'}),
      );
      await repository.savePreset(
        const TvFilterPreset(name: 'Sci-Fi', filters: {'with_genres': '878'}),
      );

      final presets = await repository.loadPresets();
      expect(presets.length, 2);
      expect(
        presets.firstWhere((preset) => preset.name == 'Favorites').filters,
        {'sort_by': 'vote_average.desc'},
      );
      expect(
        presets.firstWhere((preset) => preset.name == 'Sci-Fi').filters,
        {'with_genres': '878'},
      );
    });

    test('deletePreset removes entries and loadActiveSelection survives', () async {
      await repository.savePreset(
        const TvFilterPreset(name: 'Drama', filters: {'with_genres': '18'}),
      );
      await repository.savePreset(
        const TvFilterPreset(name: 'Comedy', filters: {'with_genres': '35'}),
      );

      await repository.deletePreset('Drama');

      final presets = await repository.loadPresets();
      expect(presets.map((preset) => preset.name).toList(), ['Comedy']);
    });

    test('persistActiveSelection stores and clears active filters', () async {
      await repository.persistActiveSelection(
        filters: {'sort_by': 'vote_average.desc'},
        presetName: 'Critics',
      );

      var selection = await repository.loadActiveSelection();
      expect(selection.presetName, 'Critics');
      expect(selection.filters, {'sort_by': 'vote_average.desc'});

      await repository.clearActiveSelection();
      selection = await repository.loadActiveSelection();
      expect(selection.presetName, isNull);
      expect(selection.filters, isNull);
    });
  });
}
