import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/account_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Account models', () {
    test('AccountProfile parses avatar data', () async {
      final json = await loadJsonFixture('account_profile.json');
      final profile = AccountProfile.fromJson(json);
      expect(profile.id, 12345);
      expect(profile.username, 'janedoe');
      expect(profile.avatar.gravatarHash, '123abc');
    });

    test('AccountListSummary parses list fixtures', () async {
      final listJson = await loadJsonListFixture('account_lists.json');
      final summary = AccountListSummary.fromJson(
        listJson.first as Map<String, dynamic>,
      );
      expect(summary.id, '1');
      expect(summary.itemCount, 10);
      expect(summary.favoriteCount, 2);
    });
  });
}
