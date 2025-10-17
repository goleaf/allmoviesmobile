import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/user_list.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('UserList parsing', () {
    test('parses collaborators, comments, and items', () async {
      final json = await loadJsonFixture('user_list.json');
      final list = UserList.fromJson(json);
      expect(list.name, 'Favorite Sci-Fi');
      expect(list.items.single.mediaId, 603);
      expect(list.collaborators.single.displayName, 'Friend');
      expect(list.comments.single.message, 'Great picks!');
      expect(list.itemCount, 1);
      expect(list.allowsEditsBy('friend'), isFalse);
      final updated = list.copyWith(isCollaborative: true);
      expect(updated.allowsEditsBy('friend'), isTrue);
    });
  });

  group('ListEntry serialization', () {
    test('round-trips json with copyWith', () async {
      final json = await loadJsonFixture('user_list.json');
      final entryJson = (json['items'] as List).first as Map<String, dynamic>;
      final entry = ListEntry.fromJson(entryJson);
      expect(entry.toJson()['media_id'], 603);
      expect(entry.copyWith(position: 2).position, 2);
    });
  });

  group('ListCollaborator & ListComment', () {
    test('round-trip serialization', () async {
      final json = await loadJsonFixture('user_list.json');
      final collaboratorJson =
          (json['collaborators'] as List).first as Map<String, dynamic>;
      final commentJson =
          (json['comments'] as List).first as Map<String, dynamic>;
      final collaborator = ListCollaborator.fromJson(collaboratorJson);
      final comment = ListComment.fromJson(commentJson);
      expect(collaborator.toJson()['user_id'], 'friend');
      expect(comment.toJson()['id'], 'comment1');
    });
  });
}
