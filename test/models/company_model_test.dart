import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/company_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Company model', () {
    late Map<String, dynamic> json;
    late Company company;

    setUp(() async {
      json = await loadJsonFixture('company.json');
      company = Company.fromJson(json);
    });

    test('fromJson parses full payload', () {
      expect(company.id, 79);
      expect(company.parentCompany, isNotNull);
      expect(company.logoGallery, isNotEmpty);
    });

    test('toJson produces round-trip map', () {
      expect(company.toJson(), equals(json));
    });

    test('equality compares deep values', () {
      final other = Company.fromJson(json);
      expect(company, equals(other));
      expect(company.hashCode, equals(other.hashCode));
    });

    test('copyWith creates modified instance', () {
      final renamed = company.copyWith(name: 'Renamed Co.');
      expect(renamed.name, 'Renamed Co.');
      expect(company.name, 'Village Roadshow Pictures');
    });

    test('handles missing optional collections', () async {
      final minimalJson = await loadJsonFixture('company_minimal.json');
      final minimal = Company.fromJson(minimalJson);
      expect(minimal.alternativeNames, isEmpty);
      expect(minimal.logoGallery, isEmpty);
      expect(minimal.producedMovies, isEmpty);
      expect(minimal.producedSeries, isEmpty);
    });
  });

  group('ParentCompany', () {
    test('round-trips via JSON', () async {
      final companyJson = await loadJsonFixture('company.json');
      final parentJson = companyJson['parent_company'] as Map<String, dynamic>;
      final parent = ParentCompany.fromJson(parentJson);
      expect(parent.toJson(), equals(parentJson));
      expect(parent, equals(ParentCompany.fromJson(parentJson)));
    });
  });

  group('CompanyLogo', () {
    test('round-trips via JSON', () async {
      final companyJson = await loadJsonFixture('company.json');
      final logos = (companyJson['logo_gallery'] as List).cast<Map<String, dynamic>>();
      final logo = CompanyLogo.fromJson(logos.first);
      expect(logo.toJson(), equals(logos.first));
      expect(logo.copyWith(width: 1024).width, 1024);
    });
  });
}
