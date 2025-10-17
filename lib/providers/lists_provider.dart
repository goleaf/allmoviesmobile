import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/movie.dart';
import '../data/models/custom_list.dart';
import '../data/models/user_list.dart';
import '../data/services/local_storage_service.dart';

class ListsProvider extends ChangeNotifier {
  ListsProvider(
    this._storage, {
    String? currentUserId,
    String? currentUserName,
  })  : _currentUserId = (currentUserId ?? _defaultUserId).trim().isEmpty
            ? _defaultUserId
            : currentUserId!.trim(),
        _currentUserName = (currentUserName ?? _defaultUserName).trim().isEmpty
            ? _defaultUserName
            : currentUserName!.trim() {
    unawaited(_loadLists());
  }

  static const String _defaultUserId = 'local-user';
  static const String _defaultUserName = 'You';
  static const Uuid _uuid = Uuid();

  final LocalStorageService _storage;
  final List<UserList> _lists = <UserList>[];

  String _currentUserId;
  String _currentUserName;
  bool _isLoading = true;
  bool _initialized = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isInitialized => _initialized;
  String? get errorMessage => _errorMessage;

  String get currentUserId => _currentUserId;
  String get currentUserName => _currentUserName;

  List<UserList> get lists => List.unmodifiable(_lists);

  List<UserList> get myLists =>
      _lists.where((list) => list.ownerId == _currentUserId).toList(growable: false);

  List<UserList> get discoverableLists => _lists
      .where((list) => list.ownerId != _currentUserId && list.isPublic)
      .toList(growable: false);

  List<UserList> get followingLists => discoverableLists
      .where((list) => list.followerIds.contains(_currentUserId))
      .toList(growable: false);

