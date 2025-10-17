import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/change_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Change models', () {
    test('parses changes fixture', () async {
      final json = await loadJsonFixture('changes.json');
      final response = ChangesResponse.fromJson(json);
      expect(response.changes, hasLength(1));
      final change = response.changes.first;
      expect(change.items.single.action, 'added');
      expect(change.toJson(), equals(json['changes'].first));
      expect(response, equals(ChangesResponse.fromJson(json)));
    });

    test('ChangeItem handles dynamic value', () {
      const item = ChangeItem(
        id: '1',
        action: 'updated',
        time: '2024-01-01 12:00:00',
        value: {'title': 'Updated'},
        originalValue: {'title': 'Old'},
      );
      expect(ChangeItem.fromJson(item.toJson()), equals(item));
    });
  });
}
