import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/network_detailed_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('NetworkDetailed', () {
    test('round-trip json', () async {
      final json = await loadJsonFixture('network_detailed.json');
      final model = NetworkDetailed.fromJson(json);
      expect(model.id, 49);
      expect(model.alternativeNames, hasLength(1));
      expect(model.toJson(), equals(json));
      expect(model, equals(NetworkDetailed.fromJson(json)));
      expect(
        model.copyWith(headquarters: 'New York City').headquarters,
        'New York City',
      );
    });
  });

  group('AlternativeName', () {
    test('supports json conversion', () async {
      final json = await loadJsonFixture('network_detailed.json');
      final alt = AlternativeName.fromJson(
        (json['alternative_names'] as List).first as Map<String, dynamic>,
      );
      expect(alt.toJson(), equals((json['alternative_names'] as List).first));
      expect(alt, equals(AlternativeName.fromJson(alt.toJson())));
    });
  });
}
