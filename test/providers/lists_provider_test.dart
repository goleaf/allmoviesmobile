import 'package:allmovies_mobile/data/models/user_list.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/providers/lists_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _InMemoryPrefs implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  Set<String> getKeys() => _data.keys.toSet();
  @override
  Object? get(String key) => _data[key];
  @override
  String? getString(String key) => _data[key] as String?;
  @override
  bool containsKey(String key) => _data.containsKey(key);
  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  // ignore: no_leading_underscores_for_local_identifiers
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LocalStorageService _makeStorage() {
  return LocalStorageService(_InMemoryPrefs());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ListsProvider', () {
    test('initializes with seeded lists when storage empty', () async {
      final storage = _makeStorage();
      final provider = ListsProvider(
        storage,
        currentUserId: 'me',
        currentUserName: 'Me',
      );

      // allow async init
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(provider.isInitialized, isTrue);
      expect(provider.isLoading, isFalse);
      // Should seed two lists (personal + curated)
      expect(provider.lists.length, 2);
      expect(provider.myLists.length, 1);
      expect(provider.discoverableLists.length, 1);
    });

    test('create, update metadata, and delete list', () async {
      final provider = ListsProvider(
        _makeStorage(),
        currentUserId: 'me',
        currentUserName: 'Me',
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final created = await provider.createList(
        name: 'Weekend Picks',
        description: 'Cozy',
        isPublic: false,
      );
      expect(created, isA<UserList>());
      expect(provider.myLists.any((l) => l.name == 'Weekend Picks'), isTrue);

      await provider.updateListMetadata(
        created!.id,
        name: 'Weekend+Picks',
        description: 'Updated',
        isPublic: true,
        isCollaborative: true,
        posterPath: '/x.jpg',
      );

      final updated = provider.listById(created.id)!;
      expect(updated.name, 'Weekend+Picks');
      expect(updated.description, 'Updated');
      expect(updated.isPublic, isTrue);
      expect(updated.isCollaborative, isTrue);
      expect(updated.posterPath, '/x.jpg');

      final deleted = await provider.deleteList(created.id);
      expect(deleted, isTrue);
      expect(provider.listById(created.id), isNull);
    });

    test('add/remove entries and reorder (manual sort)', () async {
      final provider = ListsProvider(
        _makeStorage(),
        currentUserId: 'me',
        currentUserName: 'Me',
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final list = await provider.createList(name: 'Test List');
      final listId = list!.id;

      final entryA = ListEntry(
        mediaId: 1,
        title: 'A',
        addedBy: 'me',
        addedAt: DateTime(2020),
        position: 0,
      );
      final entryB = ListEntry(
        mediaId: 2,
        title: 'B',
        addedBy: 'me',
        addedAt: DateTime(2021),
        position: 0,
      );

      final addedA = await provider.addEntry(listId, entryA);
      final addedB = await provider.addEntry(listId, entryB);
      expect(addedA && addedB, isTrue);

      var current = provider.listById(listId)!;
      expect(current.items.map((e) => e.mediaId), [1, 2]);
      // Reorder B before A
      await provider.reorderEntries(listId, 1, 0);
      current = provider.listById(listId)!;
      expect(current.items.map((e) => e.mediaId), [2, 1]);

      // Remove A
      final removedA = await provider.removeEntry(listId, 1);
      expect(removedA, isTrue);
      current = provider.listById(listId)!;
      expect(current.items.map((e) => e.mediaId), [2]);
    });

    test('update sort mode applies sorting and reindex', () async {
      final provider = ListsProvider(
        _makeStorage(),
        currentUserId: 'me',
        currentUserName: 'Me',
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final list = await provider.createList(name: 'Sort List');
      final id = list!.id;

      // Add entries out of alpha/release order
      await provider.addEntry(
        id,
        ListEntry(
          mediaId: 1,
          title: 'Zebra',
          addedBy: 'me',
          addedAt: DateTime(2020),
          position: 0,
        ),
      );
      await provider.addEntry(
        id,
        ListEntry(
          mediaId: 2,
          title: 'Alpha',
          addedBy: 'me',
          addedAt: DateTime(2021),
          position: 0,
        ),
      );

      await provider.updateListSortMode(id, ListSortMode.alphabetical);
      var current = provider.listById(id)!;
      expect(current.items.first.title, 'Alpha');

      await provider.updateListSortMode(id, ListSortMode.recentlyAdded);
      current = provider.listById(id)!;
      // Recently added sorts by addedAt desc
      expect(current.items.first.mediaId, 2);
    });

    test('follow/unfollow and collaborators affect edit rights', () async {
      final provider = ListsProvider(
        _makeStorage(),
        currentUserId: 'me',
        currentUserName: 'Me',
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final list = await provider.createList(name: 'Public', isPublic: true);
      final id = list!.id;

      // Another user list: simulate by changing current user temporarily
      await provider.setCurrentUser(userId: 'other', displayName: 'Other');
      await provider.toggleFollow(id);
      var current = provider.listById(id)!;
      expect(current.followerIds.contains('other'), isTrue);

      await provider.toggleFollow(id);
      current = provider.listById(id)!;
      expect(current.followerIds.contains('other'), isFalse);

      // Switch back to owner and add collaborator
      await provider.setCurrentUser(userId: 'me', displayName: 'Me');
      await provider.addCollaborator(
        id,
        userId: 'collab',
        displayName: 'Collab',
      );
      current = provider.listById(id)!;
      expect(current.isCollaborative, isTrue);
      expect(current.collaborators.any((c) => c.userId == 'collab'), isTrue);

      await provider.removeCollaborator(id, 'collab');
      current = provider.listById(id)!;
      expect(current.collaborators.any((c) => c.userId == 'collab'), isFalse);
    });

    test('comments add and delete in order', () async {
      final provider = ListsProvider(
        _makeStorage(),
        currentUserId: 'me',
        currentUserName: 'Me',
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final list = await provider.createList(name: 'Comments');
      final id = list!.id;

      await provider.addComment(id, ' First ');
      await provider.addComment(id, 'Second');
      var current = provider.listById(id)!;
      expect(current.comments.length, 2);
      expect(current.comments.first.message.trim(), 'First');

      final firstId = current.comments.first.id;
      await provider.deleteComment(id, firstId);
      current = provider.listById(id)!;
      expect(current.comments.length, 1);
      expect(current.comments.first.message.trim(), 'Second');
    });
  });
}
