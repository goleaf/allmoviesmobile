import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/configuration_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('ApiConfiguration', () {
    test('parses configuration fixture', () async {
      final json = await loadJsonFixture('configuration.json');
      final configuration = ApiConfiguration.fromJson(json);
      expect(configuration.images.baseUrl, startsWith('http'));
      expect(configuration.changeKeys, contains('adult'));
      expect(configuration.toJson(), equals(json));
      expect(configuration, equals(ApiConfiguration.fromJson(json)));
      expect(
        configuration.copyWith(changeKeys: ['adult']).changeKeys,
        equals(['adult']),
      );
    });
  });

  group('CountryInfo', () {
    test('round-trips JSON entries', () async {
      final countries = await loadJsonListFixture('configuration_countries.json');
      final models = countries
          .whereType<Map<String, dynamic>>()
          .map(CountryInfo.fromJson)
          .toList();
      expect(models.first.code, 'US');
      expect(models.first, equals(CountryInfo.fromJson(countries.first as Map<String, dynamic>)));
      expect(models.first.toJson(), equals(countries.first));
    });
  });

  group('LanguageInfo', () {
    test('round-trips JSON entries', () async {
      final languages = await loadJsonListFixture('configuration_languages.json');
      final models = languages
          .whereType<Map<String, dynamic>>()
          .map(LanguageInfo.fromJson)
          .toList();
      expect(models.first.code, 'en');
      expect(models.first.toJson(), equals(languages.first));
      expect(models.first, equals(LanguageInfo.fromJson(languages.first as Map<String, dynamic>)));
    });
  });

  group('Job', () {
    test('handles default list when missing', () {
      const job = Job(department: 'Directing');
      expect(job.jobs, isEmpty);
      expect(job.copyWith(jobs: ['Director']).jobs, ['Director']);
      expect(Job.fromJson(job.toJson()), equals(job));
    });

    test('parses fixture', () async {
      final jobs = await loadJsonListFixture('configuration_jobs.json');
      final model = Job.fromJson(jobs.first as Map<String, dynamic>);
      expect(model.jobs, contains('Director'));
      expect(model.toJson(), equals(jobs.first));
    });
  });

  group('Timezone', () {
    test('round-trips JSON entries', () async {
      final zones = await loadJsonListFixture('configuration_timezones.json');
      final timezone = Timezone.fromJson(zones.first as Map<String, dynamic>);
      expect(timezone.countryCode, 'US');
      expect(timezone.zones, contains('America/New_York'));
      expect(timezone.toJson(), equals(zones.first));
      expect(timezone, equals(Timezone.fromJson(zones.first as Map<String, dynamic>)));
    });
  });
}