  UserList? listById(String id) {
    try {
      return _lists.firstWhere((list) => list.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadLists() async {
    try {
      final storedLists = _storage.getCustomLists();
      if (storedLists.isEmpty) {
        final seeded = _seedLists();
        _lists
          ..clear()
          ..addAll(seeded);
        await _storage.saveCustomLists(_lists.map((l) => l.toCustomList()).toList());
      } else {
        _lists
          ..clear()
          ..addAll(storedLists.map((c) => UserList.fromCustom(c)));
      }
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to load lists: $error';
    } finally {
      _isLoading = false;
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> setCurrentUser({
    required String userId,
    required String displayName,
  }) async {
    final normalizedId = userId.trim().isEmpty ? _defaultUserId : userId.trim();
    final normalizedName =
        displayName.trim().isEmpty ? _defaultUserName : displayName.trim();

    if (_currentUserId == normalizedId && _currentUserName == normalizedName) {
      return;
    }

    _currentUserId = normalizedId;
    _currentUserName = normalizedName;
    notifyListeners();
  }

  Future<UserList?> createList({
    required String name,
    String? description,
    bool isPublic = true,
    bool isCollaborative = false,
    String? posterPath,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    final list = UserList(
      id: _uuid.v4(),
      name: trimmedName,
      ownerId: _currentUserId,
      ownerName: _currentUserName,
      description: description?.trim().isEmpty ?? true ? null : description!.trim(),
      posterPath: posterPath?.trim().isEmpty ?? true ? null : posterPath!.trim(),
      isPublic: isPublic,
      isCollaborative: isCollaborative,
      createdAt: now,
      updatedAt: now,
      items: const <ListEntry>[],
      collaborators: const <ListCollaborator>[],
      followerIds: <String>{},
      comments: const <ListComment>[],
      sortMode: ListSortMode.manual,
    );

    _lists.add(list);
    await _persist();
    notifyListeners();
    return list;
  }

  Future<bool> deleteList(String listId) async {
    final index = _lists.indexWhere(
      (list) => list.id == listId && list.ownerId == _currentUserId,
    );
    if (index == -1) {
      return false;
    }

    _lists.removeAt(index);
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> updateListMetadata(
    String listId, {
    String? name,
    String? description,
    bool? isPublic,
    bool? isCollaborative,
    String? posterPath,
  }) async {
    await _mutateList(listId, (list) {
      if (list.ownerId != _currentUserId && !list.allowsEditsBy(_currentUserId)) {
        return list;
      }

      final updated = list.copyWith(
        name: name?.trim().isEmpty ?? true ? null : name!.trim(),
        description: description?.trim().isEmpty ?? true ? null : description!.trim(),
        isPublic: isPublic,
        isCollaborative: isCollaborative,
        posterPath: posterPath?.trim().isEmpty ?? true ? null : posterPath!.trim(),
        updatedAt: DateTime.now(),
      );
      return updated;
    });
  }

  Future<void> updateListSortMode(String listId, ListSortMode mode) async {
    await _mutateList(listId, (list) {
      if (list.sortMode == mode) {
        return list;
      }

      final sortedItems = _applySort(list.items, mode);
      return list.copyWith(
        sortMode: mode,
        items: sortedItems,
        updatedAt: DateTime.now(),
      );
    });
  }

  Future<bool> addMovieToList(String listId, Movie movie) async {
    final entry = _entryFromMovie(movie);
    return addEntry(listId, entry);
  }

  Future<bool> addEntry(String listId, ListEntry entry) async {
    var added = false;
    await _mutateList(listId, (list) {
      if (!list.allowsEditsBy(_currentUserId)) {
        return list;
      }

      final alreadyExists = list.items.any(
        (item) => item.mediaId == entry.mediaId && item.mediaType == entry.mediaType,
      );
      if (alreadyExists) {
        return list;
      }

      final now = DateTime.now();
      final normalizedEntry = entry.copyWith(
        addedBy: _currentUserId,
        addedAt: now,
        position: list.items.length,
      );

      final nextItems = [...list.items, normalizedEntry];
      final sortedItems = list.sortMode == ListSortMode.manual
          ? _reindex(nextItems)
          : _applySort(nextItems, list.sortMode);

      final poster = list.posterPath ?? entry.posterPath;

      added = true;
      return list.copyWith(
        items: sortedItems,
        posterPath: poster,
        updatedAt: now,
      );
    });

    if (added) {
      notifyListeners();
    }
    return added;
  }

  Future<bool> removeEntry(
    String listId,
    int mediaId, {
    ListEntryType mediaType = ListEntryType.movie,
  }) async {
    var removed = false;
    await _mutateList(listId, (list) {
      if (!list.allowsEditsBy(_currentUserId)) {
        return list;
      }

      final items = [...list.items];
      final initialLength = items.length;
      items.removeWhere(
        (item) => item.mediaId == mediaId && item.mediaType == mediaType,
      );

      if (items.length == initialLength) {
        return list;
      }

      removed = true;
      final reindexed = list.sortMode == ListSortMode.manual
          ? _reindex(items)
          : _applySort(items, list.sortMode);

      final poster = reindexed.isEmpty
          ? null
          : (list.posterPath ?? reindexed.first.posterPath);

      return list.copyWith(
        items: reindexed,
        posterPath: poster,
        updatedAt: DateTime.now(),
      );
    });

    if (removed) {
      notifyListeners();
    }

    return removed;
  }

  Future<void> reorderEntries(
    String listId,
    int oldIndex,
    int newIndex,
  ) async {
    await _mutateList(listId, (list) {
      if (list.sortMode != ListSortMode.manual) {
        return list;
      }

      final items = [...list.items];
      if (oldIndex < 0 || oldIndex >= items.length) {
        return list;
      }

      var targetIndex = newIndex;
      if (targetIndex > oldIndex) {
        targetIndex -= 1;
      }
      if (targetIndex < 0 || targetIndex >= items.length) {
        targetIndex = items.length - 1;
      }

      final entry = items.removeAt(oldIndex);
      items.insert(targetIndex, entry);

      final reindexed = _reindex(items);
      return list.copyWith(
        items: reindexed,
        updatedAt: DateTime.now(),
      );
    });
    notifyListeners();
  }

  Future<void> toggleFollow(String listId) async {
    await _mutateList(listId, (list) {
      if (list.ownerId == _currentUserId) {
        return list;
      }

      final followers = Set<String>.from(list.followerIds);
      if (!followers.add(_currentUserId)) {
        followers.remove(_currentUserId);
      }

      return list.copyWith(
        followerIds: followers,
        updatedAt: DateTime.now(),
      );
    });
    notifyListeners();
  }

  Future<void> addCollaborator(
    String listId, {
    required String userId,
    required String displayName,
  }) async {
    await _mutateList(listId, (list) {
      if (list.ownerId != _currentUserId) {
        return list;
      }

      final collaborators = [...list.collaborators];
      final exists = collaborators.any((collab) => collab.userId == userId);
      if (exists) {
        return list;
      }

      collaborators.add(
        ListCollaborator(
          userId: userId,
          displayName: displayName,
          addedAt: DateTime.now(),
        ),
      );

      return list.copyWith(
        collaborators: collaborators,
        isCollaborative: true,
        updatedAt: DateTime.now(),
      );
    });
    notifyListeners();
  }

  Future<void> removeCollaborator(String listId, String collaboratorId) async {
    await _mutateList(listId, (list) {
      if (list.ownerId != _currentUserId) {
        return list;
      }

      final collaborators = [...list.collaborators];
      final before = collaborators.length;
      collaborators.removeWhere((collab) => collab.userId == collaboratorId);
      final removed = collaborators.length < before;
      if (!removed) {
        return list;
      }

      return list.copyWith(
        collaborators: collaborators,
        updatedAt: DateTime.now(),
      );
    });
    notifyListeners();
  }

  Future<void> addComment(String listId, String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }

    await _mutateList(listId, (list) {
      if (!list.isPublic && list.ownerId != _currentUserId) {
        return list;
      }

      final comments = [...list.comments];
      comments.add(
        ListComment(
          id: _uuid.v4(),
          userId: _currentUserId,
          userName: _currentUserName,
          message: trimmed,
          createdAt: DateTime.now(),
        ),
      );
      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return list.copyWith(
        comments: comments,
        updatedAt: DateTime.now(),
      );
    });
    notifyListeners();
  }

  Future<void> deleteComment(String listId, String commentId) async {
    await _mutateList(listId, (list) {
      final comments = [...list.comments];
      final before = comments.length;
      comments.removeWhere((comment) => comment.id == commentId);
      final removed = comments.length < before;
      if (!removed) {
        return list;
      }

      return list.copyWith(
        comments: comments,
        updatedAt: DateTime.now(),
      );
    });
    notifyListeners();
  }

  Future<void> _mutateList(
    String listId,
    UserList Function(UserList list) transform,
  ) async {
    final index = _lists.indexWhere((list) => list.id == listId);
    if (index == -1) {
      return;
    }

    final original = _lists[index];
    final updated = transform(original);

    if (identical(updated, original)) {
      return;
    }

    _lists[index] = updated.copyWith(updatedAt: updated.updatedAt ?? DateTime.now());
    await _persist();
  }

  Future<void> _persist() {
    return _storage.saveCustomLists(_lists.map((l) => l.toCustomList()).toList());
  }

  List<UserList> _seedLists() {
    final now = DateTime.now();
    final curatedItems = <ListEntry>[
      _sampleEntry(
        id: 680,
        title: 'Pulp Fiction',
        posterPath: '/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
        release: DateTime(1994, 10, 14),
        position: 0,
      ),
      _sampleEntry(
        id: 603,
        title: 'The Matrix',
        posterPath: '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
        release: DateTime(1999, 3, 31),
        position: 1,
      ),
      _sampleEntry(
        id: 27205,
        title: 'Inception',
        posterPath: '/edv5CZvWj09upOsy2Y6IwDhK8bt.jpg',
        release: DateTime(2010, 7, 16),
        position: 2,
      ),
    ];

    final curatedList = UserList(
      id: _uuid.v4(),
      name: 'Curated Essentials',
      ownerId: 'curator-team',
      ownerName: 'Curator Team',
      description: 'Critically acclaimed staples to kickstart your movie marathons.',
      posterPath: '/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
      isPublic: true,
      isCollaborative: false,
      createdAt: now.subtract(const Duration(days: 180)),
      updatedAt: now.subtract(const Duration(days: 7)),
      items: curatedItems,
      collaborators: const <ListCollaborator>[],
      followerIds: <String>{},
      comments: const <ListComment>[],
      sortMode: ListSortMode.manual,
    );

    final personalList = UserList(
      id: _uuid.v4(),
      name: 'My First List',
      ownerId: _currentUserId,
      ownerName: _currentUserName,
      description: 'Save titles you love or plan to watch. Add collaborators anytime.',
      isPublic: false,
      isCollaborative: true,
      createdAt: now,
      updatedAt: now,
      items: const <ListEntry>[],
      collaborators: const <ListCollaborator>[],
      followerIds: <String>{},
      comments: const <ListComment>[],
      sortMode: ListSortMode.manual,
    );

    return <UserList>[personalList, curatedList];
  }

  ListEntry _entryFromMovie(Movie movie) {
    final release = movie.releaseDate != null && movie.releaseDate!.isNotEmpty
        ? DateTime.tryParse(movie.releaseDate!)
        : null;
    final type = movie.mediaType == 'tv' ? ListEntryType.tv : ListEntryType.movie;
    return ListEntry(
      mediaId: movie.id,
      mediaType: type,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterUrl,
      backdropPath: movie.backdropUrl,
      releaseDate: release,
      addedBy: _currentUserId,
      addedAt: DateTime.now(),
      position: 0,
      voteAverage: movie.voteAverage,
    );
  }

  static ListEntry _sampleEntry({
    required int id,
    required String title,
    required String posterPath,
    required DateTime release,
    required int position,
  }) {
    return ListEntry(
      mediaId: id,
      mediaType: ListEntryType.movie,
      title: title,
      overview: null,
      posterPath: posterPath.startsWith('/') ? posterPath : '/$posterPath',
      backdropPath: null,
      releaseDate: release,
      addedBy: 'curator-team',
      addedAt: release,
      position: position,
      voteAverage: null,
    );
  }

  static List<ListEntry> _reindex(List<ListEntry> items) {
    final result = <ListEntry>[];
    for (var index = 0; index < items.length; index++) {
      result.add(items[index].copyWith(position: index));
    }
    return result;
  }

  static List<ListEntry> _applySort(List<ListEntry> items, ListSortMode mode) {
    if (mode == ListSortMode.manual) {
      return _reindex(items);
    }

    final sorted = [...items];
    switch (mode) {
      case ListSortMode.recentlyAdded:
        sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
      case ListSortMode.alphabetical:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case ListSortMode.releaseDate:
        sorted.sort((a, b) {
          final aDate = a.releaseDate;
          final bDate = b.releaseDate;
          if (aDate == null && bDate == null) {
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          }
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });
        break;
      case ListSortMode.manual:
        break;
    }

    return _reindex(sorted);
  }
}
